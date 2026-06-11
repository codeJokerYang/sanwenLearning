## Context

当前应用采用**深色宇宙星空主题**（Cosmic Space Theme），核心页面包括 HomePage（仪表盘）、LearningHome（课程列表）、LearningSpace（三问学习）、KnowledgeGraph（知识图谱）、ProfilePage（个人中心）等。其中 ProfilePage 已经是白色主题，其余页面均为深色背景 + 白色文字 + 毛玻璃卡片的设计。

用户明确要求：**锁定白色主题，不随系统深色/浅色模式变化**。这意味着：
- 全局强制 `ColorMode.LIGHT`
- 所有页面背景从深色渐变改为白色/浅灰
- 文字颜色从白色系改为深色系
- 卡片样式从半透明毛玻璃改为纯白+阴影
- Canvas 绘制内容需重新配色

**技术约束**：HarmonyOS NEXT API 12+，ArkTS 声明式 UI，单文件 ≤300 行。

## Goals / Non-Goals

**Goals:**
1. 在应用入口处全局锁定 `colorMode = ColorMode.LIGHT`，确保不受系统主题影响
2. 将所有 ~20 个 .ets 页面和组件从深色主题迁移到白色主题
3. 保持主色调（#5C6BC0→#3949AB 渐变）不变，确保品牌一致性
4. 确保 Canvas 组件（KnowledgeGraph、RadarChart 等）在白底上清晰可读
5. 统一所有页面的视觉语言：白底 + 深色文字 + 淡阴影卡片 + 细边框

**Non-Goals:**
1. 不实现主题切换功能（用户明确只要白色）
2. 不修改业务逻辑或数据流
3. 不引入第三方主题库或 CSS-in-JS 方案
4. 不修改 ProfilePage 的现有白色设计（仅微调统一）
5. 不修改 i18n 字符串资源

## Decisions

### D1: 全局 ColorMode 锁定方式 — EntryAbility.onWindowStageCreate()

**决策**：在 `EntryAbility.ets` 的 `onWindowStageCreate()` 中调用 `window.getLastWindow().then(win => { win.setColorMode(ColorMode.LIGHT) })`

**理由**：
- HarmonyOS 官方推荐在 Ability 层设置窗口属性，而非每个 Page 单独设置
- 一次性生效，覆盖所有后续创建的页面
- 与 `setFullScreen` / `setLayoutFullScreen` 等窗口属性放在同一位置，维护性好

**替代方案对比**：
| 方案 | 优点 | 缺点 |
|------|------|------|
| 每个 @Entry 页面单独 `.colorMode(ColorMode.LIGHT)` | 粒度可控 | 易遗漏新页面，维护成本高 |
| Application.onCreate() 中设置 | 更早生效 | ArkTS Application 生命周期可能晚于窗口创建 |
| **EntryAbility.onWindowStageCreate()（选中）** | 官方推荐，一处生效 | 无明显缺点 |

### D2: 背景色策略 — 分层白色体系

**决策**：采用三层白色背景体系，而非单一纯白：

| 层级 | 用途 | 色值 | 示例 |
|------|------|------|------|
| L1 - 纯白 | 页面根背景、主要容器 | `#FFFFFF` | HomePage、ProfilePage |
| L2 - 浅灰 | 次级区域、列表项间隔 | `#F5F7FA` 或 `#F8F9FC` | LearningHome 列表背景、设置页分组 |
| L3 - 极淡蓝 | 特殊区域强调 | `#EEF0F5` | 卡片内嵌区域、输入框聚焦态 |

**理由**：全纯白会显得单调且缺乏层次感。浅灰分隔层能提供视觉呼吸感，与主流学习 App（如 Notion、GoodNotes）的白色主题一致。

### D3: 卡片样式 — 从毛玻璃到 Material 阴影

**决策**：废弃 `rgba(255,255,255,0.06)` 半透明毛玻璃，改用 Material Design 风格的白色卡片 + 多层阴影：

```typescript
// 新卡片标准样式
.backgroundColor('#FFFFFF')
.borderRadius(16)
.shadow({
  color: 'rgba(0, 0, 0, 0.04)',
  offsetX: 0,
  offsetY: 2,
  blur: 8
})
.shadow({
  color: 'rgba(0, 0, 0, 0.02)',
  offsetX: 0,
  offsetY: 4,
  blur: 16
})
```

**理由**：
- 白色背景下毛玻璃效果不明显（因为底色已经是白的）
- 双层阴影（近暗远淡）是 Material 3 的标准做法，层次感强
- 性能优于 `blur()` + `backdropFilter` 组合

### D4: 文字颜色层级 — 四级深色体系

**决策**：建立四级文字颜色体系：

| 层级 | 色值 | 用途 | 对应原深色值 |
|------|------|------|-------------|
| T1 - 主文字 | `#1A1A2E` | 标题、重要内容 | `#FFFFFF` |
| T2 - 正文 | `#3D3D5C` | 描述、正文段落 | `rgba(255,255,255,0.85)` |
| T3 - 辅助 | `#7B7B94` | 次要信息、占位符 | `rgba(255,255,255,0.6)` |
| T4 - 禁用/分割线 | `#C4C4D0` | 禁用状态、分割线 | `rgba(255,255,255,0.2)` |

**理由**：WCAG AA 标准要求正文与背景对比度 ≥ 4.5:1。`#1A1A2E` 在 `#FFFFFF` 上对比度为 ~15:1，`#3D3D5C` 对比度为 ~7.5:1，均满足无障碍标准。

