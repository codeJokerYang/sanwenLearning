## Context

当前 AI 系统架构已具备完整的服务层（AIService + SSEStreamParser + AIConcurrencyLock）、对话层（ChatViewModel + AIIntentEngine + AIChatPanel）和网络基础设施（NetworkMonitor + GlobalRateLimiter + ApiKeyStore）。本次升级在此基础上扩展，不重构已有代码。

**现有架构关键约束**：
- HTTP：仅 `@ohos.net.http`，无第三方库
- AI API：OpenAI Chat Completions 兼容格式 + SSE，DeepSeek 模型
- 数据库：RdbStore，8 表结构（含 `material` 表可复用）
- 单文件 ≤300 行
- AI 限流：10 次/分钟

**新增能力目标**：
1. 对话从"通用问答"升级为"学习助手"——注入课程上下文、支持追问引导
2. 新增知识检索通道——通过 HTTP API 获取外部知识并注入 Prompt
3. 新增内容生成能力——AI 输出结构化 JSON → UI 渲染为思维导图/文档/框架

## Goals / Non-Goals

**Goals:**
1. 用户可在 AI 对话中输入任意学习主题，获得上下文感知的智能回答
2. 用户可通过斜杠指令或快捷按钮触发知识检索、思维导图生成、文档生成、框架生成
3. 检索到的外部知识与 AI 内置知识融合，提升回答的准确性和时效性
4. 生成的思维导图可复用 KnowledgeGraph Canvas 渲染
5. 生成的学习文档支持 Markdown 渲染（标题/列表/代码块）
6. 生成的知识框架以可折叠树形结构展示
7. 所有生成内容可持久化到 `material` 表，支持离线查看

**Non-Goals:**
1. 不实现真正的 HTML 爬虫/DOM 解析（HarmonyOS 无此能力）
2. 不引入 WebView 或第三方网络库
3. 不修改现有的 generateKnowledgeGraph / generateControversies / generateQuizQuestions 方法
4. 不实现用户账号系统或云端同步
5. 不修改 BottomTabBar 或导航结构

## Decisions

### D1: 对话增强方案 — 扩展现有 chat() 而非新建方法

**决策**：在 AIService 中新增 `chatWithContext()` 方法，复用现有 `sendAIRequest()` + SSEStreamParser 基础设施。区别在于 system prompt 注入课程上下文。

```typescript
// AIService.ets 新增
async chatWithContext(courseId: string, userMessage: string,
  onTextChunk: (text: string) => void,
  onJsonData?: (data: object) => void): Promise<void> {
  // 1. 从 DB 加载课程上下文（知识点列表/当前阶段）
  const context = await this.buildCourseContext(courseId);
  // 2. 构造增强 system prompt
  const systemPrompt = this.buildLearningAssistantPrompt(context);
  // 3. 复用 sendAIRequest() 发起 SSE 请求
  await this.sendAIRequest(systemPrompt, userMessage, onTextChunk, onJsonData);
}
```

**理由**：
- 复用已有的并发锁、限流、SSE 解析、日志记录等基础设施
- 最小化改动量，降低回归风险
- 与现有 `chat()` 方法保持一致的错误处理和超时策略

### D2: 知识检索方案 — AI 驱动的伪检索（LLM-as-Retriever）

**决策**：不实现传统爬虫，而是采用 **"AI 增强检索"** 方案：

```
用户输入主题 → AIService.generateKnowledgeSummary(topic)
                  ↓ (调用 DeepSeek API)
          返回结构化知识摘要 JSON:
          {
            keyConcepts: [{term, definition}],
            corePoints: [string],
            resources: [{title, url, summary}],
            relatedTerms: [string]
          }
                  ↓
          注入后续对话的 system prompt 作为上下文
```

**理由**：
- HarmonyOS NEXT 仅支持 `@ohos.net.http`，无法做 HTML DOM 解析
- DeepSeek 等 LLM 本身具备大量训练知识，可直接提取结构化信息
- 如需真实互联网数据，可通过 AI API 的 tool_use / function calling 能力（如果模型支持）或在服务端配置代理
- 此方案零依赖新增外部 API，完全在现有架构内实现

**替代方案对比**：
| 方案 | 优点 | 缺点 |
|------|------|------|
| **AI 增强检索（选中）** | 零新依赖，架构一致 | 知识受限于模型训练截止日期 |
| 调用搜索 API（Bing/Google） | 数据实时 | 需要 API Key + 解析 HTML/JSON + 反爬 |
| 服务端代理爬虫 | 功能最强 | 需要自建后端服务 |

### D3: 内容生成 — 统一 JSON Schema 协议

**决策**：所有内容生成方法使用统一的请求/响应协议：

**请求**：统一的 system prompt 模板 + 用户 topic 参数

**响应**：SSE 两阶段协议（与现有 AI_SERVICE_PROTOCOL 完全兼容）
- 阶段1 `type="text"`：友好提示语（如"正在为你生成量子力学思维导图..."）
- 阶段2 `type="json"`：结构化内容数据

**JSON Schema 定义**：

