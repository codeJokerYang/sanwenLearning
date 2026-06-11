# 三问高效学习机 — AI 服务协议

> 版本：v2.2 | 日期：2026-06-05 | 所有 AI 交互必须严格遵循本协议
>
> v2.2 变更：修正体积检测常量名为 LENGTH（字符数非字节数）、重构阶段2超时为跨阶段等待超时、删除解析层网络超时描述以底层 HTTP 为准
>
> v2.1 变更：锁超时从 30s 调整为 120s 防止 SSE 活跃期间幽灵并发、简化阶段2 JSON 体积检测为单次判定、Prompt 增加 JSON 禁止分片输出约束
>
> v2.0 变更：修正 Q3 options 字段类型、绑定鸿蒙 SSE 底层 API、定义解析器回调接口、明确并发锁超时清理时机、补充 JSON 缓冲超时/体积防护伪代码

---

## 1. 两阶段 SSE 协议

### 1.1 协议概述

AI 大语言模型服务通过 HTTPS + SSE（Server-Sent Events）返回流式响应。响应分为两个阶段：

```
┌──────────────────────────────────────────────────────────┐
│ 阶段1：文本流（AI 思考过程）                               │
│ 逐字输出文字描述，前端逐字渲染                              │
│                                                          │
│ data: {"type": "text", "content": "正在分析"}\n\n        │
│ data: {"type": "text", "content": "知识结构"}\n\n        │
│ data: {"type": "text", "content": "……"}\n\n             │
├──────────────────────────────────────────────────────────┤
│ 阶段2：JSON 流（结构化数据）                               │
│ 输出完整 JSON 结构，前端解析后渲染                          │
│                                                          │
│ data: {"type": "json", "data": {"nodes": [...], ...}}\n\n│
├──────────────────────────────────────────────────────────┤
│ 结束标志                                                  │
│                                                          │
│ data: [DONE]\n\n                                         │
└──────────────────────────────────────────────────────────┘
```

**阶段流转边界**：解析器通过 SSE 事件中的 `type` 字段判定当前阶段。当首次收到 `type === "json"` 的事件时，阶段1结束、阶段2开始。业务层通过解析器暴露的 `onTextChunk` / `onJsonData` 回调感知阶段切换，无需自行判断。

### 1.2 阶段1：文本流

**SSE 事件格式**：
```
data: {"type": "text", "content": "片段文本"}\n\n
```

**解析规则**：
- `type` 字段值为 `"text"` 时，`content` 为文本片段
- 前端将 `content` 追加到 UI 文本区域，实现逐字打字效果
- 使用 `@State` 驱动 ArkTS 声明式渲染

**网络中断处理**：
- 阶段1期间网络断开：UI 保留已渲染的部分文字，追加 `"[连接中断]"` 提示
- 提供 `"继续生成"` 和 `"重试"` 两个按钮
- `"继续生成"`：保持当前连接尝试恢复 SSE 流
- `"重试"`：关闭当前连接，重新发起完整请求

### 1.3 阶段2：JSON 流

**SSE 事件格式**：
```
data: {"type": "json", "data": {完整JSON对象}}\n\n
```

**解析规则**：
- `type` 字段值为 `"json"` 时，`data` 为完整 JSON 对象
- 前端对 `data` 执行 `JSON.parse()` 解析为结构化数据
- 解析成功后持久化入库并渲染结构化内容

**各业务场景的 JSON 结构**：

#### Q1 知识图谱生成

```json
{
  "nodes": [
    {
      "id": "ai_generated_id_1",
      "label": "核心概念名称",
      "type": "core",
      "description": "概念描述"
    }
  ],
  "edges": [
    {
      "source": "ai_generated_id_1",
      "target": "ai_generated_id_2",
      "relation": "关系描述"
    }
  ]
}
```

#### Q2 争议分析

```json
{
  "controversies": [
    {
      "title": "争议标题",
      "view_a": "观点A",
      "evidence_a": "证据A",
      "view_b": "观点B",
      "evidence_b": "证据B",
      "conclusion": "结论"
    }
  ]
}
```