### D5: DynamicBackground 组件改造 — 浅色装饰性渐变

**决策**：不删除 DynamicBackground，而是将其改造为**浅色装饰性背景组件**：

- 移除深色宇宙渐变（`#0D1B3E → #14142B → #0A1628`）
- 替换为极淡渐变（`#FFFFFF → #F5F7FA → #EEF0F5`）
- 保留装饰性 Circle 元素但降低透明度至 `0.03~0.06`
- 可选：添加极淡的几何图形装饰（圆形/曲线）

**理由**：保留组件结构避免大规模重构；浅色装饰能增加页面质感而不喧宾夺主。

### D6: KnowledgeGraph Canvas 重绘 — 白底星图

**决策**：Canvas 配色全面反转：

| 元素 | 原深色值 | 新浅色值 |
|------|---------|---------|
| 背景 | `#0D1B3E` 填充 | `#FAFBFC` 极淡灰填充 |
| 节点（普通） | `#5C6BC0` 发光圆 | `#5C6BC0` 实心圆 + 白色描边 |
| 节点（核心/已激活） | `#FFD54F` 金色光晕 | `#FFD700` 实心金圆 + 白描边 |
| 连线 | `rgba(93,107,192,0.3)` 虚线 | `rgba(93,107,192,0.25)` 实线/虚线 |
| 星芒射线 | `rgba(255,255,255,0.15)` | 移除或用极淡蓝 `rgba(92,107,192,0.08)` |
| 文字标签 | `#FFFFFF` | `#3D3D5C` |

**理由**：白底上的深色节点更符合传统知识图谱的视觉隐喻（如思维导图）；移除发光效果避免在白底上显得刺眼。

### D7: BottomTabBar 改造 — 白底 + 彩色图标

**决策**：
- 背景：`#FFFFFF` + 顶部阴影分割线（`rgba(0,0,0,0.06)`）
- 未选中图标：`#9E9EB8`
- 选中图标：`#5C6BC0`（主色）
- 选中文字：`#5C6BC0`
- 未选中文字：`#9E9EB8`
- 可选：选中项添加极淡背景高亮 `rgba(92,107,192,0.08)`

### D8: 对话框组件 — 白色模态

**决策**：CreateCourseDialog / DeleteConfirmDialog 统一为：
- 背景遮罩：`rgba(0,0,0,0.4)` （比原深色遮罩更深，白底需要更强对比）
- 对话框本体：`#FFFFFF` 圆角 20vp + 阴影
- 标题：`#1A1A2E` 18sp 加粗
- 内容：`#3D3D5C` 14sp
- 按钮：保持主色渐变（`#5C6BC0→#3949AB`），取消按钮改为 `#7B7B94`

## Risks / Trade-offs

| 风险 | 缓解措施 |
|------|---------|
| [性能] 20+ 文件批量修改可能导致回归 Bug | 按 Page → Component → Dialog 顺序逐个修改，每步编译验证 |
| [视觉] Canvas 白底配色可能不够美观 | 先做 KnowledgeGraph 一个页面的原型，用户确认后再推广到其他 Canvas |
| [遗漏] 新增页面可能忘记设白色主题 | D1 的全局锁已解决此问题，新增页面自动继承 Light Mode |
| [一致性] 不同开发者对"白色"的理解可能有偏差 | 本文档 D2/D3/D4 定义了精确色值表，作为唯一权威参考 |
| [DynamicBackground] 装饰元素可能在白底上不可见 | 降低使用频率，仅在 HomePage/LearningHome 使用，其他页面直接纯白 |

## Migration Plan

1. **Phase 1 — 全局锁**：修改 EntryAbility.ets，添加 `setColorMode(ColorMode.LIGHT)`
2. **Phase 2 — 核心页面迁移**（按优先级）：
   - HomePage.ets（仪表盘，用户最常看）
   - LearningHome.ets（课程列表，次常看）
   - LearningSpace.ets（三问学习，核心功能）
   - KnowledgeGraph.ets（知识图谱，Canvas 重绘）
3. **Phase 3 — 子组件迁移**（按依赖关系）：
   - DynamicBackground.ets → CourseCard.ets → StatsCard/BadgeItem/SettingRow
   - TodayCard/DailyQuestion/QuickActions/WeeklyStats/DiscoverSection/GreetingHeader
   - DebateCard/ChatBubble/ManualInputBox/ThreeAskStepper
   - BottomTabBar/CreateCourseDialog/DeleteConfirmDialog
4. **Phase 4 — 次要页面**：Assessment.ets / AssessmentResult.ets
5. **Phase 5 — Canvas 组件**：RadarChart.ets / PuzzleFragmentAnim.ets（如有）
6. **验证**：全页面截图对比，确认无残留深色元素

**回滚策略**：Git 分支 `feature/white-theme-lock`，可随时 `git checkout` 回退到深色主题。

## Open Questions

1. **KnowledgeGraph 白底星图是否需要保留连线动画？** — 建议：保留但降低透明度
2. **是否需要在设置页添加"主题切换"开关预留？** — 当前不做，但代码结构上预留扩展点（如将色值提取为 ThemeToken 常量文件）
3. **DynamicBackground 是否完全移除还是改造？** — 决策为改造（见 D5），但如果用户觉得多余可以后续移除
