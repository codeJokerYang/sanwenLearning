## Context

### 当前状态

本项目（三问高效学习机）是一个基于 HarmonyOS NEXT 的 ArkTS 应用，采用 MVVM 分层架构。现有的 AI 交互能力完全内嵌于三问流程的固定阶段中：

- **Q1 阶段**：`AIService.generateKnowledgeGraph()` → SSE 两阶段 → 知识图谱节点/边入库
- **Q2 阶段**：`AIService.generateControversies()` + `AIService.evaluateAnswer()` → 争议生成 + 见解评价
- **Q3 阶段**：`AIService.generateQuizQuestions()` → 布鲁姆 9 题生成与校验

AI 服务层已具备完善的基础设施：SSEStreamParser（两阶段流式解析）、AIConcurrencyLock（120s 并发锁）、GlobalRateLimiter（10次/分钟限流）、NetworkMonitor（离线拦截）、ApiKeyStore（HUKS 加密）。UI 层有 ChatBubble（流式文本气泡）和 AIRecommendBtn（推荐按钮）组件，但均服务于特定流程步骤。

### 约束条件

| 维度 | 约束 |
|------|------|
| 平台 | HarmonyOS NEXT API 12+，ArkTS 声明式 UI |
| 网络 | 仅 `@ohos.net.http`，严禁第三方库 / WebSocket |
| 数据库 | `@ohos.data.relationalStore`（RdbStore），主键 UUID v4 |
| 架构 | Pages → ViewModels → Services，严禁跨层调用 |
| 单文件 | ≤300 行 |
| 安全 | API Key HUKS 加密，解密后仅存函数作用域 |
| 性能 | @State ≤1MB，animateTo ≤500ms |

### 利益相关方

- **学员（终端用户）**：期望获得灵活的 AI 学习辅助，不限于固定流程
- **AI 服务提供方**：接口兼容 OpenAI Chat Completions 格式 + SSE
- **产品/设计**：UI 需统一于现有深色主题（深蓝紫渐变背景）

## Goals / Non-Goals

**Goals：**

1. 提供全局可用的 AI 对话入口，学员可在任意页面（首页/Q1/Q2/Q3/设置）唤起对话面板
2. 实现意图识别引擎，将用户自然语言分发至知识问答、学习建议、操作辅助、课程导航四类处理逻辑
3. 支持多轮上下文感知对话，AI 响应基于当前课程进度（激活节点/争议/作答记录）动态构建 Prompt
4. 对话消息完整持久化至本地数据库，支持历史会话查看与延续
5. 复用现有 AIService / SSEStreamParser 基础设施，通用对话仅使用 Phase1(text) 流式输出
6. UI 风格与现有深色主题一致，交互流畅（流式打字效果 + 光标闪烁）

**Non-Goals（明确排除）：**

1. 不实现语音输入/语音合成（TTS）（当前版本仅文本）
2. 不实现多模态理解（图片/文件上传解析）
3. 不修改现有三问流程的任何逻辑或 UI（纯增量添加）
4. 不实现云端同步（对话数据仅本地存储）
5. 不实现 RAG（检索增强生成）或向量数据库
6. 不改变现有 GlobalRateLimiter 配额策略（10次/分钟全局共享）

## Decisions

### 决策 1：独立 ChatViewModel vs 扩展 ThreeAskViewModel

**选择**：创建独立的 `ChatViewModel`

**理由**：
- 单一职责原则：对话状态管理（消息列表/输入态/流式输出/会话切换）与三问流程状态机（Q1→Q2→Q3 步骤控制）是完全独立的业务域
- ThreeAskViewModel 已接近行数上限（需确认），继续扩展违反单文件 ≤300 行规则
- 对话功能可能从任意页面唤起，独立 ViewModel 更便于通过 @Provide/@Consume 跨层注入

**备选方案**：扩展 ThreeAskViewModel —— 被否决，因职责耦合过重。

### 决策 2：浮层面板（Overlay/Popup） vs 独立页面（Router）

**选择**：使用半屏浮层面板（`@Builder + bindSheetCover / bindContentCover`）

**理由**：
- 浮层可在不离开当前页面的前提下打开/关闭，保持学习上下文连续性
- 用户在 Q2 写见解时可以随时打开对话询问"这个概念怎么理解"，关闭后继续作答
- HarmonyOS NEXT 的 `bindSheetCover` 支持拖拽关闭、半屏/全屏切换，体验原生
- 独立 Router 页面会导致上下文丢失（@State 重置），且需要传递大量参数

**备选方案**：Router 跳转独立对话页 —— 被否决，上下文断裂。

### 决策 3：意图识别 — 本地规则 vs 远程 AI 分类

**选择**：**混合方案** — 本地关键词/正则快速路由 + fallback 到 AI 辅助分类

**理由**：
- 纯远程 AI 分类会增加一次额外 API 调用，消耗配额且增加延迟
- 常见意图有明显关键词特征（"什么是""怎么用""帮我""跳转到"），本地规则可覆盖 ~80% 场景
- 对于模糊输入，利用同一请求的 AI 响应隐式完成意图识别（无需单独分类调用）
- 本地规则表易于维护和扩展，无需模型更新

**意图分类规则表**：

| 意图类型 | 关键词特征 | 处理方式 |
|---------|-----------|---------|
| `KNOWLEDGE_QA` | 什么是/为什么/解释一下/...是什么 | 注入课程节点上下文到 Prompt |
| `LEARNING_ADVICE` | 怎么学/建议/帮我想想/下一步 | 注入学习进度上下文到 Prompt |
| `OPERATION_ASSIST` | 帮我创建/删除/生成/开启 | 返回操作建议（不直接执行） |
| `COURSE_NAVIGATION` | 回到/跳转/进入 Q1/Q2/Q3/首页 | 返回导航指引文案 |

