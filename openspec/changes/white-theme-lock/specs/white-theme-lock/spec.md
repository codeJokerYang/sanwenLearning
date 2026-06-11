## ADDED Requirements

### Requirement: 全局浅色主题锁定

应用 MUST 在启动时强制将窗口颜色模式设置为 `ColorMode.LIGHT`，确保无论操作系统处于深色模式还是浅色模式，应用界面始终以白色/浅色基调渲染。

#### Scenario: 应用启动时锁定浅色模式
- **WHEN** 用户启动应用，`EntryAbility.onWindowStageCreate()` 被调用
- **THEN** 系统 SHALL 通过 `window.getLastWindow().then(win => win.setColorMode(ColorMode.LIGHT))` 将窗口颜色模式强制设为 LIGHT
- **THEN** 后续所有页面 MUST 继承此 Light Mode 设置，不受系统主题切换影响

#### Scenario: 系统切换深色模式时应用不变
- **WHEN** 应用正在运行中，用户在系统设置中切换到深色模式
- **THEN** 应用界面 MUST 保持白色/浅色外观，不发生任何颜色变化

---

### Requirement: 页面背景色统一为白色体系

所有页面和容器的背景色 MUST 使用白色体系（L1/L2/L3 三层），严禁使用深色背景值（如 `#0D1B3E`、`#14142B`、`#0A1628`）。

#### Scenario: 根页面使用纯白背景
- **WHEN** 渲染 HomePage、ProfilePage 等根页面
- **THEN** 页面根容器背景色 MUST 为 `#FFFFFF`

#### Scenario: 列表页使用浅灰背景
- **WHEN** 渲染 LearningHome 等列表类页面
- **THEN** 页面根容器背景色 MUST 为 `#F5F7FA` 或 `#F8F9FC`
- **THEN** 卡片项背景 MUST 为 `#FFFFFF`

#### Scenario: 特殊区域使用极淡蓝灰
- **WHEN** 渲染输入框聚焦态、卡片内嵌区域等特殊区域
- **THEN** 背景色 MUST 为 `#EEF0F5`

---

### Requirement: 文字颜色统一为深色体系

所有文字元素 MUST 使用深色系文字颜色（T1/T2/T3/T4 四级），严禁使用 `#FFFFFF` 或 `rgba(255,255,255,...)` 作为主要文字颜色。

#### Scenario: 标题和重要内容使用主文字色
- **WHEN** 渲染页面标题、卡片标题、按钮文字等重要文本
- **THEN** 文字颜色 MUST 为 `#1A1A2E`

#### Scenario: 正文段落使用正文色
- **WHEN** 渲染描述文字、详情内容等正文段落
- **THEN** 文字颜色 MUST 为 `#3D3D5C`

#### Scenario: 次要信息使用辅助色
- **WHEN** 渲染时间戳、提示文字、占位符等次要信息
- **THEN** 文字颜色 MUST 为 `#7B7B94`

#### Scenario: 禁用状态和分割线使用禁用色
- **WHEN** 渲染禁用状态的文字或分割线
- **THEN** 颜色 MUST 为 `#C4C4D0`

---

### Requirement: 卡片组件采用 Material 阴影样式

所有卡片型组件（CourseCard、StatsCard、TodayCard、DailyQuestion 等）MUST 使用白色背景 + 双层阴影的 Material Design 样式，废弃半透明毛玻璃效果。

#### Scenario: 标准卡片渲染
- **WHEN** 渲染任意卡片组件
- **THEN** 卡片背景 MUST 为 `#FFFFFF`
- **THEN** 圆角 MUST 为 16vp
- **THEN** MUST 包含两层阴影：近影（blur:8, color:rgba(0,0,0,0.04)）+ 远影（blur:16, color:rgba(0,0,0,0.02)）
- **THEN** 严禁使用 `backgroundColor('rgba(255,255,255,0.06)')` 等半透明背景

#### Scenario: 边框使用淡分割线色
- **WHEN** 卡片需要边框时
- **THEN** 边框颜色 MUST 为 `rgba(0,0,0,0.06)` 或 `#E8EAED`
- **THEN** 严禁使用 `rgba(255,255,255,0.08)` 等白色半透明边框

---

### Requirement: DynamicBackground 改造为浅色装饰背景

DynamicBackground 组件 MUST 从深色宇宙渐变改造为浅色装饰性渐变背景。

#### Scenario: 浅色渐变背景渲染
- **WHEN** DynamicBackground 组件被挂载到页面
- **THEN** 背景渐变 MUST 从 `#FFFFFF → #F5F7FA → #EEF0F5`（或类似浅色序列）
- **THEN** 严禁包含 `#0D1B3E`、`#14142B`、`#0A1628` 等深色值
- **THEN** 装饰性 Circle 元素透明度 MUST ≤ 0.06

---

### Requirement: KnowledgeGraph Canvas 白底重绘

KnowledgeGraph 的 Canvas 渲染 MUST 在白底背景下重新设计节点、连线、文字配色方案。

