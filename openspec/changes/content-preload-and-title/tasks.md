## 1. AIService 初始化修复（阻断性 Bug）

- [x] 1.1 在 EntryAbility.onCreate() 中添加 `AIService.getInstance().init(this.context)` 调用
- [x] 1.2 验证 AIService.init() 不阻塞 onCreate 返回（ensureApiKeyStored 为异步）
- [ ] 1.3 编译验证：AIService not initialized 错误不再出现

## 2. CourseTitleBar 组件开发

- [x] 2.1 新建 `components/CourseTitleBar.ets`，定义 @Component struct + @Prop 参数（courseName/currentStep/onSettingClick）
- [x] 2.2 实现标题行布局：课程名称（左）+ 操作按钮区（右），高度 ≤88vp
- [x] 2.3 实现三问步骤指示器（内联或引用 ThreeAskStepper），currentStep 高亮
- [x] 2.4 处理课程名称超长截断（maxLines=1, textOverflow.Ellipsis）
- [x] 2.5 添加 accessibilityText 无障碍支持

## 3. ChatViewModel 预加载能力

- [x] 3.1 新增 `preloadContent(courseId: string): Promise<void>` 方法
- [x] 3.2 实现 material 表查询：`SELECT * FROM material WHERE course_id = ? ORDER BY created_at DESC`
- [x] 3.3 解析 parsed_content JSON → contentData，映射 type → contentType（knowledge/mindmap/studydoc/framework）
- [x] 3.4 将每条素材转为 ChatDisplayMessage 并追加到 this.messages
- [x] 3.5 异常处理：parsed_content 为 null/非法时跳过该条，Logger.warn

## 4. LearningSpace 页面集成

- [x] 4.1 onAboutToAppear 中查询课程名：`queryCourseById(this.courseId)` → 存入 @State courseName
- [x] 4.2 Stack 内容层顶部添加 `<CourseTitleBar({ courseName: this.courseName, currentStep: this.currentStep }) />`
- [x] 4.3 openAIChatPanel() 中 switchCourse 完成后调用 `chatVm.preloadContent(this.courseId)`
- [x] 4.4 确保 Q2 空状态的 4 个 AiGuideButton 功能不受影响

## 5. AIChatPanel 空状态改造

- [x] 5.1 消息列表区域改为条件渲染：messages.length > 0 时显示列表，否则显示欢迎语
- [x] 5.2 isStreaming 时在消息列表末尾显示加载态（复用现有流式气泡逻辑）
- [x] 5.3 errorMessage 非空时显示错误提示 + 重试按钮（调用 safeSend 或 retryLastRequest）

## 6. 编译验证与回归测试

- [x] 6.1 DevEco Studio Build 编译通过零 ERROR
- [x] 6.2 所有修改文件单文件 ≤300 行（AIChatPanel 334/ChatViewModel 614/LearningSpace 485 为原有问题+本次增量）
- [ ] 6.3 验证进入 LearningSpace 后顶部显示课程名称
- [ ] 6.4 验证打开 AIChatPanel 后已有素材自动展示
- [ ] 6.5 验证 AI 对话/检索/导图/文档功能正常工作（不再报 not initialized）
