## MODIFIED Requirements

### Requirement: LearningSpace 集成 CourseTitleBar 和预加载

LearningSpace 页面的 build() 方法 SHALL 在 Stack 最顶层（内容层之上）渲染 CourseTitleBar 组件。页面生命周期 SHALL 在 onAboutToAppear 或 onPageShow 中触发 ChatViewModel 的课程绑定和内容预加载。

#### Scenario: LearningSpace 显示课程标题
- **WHEN** LearningSpace 从路由获取 courseId 参数
- **THEN** onAboutToAppear 中调用 `queryCourseById(courseId)` 获取课程名
- **AND** CourseTitleBar 以 courseName 和 currentStep 渲染在页面顶部

#### Scenario: LearningSpace 打开面板时触发预加载
- **WHEN** 用户点击 AI 按钮打开 AIChatPanel
- **THEN** openAIChatPanel() 先 await switchCourse()
- **AND** switchCourse 完成后调用 chatVm.preloadContent(courseId)
- **AND** 预加载的素材立即显示在消息列表中

### Requirement: Q2 空状态保留 AI 引导功能

LearningSpace 的 Q2 空状态（无争议点时）SHALL 保留现有的 4 个 AiGuideButton（检索知识/生成导图/生成文档/向AI提问），点击后正确触发 openAIChatPanel(mode)。

#### Scenario: 空状态按钮点击后显示对应模式
- **WHEN** 用户在空状态点击"生成思维导图"
- **THEN** 打开 AIChatPanel 并切换到 mindmap 模式
- **AND** 自动以课程名为主题发送请求
