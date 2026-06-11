## ADDED Requirements

### Requirement: 知识摘要生成（AI 增强检索）

系统 MUST 能够根据用户指定的学习主题，通过 AI 生成结构化的知识摘要，模拟"网络检索"效果。

#### Scenario: 通过斜杠指令触发知识检索
- **WHEN** 用户在 AI 对话中输入 `/search 量子力学` 或点击"检索"快捷按钮后输入主题
- **THEN** 系统 MUST 调用 `AIService.generateKnowledgeSummary('量子力学')`
- **THEN** AI MUST 返回包含以下字段的结构化 JSON：
  - `keyConcepts`: 至少 3-5 个核心概念（术语+定义）
  - `corePoints`: 至少 5-8 个关键知识点
  - `resources`: 至少 3-5 条相关资源（标题+URL摘要）
  - `relatedTerms`: 至少 5 个相关学术术语
- **THEN** 结果 MUST 以 `KnowledgeContent` 类型消息展示在对话中

#### Scenario: 检索结果注入对话上下文
- **WHEN** 知识摘要生成完成后
- **THEN** 摘要内容 MUST 自动注入到后续对话的 system prompt 中
- **THEN** 用户后续的提问 MUST 能够引用检索到的概念和知识点
- **THEN** AI 回答 MUST 基于检索结果给出更准确的解释

#### Scenario: 检索结果本地缓存
- **WHEN** 同一主题的知识摘要被多次请求
- **THEN** 系统 MUST 在 24 小时内返回缓存的結果，避免重复消耗 Token
- **THEN** 缓存 MUST 存储在内存 Map 中（key=主题关键词 hash），不占用数据库空间
- **WHEN** 缓存过期后再次请求
- **THEN** 系统 MUST 重新调用 AI API 生成最新摘要

#### Scenario: 检索降级策略
- **WHEN** 网络断开或 AI 服务不可用时触发知识检索
- **THEN** 系统 MUST 显示离线提示（按项目规则：断网时严禁发起 AI 请求）
- **THEN** 如果存在同主题的历史缓存结果
- **THEN** 系统 MUST 展示缓存结果并标注"离线缓存"

---

### Requirement: 检索结果展示

生成的知识摘要 MUST 以清晰的结构化界面呈现。

#### Scenario: 知识摘要卡片渲染
- **WHEN** 知识摘要消息需要在对话中展示
- **THEN** 系统 MUST 使用 ContentPreviewCard 组件渲染，包含：
  - 主题标题（大字加粗）
  - 核心概念列表（术语-定义对，可折叠）
  - 关键知识点（编号列表）
  - 相关资源（可点击的链接卡片）
  - 相关术语标签云（横向排列的小标签）
- **THEN** 卡片 MUST 支持"复制全文"操作
- **THEN** 卡片 MUST 支持"基于此生成导图/文档"快捷操作按钮
