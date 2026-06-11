## ADDED Requirements

### Requirement: 按钮点击响应恢复

所有界面按钮 MUST 在可用状态下正确响应用户的点击操作。

#### Scenario: AIChatPanel 发送按钮可点击
- **WHEN** 用户在 AIChatPanel 输入框中已输入文字且 AI 未在流式输出中
- **THEN** 发送按钮 MUST 处于可点击状态（enabled=true）
- **WHEN** 用户点击发送按钮
- **THEN** 系统 MUST 调用 ChatViewModel.sendMessage() 并触发后续对话/AI 请求流程

#### Scenario: AIChatPanel AIActionBar 按钮可点击
- **WHEN** 用户点击 AIActionBar 中的任意模式按钮（对话/检索/导图/文档/框架）
- **THEN** 按钮 MUST 触发 mode 切换，当前选中按钮高亮状态更新
- **THEN** 输入框 placeholder 文本 MUST 更新为对应模式的专属提示

#### Scenario: LearningSpace 空状态引导按钮可点击
- **WHEN** 用户点击 Q2 空状态区域的任意一个引导入口按钮（检索知识/生成导图/生成文档/向 AI 提问）
- **THEN** 按钮 MUST 触发对应功能：
  - "检索相关知识" → 打开 AIChatPanel + 切换到 retrieve 模式
  - "生成思维导图" → 打开 AIChatPanel + 切换到 mindmap 模式
  - "生成学习文档" → 打开 AIChatPanel + 切换到 studydoc 模式
  - "向 AI 提问" → 打开 AIChatPanel + 切换到 chat 模式

---

### Requirement: 按钮禁用态视觉反馈

被禁用的按钮 MUST 有明确的视觉区分，避免用户误以为可交互。

#### Scenario: 流式输出中按钮禁用
- **WHEN** AI 正在进行流式文本输出（isStreaming = true）
- **THEN** 发送按钮 MUST 显示为禁用态：opacity(0.4) + 降低背景色亮度
- **THEN** 点击禁用按钮 MUST 无任何响应（不触发 onClick）

#### Scenario: 网络不可用时输入区域提示
- **WHEN** 设备处于断网状态
- **THEN** 输入栏上方 MUST 显示"当前无网络连接"提示文字
- **THEN** TextInput 允许用户继续输入（不禁用），但发送按钮点击后显示网络错误提示

---

### Requirement: 课程上下文自动绑定

打开 AIChatPanel 时 MUST 自动将当前课程绑定到 ChatViewModel。

#### Scenario: 从 LearningSpace 打开面板
- **WHEN** 用户通过 AIChatFab 或 AiGuideButton 打开 AIChatPanel
- **THEN** 系统 MUST 先调用 viewModel.switchCourse(courseId) 绑定课程
- **THEN** 再设置 chatOpen = true 显示面板
- **THEN** ChatViewModel.hasActiveCourse MUST 为 true

---

### Requirement: 交互异常防护

所有用户触发的 onClick 回调 MUST 有异常捕获机制，防止单个组件异常扩散。

#### Scenario: onClick 回调异常不阻塞其他交互
- **WHEN** 某个按钮的 onClick 回调内部抛出 JavaScript 异常
- **THEN** 异常 MUST 被 catch 捕获并记录到 Logger
- **THEN** 同一面板内的其他按钮 MUST 仍然可以正常点击
- **THEN** 用户 MUST 看到"操作失败，请重试"的友好提示（非技术堆栈）

#### Scenario: 关键操作日志记录
- **WHEN** 用户触发以下操作：发送消息、切换模式、清空对话、关闭面板
- **THEN** 系统 MUST 输出 Logger.info 级别日志（含操作类型 + 时间戳）