#### Q3 测评题目

```json
{
  "questions": [
    {
      "bloom_level": 1,
      "question_text": "题目文本",
      "options": ["A.选项1", "B.选项2", "C.选项3", "D.选项4"],
      "correct_answer": "标准答案",
      "linked_node_ids": ["node_id_1", "node_id_2"]
    }
  ]
}
```

**`options` 字段类型硬性约束**：

- `options` 必须为标准 JSON 数组（`string[]`），**严禁使用字符串套数组的格式**
- 正确：`"options": ["A.选项1", "B.选项2", "C.选项3", "D.选项4"]`
- 错误：`"options": "['A.选项1','B.选项2','C.选项3','D.选项4']"` — 大模型极易输出单双引号混乱的无效 JSON，导致二次解析崩溃
- 前端一次 `JSON.parse` 必须直接将 `options` 解析为 `string[]`，不得再做二次字符串解析
- 主观题（应用/分析/评价/创造层级）：`"options": []`（空数组）

### 1.4 结束标志

```
data: [DONE]\n\n
```

- 收到 `[DONE]` 标志后，关闭 SSE 连接，释放 AI 并发锁
- 若未收到 `[DONE]` 但连接断开，按网络中断处理

---

## 2. HarmonyOS SSE 底层 API 强制绑定

### 2.1 唯一合法的网络模块

**硬性约束**：必须使用 `@ohos.net.http` 模块接收 SSE 流式数据，严禁使用任何第三方网络库。

```typescript
import { http } from '@kit.NetworkKit'
```

**严禁使用**：
- Web 端 `EventSource` API（HarmonyOS 不支持）
- Web 端 `fetch` API（HarmonyOS 不支持）
- `axios` / `request` / `got` 等第三方 HTTP 库
- `@ohos.net.webSocket`（WebSocket 不是 SSE）

### 2.2 SSE 连接建立与数据接收

```typescript
function createSSEConnection(
  url: string,
  headers: Record<string, string>,
  body: string,
  parser: SSEStreamParser
): http.HttpRequest {
  const httpRequest = http.createHttp()

  // 订阅流式数据接收事件（核心）
  httpRequest.on('dataReceive', (data: ArrayBuffer) => {
    const text = util.TextDecoder.create('utf-8').decodeToString(new Uint8Array(data))
    parser.onChunkReceived(text)
  })

  // 订阅流结束事件
  httpRequest.on('dataEnd', () => {
    parser.onStreamEnd()
  })

  // 发起 POST 请求（SSE 模式）
  httpRequest.requestInStream(
    url,
    {
      method: http.RequestMethod.POST,
      header: {
        'Content-Type': 'application/json',
        'Accept': 'text/event-stream',
        ...headers
      },
      extraData: body,
      connectTimeout: 15000,   // 连接超时 15 秒
      readTimeout: 60000       // 读取超时 60 秒（SSE 长连接）
    }
  )

  return httpRequest
}
```

### 2.3 SSE 连接关闭

```typescript
function closeSSEConnection(httpRequest: http.HttpRequest): void {
  httpRequest.off('dataReceive')
  httpRequest.off('dataEnd')
  httpRequest.destroy()
}
```

### 2.4 数据流向

```
AI LLM 服务
    │ HTTPS POST (SSE)
    ▼
@ohos.net.http.createHttp()
    │ on('dataReceive') → ArrayBuffer → UTF-8 解码
    ▼
SSEStreamParser.onChunkReceived(text)
    │ 缓冲区 + \n\n 截取解析
    ▼
┌─────────────────────────────────────┐
│ type="text" → onTextChunk(content)  │  阶段1：逐字渲染
│ type="json"  → onJsonData(data)     │  阶段2：结构化数据
│ [DONE]       → onDone()             │  结束
│ 解析失败     → Logger.error         │  丢弃+记日志
│ 超时/溢出    → onError(msg)         │  防护触发
└─────────────────────────────────────┘
    │ on('dataEnd')
    ▼
SSEStreamParser.onStreamEnd()
```

