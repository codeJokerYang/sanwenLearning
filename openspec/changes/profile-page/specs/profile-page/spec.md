## ADDED Requirements

### Requirement: 用户信息头部展示
系统 SHALL 在页面顶部展示用户头像（圆形，80vp）、昵称（"三问智学员"默认值）和个人简介（"用三问法，深度理解每一个知识"默认值）。头部区域 SHALL 使用紫色渐变背景（#5E35B1 → #7C4DFF），头像下方显示用户名和简介文字。头像区域 SHALL 支持点击进入个人资料编辑页（当前为 Toast 提示"功能开发中"）。

#### Scenario: 显示默认用户信息
- **WHEN** 用户首次打开"我的"页面且未设置自定义信息
- **THEN** 系统显示默认头像图标、默认昵称"三问智学员"、默认简介"用三问法，深度理解每一个知识"

#### Scenario: 点击头像区域
- **WHEN** 用户点击头像或用户名区域
- **THEN** 系统弹出 Toast 提示"个人资料编辑功能开发中"

### Requirement: 学习数据统计卡片
系统 SHALL 展示 4 项学习统计数据卡片，横向等宽排列：课程数（从 course 表 COUNT）、已完成课程数（status=completed）、学习天数（首次创建课程至今的天数差）、平均评分（从 evaluation_report 聚合 AVG）。每张卡片 SHALL 包含图标、大号数字和标签文字。数字为 0 时显示 "0"，无数据时显示 "--"。卡片 SHALL 使用毛玻璃半透明背景（rgba(255,255,255,0.06)）+ 圆角(16vp) + 微妙边框。

#### Scenario: 有数据时展示统计
- **WHEN** 用户有 3 门课程、1 门完成、学习 7 天、平均评分 85
- **THEN** 4 张卡片分别显示 "3 课程数"、"1 已完成"、"7 学习天数"、"85 平均分"

#### Scenario: 无数据时展示占位
- **WHEN** 用户从未创建过课程
- **THEN** 课程数/已完成/学习天数显示 "0"，平均评分显示 "--"

### Requirement: 成就勋章展示区
系统 SHALL 展示成就勋章模块，包含标题"成就勋章"+ 奖杯图标，下方横向排列至少 3 个勋章项。每个勋章项 SHALL 包含：勋章图标（已解锁彩色/锁定灰色）、勋章名称、解锁条件描述。初始版本 SHALL 包含 3 个固定成就：
- **初学者**：创建第一个课程后解锁
- **三问达人**：完成一个课程的全部三问步骤后解锁
- **学习先锋**：累计学习天数 ≥7 天后解锁

#### Scenario: 未解锁成就显示锁定态
- **WHEN** 用户未满足某成就的解锁条件
- **THEN** 该成就项显示灰色图标、名称文字 opacity(0.4)、条件描述保持可见

#### Scenario: 已解锁成就高亮显示
- **WHEN** 用户已满足某成就解锁条件
- **THEN** 该成就项显示彩色图标、名称文字正常亮度、可点击查看详情（Toast 提示）

### Requirement: 设置菜单列表
系统 SHALL 展示设置菜单模块，包含分组标题"设置"+ 齿轮图标，下方列表包含以下菜单项：
- **主题皮肤**：右侧显示当前主题名（如"宇宙蓝"），右箭头指示可跳转，点击提示"功能开发中"
- **API 配置**：右侧显示配置状态（如"已配置"/"未配置"），点击跳转 API 设置页（Toast 提示）
- **关于三问智学**：右侧显示版本号（如"v1.0.0"），点击弹出版本信息对话框

每个菜单行 SHALL 使用图标 + 文字 + 右侧值的左对齐布局，行高 56vp，底部 Divider 分隔线。

#### Scenario: 点击主题皮肤菜单
- **WHEN** 用户点击"主题皮肤"设置行
- **THEN** 系统弹出 Toast 提示"主题切换功能开发中"

#### Scenario: 点击关于菜单
- **WHEN** 用户点击"关于三问智学"设置行
- **THEN** 系统弹出 AlertDialog 显示应用名称、版本号、版权信息

### Requirement: 底部 TabBar 导航
系统 SHALL 实现底部 TabBar 导航栏，固定在屏幕底部，包含 4 个 Tab：
- **首页**（房屋图标）：指向 HomePage
- **学习**（书本图标）：指向 LearningSpace
- **测评**（图表图标）：指向 AssessmentResult
- **我的**（人物图标）：指向 ProfilePage（选中态高亮）

TabBar SHALL 使用 BarPosition.End 固定底部，选中态图标和文字使用主色 #5C6BC0，未选中态使用灰色 rgba(255,255,255,0.4)。Tab 切换 SHALL 通过 Tabs 组件 index 控制，不触发路由跳转。

#### Scenario: 切换到"我的"Tab
- **WHEN** 用户在任意页面点击底部"我的"Tab
- **THEN** 内容区切换至 ProfilePage，"我的"Tab 图标和文字变为高亮色

#### Scenario: 默认选中首页
- **WHEN** 应用启动进入主页
- **THEN** 底部 TabBar 默认选中"首页"Tab，其他 Tab 为未选中态

### Requirement: 页面滚动与布局
ProfilePage 的内容区域 SHALL 支持垂直滚动（Scroll + List 或 Scroll + Column）。整体布局从上到下为：用户信息头部 → 数据统计卡片行 → 成就勋章区 → 设置菜单列表 → 底部安全区 padding。页面背景 SHALL 使用深色渐变（与 LearningSpace 一致），各模块间距 16vp。滚动时头部区域 SHALL 保持视觉连贯性（不吸顶固定）。

#### Scenario: 内容超出屏幕高度时可滚动
- **WHEN** ProfilePage 内容总高度超过屏幕可视区域
- **THEN** 用户可通过上下滑动浏览全部内容，滚动流畅无卡顿

### Requirement: 国际化与无障碍
ProfilePage 所有面向用户的文案 SHALL 通过 `$r('app.string.xxx')` 引用 string.json 资源，严禁硬编码中文。关键交互元素 SHALL 设置 accessibilityText：
- 头像区域：`$r('app.string.a11y_profile_avatar')`
- 统计卡片：`$r('app.string.a11y_stats_course')` 等
- 设置菜单项：`$r('app.string.a11y_setting_theme')` 等
- TabBar 图标：`$r('app.string.a11y_tab_profile')` 等

#### Scenario: 屏幕阅读器朗读用户信息区
- **WHEN** 无障碍模式下的屏幕阅读器聚焦到用户信息头部
- **THEN** 朗读内容为"用户头像，三问智学员，用三问法深度理解每一个知识"
