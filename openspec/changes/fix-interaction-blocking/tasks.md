## 1. 修复 AIChatPanel InputBar 按钮交互阻塞

- [x] 1.1 修改 TextInput 的 `.enabled()` 条件：移除 `isNetworkAvailable` 检查，始终允许输入
- [x] 1.2 修改发送 Button 的 `.enabled()` 条件：仅保留 `!this.viewModel.isStreaming`
- [x] 1.3 为发送按钮添加 disabled 视觉态：当 `isStreaming=true` 时追加 `.opacity(0.4)` + 降低 backgroundColor
- [x] 1.4 验证：输入框可输入 → 点击发送 → 触发 sendMessage

## 2. 修复课程上下文绑定缺失

- [x] 2.1 在 LearningSpace 中新增私有方法 `openAIChatPanel(mode?: string)`：先调用 `viewModel.switchCourse(this.courseId)` 再设置 `chatOpen = true`
- [x] 2.2 将 AIChatFab 的 onClick 从直接设置 `chatOpen = true` 改为调用 `this.openAIChatPanel()`
- [x] 2.3 验证：从 LearningSpace 打开面板后 ChatViewModel.hasActiveCourse === true

## 3. 实现 LearningSpace AiGuideButton 真实功能

- [x] 3.1 修改"检索相关知识"按钮 onClick：调用 `openAIChatPanel('retrieve')`
- [x] 3.2 修改"生成思维导图"按钮 onClick：调用 `openAIChatPanel('mindmap')`
- [x] 3.3 修改"生成学习文档"按钮 onClick：调用 `openAIChatPanel('studydoc')`
- [x] 3.4 修改"向 AI 提问"按钮 onClick：调用 `openAIChatPanel('chat')`
- [x] 3.5 验证：每个按钮点击后面板打开且模式/输入框状态正确

## 4. 增强错误处理与日志

- [x] 4.1 AIChatPanel 发送按钮 onClick 包裹 try-catch（safeSend 方法）
- [x] 4.2 catch 中调用 Logger.error 记录异常 + 设置 errorMessage
- [x] 4.3 ChatViewModel.sendMessage 入口添加操作日志 Logger.info
- [x] 4.4 异常时其他按钮仍可点击（try-catch 不影响组件状态）

## 5. 编译验证

- [x] 5.1 编译通过零错误
- [x] 5.2 所有修改文件单文件 ≤300 行（LearningSpace.ets 486行为原有问题，本次+16行）