#### Scenario: Canvas 背景填充
- **WHEN** KnowledgeGraph 执行 Canvas 填充操作
- **THEN** 背景色 MUST 为 `#FAFBFC`（极淡灰），而非 `#0D1B3E`

#### Scenario: Canvas 节点绘制
- **WHEN** Canvas 绘制知识节点
- **THEN** 普通节点 MUST 使用 `#5C6BC0` 实心圆 + 白色描边
- **THEN** 核心/已激活节点 MUST 使用 `#FFD700` 实心圆 + 白色描边
- **THEN** 严禁使用发光效果（glow blur），白底上发光不协调

#### Scenario: Canvas 连线绘制
- **WHEN** Canvas 绘制节点间连线
- **THEN** 连线颜色 MUST 为 `rgba(93,107,192,0.25)`
- **THEN** 可保留虚线样式但降低视觉强度

#### Scenario: Canvas 文字标签
- **WHEN** Canvas 绘制节点名称文字
- **THEN** 文字颜色 MUST 为 `#3D3D5C`，严禁使用 `#FFFFFF`

---

### Requirement: BottomTabBar 白底导航栏

BottomTabBar 导航栏 MUST 使用白色背景 + 彩色图标方案。

#### Scenario: 底部导航栏渲染
- **WHEN** BottomTabBar 组件被渲染
- **THEN** 背景色 MUST 为 `#FFFFFF`
- **THEN** 顶部 MUST 有 `rgba(0,0,0,0.06)` 分割线或阴影
- **THEN** 未选中图标颜色 MUST 为 `#9E9EB8`
- **THEN** 选中图标和文字颜色 MUST 为 `#5C6BC0`（主色）
- **THEN** 未选中文字颜色 MUST 为 `#9E9EB8`

---

### Requirement: 对话框组件白色模态样式

CreateCourseDialog 和 DeleteConfirmDialog MUST 使用白色模态对话框样式。

#### Scenario: 对话框渲染
- **WHEN** 弹出 CreateCourseDialog 或 DeleteConfirmDialog
- **THEN** 背景遮罩 MUST 为 `rgba(0,0,0,0.4)`
- **THEN** 对话框本体背景 MUST 为 `#FFFFFF`，圆角 20vp + 阴影
- **THEN** 标题文字 MUST 为 `#1A1A2E`，18sp 加粗
- **THEN** 内容文字 MUST 为 `#3D3D5C`，14sp
- **THEN** 主按钮保持 `#5C6BC0→#3949AB` 渐变
- **THEN** 取消/次要按钮文字 MUST 为 `#7B7B94`

---

### Requirement: LearningSpace 三问页面白色化

LearningSpace 页面（Q2 辩论/Q3 答题）MUST 从深色宇宙风改为白色容器风格。

#### Scenario: LearningSpace 页面背景
- **WHEN** 用户进入 LearningSpace 页面
- **THEN** 页面背景 MUST 为 `#F5F7FA` 或 `#FFFFFF`
- **THEN** 严禁使用 Stack 层叠的深色渐变 + 星星装饰 + 星云装饰
- **THEN** 移除或替换 DynamicBackground（如使用则必须是浅色版本）

#### Scenario: DebateCard 白色化
- **WHEN** LearningSpace 中渲染 DebateCard
- **THEN** 卡片背景 MUST 为 `#FFFFFF` + 阴影
- **THEN** 标题文字 MUST 为 `#1A1A2E`
- **THEN** 正文 MUST 为 `#3D3D5C`
- **THEN** 移除紫色发光边框，改用 `#E8EAED` 细边框或无边框

#### Scenario: ChatBubble 白色化
- **WHEN** LearningSpace 中渲染 ChatBubble
- **THEN** AI 气泡背景 MUST 为 `#F0F2F8`（浅蓝灰）
- **THEN** AI 气泡文字 MUST 为 `#1A1A2E`
- **THEN** 用户气泡保持主色 `#5C6BC0`，文字为 `#FFFFFF`（白字在主色上可读）

#### Scenario: ManualInputBox 白色化
- **WHEN** LearningSpace 中渲染 ManualInputBox
- **THEN** 输入框背景 MUST 为 `#FFFFFF`
- **THEN** 边框 MUST 为 `#E8EAED`
- **THEN** 提示文字 MUST 为 `#7B7B94`
- **THEN** 输入文字 MUST 为 `#1A1A2E`

---

### Requirement: 主色调保持不变

品牌主色调 `#5C6BC0→#3949AB` 渐变 MUST 在白色主题下保持不变，用于按钮、选中态、强调元素。

#### Scenario: 主色按钮在白底上的渲染
- **WHEN** 页面中使用主色调按钮
- **THEN** 按钮渐变 MUST 保持 `#5C6BC0→#3949AB`
- **THEN** 按钮文字 MUST 为 `#FFFFFF`（白字在主色上对比度足够）

#### Scenario: 强调元素使用主色
- **WHEN** 需要表示选中、激活、链接等强调态
- **THEN** 颜色 MUST 为 `#5C6BC0` 或其同色系变体
