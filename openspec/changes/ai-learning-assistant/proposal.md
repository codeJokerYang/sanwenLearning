## Why

当前应用的 AI 功能（AIService / ChatViewModel / AIChatPanel）已具备基础对话能力，但存在以下局限：

1. **对话能力单一**：现有 `chat()` 方法仅支持通用问答，缺乏学习场景专属的上下文感知、多轮追问引导和结构化输出能力。用户无法通过自然语言触发知识检索或内容生成。
2. **无外部知识获取渠道**：AI 回答完全依赖模型内置知识（DeepSeek），无法根据用户指定的学习主题主动检索互联网上的最新资料、文献和学习资源。
3. **无内容生成能力**：用户无法要求 AI 生成思维导图、学习文档、知识框架等结构化学习材料——这些是"三问高效学习机"从"问答工具"升级为"学习系统"的关键差异化功能。

截图显示当前 LearningSpace Q2 页面处于"暂无争议点"的静态等待状态，说明 AI 的被动响应模式限制了学习流程的主动性。

## What Changes

### 一、增强 AI 对话系统（基于现有架构扩展）

- **扩展 AIService**：新增 3 个专用方法：
  - `chatWithContext(courseId, message)` — 注入课程上下文（已学知识点/当前阶段）的多轮对话
  - `generateMindMap(topic)` — 基于主题生成思维导图 JSON 结构
  - `generateStudyDoc(topic)` — 基于主题生成结构化学习文档
  - `generateLearningFramework(subject)` — 基于学科生成完整知识体系框架
- **扩展 AIIntentEngine**：新增意图类型 `KNOWLEDGE_RETRIEVAL` / `MIND_MAP_GEN` / `STUDY_DOC_GEN` / `FRAMEWORK_GEN`，支持斜杠指令 `/mindmap` `/doc` `/framework` `/search`
- **扩展 ChatViewModel**：支持结构化内容消息类型（非纯文本），新增内容预览和导出能力

### 二、网络知识检索模块（KnowledgeRetriever）

- **新建 `KnowledgeRetriever.ets` 服务**：使用 `@ohos.net.http` 调用搜索 API 或知识 API，获取主题相关的：
  - 关键概念定义和解释
  - 核心知识点列表
  - 推荐学习资源链接（标题+摘要）
  - 相关学术术语
- **检索结果注入 AI Prompt**：将检索到的结构化信息作为上下文注入到 AI 对话中，提升回答准确性和时效性
- **缓存机制**：相同主题的检索结果本地缓存（RdbStore 或内存 Map），避免重复请求

### 三、学习内容生成与展示

- **思维导图生成**：AI 返回 `{ nodes: [{id, label, x, y, type}], edges: [{source, target}] }` JSON → 复用 KnowledgeGraph Canvas 渲染
- **学习文档生成**：AI 返回 Markdown 格式文本 → 新建 `StudyDocViewer.ets` 组件渲染（支持标题/章节/代码块/表格）
- **知识框架生成**：AI 返回层级树形 JSON → 新建 `FrameworkTree.ets` 组件渲染（可折叠树形列表）
- **内容持久化**：生成的材料存储到 `material` 表（已有 schema），支持离线查看和历史回顾

### 四、UI 交互升级

- **AIChatPanel 增强**：
  - 输入框上方增加快捷功能栏（4 个胶囊按钮：💬对话 / 🔍检索 / 🗺️导图 / 📄文档）
  - 支持切换对话模式（普通模式 ↔ 内容生成模式）
  - 生成中的内容显示进度动画（骨架屏/打字机效果）
  - 已生成内容支持预览卡片（可展开/收起/导出）
- **LearningSpace 集成**：Q2 争议分析页面的"暂无争议点"状态改为引导用户使用 AI 检索/生成功能的入口

## Capabilities

### New Capabilities
- `ai-enhanced-dialogue`: 增强型 AI 对话 — 上下文感知 + 多轮追问 + 结构化输出
- `knowledge-retrieval`: 网络知识检索 — HTTP API 调用 + 结果缓存 + Prompt 注入
- `content-generation`: 学习内容生成 — 思维导图/学习文档/知识框架的 AI 生成与展示

### Modified Capabilities
- （无现有 spec 需修改）

## Impact

- **新增文件**（约 8-10 个）：
  - `services/KnowledgeRetriever.ets` — 知识检索服务
  - `viewmodels/ContentGenViewModel.ets` — 内容生成 ViewModel
  - `components/StudyDocViewer.ets` — 文档查看器组件
  - `components/FrameworkTree.ets` — 知识框架树组件
  - `components/ContentPreviewCard.ets` — 生成内容预览卡片
  - `components/AIActionBar.ets` — AI 功能快捷操作栏
  - `pages/ContentViewer.ets` — 内容详情页（可选）
- **修改文件**（约 5 个）：
  - `services/AIService.ets` — 新增 4 个方法
  - `services/AIIntentEngine.ets` — 新增 4 种意图
  - `viewmodels/ChatViewModel.ets` — 支持结构化消息 + 新模式
  - `components/AIChatPanel.ets` — 集成功能栏 + 内容预览
  - `pages/LearningSpace.ets` — 空状态改为 AI 引导入口
- **数据库**：复用现有 `material` 表 schema，无需 ALTER TABLE
- **风险点**：
  - 网络检索依赖外部 API 可用性 → 需要降级策略（检索失败时仅用 AI 内置知识）
  - 内容生成 Token 消耗大 → 需要提示用户并支持分步生成
  - 单文件 ≤300 行限制 → 大型组件需拆分为子组件