---

## 3. SSE 解析硬性规则

### 3.1 解析器回调接口定义

`SSEStreamParser` 必须向外暴露以下回调接口，业务层通过注册回调感知阶段切换和数据到达：

```typescript
interface SSEStreamCallbacks {
  /** 阶段1：逐字渲染回调，每收到一个 text 事件触发一次 */
  onTextChunk?: (text: string) => void

  /** 阶段2：结构化数据到达回调，收到 json 事件时触发 */
  onJsonData?: (json: object) => void

  /** 错误回调：JSON 缓冲超时/溢出/解析严重错误时触发 */
  onError?: (err: string) => void

  /** 结束回调：收到 [DONE] 标志时触发 */
  onDone?: () => void
}
```

**阶段流转判定**：业务层无需自行判断阶段，解析器自动根据 `type` 字段分发：
- 收到 `type="text"` → 调用 `onTextChunk`（阶段1进行中）
- 收到 `type="json"` → 调用 `onJsonData`（阶段2开始，阶段1自动结束）
- 收到 `[DONE]` → 调用 `onDone`（全部结束）

### 3.2 缓冲区机制（粘包/半包处理）

**核心原则**：必须维护 `string buffer`，仅当遇到 `\n\n` 时才截取解析。

```typescript
// SSE 解析器完整伪代码
class SSEStreamParser {
  private buffer: string = ''
  private callbacks: SSEStreamCallbacks

  // 阶段2 防护状态
  private lastTextChunkTime: number = 0   // 最后一次收到 text 事件的时间（跨阶段超时判定）
  private static readonly CROSS_PHASE_TIMEOUT_MS: number = 15000  // 跨阶段等待超时 15 秒
  private static readonly JSON_BUFFER_MAX_LENGTH: number = 5242880 // 5M 字符数上限

  constructor(callbacks: SSEStreamCallbacks) {
    this.callbacks = callbacks
  }

  onChunkReceived(rawChunk: string): void {
    // 跨阶段等待超时检测：text 流结束后长时间未收到 json 事件
    if (this.lastTextChunkTime > 0 && Date.now() - this.lastTextChunkTime > SSEStreamParser.CROSS_PHASE_TIMEOUT_MS) {
      this.buffer = ''
      this.lastTextChunkTime = 0
      this.callbacks.onError?.('Cross-phase timeout: no JSON received after text stream')
      return
    }

    this.buffer += rawChunk

    while (this.buffer.includes('\n\n')) {
      const endIndex = this.buffer.indexOf('\n\n')
      const eventStr = this.buffer.substring(0, endIndex)
      this.buffer = this.buffer.substring(endIndex + 2) // 跳过 \n\n

      // 跳过空行和注释行
      if (eventStr.trim() === '' || eventStr.startsWith(':')) {
        continue
      }

      // 解析 data: 前缀
      this.parseEvent(eventStr)
    }
    // buffer 中剩余不完整数据等待下次 onChunkReceived 拼接
  }

  private parseEvent(eventStr: string): void {
    const lines = eventStr.split('\n')
    for (const line of lines) {
      if (line.startsWith('data: ')) {
        const data = line.substring(6) // 去除 "data: " 前缀

        // 结束标志
        if (data === '[DONE]') {
          this.callbacks.onDone?.()
          return
        }

        // JSON 解析
        try {
          const parsed = JSON.parse(data)
          this.handleParsedData(parsed)
        } catch (e) {
          // JSON 解析失败：丢弃当前事件，记录日志，不中断流程
          Logger.error('SSE JSON parse failed', data, e.message)
          // 严禁抛出异常中断整个 SSE 流
        }
      }
    }
  }

  private handleParsedData(parsed: Record<string, Object>): void {
    const type = parsed['type'] as string

    if (type === 'text') {
      // 阶段1：文本片段
      const content = parsed['content'] as string
      this.lastTextChunkTime = Date.now()
      this.callbacks.onTextChunk?.(content)

    } else if (type === 'json') {
      // 阶段2：结构化数据 —— 执行防护校验
      // 单次 JSON 体积检测（5M 字符数上限）
      const dataStr = JSON.stringify(parsed['data'])

      // 防护：单次 JSON 体积检测（5M 字符数）
      if (dataStr.length > SSEStreamParser.JSON_BUFFER_MAX_LENGTH) {
        this.buffer = ''
        this.lastTextChunkTime = 0
        this.callbacks.onError?.('JSON buffer overflow: exceeded 5M characters')
        return
      }

      // 校验通过，回调业务层
      this.callbacks.onJsonData?.(parsed['data'] as object)

      // 重置防护状态（单次 json 事件处理完毕）
      this.lastTextChunkTime = 0
    }
  }

  /** 流结束回调（由 on('dataEnd') 触发） */
  onStreamEnd(): void {
    // 如果 buffer 中还有残留数据，尝试最后一次解析
    if (this.buffer.trim().length > 0) {
      this.parseEvent(this.buffer)
      this.buffer = ''
    }
    // 若未收到 [DONE] 但流已结束，按网络中断处理
    // （由业务层在 onDone 回调中设置标志位判断）
  }
}
```

