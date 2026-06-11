## Context

当前 AIChatPanel 作为 Stack 浮层覆盖在 LearningSpace 上方。交互链路：

```
用户点击按钮 → onClick 回调 → ChatViewModel 方法 → AIService 调用
```

断裂点发生在多个环节。ArkUI 的 `.enabled(false)` 会完全禁止触摸事件（包括视觉上的变化取决于平台实现），而 ArkUI 的 TextInput 即使 `enabled(false)` 在某些场景下仍可接收键盘输入。

**技术约束**：HarmonyOS NEXT API 12+, ArkTS 声明式 UI, 单文件 ≤300 行。

## Goals / Non-Goals

**Goals:**
1. 所有按钮在可用状态下必须响应点击事件
2. 按钮禁用时必须有明确的视觉区分
3. 操作失败时必须有用户可见的错误/提示信息
4. LearningSpace 空状态的 4 个引导按钮必须可点击并触发实际功能
5. onClick 异常不能影响其他 UI 元素的交互能力

**Non-Goals:**
1. 不重构 AIChatPanel 的整体布局结构
2. 不修改 AIService 或 SSEStreamParser
3. 不新增页面或路由

## Decisions

### D1: 分离 TextInput 和 Button 的 enabled 条件

**决策**：TextInput 保持始终 enabled（仅在网络不可用时才禁用），Button 的 enabled 仅受 `isStreaming` 控制。网络检查延迟到点击时的运行时判断。

**理由**：
- 用户应随时可以输入文字（即使离线也可以先写好）
- 发送按钮仅在 AI 正在流式输出时禁用（防止并发请求）
- 网络错误在点击时以 toast/错误提示形式反馈，而非预先禁用

### D2: LearningSpace 打开面板时自动绑定课程

**决策**：在 LearningSpace 中，AIChatFab 的 onClick 和 AiGuideButton 的 onClick 都需要先调用 `viewModel.switchCourse(this.courseId)` 再打开面板。

**理由**：
- 当前 chatOpen 状态切换和 course 绑定是两个独立操作，容易遗漏
- 将绑定逻辑收敛到统一的 openPanel() 方法中

### D3: Disabled 视觉态统一规范

**决策**：所有 disabled 按钮统一应用：
- `opacity(0.4)`
- `backgroundColor` 降低为原色的 50% 透明度
- 无 cursor/highlight 效果

### D4: onClick 异常保护模式

**决策**：所有公开的 onClick 回调（用户可直接触发的）统一包裹 try-catch，catch 中调用 Logger.error 并可选地显示 fallback 提示。

## Risks / Trade-offs

| 风险 | 缓解措施 |
|------|---------|
| 移除 Button 的 isNetworkAvailable enabled 检查后，离线时点击会触发网络请求再失败 | 可接受：AIService 内部已有网络检查 + 友好错误提示 |
| switchCourse 在每次打开面板时调用可能有性能开销 | switchCourse 内部有 courseId 相同判断会提前返回 |
