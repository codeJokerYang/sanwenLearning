## 1. 数据层：数据库 Schema 与 CRUD

- [x] 1.1 在 `models/Models.ets` 中新增 `AiConversation` 和 `AiMessage` 接口定义（id/course_id/title/created_at/updated_at + id/conversation_id/role/content/intent_type/created_at）
- [x] 1.2 编写 DB Migration 脚本，递增 DB_VERSION，使用 ALTER TABLE 创建 `ai_conversation` 和 `ai_message` 两表（含 `[DB_MIGRATION]` 注释和外键约束）
- [x] 1.3 在 `db/RdbHelper.ets` 中新增对话相关 CRUD 方法：`insertConversation()` / `insertMessage()` / `getMessagesByConversationId()` / `getLatestConversationByCourseId()` / `deleteConversationsByCourseId()`
- [ ] 1.4 在 `docs/DB_MIGRATION_LOG.md` 中记录本次迁移信息

## 2. 意图识别引擎

- [x] 2.1 新建 `services/AIIntentEngine.ets`，定义 `IntentType` 枚举（KNOWLEDGE_QA / LEARNING_ADVICE / OPERATION_ASSIST / COURSE_NAVIGATION）和 `IntentRule` 接口
- [x] 2.2 实现意图规则匹配表（关键词正则数组），覆盖四类意图的中文关键词特征
- [x] 2.3 实现 `classify(input: string): IntentType | null` 纯函数，执行关键词匹配并返回意图分类结果
- [ ] 2.4 编写单元测试验证各类意图输入的分类准确率和边界情况（空串/超长/特殊字符/无匹配）

## 3. AI 服务层扩展

- [x] 3.1 在 `services/AIService.ets` 中新增 `chat(courseId, userMessage, contextMessages, onTextChunk): Promise<void>` 公开方法
- [x] 3.2 实现 `buildChatPrompt(userMessage, courseContext, historyMessages): string` 方法，按设计文档组装 Prompt（角色→上下文→历史→输入→约束），控制总长度 ≤2000 字符
- [x] 3.3 实现 `buildCourseContext(courseId): Promise<string>` 私有方法，从 DB 查询当前课程上下文（阶段/激活节点名列表/争议标题/作答摘要）并压缩为文本
- [x] 3.4 适配 `chat()` 方法的 SSE 回调：仅绑定 `onTextChunk`，`onJsonData` 设为 null（静默丢弃 Phase2 数据）
- [x] 3.5 扩展 `logRequest()` 支持 `request_type='chat'` 类型，`response_body` 记录为空字符串
- [x] 3.6 验证 `chat()` 方法完整流程：前置校验 → 锁获取 → Prompt 构建 → SSE 连接 → 流式回调 → 锁释放 → 日志记录 → Key 清空

## 4. 对话 ViewModel

- [x] 4.1 新建 `viewmodels/ChatViewModel.ets`，管理对话状态：messages / isStreaming / inputText / currentConversationId / currentCourseId
- [x] 4.2 实现 `sendMessage(text: string)` 方法：意图识别 → 消息入队 → 调用 AIService.chat() → 流式追加 AI 消息 → 持久化至 DB
- [x] 4.3 实现 `loadHistory(courseId: string)` 方法：查询最近会话及消息，填充 messages 状态
- [x] 4.4 实现 `clearConversation()` 方法：清空 UI 消息列表，创建新 conversation 记录
- [x] 4.5 实现 `retryLastMessage()` 方法：重新发送最后一条用户消息（用于失败重试场景）
- [x] 4.6 实现输入校验逻辑：空消息拦截 / 500 字符上限检测 / 流式输出中禁止发送
- [x] 4.7 处理错误状态展示：网络断开提示 / AI 忙锁冲突提示 / 请求失败重试按钮

## 5. UI 组件开发

- [x] 5.1 新建 `components/AIChatFab.ets`：右下角悬浮圆形按钮（44vp×44vp），渐变紫色调，带活跃态指示点，点击触发 `@Link isOpen` 状态切换
- [x] 5.2 新建 `components/ChatMessageList.ets`：基于 ForEach 的消息列表组件，区分用户消息（右对齐/蓝底）和 AI 消息（左对齐/透明紫底），支持自动滚动到底部
- [x] 5.3 增强 `components/ChatBubble.ets`：保留现有功能，通用对话使用 ChatMessageList 独立渲染
- [x] 5.4 新建 `components/ChatInputBar.ets`：输入框 + 发送按钮 + 字符计数 + 斜杠指令触发器，支持多行输入
- [x] 5.5 斜杠指令选择器内嵌于 ChatInputBar 组件（输入 `/` 时弹出）
- [x] 5.6 新建 `components/AIChatPanel.ets`：对话面板容器组件，组合 MessageList + InputBar + 工具栏，半屏浮层效果
- [x] 5.7 各组件添加 accessibilityText / accessibilityDescription 无障碍属性

## 6. 页面集成

- [x] 6.1 在各主要页面（HomePage/KnowledgeGraph/LearningSpace/Assessment/AssessmentResult）中挂载 `<AIChatFab>` 组件
- [x] 6.2 各页面创建 ChatViewModel 实例并通过 @Link 传递给 AIChatPanel
- [ ] 6.3 验证从 Q2 页面打开/关闭对话面板时，Q2 页面状态（已输入见解内容、AI 评价流式输出）不受影响
- [ ] 6.4 验证首页无课程状态下打开对话面板显示引导提示文案

## 7. 课程级联删除适配

- [x] 7.1 在现有课程删除事务中追加 ai_message/ai_conversation 删除（在 material 之后、course 之前执行）
- [ ] 7.2 验证删除课程后关联对话数据完全清理

## 8. 测试与验证

- [ ] 8.1 手动端到端测试：首页唤起对话 → 发送知识问答消息 → 验证流式渲染 → 关闭面板 → Q2 页面唤起 → 验证历史恢复 → 发送学习建议 → 验证上下文感知
- [ ] 8.2 并发冲突测试：在 Q2 AI 评价进行中打开对话面板发送消息 → 验证"AI 正忙"提示正确展示
- [ ] 8.3 离线测试：断网状态下验证发送按钮禁用 + 提示横幅 + 网络恢复后自动解除
- [ ] 8.4 快捷指令测试：`/help` `/clear` `/q1` `/q2` `/q3` 各指令功能验证
- [ ] 8.5 性能验证：50 条消息场景下 LazyForEach 渲染帧率 ≥55fps；意图识别耗时 <5ms；单次 chat() 请求全流程日志记录完整性检查
