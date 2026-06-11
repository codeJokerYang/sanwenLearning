## Why

当前应用大量页面使用了**深色宇宙星空主题**（DynamicBackground 深色渐变 + 毛玻璃卡片 + 白色文字），包括 HomePage、LearningHome、LearningSpace、KnowledgeGraph、ProfilePage 等核心页面。虽然视觉上与"不背单词"等竞品风格一致，但存在以下问题：

1. **系统主题冲突**：当用户设备设置为浅色模式时，应用强制深色主题造成体验割裂
2. **可读性争议**：深色背景上的白色文字在强光环境下（户外/日光）可读性差
3. **用户偏好不可控**：无法跟随或锁定用户偏好的主题色
4. **截图中的 ProfilePage 已是白色**：个人中心页已使用白色背景（如截图所示），说明产品方向上白色主题更符合学习类 App 的专业感

用户明确要求：**界面保持白色主题风格，不随系统颜色主题适配**。即无论系统是深色还是浅色模式，应用始终以白色/浅色基调呈现。

## What Changes

- **全局主题锁定为 Light Mode**：在 EntryAbility 或 Application 中设置 `colorMode = ColorMode.LIGHT`，强制所有页面使用浅色模式渲染
- **重写所有深色页面为白色主题**：
  - `HomePage.ets` — 从深色宇宙风改为白色仪表盘
  - `LearningHome.ets` — 从深色宇宙风改为白色课程列表
  - `LearningSpace.ets` — 从深色宇宙风改为白色三问容器
  - `KnowledgeGraph.ets` — Canvas 渲染从暗底星座改为白底星图
  - `ProfilePage.ets` — 已是白色，微调统一
  - `Assessment.ets` / `AssessmentResult.ets` — 改为白色主题
- **子组件主题迁移**（~15 个组件）：
  - DynamicBackground → 浅色渐变背景（白→淡蓝灰）
  - CourseCard / StatsCard / BadgeItem / SettingRow → 白色卡片 + 阴影
  - TodayCard / DailyQuestion / QuickActions / WeeklyStats / DiscoverSection → 白色毛玻璃/纯白
  - GreetingHeader / ThreeAskStepper / DebateCard / ChatBubble / ManualInputBox → 白色系
  - BottomTabBar → 白色底 + 图标着色
  - DeleteConfirmDialog / CreateCourseDialog → 白色对话框
- **色彩 Token 更新**：新增 light-mode 色彩映射表

## Capabilities

### New Capabilities
- `white-theme-lock`: 全局浅色主题强制锁定，跨页面一致性保证

### Modified Capabilities
- （无现有 spec 需修改）

## Impact

- **修改文件**（约 20+ 个）：所有 .ets 页面和组件文件的背景色、文字色、边框色、阴影等样式属性
- **核心变更点**：
  | 原值 (Dark) | 新值 (Light) |
  |---|---|
  | 背景: `#0D1B3E` linearGradient | 背景: `#FFFFFF` 或 `#F5F7FA` |
  | 文字: `#FFFFFF` / `rgba(255,255,255,0.x)` | 文字: `#1A1A2E` / `rgba(26,26,46,0.x)` |
  | 卡片: `rgba(255,255,255,0.06)` | 卡片: `#FFFFFF` with shadow |
  | 边框: `rgba(255,255,255,0.08)` | 边框: `rgba(0,0,0,0.06)` or `#E8EAED` |
  | 主色按钮: `#5C6BC0→#3949AB` | 保持不变（主色不受主题影响） |
  | Scrim: `rgba(8,12,30,0.35)` | 移除或改为极淡遮罩 |
- **风险**：Canvas 绘制内容（KnowledgeGraph/RadarChart/PuzzleFragmentAnim）需要重新设计配色方案