### 决策 4：对话存储 — 新增两张表 vs 复用 ai_request_log

**选择**：新增 `ai_conversation` + `ai_message` 两张表

**理由**：
- `ai_request_log` 是审计日志（每次 API 调用一条记录），语义不同于对话消息（用户消息无 API 调用）
- 对话需要会话概念（conversation_id 关联多条 message），支持多会话管理
- 用户消息也需要持久化（用于上下文恢复），但不会写入 ai_request_log

**Schema 设计**：

```
ai_conversation (id, course_id, title, created_at, updated_at)
ai_message (id, conversation_id, role, content, intent_type, created_at)
-- role: 'user' | 'assistant'
-- intent_type: 'KNOWLEDGE_QA' | 'LEARNING_ADVICE' | 'OPERATION_ASSIST' | 'COURSE_NAVIGATION' | null
-- 外键: conversation_id REFERENCES ai_conversation(id) ON DELETE CASCADE
```

### 决策 5：AIService.chat() 协议策略

**选择**：复用 SSE 两阶段协议，但通用对话**仅使用 Phase1(text)**，忽略 Phase2(json)

**理由**：
- 自由对话的响应是自然语言文本，无需结构化 JSON 数据
- 复用现有 `sendAIRequest()` 基础设施（锁/限流/网络检查/日志），无需重写网络层
- SSEStreamParser 的 `onTextChunk` 回调可直接驱动 ChatBubble 流式渲染
- 若 AI 端返回了 Phase2(json)，静默丢弃即可（不影响 text 内容显示）

**Prompt 构建策略** (`buildChatPrompt`)：
```
[系统角色] 你是三问高效学习机的智能学习伙伴...
[课程上下文] 当前课程名 / 所在三问阶段 / 已激活节点摘要 / 近期作答摘要
[对话历史] 最近 N 轮消息（user + assistant 交替，控制 Token 数量）
[用户输入] {userMessage}
[约束] 基于课程资料回答，禁止编造，禁止替代学员作答
```

### 决策 6：全局入口位置与样式

**选择**：右下角悬浮 FAB 按钮（Floating Action Button），各页面统一挂载

**理由**：
- 右下角 FAB 是移动端全局操作的业界标准模式（如 GitHub Copilot Chat）
- 不干扰主内容区域（三问流程的核心交互区）
- 统一位置降低用户学习成本
- 样式：圆形 44vp×44vp，渐变紫色调（匹配主题色），带未读/活跃态指示点

**各页面挂载方式**：在每个 Page 的根 `Column/Stack` 末尾放置 `<AIChatFab>` 组件，通过 `@Provide('chatViewModel')` 共享 ChatViewModel 实例。

## Risks / Trade-offs

| 风险 | 缓解措施 |
|------|---------|
| **API 配额耗尽风险**：自由对话可能频繁触发请求，消耗 10次/分钟全局配额，影响三问流程 AI 调用 | 对话场景加入独立冷却计时器（建议 3次/分钟），UI 显示剩余可发送次数；达到上限时禁用输入并提示 |
| **上下文 Prompt 过长**：多轮对话历史 + 课程上下文可能导致 Prompt 超出模型 Token 上限 | 滑动窗口保留最近 8 轮消息；课程上下文压缩为摘要（节点名列表而非完整内容）；总 Prompt 预估控制在 2000 字以内 |
| **单文件超行风险**：ChatPanel 组件可能因包含消息列表/输入框/工具栏而超过 300 行 | 拆分为 ChatPanel（容器+布局）+ ChatMessageList（消息列表）+ ChatInputBar（输入栏）三个组件 |
| **并发锁冲突**：用户在 Q2 页面等待 AI 评价时同时打开对话面板发起新请求 | 复用 AIConcurrencyLock，按 courseId 加锁；对话请求获取锁失败时提示"AI 正忙，请稍后再试" |
| **数据库迁移兼容**：新增 2 表需走 ALTER TABLE 而非 DROP TABLE | DB_VERSION 递增；迁移脚本含 `[DB_MIGRATION] Vx->Vy:` 注释；新字段允许 NULL 或有默认值 |
| **@State 内存压力**：长对话的消息列表可能超过 1MB 限制 | 使用 LazyForEach + 分页加载（每页 20 条）；仅渲染可视区域消息 |

## Migration Plan

### 部署步骤

1. **DB Migration**：执行 ALTER TABLE 新增 `ai_conversation` 和 `ai_message` 表，DB_VERSION 递增
2. **代码部署**：按 Services → Models/DB → ViewModels → Components → Pages 顺序合入
3. **配置变更**：无需外部配置变更

### 回滚策略

- 新增表不影响已有 8 表，回滚仅需移除新增代码
- 若回滚，`ai_conversation` / `ai_message` 表可保留（无害遗留数据），或在下一版本迁移脚本中清理

## Open Questions

1. **对话配额策略**：是否需要将对话请求与三问流程请求的限流配额分离？（建议分离，待产品确认具体数值）
2. **多会话管理**：是否需要支持"新建对话"/"历史会话列表"功能，还是仅维护单个持续会话？（建议首版先支持单会话，后续迭代多会话）
3. **快捷指令（Slash Commands）**：是否需要支持 `/help` `/q1` `/q2` 等斜杠指令作为意图识别的补充入口？（建议纳入首版，实现成本低且用户体验好）
