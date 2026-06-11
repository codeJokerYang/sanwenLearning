## 1. 基础设施与路由

- [ ] 1.1 在 module.json5 中添加 ProfilePage 路由配置（name: "ProfilePage", uri: "pages/ProfilePage"）
- [ ] 1.2 创建 string.json 国际化资源文件，添加 profile 页面所有文案（中英文）：用户昵称、简介、统计标签、成就名称、设置项名称、Tab 名称、无障碍文本
- [ ] 1.3 创建 UserSettingsModel.ets 数据模型（theme: string, apiConfigured: boolean, version: string）

## 2. 子组件开发

- [ ] 2.1 创建 ProfileHeader.ets — 用户头像(80vp圆形)+昵称+简介头部组件，紫色渐变背景(#5E35B1→#7C4DFF)，点击事件 Toast 提示
- [ ] 2.2 创建 StatsCard.ets — 统计数据卡片组件(icon + number + label)，毛玻璃背景 rgba(255,255,255,0.06)，圆角 16vp
- [ ] 2.3 创建 BadgeItem.ets — 成就勋章项组件(图标+名称+条件描述)，支持 unlocked/locked 双态
- [ ] 2.4 创建 SettingRow.ets — 设置菜单行组件(图标左侧+文字+右侧值+箭头)，行高 56vp，底部 Divider

## 3. ProfilePage 主页面

- [ ] 3.1 创建 ProfilePage.ets 主组件 — Scroll + Column 纵向布局：ProfileHeader → StatsRow(4个StatsCard) → BadgeSection → SettingList
- [ ] 3.2 实现数据统计逻辑 — 从 AppStorage 或 mock 数据读取 courseCount/completedCount/studyDays/avgScore
- [ ] 3.3 实现成就解锁判断逻辑 — 根据课程数/完成状态/学习天数计算 3 个成就的 locked/unlocked 状态
- [ ] 3.4 实现设置菜单交互 — 主题皮肤/API配置 Toast 提示、关于弹 AlertDialog
- [ ] 3.5 添加无障碍支持 — 所有可交互元素设置 accessibilityText

## 4. 底部 TabBar 导航

- [ ] 4.1 在 HomePage 外层包裹 Tabs 组件（BarPosition.End），整合 4 个 TabContent（HomePage/LearningSpace/AssessmentResult/ProfilePage）
- [ ] 4.2 实现 TabBar 自定义渲染 — 图标+文字，选中态 #5C6BC0 / 未选中态 rgba(255,255,255,0.4)
- [ ] 4.3 配置 TabBar 安全区域底部 padding（适配全面屏）

## 5. 验证与集成

- [ ] 5.1 编译验证 — hvigor assembleHap 零错误零警告（deprecated 警告除外）
- [ ] 5.2 功能验证 — Tab 切换正常、统计数据正确展示、设置菜单响应正确
- [ ] 5.3 视觉验证 — 与截图参考一致：深色渐变背景、毛玻璃卡片、紫色头部、底部导航高亮态
