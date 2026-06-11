## Why

当前 HomePage 为空占位页（"首页功能开发中"），仅展示 3 个功能预告标签。作为应用的**第一入口页面**，首页承担着用户首屏印象、学习状态总览、快速操作入口、AI 智能推荐等核心职责。缺失这些能力导致：
1. 用户打开 App 后无明确行动指引，不知道该做什么
2. 无法一眼看到自己的学习进度和成就
3. AI 能力（智能推荐、每日问题）没有曝光入口
4. 与竞品（如不背单词、百词斩）相比缺乏吸引力和留存机制

HomePage 需要从"空壳占位"升级为**信息密度适中、视觉吸引力强、引导路径清晰**的学习仪表盘。

## What Changes

- **重写 HomePage**：从占位页升级为完整的学习仪表盘，包含 6 大模块
  - 1. **品牌问候区**：动态问候语 + 用户名 + 今日日期 + 天气/心情装饰
  - 2. **今日学习卡片**：当日学习进度环形图 + 三问阶段指示器 + "继续学习"快捷入口
  - 3. **AI 每日一问**：基于用户课程生成每日思考题，点击进入对话
  - 4. **快捷操作区**：新建课程 / 上传资料 / 开始测评 / 查看报告
  - 5. **学习数据概览**：本周学习时长、累计知识点、连续学习天数
  - 6. **发现与推荐**：热门课程模板、AI 推荐学习路径、社区精选

- **新增子组件**：
  - `GreetingHeader.ets` — 品牌问候头部（时间感知问候语）
  - `TodayCard.ets` — 今日学习进度卡片（环形进度+三问步骤条）
  - `DailyQuestion.ets` — AI 每日一问卡片
  - `QuickActions.ets` — 快捷操作网格（4 宫格按钮）
  - `WeeklyStats.ets` — 本周学习统计面板
  - `DiscoverSection.ets` — 发现与推荐区域

- **新增 HomeViewModel 方法**：加载今日学习数据、获取每日问题、计算周统计数据

## Capabilities

### New Capabilities
- `homepage-dashboard`: 完整的首页学习仪表盘，含 6 大模块的信息聚合与交互

### Modified Capabilities
- （无现有 spec 需修改）

## Impact

- **新增文件**（7 个）：
  - `entry/src/main/ets/pages/HomePage.ets` — 重写为完整仪表盘
  - `entry/src/main/ets/components/GreetingHeader.ets`
  - `entry/src/main/ets/components/TodayCard.ets`
  - `entry/src/main/ets/components/DailyQuestion.ets`
  - `entry/src/main/ets/components/QuickActions.ets`
  - `entry/src/main/ets/components/WeeklyStats.ets`
  - `entry/src/main/ets/components/DiscoverSection.ets`

- **修改文件**（2 个）：
  - `entry/src/main/ets/viewmodels/HomeViewModel.ets` — 新增 dashboard 数据方法
  - `entry/src/main/resources/base/en_US/element/string.json` — 英文资源

- **依赖**：无需新增第三方依赖，纯 ArkUI 实现
- **风险**：HomePage 行数可能接近 300 行上限，需严格控制并通过子组件拆分
