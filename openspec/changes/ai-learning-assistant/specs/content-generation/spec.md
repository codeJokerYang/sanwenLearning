## ADDED Requirements

### Requirement: 思维导图生成与渲染

系统 MUST 支持用户指定主题后，AI 自动生成思维导图并以可视化方式展示。

#### Scenario: 通过快捷按钮触发导图生成
- **WHEN** 用户点击 AIActionBar 的"🗺️导图"按钮并输入主题（如"相对论"）
- **THEN** 系统 MUST 调用 `AIService.generateMindMap('相对论')`
- **THEN** AI MUST 返回符合 MindMapData schema 的 JSON（阶段 2 SSE）
- **THEN** 返回的数据 MUST 包含：
  - `nodes`: 至少 8-20 个节点（含 id/label/x/y/nodeType）
  - `edges`: 节点间的关联关系
  - `title`: 导图标题

#### Scenario: 思维导图 Canvas 渲染
- **WHEN** MindMapData 数据就绪
- **THEN** 系统 MUST 使用 Canvas 渲染思维导图（复用 KnowledgeGraph 的绘制逻辑）
- **THEN** 节点 MUST 根据 nodeType 区分样式：
  - `CORE` — 主色实心圆 + 白描边
  - `CONCEPT` — 浅色圆 + 深色文字
  - `DETAIL` — 小圆点 + 连线
- **THEN** 连线 MUST 用曲线或直线连接源和目标节点
- **THEN** 导图 MUST 支持手势缩放和平移（如 KnowledgeGraph 已支持）

#### Scenario: 思维导图持久化
- **WHEN** 思维导图生成完成
- **THEN** 完整的 MindMapData JSON MUST 存储到 material 表（type='mindmap'）
- **THEN** 用户可在"我的课程→素材"中查看历史导图
- **THEN** 导图 MUST 支持从 material 表重新加载渲染

---

### Requirement: 学习文档生成与渲染

系统 MUST 支持用户指定主题后，AI 自动生成结构化学习文档。

#### Scenario: 文档生成触发与流程
- **WHEN** 用户点击 AIActionBar 的"📄文档"按钮并输入主题
- **THEN** 系统 MUST 先显示"正在生成文档..."的进度提示
- **THEN** 调用 `AIService.generateStudyDoc(topic)` 获取 StudyDocData
- **THEN** 生成完成后 MUST 使用 StudyDocViewer 组件渲染

#### Scenario: 学习文档 Markdown 渲染
- **WHEN** StudyDocData 就绪
- **THEN** StudyDocViewer MUST 渲染以下 Markdown 子集：
  - 标题：H1（文档大标题）、H2（章节标题）、H3（小节标题）
  - 列表：有序列表和无序列表
  - 强调：粗体（**text**）、斜体（*text*）
  - 代码块：语言标识 + 等宽字体 + 浅色背景
  - 分割线：章节间的视觉分隔
- **THEN** 文档 MUST 支持垂直滚动阅读
- **THEN** 文档顶部 MUST 显示目录导航（点击跳转到对应章节）

#### Scenario: 文档关键术语表
- **WHEN** 学习文档包含 keyTerms 字段
- **THEN** 文档底部 MUST 附带关键术语表（术语 - 定义对照表）
- **THEN** 术语表中的术语如果在正文出现
- **THEN** 可考虑高亮显示（Phase 2 可选）

#### Scenario: 文档持久化与导出
- **WHEN** 学习文档生成完成
- **THEN** 完整的 StudyDocData JSON MUST 存储到 material 表（type='studydoc'）
- **THEN** 文档 MUST 支持在素材管理页中查看
- **THEN** 文档 MUST 支持"分享"或"复制文本"操作（Phase 1 仅复制）

---

### Requirement: 知识框架生成与渲染

系统 MUST 支持用户指定学科后，AI 自动生成完整的知识体系框架。

#### Scenario: 框架生成触发
- **WHEN** 用户点击 AIActionBar 的"🏗️框架"按钮并输入学科名称（如"高等数学"）
- **THEN** 系统 MUST 调用 `AIService.generateLearningFramework('高等数学')`
- **THEN** AI MUST 返回符合 FrameworkData schema 的 JSON
- **THEN** 返回数据 MUST 包含层级树形结构（至少 3 层深度：章→节→点）

#### Scenario: 可折叠树形渲染
- **WHEN** FrameworkData 就绪
- **THEN** FrameworkTree 组件 MUST 以可折叠树形列表渲染知识体系
- **THEN** 每个节点 MUST 显示：
  - 节点标签
  - 层级缩进（level × 16vp）
  - 展开/折叠箭头（仅当有 children 时）
  - 可选描述文字
  - 可选预估学习时长
- **THEN** 点击节点 MUST 切换展开/折叠状态
- **THEN** 根节点默认展开，其余节点默认折叠

#### Scenario: 推荐学习路径高亮
- **WHEN** FrameworkData 包含 learningPath 数组
- **THEN** 框架树中属于推荐路径的节点 MUST 高亮显示（主色文字或左侧竖线）
- **THEN** 路径节点之间 MUST 有虚线箭头连接表示顺序

#### Scenario: 框架持久化
- **WHEN** 知识框架生成完成
- **THEN** 完整的 FrameworkData JSON MUST 存储到 material 表（type='framework'）
- **THEN** 框架 MUST 支持从素材管理页重新加载

---

### Requirement: 内容生成统一交互规范

所有内容生成功能 MUST 遵循统一的交互流程和错误处理规范。

#### Scenario: 生成前确认
- **WHEN** 用户触发任一内容生成操作（导图/文档/框架）
- **THEN** 如果该主题已有近期（<1h）生成的同类型内容
- **THEN** 系统 SHOULD 提示"你最近生成过 xxx，是否查看旧版本还是重新生成？"
- **否则**
- **THEN** 系统 MUST 直接开始生成

#### Scenario: 生成中状态
- **WHEN** 内容正在生成中
- **THEN** 对话区域 MUST 显示骨架屏占位符（匹配目标内容类型的布局轮廓）
- **THEN** 输入框 MUST 显示"生成中..."禁用状态
- **THEN** 取消按钮 MUST 可用（允许用户中断生成）

#### Scenario: 生成结果预览
- **WHEN** 内容生成完成
- **THEN** 结果 MUST 以 ContentPreviewCard 形式插入到对话消息列表中
- **THEN** 卡片 MUST 包含：内容类型图标 + 标题 + 预览内容（折叠态显示摘要）
- **THEN** 点击卡片 MUST 展开/收起完整内容
- **THEN** 卡片底部 MUST 显示"重新生成"/"保存到素材"/"基于此继续对话"操作按钮
