## 1. 基础设施与数据层

- [x] 1.1 在 string.json（中/英）添加首页全部文案资源：问候语(6时段)、今日进度、三问标签(Q1/Q2/Q3)、每日一问、快捷操作(4个)、统计数据(3个)、发现区文案、无障碍文本 — 约 50 条
- [x] 1.2 在 HomeViewModel.ets 新增 `loadDashboardData()` 方法：聚合查询 course 表获取活跃课程(current_step/progress/title)、question_record 统计本周答题数、计算连续学习天数；新增 `getDailyQuestion()` 返回 mock 每日问题
- [x] 1.3 在 HomeViewModel.ets 新增 `getGreetingByHour()` 工具方法：根据当前小时返回对应问候语 ResourceStr

## 2. 子组件开发（6 个）

- [x] 2.1 创建 GreetingHeader.ets — 时间感知问候头部组件
- [x] 2.2 创建 TodayCard.ets — 今日学习进度核心卡片组件
- [x] 2.3 创建 DailyQuestion.ets — AI 每日一问卡片组件
- [x] 2.4 创建 QuickActions.ets — 快捷操作 4 宫格组件
- [x] 2.5 创建 WeeklyStats.ets — 学习数据概览面板组件
- [x] 2.6 创建 DiscoverSection.ets — 发现与推荐区域组件

## 3. HomePage 主页面组装

- [x] 3.1 重写 HomePage.ets — Stack(DynamicBackground + Scrim + Scroll(Column))
- [x] 3.2 实现各模块间导航跳转
- [x] 3.3 实现 mock 数据降级
- [x] 3.4 添加无障碍支持 — 所有可交互元素 accessibilityText

## 4. 编译验证与视觉检查

- [ ] 4.1 hvigor assembleHap 编译零错误（deprecated WARN 可接受）
- [ ] 4.2 HomePage 行数 ≤300 行验证
- [ ] 4.3 所有子组件各自 ≤100 行验证
- [ ] 4.4 DevEco Studio Previewer 或真机预览确认 6 大模块正确渲染