### 3.3 JSON 解析失败处理

**硬性规则**：JSON 解析失败时，**必须丢弃并记日志，不能中断流程**。

| 场景 | 处理方式 |
|------|---------|
| 单个事件 JSON 格式错误 | 丢弃该事件，Logger.error 记录，继续处理后续事件 |
| 阶段2 JSON 结构不符合预期 | 记录 status=failed 日志，提示用户重试 |
| 跨阶段等待超时（15秒） | 清空 buffer，触发 `onError('Cross-phase timeout: no JSON received after text stream')`，关闭连接，提示重试 |
| 阶段2 JSON 超过 5M 字符数 | 清空 buffer，触发 `onError('JSON buffer overflow: exceeded 5M characters')`，关闭连接，防止内存溢出（单次 JSON 字符数判定） |

### 3.4 分片乱序防护

若前一个 JSON 事件未处理完毕又收到新的 JSON 事件，**丢弃旧数据，以新数据为准**。

### 3.5 SSE 连接生命周期

```
createHttp() → on('dataReceive') → onChunkReceived() * N → onDone() → close()
                  on('dataEnd')  → onStreamEnd()                    ↑
                                                                    或 onError() → close()
```

- 网络连接超时由底层 `@ohos.net.http` 的 `readTimeout` (60秒) 统一管控，解析层不处理网络超时
- 锁超时：AI 并发锁持有超过 120 秒自动释放
- 冷启动：应用 onCreate() 时清空所有残留锁状态

---

## 4. 防幻觉规则

### 4.1 Prompt 上下文注入

**核心原则**：所有 AI 请求的 Prompt 中，必须注入 `parsed_content` 作为上下文，约束 AI 严格基于资料回答。

**Prompt 模板**：

```
你是一位严谨的学术导师。请严格基于以下参考资料回答，不得编造资料中不存在的信息。

## 参考资料
{parsed_content_1}

{parsed_content_2}

...

## 任务
{具体任务描述}

## 输出格式要求
{JSON 结构要求}

⚠️ 严禁将 JSON 结构拆分为多个事件分片输出，必须在一个 data 事件中输出完整的 JSON 对象。
```

### 4.2 知识节点 ID 约束

**生成测评题目时的硬性规则**：

Prompt 中必须注入 Q1 知识节点列表，并强制约束：

```
## 可引用的知识节点
以下是当前课程的所有知识节点，你只能在 linked_node_ids 中引用以下节点 ID：
- {node_id_1}: {label_1}
- {node_id_2}: {label_2}
- ...

严禁编造不存在于上述列表中的节点 ID，输出必须严格遵循 JSON 格式。
```

### 4.3 禁止替代用户作答

Q2 见解评价和 Q3 答题评价的 Prompt 中，必须包含以下约束指令：

