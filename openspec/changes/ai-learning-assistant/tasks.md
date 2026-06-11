## 1. AIService 扩展（核心 AI 能力）

- [x] 1.1 在 `AIService.ets` 中新增 `chatWithContext(courseId, message, onTextChunk, onJsonData)` 方法，注入课程上下文到 system prompt
- [x] 1.2 新增 `buildCourseContext(courseId)` 私有方法：从 DB 查询知识点列表/当前阶段/已有内容，组装上下文字符串（已有实现）
- [x] 1.3 新增 `buildLearningAssistantPrompt(context)` 私有方法：构造学习助手专属 system prompt 模板
- [x] 1.4 新增 `generateKnowledgeSummary(topic, onTextChunk, onJsonData)` 方法：生成结构化知识摘要（统一为 generateContent('knowledge_summary', ...)）
- [x] 1.5 新增 `generateMindMap(topic, onTextChunk, onJsonData)` 方法：生成思维导图 JSON（统一为 generateContent('mindmap', ...)）
- [x] 1.6 新增 `generateStudyDoc(topic, onTextChunk, onJsonData)` 方法：生成学习文档 JSON（统一为 generateContent('study_doc', ...)）
- [x] 1.7 新增 `generateLearningFramework(subject, onTextChunk, onJsonData)` 方法：生成知识框架 JSON（统一为 generateContent('framework', ...)）
- [x] 1.8 所有新方法的 system prompt MUST 包含防幻觉指令（禁止编造、标注不确定信息）
- [x] 1.9 所有新方法 MUST 调用 `logRequest()` 记录 ai_request_log

## 2. AIIntentEngine 扩展（意图识别）

- [x] 2.1 在 `AIIntentEngine.ets` 中新增意图枚举值：`KNOWLEDGE_RETRIEVAL` / `MIND_MAP_GEN` / `STUDY_DOC_GEN` / `FRAMEWORK_GEN`
- [x] 2.2 新增关键词匹配规则：
  - `/search` 或包含"检索""搜索""查找" → KNOWLEDGE_RETRIEVAL
  - `/mindmap` 或包含"导图""思维导图""图谱" → MIND_MAP_GEN
  - `/doc` 或包含"文档""学习资料""笔记" → STUDY_DOC_GEN
  - `/framework` 或包含"框架""体系""大纲""知识树" → FRAMEWORK_GEN
- [x] 2.3 更新 `/help` 指令响应，展示所有可用指令（含新增的 4 个）

## 3. KnowledgeRetriever 服务（新建）

- [x] 3.1 创建 `services/KnowledgeRetriever.ets`：单例服务，管理知识摘要的缓存和获取
- [x] 3.2 实现 `getSummary(topic): Promise<KnowledgeSummary>` 方法：先查缓存（TTL 24h），缓存未命中则调用 AIService.generateContent()
- [x] 3.3 实现内存缓存 Map（key=topic hash, value=KnowledgeSummary + timestamp）
- [x] 3.4 实现 `clearCache()` 方法
- [x] 3.5 定义 `KnowledgeSummary` 接口：{ keyConcepts, corePoints, resources, relatedTerms }

## 4. ChatViewModel 扩展（对话状态管理）

- [x] 4.1 新增 `currentMode: 'chat' | 'retrieve' | 'mindmap' | 'studydoc' | 'framework'` 状态
- [x] 4.2 新增 `switchMode(mode)` 方法：切换功能模式并更新 UI
- [x] 4.3 扩展 `sendMessage()` 方法：根据 currentMode 调用不同的 AIService 方法
- [x] 4.4 新增结构化消息处理逻辑：当 onJsonData 回调触发时，解析 type 字段并路由到对应渲染器
- [x] 4.5 新增 `retryContentGeneration()` 方法：重试失败的内容生成请求
- [x] 4.6 扩展 `ChatDisplayMessage` 类型支持结构化数据（新增 contentType / contentData 字段）

## 5. UI 组件开发

