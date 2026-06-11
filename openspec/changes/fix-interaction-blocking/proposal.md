## Why

用户报告严重交互异常：AIChatPanel 中发送按钮点击无响应，界面其他按键也无法点击。通过代码分析定位到以下根因：

### 根因 1：InputBar 按钮被 `enabled()` 条件联合禁用
[AIChatPanel.ets:264](file:///e:\huaweiApp\AppSth\sanwenLearning\entry\src\main\ets\components\AIChatPanel.ets#L264) 和 [L276](file:///e:\huaweiApp\AppSth\sanwenLearning\entry\src\main\ets\components\AIChatPanel.ets#L276)：
```typescript
TextInput(...).enabled(!this.viewModel.isStreaming && this.viewModel.isNetworkAvailable)
Button(...).enabled(!this.viewModel.isStreaming && this.viewModel.isNetworkAvailable)
```
当 `isNetworkAvailable = false` 时，**输入框和发送按钮同时被禁用**。但用户仍能在输入框中输入文字（TextInput 的 enabled 在 ArkUI 中可能不阻止键盘输入），导致"能打字但不能发送"的困惑体验。

### 根因 2：无课程时 sendMessage 静默返回
[ChatViewModel.ets:141-148](file:///e:\huaweiApp\AppSth\sanwenLearning\entry\src\main\ets\viewmodels\ChatViewModel.ets#L141-L148)：
```typescript
if (!this.hasActiveCourse) {
  // 仅显示一条系统消息，然后 return —— 无任何反馈表明操作未完成
  return
}
```
用户在 LearningSpace 页面打开 AIChatPanel 时，`hasActiveCourse` 可能未被正确设置（chatOpen 了但 course 未绑定），导致所有消息被静默丢弃。

### 根因 3：LearningSpace 空状态按钮为空函数
[LearningSpace.ets:~311-323](file:///e:\huaweiApp\AppSth\sanwenLearning\entry\src\main\ets\pages\LearningSpace.ets)：
Q2 空状态的 4 个 AI 引导入口按钮全部使用 `onClick(() => {})` 空回调，点击无任何响应。

### 根因 4：缺少交互状态反馈和错误边界
- 按钮禁用时无视觉提示（disabled 态与正常态外观几乎一致）
- onClick 异常无 try-catch 保护，可能导致整个组件状态卡死
- 无操作日志记录，难以复现问题

## What Changes

### A. 修复交互阻塞（Critical）

1. **分离 TextInput 和 Button 的 enabled 条件**：TextInput 始终允许输入；Button 仅在 `isStreaming` 时禁用（网络检查移到点击时运行时判断）
2. **修复 hasActiveCourse 初始化时机**：在 LearningSpace 打开 AIChatPanel 时主动调用 `viewModel.switchCourse(courseId)`
3. **实现 LearningSpace AiGuideButton 的真实功能**：每个按钮点击后打开 AIChatPanel 并切换到对应模式+预设提示文本
4. **添加按钮 disabled 视觉态**：降低 opacity + 灰色背景，让用户明确感知不可用状态

### B. 增强错误处理（Robustness）

5. **所有 onClick 回调包裹 try-catch**：防止异常导致组件状态异常
6. **添加操作日志**：关键交互点输出 Logger.info，便于排查
7. **网络不可用时显示明确提示**：InputBar 区域增加离线原因说明

### C. 功能完善（Enhancement）

8. **AIActionBar 模式切换增加触觉反馈**（Phase 2）
9. **检索结果选择下拉列表**（Phase 2 — 用户需求中的"图二功能升级"）
10. **三问学习法 AI 问答流程**（Phase 2 — 出题→作答→判题→下一题）

## Impact

- **主要修改文件**：
  - `components/AIChatPanel.ets` — 修复 enabled 逻辑 + disabled 视觉态 + 错误处理
  - `viewmodels/ChatViewModel.ets` — 改进无课程时的反馈逻辑
  - `pages/LearningSpace.ets` — 实现 AiGuideButton 真实 onClick 功能
- **风险极低**：均为增量修改，不改变现有数据流或架构