```
禁止替代用户作答。你必须基于用户的真实输入进行评价，不得为用户生成答案。
如果用户输入过于简短或空洞，请指出不足而非替其补充。
```

### 4.4 防幻觉校验清单

| 校验项 | 校验方式 | 失败处理 |
|--------|---------|---------|
| 知识图谱节点 ID 合法性 | 遍历 nodes，检查 id 非空且格式正确 | 丢弃非法节点 |
| 知识图谱边引用合法性 | 遍历 edges，检查 source/target 存在于 nodes 中 | 丢弃非法边 |
| 测评题 linked_node_ids 合法性 | 遍历题目，检查所有 node_id 存在于 knowledge_node 表 | 丢弃非法引用 |
| 布鲁姆层级分布 | 校验 9 题 bloom_level 分布 | 拒绝入库，重试（上限 2 次） |
| 争议逻辑链完整性 | 检查 view_a/evidence_a/view_b/evidence_b/conclusion 非空 | 丢弃不完整争议 |
| Q3 options 类型 | 校验 options 为 `string[]`（JSON 数组），非字符串 | 拒绝入库，重试 |

---

## 5. AI 并发控制

### 5.1 并发锁机制

**【最高规范声明】**：本协议为 AI 并发控制参数的唯一权威来源。锁超时时间以本文件定义的 120000ms (120秒) 为准，其他任何文档（如性能约束）若与此冲突，一律以本协议为准。

```typescript
class AIConcurrencyLock {
  // Map<courseId, {locked: boolean, acquireTime: number}>
  private lockMap: Map<string, { locked: boolean; acquireTime: number }> = new Map()

  acquireLock(courseId: string): boolean {
    // 【强制】每次获取锁前，先清理全局超时锁
    this.forceReleaseTimeout()

    const entry = this.lockMap.get(courseId)
    if (entry && entry.locked) {
      // forceReleaseTimeout 已清理超时锁，若仍被占用说明锁有效
      return false
    }
    this.lockMap.set(courseId, { locked: true, acquireTime: Date.now() })
    return true
  }

  releaseLock(courseId: string): void {
    this.lockMap.delete(courseId)
  }

  /**
   * 清理全局超时锁。
   * 【强制调用时机】必须在每次 acquireLock() 开头调用，
   * 而非依赖外部定时器。这确保超时锁不会永远占着 Map 内存。
   */
  forceReleaseTimeout(): void {
    const now = Date.now()
    for (const [courseId, entry] of this.lockMap) {
      if (entry.locked && now - entry.acquireTime > 120000) {
        // **锁超时必须远大于 SSE readTimeout(60s)，防止连接仍在活跃时锁被释放导致并发重入**
        Logger.warn('AI lock timeout, force release', courseId)
        this.lockMap.delete(courseId)
      }
    }
  }

  clearAllOnColdStart(): void {
    this.lockMap.clear()
  }
}
```

### 5.2 锁使用流程

```
1. acquireLock(courseId)
   ├── 内部自动调用 forceReleaseTimeout() 清理全局超时锁
   ├── 返回 true → 继续
   └── 返回 false → 禁用按钮+显示加载态
2. 发起 AI 请求
3. 请求完成/失败/超时 → releaseLock(courseId)
4. logRequest(aiRequestLog)
```

---

## 6. AI 请求日志

每次 AI 请求完成后，**必须**记录以下信息至 `ai_request_log` 表：

| 字段 | 说明 | 示例 |
|------|------|------|
| request_type | 请求类型 | `knowledge_graph` / `controversy` / `quiz` / `evaluation` |
| request_prompt | 完整 Prompt 内容 | 含上下文注入的完整文本 |
| response_body | 响应内容 | 阶段2 JSON 原文 |
| status | 执行状态 | `success` / `failed` / `timeout` |
| duration_ms | 耗时毫秒 | 从 acquireLock 到 releaseLock 的时间差 |

**严禁遗漏日志记录**，即使请求失败也必须记录。
