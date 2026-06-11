## Context

LearningHome（学习页）是应用的核心页面之一，承担课程列表展示、搜索、新建/删除课程、AI 对话等功能。当前采用 `Stack` 多层布局：

- Layer 1: DynamicBackground（深色渐变背景）
- Layer 2: Scrim（半透明遮罩）
- Layer 3: Scroll（内容区：Header + SearchBar + 课程列表）
- 浮层: FAB（新建）+ AIChatFab + AIChatPanel + BottomTabBar

**两个关键 UX 缺陷**：
1. FAB（`right:16, bottom:28`）与 AIChatFab（`x:'80%', y:'90%'`）在右下角视觉重叠
2. 搜索栏在 Scroll 内部，滚动时消失

**技术约束**：HarmonyOS NEXT API 12+，ArkTS 声明式 UI，单文件 ≤300 行。

## Goals / Non-Goals

**Goals:**
1. FAB（新建课程）与 AI ChatFab 在视觉和操作上完全独立，无任何重叠
2. 搜索栏在页面滚动时始终固定在顶部可见
3. 所有现有功能（CRUD、搜索、AI 对话、对话框等）保持不变
4. 文件行数不超过 300 行

**Non-Goals:**
1. 不改变深色主题色彩体系（仅调整布局位置）
2. 不修改 CourseCard / AIChatPanel / BottomTabBar 等子组件内部实现
3. 不引入新的第三方依赖或组件库

## Decisions

### D1: FAB 改为 Header 内嵌按钮 — 移除绝对定位 FAB

**决策**：将"新建课程"FAB 从 `position({ right:16, bottom:28 })` 的绝对定位浮层，改为嵌入到顶部 Header 行右侧的圆形图标按钮。

**新 Header 结构**：
```
Row {
  [品牌标题 + 副标题]    layoutWeight(1)
  [课程计数圆]            36x36
  [设置按钮 ⚙️]           36x36, margin-left:8
  [新建按钮 +]            36x36, margin-left:8, 主色渐变背景
}
```

**理由**：
- 彻底消除与 AIChatFab 的重叠问题
- 符合移动端设计惯例（如微信"+"在右上角）
- 用户无需伸手到屏幕最底部操作高频的新建功能
- Header 区域空间充足（当前只有计数圆 + 设置按钮）

**替代方案对比**：
| 方案 | 优点 | 缺点 |
|------|------|------|
| **Header 内嵌 + 按钮（选中）** | 无重叠，符合惯例 | Header 变宽需注意 |
| FAB 上移至 bottom:80 | 改动最小 | 可能仍与 TabBar 或 AI 重叠 |
| FAB 改为 mini 圆形 | 节省空间 | 点击目标过小 <44vp |

### D2: 搜索栏吸顶 — Stack 分层方案

**决策**：使用 `Stack` 分层将搜索栏提升为固定层。具体结构：

```
Stack {
  // Layer 0: 背景（DynamicBackground + Scrum）— 保持不变
  
  // Layer 1: 固定顶栏区域（新增 Column）
  Column {
    Row { /* Header: 品牌 + 计数 + 设置 + 新建 */ }
    Row { /* SearchBar */ }
  }
  .position({ top: 0, left: 0 })   // 固定顶部
  .width('100%')
  
  // Layer 2: 可滚动内容区（Scroll）
  Scroll {
    Column {
      // "我的课程 N门" 标题栏
      // 课程列表 List / Empty / Error / Loading
      Blank().height(120)  // 顶部留白避免被固定栏遮挡
    }
  }
  .width('100%').height('100%')
  
  // Layer 3: AI ChatFab — 调整位置
  AIChatFab.position({ right: 16, bottom: 88 })  // TabBar 上方
  
  // Layer 4: BottomTabBar — 保持不变
}
```

**理由**：
- ArkUI 没有 CSS `position:sticky`，但 `Stack` + `position` 可实现同等效果
- 固定层和滚动层分离清晰，易于维护
- 搜索栏始终可见，用户可随时搜索

**替代方案**：
| 方案 | 优点 | 缺点 |
|------|------|------|
| **Stack 分层（选中）** | 实现简单，兼容性好 | 需手动管理 z-index |
| List sticky 属性 | 原生支持 | HarmonyOS API 12 List sticky 支持有限 |
| 自定义 ScrollView 回调 | 精确控制 | 复杂度高，性能开销大 |

### D3: AIChatFab 位置调整 — 右下角独立区域

**决策**：将 AIChatFab 从 `{ x:'80%', y:'90%' }`（百分比定位，易重叠）改为 `{ right: 16, bottom: 88 }`（绝对定位，TabBar 正上方）。

**理由**：
- 百分比定位在不同屏幕尺寸下位置不固定
- `bottom: 88` 确保 AI 按钮在 TabBar（高度 ~56vp + 安全区）上方
- 与原 FAB 位置错开（FAB 已移入 Header），不再冲突
- 保持右下角的快捷访问习惯

### D4: 滚动内容顶部安全距

**决策**：Scroll 内容区的第一个元素前添加 `Blank().height(120)`（约 Header 高度 76 + SearchBar 高度 44），确保滚动到顶部时内容不被固定顶栏遮挡。

## Risks / Trade-offs

| 风险 | 缓解措施 |
|------|---------|
| Header 内嵌新建按钮后宽度溢出 | 使用紧凑尺寸（36x36 圆形按钮，只显示 "+" 图标），文字提示用 tooltip 或长按显示 |
| 固定顶栏遮挡课程列表首屏内容 | Scroll 内容添加 120vp 顶部留白 |
| AIChatFab position 从百分比改为绝对值后在大屏设备上位置偏差 | 使用 vp 单位自适应；或改用 `.align(Alignment.BottomEnd)` + margin |
| 单文件可能超 300 行 | 将 Header 区域提取为 `@Builder` 方法减少 build() 内代码量 |

## Open Questions

1. **空状态下的"创建第一门课程"按钮如何处理？** → 保留空状态内的 CTA 按钮不变，Header 内嵌的"+"按钮作为辅助入口
2. **是否需要给 Header 新建按钮加 tooltip？** → 建议不加（"+" 是通用约定），但可考虑长按震动反馈
