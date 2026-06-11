# AI Service - AI 服务层扩展规格说明（增量变更）

本规格说明定义了对现有 AI 服务层的增量变更需求。原始规格位于 `openspec/specs/ai-service/spec.md`（REQ-AI-001 至 REQ-AI-012），本文件仅描述新增和变更部分。

## ADDED Requirements

### Requirement: 通用对话请求方法

AIService SHALL 新增 `chat()` 公开方法，用于处理通用自由对话请求。该方法 SHALL 复用现有 `sendAIRequest()` 基础设施（并发锁/限流/网络检查/HUKS 解密/SSE 连接/日志记录），但仅消费 SSE Phase1(text) 流式数据，忽略 Phase2(json) 结构化数据。

#### Scenario: 发起通用对话请求
- **WHEN** ViewModel 调用 `aiService.chat(courseId, userMessage, contextMessages, onTextChunk)`
- **THEN** AIService 执行前置校验链（初始化检查 → 网络检查 → 限流检查 → 并发锁获取）
- **AND** 通过 `buildChatPrompt()` 构建包含课程上下文和对话历史的 Prompt
- **AND** 通过 `sendAIRequest()` 建立 SSE 连接
- **AND** SSEStreamParser 的 `onTextChunk` 回调逐段将文本传给调用方
- **AND** 收到 `[DONE]` 信号后释放锁、记录日志、清空 API Key 明文

#### Scenario: 通用对话请求的日志记录
- **WHEN** 通用对话请求完成（无论成功或失败）
- **THEN** 系统向 `ai_request_log` 表写入一条记录
- **AND** `request_type = 'chat'`
- **AND** `request_prompt` 包含脱敏后的完整 Prompt 文本
- **AND** `response_body` 为空字符串（通用对话无 Phase2 JSON）
- **AND** `duration_ms` 记录从 acquireLock 到 releaseLock 的耗时

#### Scenario: 通用对话请求并发冲突
- **WHEN** 同一 courseId 下已有三问流程的 AI 请求持有并发锁
- **THEN** `chat()` 方法的 `acquireLock()` 调用返回 false
- **AND** 方法 reject 并返回错误码 `AI_FAILED`
- **AND** ViewModel 层展示"AI 正在处理其他任务，请稍后再试"提示

---

### Requirement: 对话 Prompt 构建

AIService SHALL 新增 `buildChatPrompt()` 方法，用于构建通用对话的系统 Prompt。该方法 SHALL 按以下结构组装 Prompt：系统角色定义 → 课程上下文 → 对话历史（最近 8 轮）→ 用户输入 → 系统约束。总 Prompt 长度 SHALL 控制在 2000 字符以内。

#### Scenario: 含完整上下文的 Prompt 构建
- **WHEN** 用户在 Q2 阶段发起第 3 轮对话
- **THEN** `buildChatPrompt()` 生成的 Prompt 包含：
  - 系统角色："你是三问高效学习机的智能学习伙伴..."
  - 课程上下文：课程名 + "当前处于 Q2 为什么阶段" + 已激活节点名称列表（最多 15 个）+ 争议标题列表（最多 5 个）
  - 对话历史：最近 8 轮消息（4 组 user-assistant 交替）
  - 当前用户输入原文
  - 系统约束：基于参考资料回答 / 禁止编造 / 禁止替代学员作答 / JSON 禁止分片输出

#### Scenario: 对话历史过长时的截断策略
- **WHEN** 当前会话已积累超过 16 条消息（8 轮）
- **THEN** 仅取最近 8 轮（16 条）消息作为对话历史注入 Prompt
- **AND** 最早的消息被截断丢弃

#### Scenario: 无课程上下文时的 Prompt 降级
- **WHEN** `chat()` 方法传入的 `courseId` 为空或课程不存在
- **THEN** Prompt 不包含课程上下文段落
- **AND** 系统角色调整为通用学习伙伴角色
- **AND** 引导用户选择课程以获得更好体验

---

### Requirement: SSE StreamParser 通用对话适配

SSEStreamParser SHALL 支持纯文本模式（仅 Phase1），在此模式下收到 Phase2(json) 数据时静默丢弃，不触发 `onJsonData` 回调，不报错。

#### Scenario: 通用对话收到意外 Phase2 数据
- **WHEN** 通用对话的 SSE 流在 Phase1(text) 结束后返回了 Phase2(json) 数据
- **THEN** SSEStreamParser 解析 json 数据但不调用 `onJsonData` 回调（回调为 undefined 或 null）
- **AND** 不记录 Error 日志
- **AND** 继续正常等待 `[DONE]` 信号

## MODIFIED Requirements

> 以下为对现有 REQ 的行为扩展，原有 REQ 的核心行为不变。

### Requirement: AI 请求全量日志记录（扩展 REQ-AI-012）

原 REQ-AI-012 要求每次 AI 请求必须记录 `ai_request_log`。现扩展 `request_type` 字段的合法值域，新增 `'chat'` 类型。

- **WHEN** 通用对话请求完成
- **THEN** `ai_request_log.request_type = 'chat'`（原有值：`knowledge_graph` / `controversy` / `quiz` / `evaluation` 保持不变）
- **AND** 其余字段（request_prompt / response_body / status / duration_ms / create_time）的记录规范不变
