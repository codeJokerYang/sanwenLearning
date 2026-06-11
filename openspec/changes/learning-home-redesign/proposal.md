## Why

当前学习页（LearningHome）存在两个关键 UX 问题：

1. **功能按钮重叠**：右下角同时存在"新建课程"FAB（`position: right:16, bottom:28`）和"AI 对话"FAB（`position: x:'80%', y:'90%'`），两者在视觉上严重重叠，导致用户难以准确点击目标按钮，且界面显得杂乱无章。
2. **搜索栏不固定**：搜索栏位于 `Scroll()` 内部，当用户向下滚动浏览课程列表时，搜索栏会随内容一起滚出屏幕顶部。用户若要重新搜索必须先滚回顶部，操作路径冗余。

截图清晰显示：FAB 和 AI 按钮在底部右侧几乎完全叠在一起，严重影响可用性。

## What Changes

- **分离 FAB 与 AI 按钮**：将"新建课程"FAB 移至更合理的位置（如搜索栏右侧或标题栏内嵌），将 AI ChatFab 固定在独立位置（如底部导航栏上方或右下角独立区域），确保两个按钮视觉分离、互不遮挡
- **搜索栏吸顶固定**：将搜索栏从 Scroll 内部提取到固定区域，使用 `Stack` + `position` 或 `List` 的 `sticky` 属性实现滚动时搜索栏始终可见
- **保持所有现有功能不变**：课程列表 CRUD、搜索过滤、AI 对话、删除确认、创建课程对话框等全部保留原有逻辑

### 布局变更示意

**当前布局（问题状态）**：
```
┌──────────────────────┐
│ Header (品牌+计数+设置) │ ← 在 Scroll 内
│ SearchBar             │ ← 在 Scroll 内，滚动消失
│ ──────────────────── │
│ 我的课程 N门          │
│ [CourseCard]          │
│ [CourseCard]          │
│ ...                   │
│                       │
│              [+ 新建]  │ ← FAB right:16 bottom:28
│           [🤖 AI]     │ ← AIChatFab x:80% y:90%  ⚠️ 重叠!
│ [TabBar]              │
└──────────────────────┘
```

**目标布局（修复后）**：
```
┌──────────────────────┐
│ Header (品牌+计数) [⚙️][+]│ ← 固定顶栏，新建按钮内嵌
├──────────────────────┤
│ 🔍 搜索课程...        │ ← Sticky 吸顶，始终可见
├──────────────────────┤
│ 我的课程 N门          │
│ [CourseCard]          │
│ [CourseCard]          │
│ ...                   │
│                       │
│           [🤖 AI]     │ ← 独立位置，不与任何元素重叠
│ [TabBar]              │
└──────────────────────┘
```

## Capabilities

### New Capabilities
- `learning-home-layout`: 学习页布局重构 — FAB/AI 分离 + 搜索栏吸顶

### Modified Capabilities
- （无现有 spec 需修改）

## Impact

- **主要修改文件**：
  - `entry/src/main/ets/pages/LearningHome.ets` — 核心布局重构（唯一需要改动的文件）
- **涉及组件（不改代码，仅调整位置/父容器）**：
  - `AIChatFab.ets` — 调整 position 参数
  - `AIChatPanel.ets` — 无变化
  - `CourseCard.ets` — 无变化
  - `BottomTabBar.ets` — 无变化
  - `DynamicBackground.ets` — 无变化
- **风险点**：
  - FAB 从绝对定位改为内联可能影响 BottomTabBar 遮挡关系 → 需增加底部安全距
  - SearchBar 提取为固定层需注意 z-index 与 Scroll 内容的层级关系
  - AIChatFab 位置调整后需验证展开动画不受影响