### 5.1 AIActionBar 功能栏
- [x] 5.1.1 创建 `components/AIActionBar.ets`：横向胶囊按钮组（💬对话 / 🔍检索 / 🗺️导图 / 📄文档 / 🏗️框架）
- [x] 5.1.2 每个按钮 MUST 为 44vp 最小点击区域（无障碍要求）
- [x] 5.1.3 当前选中模式按钮高亮显示（主色背景+白字），其余为描边样式
- [x] 5.1.4 点击按钮回调通知 ChatViewModel 切换模式

### 5.2 ContentPreviewCard 内容预览卡片
- [x] 5.2.1 创建 `components/ContentPreviewCard.ets`：统一的内容预览卡片容器
- [x] 5.2.2 支持 4 种内容类型的折叠/展开切换
- [x] 5.2.3 折叠态显示：类型图标 + 标题 + 2 行摘要 + "展开查看"
- [x] 5.2.4 展开态显示：完整渲染内容 + 操作按钮行
- [x] 5.2.5 操作按钮："重新生成" / "保存素材" / "基于此继续"

### 5.3 StudyDocViewer 文档查看器
- [x] 5.3.1 创建 `components/StudyDocViewer.ets`：Markdown 子集渲染器
- [x] 5.3.2 支持 H1/H2/H3 标题渲染（不同字号和间距）
- [x] 5.3.3 支持有序列表和无序列表
- [x] 5.3.4 支持粗体/斜体文本
- [x] 5.3.5 支持代码块（等宽字体 + 浅灰背景 + 语言标签）
- [x] 5.3.6 顶部固定目录导航（章节标题列表）

### 5.4 FrameworkTree 知识框架树
- [x] 5.4.1 创建 `components/FrameworkTree.ets`：可折叠树形列表组件
- [x] 5.4.2 根据 level 计算缩进（level × 16vp 左边距）
- [x] 5.4.3 节点展开/折叠动画（@State 触发自动 animateTo）
- [x] 5.4.4 推荐路径节点高亮（主色左侧竖线 + 紫色文字着色）
- [x] 5.4.5 单文件 ≤300 行（实际约 190 行）

### 5.5 AIChatPanel 集成改造
- [x] 5.5.1 在输入框上方集成 AIActionBar 组件
- [x] 5.5.2 根据当前模式动态更改 placeholder 文本（5 种模式各有专属提示）
- [x] 5.5.3 内容生成模式下发送按钮文案改为"生成"
- [x] 5.5.4 结构化消息使用 ContentPreviewCard 渲染（非普通 ChatBubble）
- [ ] 5.5.5 生成中在内容区显示骨架屏占位符（Phase 2 增强）
- [x] 5.5.6 改造后单文件约 270 行（≤300 行限制内）

## 6. LearningSpace 空状态改造

- [x] 6.1 将 Q2 "暂无争议点"静态空状态改为 AI 引导入口卡片
- [x] 6.2 显示 4 个快捷入口按钮（2×2 网格）：🔍检索相关知识 / 🗼️生成思维导图 / 📄生成学习文档 / 💬向 AI 提问
- [x] 6.3 新增 AiGuideButton @Builder 方法（图标+标签卡片样式）

## 7. 数据持久化与素材管理

- [x] 7.1 实现内容生成完成后的 material 表写入逻辑（复用现有 RdbHelper）
- [x] 7.2 content 字段存储 JSON.stringify(MindMapData/StudyDocData/FrameworkData/KnowledgeSummary)
- [x] 7.3 source 字段标记为 'ai_generated'（通过 file_name 前缀 `[AI]` 标识 + type 字段区分）
- [ ] 7.4 验证从 material 表读取并重新渲染各类型内容（需素材管理页面支持，Phase 2）

## 8. 编译验证与测试

- [ ] 8.1 编译通过，零错误（需在 DevEco Studio 中 Build）
- [ ] 8.2 所有新增/修改文件单文件 ≤300 行
- [ ] 8.3 验证 AI 对话基本流程（发送→接收→展示）正常
- [ ] 8.4 验证 4 种内容生成模式的切换和执行
- [ ] 8.5 验证断网时提示正确且不发起请求
- [ ] 8.6 验证限流机制生效（>10 次/分钟拦截）
- [ ] 8.7 验证 ai_request_log 正确记录每次请求