```typescript
// 思维导图响应
interface MindMapData {
  type: 'mindmap';
  title: string;
  nodes: Array<{ id: string; label: string; x: number; y: number; nodeType: string }>;
  edges: Array<{ source: string; target: string; weight: number }>;
}

// 学习文档响应
interface StudyDocData {
  type: 'studydoc';
  title: string;
  subject: string;
  sections: Array<{
    heading: string;        // H1/H2/H3
    content: string;         // Markdown text
    bulletPoints?: string[]; // 可选列表
    codeBlock?: { language: string; code: string }; // 可选代码
  }>;
  summary: string;
  keyTerms: Array<{ term: string; definition: string }>;
}

// 知识框架响应
interface FrameworkData {
  type: 'framework';
  subject: string;
  tree: Array<{
    id: string;
    label: string;
    level: number;           // 0=根, 1=章, 2=节, 3=点
    children?: string[];     // 子节点 ID 列表
    description?: string;
    estimatedHours?: number;
  }>;
  learningPath: string[];   // 推荐学习顺序（ID 序列）
}
```

**理由**：
- 复用现有 SSEStreamParser 的两阶段协议，无需修改解析器
- 结构化 JSON 可直接被 UI 组件消费（Canvas / Tree / Markdown 渲染器）
- `type` 字段区分内容类型，ChatViewModel 可根据类型路由到不同渲染器

### D4: UI 交互设计 — AIChatPanel 内嵌功能模式切换

**决策**：在 AIChatPanel 中增加 **功能模式栏（AIActionBar）**，用户可在以下模式间切换：

```
┌─────────────────────────────┐
│ 🤖 AI 学习助手        ✕ 清空 │
├─────────────────────────────┤
│ [💬对话] [🔍检索] [🗺️导图] [📄文档] [🏗️框架] │ ← AIActionBar
├─────────────────────────────┤
│                             │
│  (对话/内容区域)             │
│  根据模式显示不同内容:       │
│  - 对话模式: 消息气泡列表    │
│  - 导图模式: Canvas 渲染     │
│  - 文档模式: Markdown 渲染   │
│  - 框架模式: 树形列表渲染    │
│                             │
├─────────────────────────────┤
│ [输入框............] [发送]  │
└─────────────────────────────┘
```

**模式切换逻辑**：
- 点击胶囊按钮 → 切换模式 → 输入框 placeholder 变更 → 发送时调用不同 AIService 方法
- 对话模式为默认模式
- 内容生成模式下，发送按钮变为 "生成" 文字
- 生成过程中显示骨架屏/进度指示器

### D5: 内容持久化 — 复用 material 表

**决策**：所有 AI 生成的内容存储到现有 `material` 表：

```sql
-- 已有 schema（复用）
material(
  id TEXT PRIMARY KEY,        -- UUID v4
  course_id TEXT,              -- 关联课程（可为空 = 全局素材）
  material_type TEXT,          -- 'mindmap' | 'studydoc' | 'framework' | 'knowledge'
  title TEXT,                  -- 内容标题
  content TEXT,                -- JSON 字符串（MindMapData/StudyDocData/FrameworkData）
  source TEXT,                 -- 'ai_generated' | 'web_retrieved' | 'user_uploaded'
  status INTEGER,              -- 0=pending, 1=ready, 2=failed
  created_at INTEGER,
  updated_at INTEGER
)
```

**理由**：
- 无需 ALTER TABLE，schema 已满足需求
- 与用户上传的 PDF/Material 共享同一张表，统一管理
- `content` 字段存 JSON，不同 type 用不同 schema 解析

### D6: LearningSpace 空状态改造

**决策**：将 Q2 "暂无争议点"空状态从静态提示改为 **AI 引导入口卡片**：

```
┌──────────────────────────────┐
│                              │
│         ❓                   │
│                              │
│   暂无争议点，让 AI 来帮你    │
│                              │
│   ┌──────────┐ ┌──────────┐  │
│   │ 🔍 检索   │ │ 🗺️ 导图   │  │
│   │ 相关知识   │ │ 生成导图   │  │
│   └──────────┘ └──────────┘  │
│   ┌──────────┐ ┌──────────┐  │
│   │ 📄 文档   │ │ 💬 问 AI  │  │
│   │ 生成文档   │ │ 自由提问   │  │
│   └──────────┘ └──────────┘  │
│                              │
└──────────────────────────────┘
```

每个按钮点击后跳转/打开 AIChatPanel 并预设对应模式的指令。

## Risks / Trade-offs

| 风险 | 缓解措施 |
|------|---------|
| 内容生成 Token 消耗大（可能 2000+ tokens/次） | 生成前提示用户确认；支持分步生成（先框架再细节）；限流器控制频率 |
| AI 返回的 JSON 可能不符合预期 schema | SSEStreamParser 的 onJsonData 回调中做 schema validation；失败时降级为纯文本展示 |
| 思维导图 Canvas 渲染节点过多导致性能问题 | 限制最大节点数（≤30）；超出时截断或分页；遵循 PERFORMANCE_CONVENTIONS |
| StudyDocViewer Markdown 渲染复杂度高 | 仅支持子集（H1-H3 / 列表 / 代码块 / 粗体斜体）；不支持表格/图片 |
| KnowledgeRetriever 结果可能过时或不准确 | 显示"由 AI 生成"标注；允许用户反馈修正；缓存 TTL 24h |
| 文件行数超 300 行限制 | AIChatPanel 重构为拆分模式栏+内容区；AIService 新方法控制在 50 行内 |

## Open Questions

1. **是否需要支持导出功能？**（如导出思维导图为图片、导出文档为 PDF）→ 建议 Phase 2 实现，Phase 1 仅支持应用内预览
2. **知识检索是否需要配置额外的搜索 API Key？** → 如果采用 D2 方案（AI 增强），则不需要；如需真实搜索 API 则需要
3. **生成内容的编辑能力？** → Phase 1 只读；Phase 2 可考虑简单编辑
