## Why

当前项目的 AI 交互能力被严格绑定在三问流程（Q1 知识图谱 → Q2 争议分析 → Q3 测评答题）的固定阶段中，用户无法在任意时刻以自然语言与 AI 进行自由对话、提问或获取建议。随着课程学习深入，学员需要一个**通用 AI 对话入口**，能够在学习过程中随时向 AI 提问、寻求知识解释、获取学习建议或请求操作辅助，从而将 AI 从"流程执行者"升级为"智能学习伙伴"，提升学习体验的灵活性和个性化程度。

## What Changes

- **新增通用 AI 对话系统**：支持用户在任意页面通过浮动入口发起自由对话，AI 基于当前课程上下文（已激活节点、已有争议、作答记录等）提供智能响应
- **新增意图识别引擎**：解析用户自然语言输入，识别意图类型（知识问答 / 学习建议 / 操作辅助 / 课程导航），分发至对应处理逻辑
- **新增对话历史管理**：完整记录每轮对话（角色/时间戳/原文/意图分类），持久化至本地数据库，支持上下文延续
- **增强 ChatBubble 组件**：支持 Markdown 渲染、代码块展示、多轮对话消息列表，复用于通用对话场景
- **新增 AI 对话浮层/面板组件**：作为全局交互入口，可从任意页面唤起，风格统一于现有深色主题设计
- **扩展 AIService 能力**：新增 `chat()` 通用对话方法，基于现有 SSE 两阶段协议，返回纯文本流式响应
- **新增对话数据模型**：`ai_conversation` 表 + `ai_message` 表，存储会话与消息记录

### BREAKING CHANGES

无。所有变更均为增量添加，不影响现有三问流程的任何功能。

## Capabilities

### New Capabilities

- `ai-chat`: 通用 AI 自由对话系统，包含意图识别、多轮对话、上下文感知响应、对话历史持久化及 UI 浮层入口
- `ai-intent-engine`: 自然语言意图识别引擎，支持知识问答/学习建议/操作辅助/课程导航等意图分类与路由

### Modified Capabilities

- `ai-service`: 新增 `chat()` 通用对话方法，扩展现有 AIService 的能力边界（REQ 层面新增通用对话请求类型）

## Impact

**受影响的代码模块**：

| 模块 | 影响类型 | 说明 |
|------|---------|------|
| `services/AIService.ets` | 扩展 | 新增 `chat()` 方法 + `buildChatPrompt()` 方法 |
| `services/SSEStreamParser.ets` | 复用 | 通用对话仅使用 Phase1(text) 流式输出，无需 Phase2(json) |
| `components/ChatBubble.ets` | 增强 | 支持 Markdown 渲染、消息角色区分（用户/AI）、多消息列表 |
| `components/AIChatPanel.ets` | **新增** | 全局 AI 对话浮层组件 |
| `viewmodels/ThreeAskViewModel.ets` | 扩展 | 新增对话状态管理（可选，或独立 ChatViewModel） |
| `models/Models.ets` | 扩展 | 新增 AiConversation / AiMessage 接口 |
| `db/init.sql` | 扩展 | 新增 ai_conversation / ai_message 两表 |
| `db/RdbHelper.ets` | 扩展 | 新增对话 CRUD 方法 |
| `pages/*.ets` | 微调 | 各页面添加 AI 对话浮层入口挂载点 |

**受影响的 API 与依赖**：

- 无外部依赖变更（仍使用 @ohos.net.http + 现有 AI 接口）
- 数据库新增 2 表（ai_conversation / ai_message），需走 DBMigration（版本递增）
- API 调用量可能增加，需关注 GlobalRateLimiter（10次/分钟）是否需要为对话场景调整配额策略

**受影响的系统**：

- 本地 RdbStore 数据库（Schema 变更）
- ai_request_log 表（新增 `chat` 类型请求记录）
