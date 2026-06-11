## Context

当前应用已有 HomePage（首页课程列表）、LearningSpace（三问学习空间）、KnowledgeGraph（知识图谱）、Assessment（测评）、AssessmentResult（评价报告）5 个页面，但缺少"我的"个人中心页面。应用采用 HarmonyOS NEXT ArkTS 声明式 UI + Stage 模型，设计 Token 体系已建立（颜色/尺寸/圆角/间距），暗色模式支持已在部分页面实现。底部导航尚未统一为 TabBar，各页面间通过 router.pushUrl 跳转。

**约束条件：**
- 单文件 ≤300 行（ARCHITECTURE_CONVENTIONS）
- 严禁硬编码中文用户文案，必须使用 `$r()` 资源引用
- 最小可点击区域 44vp × 44vp
- 组件内仅用 @Prop 展示型传递

## Goals / Non-Goals

**Goals：**
- 实现完整的"我的"个人中心页面，包含 4 大模块（用户信息、数据统计、成就徽章、设置菜单）
- 与现有宇宙星空/毛玻璃视觉风格保持一致
- 响应式布局适配手机屏幕（375-414vp 宽度）
- 底部 TabBar 导航整合 4 个核心 Tab（首页/学习/测评/我的）

**Non-Goals：**
- 不实现真实的用户登录/注册系统（当前为单机学习机）
- 不实现服务端同步的统计数据（使用本地 mock 数据）
- 不实现主题切换功能（仅展示入口，后续迭代）
- 不实现 API 配置的真实存储（仅 UI 占位）

## Decisions

### D1: 页面架构 — 单文件 + 子组件拆分

**选择**：ProfilePage 主组件 + 5 个子组件独立文件

**理由**：
- ProfileHeader / StatsCard / BadgeItem / SettingRow 各自职责单一
- 符合 ARCHITECTURE_CONVENTIONS 的 components 目录规范
- 主页面控制在 200 行以内

**替代方案**：全部内联在 ProfilePage → 超过 300 行限制，拒绝

### D2: 数据来源 — AppStorage 全局状态

**选择**：用户昵称/头像/统计数据存入 AppStorage，ProfilePage 通过 @StorageProp 读取

**理由**：
- 用户信息跨多个页面共享（HomePage 也可能显示用户名）
- 无需引入 ViewModel 层（纯展示页面，无业务逻辑）
- AppStorage 是 ArkUI 推荐的全局状态方案

**替代方案**：新建 ProfileViewModel → 过度工程化，纯展示无需 VM

### D3: 视觉风格 — 与 LearningSpace 宇宙风格对齐

**选择**：沿用 LearningSpace 的深色渐变背景 + 毛玻璃卡片风格

**理由**：
- 截图参考显示用户期望统一的深色宇宙风格
- 头部区域用紫色渐变背景呼应品牌色
- 卡片使用半透明背景 + 微妙边框

### D4: 成就勋章 — 静态展示 + 锁定态

**选择**：3 个固定成就项（初学者/三问达人/学习先锋），根据条件显示已解锁/锁定态

**理由**：
- 成就系统是游戏化激励核心，需在 v1.0 就有基础展示
- 锁定态用灰色 + 禁用图标传达"未达成"
- 数据从 course/question_record 表聚合计算

### D5: 底部导航 — Tabs 组件

**选择**：使用 ArkUI Tabs + TabContent + BarPosition.End 实现底部 TabBar

**理由**：
- 系统级组件，自动处理选中态动画和手势
- 4 个 Tab：首页(Home)/学习(LearningSpace)/测评(AssessmentResult)/我的(ProfilePage)
- 自定义 Tab 图标+文字

## Risks / Trade-offs

| 风险 | 缓解措施 |
|------|---------|
| ProfilePage 行数超 300 | 严格拆分子组件，主页面仅做 Stack 布局编排 |
| 底部 Tabs 改造影响现有路由 | 保留 router.pushUrl 用于非 Tab 页面跳转，Tab 切换用 tabs index |
| 暗色模式下可读性不足 | 文字颜色使用高对比度 token（白色 0.85/0.6 两级） |
| 国际化资源缺失 | 所有用户文案走 string.json，中英文双份 |
