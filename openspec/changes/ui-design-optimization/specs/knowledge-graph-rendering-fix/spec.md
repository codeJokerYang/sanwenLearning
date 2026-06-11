## ADDED Requirements

### Requirement: HomePage 崩溃修复
系统 SHALL 修复 HomePage 第 181 行 `Cannot read property length of undefined` 崩溃，确保 `@State` 数组初始化为 `[]` 并增加空值防护。

#### Scenario: 课程列表未加载时不崩溃
- **WHEN** HomePage 的 aboutToAppear 尚未完成数据加载
- **THEN** 页面正常渲染 StatusLayout Loading 状态，不因 `undefined.length` 崩溃

#### Scenario: 课程列表为空时正常显示
- **WHEN** 数据库中无课程记录
- **THEN** 页面显示 StatusLayout Empty 状态，不崩溃

### Requirement: 知识图谱坐标映射统一
系统 SHALL 统一碎片节点叠加层与 Canvas 绘制的坐标映射逻辑，消除视觉错位。映射函数定义：`mapToCanvas(pos: Position, canvasWidth: number, canvasHeight: number, layoutSpace: number = 600): Position`，计算 `scale = Math.min(w/layoutSpace, h/layoutSpace)`，`offsetX/Y = (canvasSize - layoutSpace * scale) / 2`。

#### Scenario: 碎片节点与 Canvas 节点位置一致
- **WHEN** 知识图谱渲染完成
- **THEN** 碎片态 @Component 节点与 Canvas 绘制的连线端点位置完全重合

#### Scenario: 坐标映射函数单一来源
- **WHEN** 开发者搜索坐标映射逻辑
- **THEN** 仅存在一个 `mapToCanvas()` 工具函数（common/utils.ets），碎片叠加层和 Canvas 绘制均调用此函数

#### Scenario: 不同 Canvas 尺寸下映射正确
- **WHEN** Canvas 尺寸变化（如横竖屏切换）
- **THEN** mapToCanvas 自动重新计算 scale 和 offset，节点位置正确映射

### Requirement: MindBadgeAnim 粒子效果修复
系统 SHALL 修复 MindBadgeAnim 中粒子 x/y 坐标始终为 0 的缺陷，使粒子从勋章中心向外扩散。

#### Scenario: 粒子正确扩散
- **WHEN** 心智塑成勋章动画触发
- **THEN** 粒子从勋章中心向四周扩散（x = cx + dist * Math.cos(angle), y = cy + dist * Math.sin(angle)），而非全部堆叠在左上角

### Requirement: MindBadgeAnim 动画时长与曲线合规
系统 SHALL 将 MindBadgeAnim 的 animateTo 时长缩短至不超过 500ms，采用分阶段动画策略，并使用指定缓动曲线。

#### Scenario: 勋章出现动画时长与曲线
- **WHEN** 心智塑成勋章动画触发
- **THEN** 勋章缩放出现的 animateTo 时长 = 500ms，曲线 = `Curves.springMotion(0.6, 0.8)`

#### Scenario: 粒子扩散动画时长与曲线
- **WHEN** 勋章出现动画完成后触发粒子扩散（onFinish 回调链式触发）
- **THEN** 粒子扩散的 animateTo 时长 = 500ms，曲线 = `Curve.EaseOut`

#### Scenario: 淡出消失动画
- **WHEN** 粒子扩散完成后触发淡出
- **THEN** 淡出 animateTo 时长 = 300ms，曲线 = `Curve.EaseIn`

### Requirement: ChatBubble 定时器泄漏修复
系统 SHALL 在 ChatBubble 的 aboutToDisappear 中清除 setTimeout 定时器，防止内存泄漏。

#### Scenario: 组件销毁时定时器清除
- **WHEN** ChatBubble 组件被销毁
- **THEN** 递归 setTimeout 定时器被清除（记录 timerId 并 clearTimeout），不再触发状态更新

### Requirement: DebateCard 接入 ManualInputBox
系统 SHALL 将 DebateCard 中的 TextArea 替换为 ManualInputBox 组件，实现 Q2 阶段防粘贴。

#### Scenario: Q2 见解输入防粘贴
- **WHEN** 用户在 Q2 争议分析界面尝试粘贴内容到见解输入框
- **THEN** 粘贴操作被拦截（最佳努力），与 Q3 ManualInputBox 行为一致

### Requirement: 知识图谱性能降级 UI
系统 SHALL 实现知识图谱节点数 >50 和 >100 的性能降级策略 UI。降级判断时机为 aboutToAppear 数据加载完成后直接决定渲染模式，避免运行中 Canvas→列表突变。

#### Scenario: 节点数 51~100 降级
- **WHEN** 知识图谱节点数为 51~100
- **THEN** renderMode = 'canvas_only'，关闭碎片动画，仅 Canvas 渲染 + 点击激活，提示"节点较多，已优化渲染模式"

#### Scenario: 节点数 >100 降级
- **WHEN** 知识图谱节点数超过 100
- **THEN** renderMode = 'list'，降级为文本列表模式，提示"节点过多，已切换列表视图"

#### Scenario: 降级过渡方式
- **WHEN** 极端场景需运行中切换渲染模式
- **THEN** 使用 animateTo({ duration: 300, curve: Curve.EaseInOut }) 淡入淡出过渡

### Requirement: 页面文件行数合规
系统 SHALL 确保所有页面 .ets 文件不超过 300 行。

#### Scenario: HomePage 行数合规
- **WHEN** 开发者检查 HomePage.ets 行数
- **THEN** 文件行数 <= 300（DeleteConfirmDialog 和 CreateCourseDialog 已拆为独立组件）

#### Scenario: Assessment 行数合规
- **WHEN** 开发者检查 Assessment.ets 行数
- **THEN** 文件行数 <= 300（QuizCard 已拆为独立组件）

### Requirement: 冗余组件清理
系统 SHALL 清理未被使用的 ThreeAskIndicator 组件和 Index.ets 占位页。

#### Scenario: ThreeAskIndicator 合并
- **WHEN** 开发者检查 ThreeAskIndicator.ets
- **THEN** 该组件已合并到 ThreeAskStepper 或已删除，无独立文件

#### Scenario: Index.ets 清理
- **WHEN** 开发者检查 main_pages.json
- **THEN** Index.ets 占位页已从页面注册中移除，文件已删除

### Requirement: 拆分组件接口契约
系统 SHALL 按以下接口规范拆分组件：

#### Scenario: DeleteConfirmDialog 接口
- **WHEN** 开发者查看 DeleteConfirmDialog 组件
- **THEN** 接口为：`@Prop courseName: string`, `onConfirm: () => void`, `onCancel: () => void`, `controller: CustomDialogController`, 容器具有 `accessibilityText`

#### Scenario: CreateCourseDialog 接口
- **WHEN** 开发者查看 CreateCourseDialog 组件
- **THEN** 接口为：`@Prop inputValue: string`, `@State localInput: string`, `onConfirm: (title: string) => void`, `onCancel: () => void`, `controller: CustomDialogController`, TextInput 具有 `accessibilityText`

#### Scenario: QuizCard 接口
- **WHEN** 开发者查看 QuizCard 组件
- **THEN** 接口为：`@Prop quiz: QuizQuestionModel`, `@Prop questionIndex: number`, `@Prop isAnswered: boolean`, `@Prop userAnswer: string`, `@Prop aiEvaluation: string`, `onSubmit: (answer: string) => void`
