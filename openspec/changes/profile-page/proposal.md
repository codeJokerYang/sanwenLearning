## Why

当前应用缺少"我的"个人中心页面，用户无法查看个人信息、学习统计数据、成就徽章和系统设置。作为学习机产品，个人中心是用户管理身份、追踪学习进度、个性化配置的核心入口，缺失该页面导致用户体验不完整，无法形成完整的应用导航闭环。

## What Changes

- **新增 ProfilePage（我的页面）**：包含用户头像/昵称/简介展示区、4 项学习数据统计卡片（课程数/已完成/学习天数/平均评分）、成就勋章展示区、设置菜单列表（主题皮肤/API配置/关于）
- **新增底部 TabBar 导航**：在 HomePage / LearningSpace / AssessmentResult 基础上新增第 4 个"我的"Tab
- **新增 UserSettingsModel 数据模型**：存储用户偏好（主题、API 配置等）
- **修改 EntryAbility 路由注册**：添加 ProfilePage 路由映射

## Capabilities

### New Capabilities
- `profile-page`: 个人中心页面，含用户信息区、数据统计、成就徽章、设置菜单四大模块的完整 UI 与交互逻辑

### Modified Capabilities
- （无现有 spec 需要修改）

## Impact

- **新增文件**：
  - `entry/src/main/ets/pages/ProfilePage.ets` — 个人中心页面主组件
  - `entry/src/main/ets/components/ProfileHeader.ets` — 用户头像+昵称+简介头部组件
  - `entry/src/main/ets/components/StatsCard.ets` — 统计数字卡片组件
  - `entry/src/main/ets/components/BadgeItem.ets` — 成就徽章项组件
  - `entry/src/main/ets/components/SettingRow.ets` — 设置菜单行组件
  - `entry/src/main/ets/models/UserSettingsModel.ets` — 用户设置数据模型
- **修改文件**：
  - `entry/src/main/ets/pages/HomePage.ets` — 添加底部 TabBar 导航容器
  - `entry/src/main/resources/base/profile/` — 新增 string.json 国际化资源
  - `module.json5` — 添加 ProfilePage 路由
- **依赖**：无需新增第三方依赖，纯 ArkUI 实现
