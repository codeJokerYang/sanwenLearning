## 1. 全局主题锁定

- [ ] 1.1 在 `EntryAbility.ets` 的 `onWindowStageCreate()` 中添加 `setColorMode(ColorMode.LIGHT)` 调用，强制全局浅色模式
- [ ] 1.2 验证全局锁生效：编译运行后确认所有页面不受系统深色模式影响

## 2. 核心页面白色化迁移

### 2.1 HomePage 仪表盘
- [ ] 2.1.1 移除 HomePage 中的深色背景（如有残留的 DynamicBackground 深色渐变），改为 `#FFFFFF` 或 `#F5F7FA`
- [ ] 2.1.2 确认 GreetingHeader / TodayCard / DailyQuestion / QuickActions / WeeklyStats / DiscoverSection 子组件在 HomePage 中渲染为白色主题
- [ ] 2.1.3 验证 HomePage 整体视觉效果：白底 + 深色文字 + 白色卡片阴影

### 2.2 LearningHome 课程列表
- [ ] 2.2.1 将 LearningHome 页面背景从深色宇宙渐变改为 `#F5F7FA` 浅灰
- [ ] 2.2.2 替换或改造 DynamicBackground 为浅色版本（`#FFFFFF → #F5F7FA → #EEF0F5` 渐变）
- [ ] 2.2.3 CourseCard 组件改为白色卡片 + 阴影样式（见 3.1）
- [ ] 2.2.4 搜索框、FAB、AIChatFab、AIChatPanel 改为白色/浅色系
- [ ] 2.2.5 验证课程列表页整体白色风格

### 2.3 LearningSpace 三问学习页
- [ ] 2.3.1 移除 Stack 层叠中的深色渐变背景 + 星星装饰 + 星云装饰
- [ ] 2.3.2 页面根背景改为 `#F5F7FA`
- [ ] 2.3.3 DebateCard 改为白色卡片 + 阴影（移除紫色发光边框）
- [ ] 2.3.4 ChatBubble 改为浅蓝灰底（`#F0F2F8`）+ 深色文字
- [ ] 2.3.5 ManualInputBox 改为白底 + 浅边框 + 深色文字
- [ ] 2.3.6 ThreeAskStepper 步骤指示器改为白色底 + 主色激活态
- [ ] 2.3.7 底部淡出遮罩（scrim）从 `rgba(8,12,30,0.35)` 改为 `rgba(0,0,0,0.03)` 或移除

### 2.4 KnowledgeGraph 知识图谱
- [ ] 2.4.1 Canvas 背景填充从 `#0D1B3E` 改为 `#FAFBFC`
- [ ] 2.4.2 节点绘制：普通节点 `#5C6BC0` 实心圆 + 白描边；核心节点 `#FFD700` 实心圆 + 白描边
- [ ] 2.4.3 连线颜色改为 `rgba(93,107,192,0.25)`
- [ ] 2.4.4 移除星芒射线效果或改为极淡蓝 `rgba(92,107,192,0.08)`
- [ ] 2.4.5 文字标签从 `#FFFFFF` 改为 `#3D3D5C`
- [ ] 2.4.6 PhaseChip / TipChip 组件改为白底 + 深色文字

### 2.5 ProfilePage 个人中心
- [x] 2.5.1 审查 ProfilePage 已有白色样式，微调确保与全局色值体系一致（T1-T4 文字色、L1-L3 背景色）
- [x] 2.5.2 BadgeItem / SettingRow / StatsCard 组件统一为白色卡片 + 阴影

### 2.6 Assessment / AssessmentResult 页面
- [ ] 2.6.1 Assessment 页面背景和组件改为白色主题
- [ ] 2.6.2 AssessmentResult 页面背景和组件改为白色主题

## 3. 子组件白色化迁移

### 3.1 卡片类组件
- [ ] 3.1.1 `CourseCard.ets` — 背景→`#FFFFFF`，文字→T1/T2，添加双层阴影，边框→`rgba(0,0,0,0.06)`
- [ ] 3.1.2 `TodayCard.ets` — 背景→`#FFFFFF`+阴影，进度环保持主色，文字→T1/T2/T3
- [ ] 3.1.3 `DailyQuestion.ets` — 背景→`#FFFFFF`+阴影，文字→T1/T2
- [x] 3.1.4 `StatsCard.ets` (如存在) — 白色卡片 + 阴影
- [x] 3.1.5 `BadgeItem.ets` — 白色卡片 + 阴影

### 3.2 仪表盘子组件
- [ ] 3.2.1 `GreetingHeader.ets` — 问候语文字→T1，时间图标保持不变，副文字→T3
- [ ] 3.2.2 `QuickActions.ets` — 按钮容器白底+阴影，图标+文字→T1/T2
- [ ] 3.2.3 `WeeklyStats.ets` — 标签→T3，数值→T1，进度条保持主色渐变
- [ ] 3.2.4 `DiscoverSection.ets` — 模板卡片白底+阴影，推荐路径卡片白底

### 3.3 对话与输入组件
- [ ] 3.3.1 `DebateCard.ets` — 背景→`#FFFFFF`+阴影，标题→T1，内容→T2，移除紫色发光边框
- [ ] 3.3.2 `ChatBubble.ets` — AI气泡→`#F0F2F8`+T1文字，用户气泡保持主色+白字
- [ ] 3.3.3 `ManualInputBox.ets` — 输入框→白底+`#E8EAED`边框，占位符→T3，输入文字→T1
- [ ] 3.3.4 `ThreeAskStepper.ets` — 底→白，未完成步骤→T4，已完成→主色，当前→主色高亮

### 3.4 导航与对话框
- [ ] 3.4.1 `BottomTabBar.ets` — 背景→`#FFFFFF`，顶部分割线→`rgba(0,0,0,0.06)`，未选中图标/文字→`#9E9EB8`，选中→`#5C6BC0`
- [ ] 3.4.2 `CreateCourseDialog.ets` — 遮罩→`rgba(0,0,0,0.4)`，对话框→`#FFFFFF`+圆角20vp+阴影，标题→T1(18sp加粗)，内容→T2(14sp)
- [ ] 3.4.3 `DeleteConfirmDialog.ets` — 同 CreateCourseDialog 白色模态样式

### 3.5 背景组件
- [ ] 3.5.1 `DynamicBackground.ets` — 渐变改为 `#FFFFFF → #F5F7FA → #EEF0F5`，Circle 装饰透明度 ≤ 0.06

## 4. Canvas 特殊处理

- [ ] 4.1 `KnowledgeGraph.ets` Canvas — 按 2.4 节完整重绘配色方案
- [ ] 4.2 `RadarChart.ets` (如存在) — 白底 + 深色轴线 + 主色数据区域
- [ ] 4.3 `PuzzleFragmentAnim.ets` (如存在) — 检查并迁移为白色兼容配色

## 5. 编译验证

- [ ] 5.1 执行 Build → 编译通过，零错误零警告
- [ ] 5.2 逐页面视觉检查：HomePage / LearningHome / LearningSpace / KnowledgeGraph / ProfilePage / Assessment / AssessmentResult
- [ ] 5.3 确认无残留深色元素（背景/文字/边框/遮罩）
- [ ] 5.4 切换系统深色/浅色模式验证应用界面不变
