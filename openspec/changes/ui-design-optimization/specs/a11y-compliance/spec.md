## ADDED Requirements

### Requirement: 关键交互元素 accessibilityText 补全
系统 SHALL 为以下关键交互元素设置 `accessibilityText`：搜索框 TextInput、删除确认对话框、创建课程对话框、Assessment Radio 选项、DebateCard 提交按钮、DebateCard TextArea 输入框、KnowledgeGraph Canvas 区域。

#### Scenario: 搜索框无障碍
- **WHEN** 屏幕阅读器聚焦到搜索框
- **THEN** 朗读"搜索框，输入您想学习的领域问题"

#### Scenario: 对话框无障碍
- **WHEN** 删除确认对话框弹出
- **THEN** 对话框容器具有 accessibilityText"确认删除课程"

#### Scenario: Radio 选项无障碍
- **WHEN** 屏幕阅读器聚焦到 Assessment 的 Radio 选项
- **THEN** 朗读该选项的文字内容

#### Scenario: Canvas 区域无障碍
- **WHEN** 屏幕阅读器聚焦到知识图谱 Canvas 区域
- **THEN** 朗读动态文本"知识图谱，共 N 个节点，M 个已点亮"（N/M 随节点状态实时更新）

### Requirement: Canvas 区域无障碍动态更新
系统 SHALL 确保 Canvas 区域的 accessibilityText 绑定 @State 变量，节点状态变更时自动触发无障碍框架重新朗读。

#### Scenario: 节点点亮后无障碍更新
- **WHEN** 用户点亮一个知识节点
- **THEN** activatedCount @State 变量 +1 → accessibilityText 自动更新 → 屏幕阅读器可朗读更新后的节点数

#### Scenario: accessibilityText 的 i18n 处理
- **WHEN** Canvas accessibilityText 需要包含动态数值
- **THEN** 使用格式化资源 `$r('app.string.a11y_canvas_status', this.totalNodeCount, this.activatedCount)` 或 `resourceManager.getStringSync()` 获取字符串后拼接

### Requirement: 关键输入元素 accessibilityDescription 补全
系统 SHALL 为以下输入元素设置 `accessibilityDescription`：ManualInputBox、DebateCard TextArea。

#### Scenario: ManualInputBox 无障碍描述
- **WHEN** 屏幕阅读器聚焦到 ManualInputBox
- **THEN** 朗读描述"手动输入您的答案，禁止粘贴"

### Requirement: 最小可点击区域合规
系统 SHALL 确保所有可点击元素的触摸区域不小于 44vp x 44vp。

#### Scenario: CourseCard 删除按钮可点击区域
- **WHEN** 开发者检查 CourseCard 删除按钮的触摸区域
- **THEN** 触摸区域 >= 44vp x 44vp（通过外层容器 padding 或 hitTestBehavior 扩展）

#### Scenario: ThreeAskStepper 步骤圆可点击区域
- **WHEN** 开发者检查 ThreeAskStepper 步骤圆的触摸区域
- **THEN** 触摸区域 >= 44vp x 44vp

#### Scenario: ThreeAskIndicator 圆点可点击区域
- **WHEN** 开发者检查 ThreeAskIndicator 圆点的触摸区域
- **THEN** 触摸区域 >= 44vp x 44vp（若已合并到 ThreeAskStepper，则由 ThreeAskStepper 统一保证）

### Requirement: 文字与背景对比度合规
系统 SHALL 确保所有文字与背景的对比度不低于 4.5:1（WCAG AA 标准），包括亮色和暗色模式。

#### Scenario: 亮色模式主文字对比度
- **WHEN** 开发者检查 `color_text_primary`(#1A1A1A) 在 `color_bg_page`(#F5F5F5) 上的对比度
- **THEN** 对比度 >= 4.5:1

#### Scenario: 亮色模式禁用文字对比度
- **WHEN** 开发者检查 `color_text_disabled`(#999999) 在白色背景上的对比度
- **THEN** 若对比度 < 4.5:1，则调整颜色值至合规

#### Scenario: 暗色模式文字对比度
- **WHEN** 开发者检查暗色模式下 `color_text_primary`(暗色值 #E5E5E5) 在 `color_bg_page`(暗色值 #1A1A1A) 上的对比度
- **THEN** 对比度 >= 4.5:1
