## Context

### 当前状态

LearningSpace（Q2 争议分析页面）是用户进入课程后的核心学习界面。当前存在以下问题：

1. **AIService 未初始化（阻断性 Bug）**：EntryAbility.ets 中仅调用了 `Logger.init()` 和 `RdbHelper.init()`，**从未调用 `AIService.init(context)`**。导致所有 AI 方法在检查 `!this.context` 时抛出 `"AIService not initialized: call init(context) first"` 错误。
2. **无课程标题显示**：页面顶部仅显示通用标题"为什么 — 争议分析 Q2"，无法体现当前学习的具体课程名称
3. **内容需手动触发**：进入页面后 AIChatPanel 显示空状态欢迎语，用户必须手动点击按钮才能生成/检索内容

### 约束

- HarmonyOS NEXT API 12+，ArkTS 声明式 UI
- 单文件 ≤300 行
- 仅 @ohos.net.http，禁止第三方网络库
- 复用现有 material 表存储 AI 生成内容
- 不改变数据库表结构

## Goals / Non-Goals

**Goals:**
- 修复 AIService 初始化缺失的阻断性 Bug
- LearningSpace 顶部展示当前课程名称 + 三问进度
- 进入学习页面时自动预加载已有素材并渲染到界面
- AI 功能可用时自动触发一次知识摘要预请求

**Non-Goals:**
- 不修改 HomePage / LearningHome / ProfilePage 的 UI
- 不新增数据库表或 ALTER TABLE
- 不实现后台推送/离线缓存等复杂机制
- 不改造三问流程本身的业务逻辑

## Decisions

### D1: AIService 初始化入口 — 在 EntryAbility.onCreate 中调用

| 选择 | 方案 | 理由 |
|------|------|------|
| **采用** | EntryAbility.onCreate() 中添加 `AIService.getInstance().init(this.context)` | 与 Logger/RdbHelper 初始化保持一致，应用启动时一次性完成 |
| 放弃 | 懒初始化（首次使用时 init） | 需要在每个调用点加 guard，容易遗漏；且 context 在 Ability 层最易获取 |

### D2: 课程标题栏 — 新建 CourseTitleBar 组件

| 选择 | 方案 | 理由 |
|------|------|------|
| **采用** | 独立 CourseTitleBar 组件，接收 courseName/currentStep 参数 | 符合组件化原则；可复用于 Q1/Q3 页面 |
| 放弃 | 直接在 LearningSpace build() 内联 | LearningSpace 已 486 行，不能再膨胀 |

CourseTitleBar 布局：
```
┌─────────────────────────────────────┐
│ [←]  量子力学          [⚙️] [📊]   │  ← 标题行：课程名 + 操作图标
│ ───────────────────────────────── │
│  ①是什么 → ②为什么 → ③怎么用      │  ← 三问步骤条（复用 ThreeAskStepper）
└─────────────────────────────────────┘
```

### D3: 内容预加载策略 — onPageShow 触发两阶段加载

| 阶段 | 动作 | 数据源 | 耗时 |
|------|------|--------|------|
| **阶段1（同步）** | 从 material 表读取已缓存的素材 | 本地 RdbStore | <50ms |
| **阶段2（异步）** | 若阶段1 无缓存，发起 AI 知识摘要预请求 | 网络 SSE | 3-15s |

关键设计：**阶段1 立即渲染已有内容，阶段2 后台填充新内容**。不阻塞页面渲染。

### D4: AIChatPanel 空状态改造 — 条件渲染

```
有缓存素材时:  [素材卡片列表] (ContentPreviewCard × N)
无缓存且未加载中: [欢迎语 + 快捷模式选择]
加载中: [Skeleton 加载动画]
加载失败: [错误提示 + 重试按钮]
```

### D5: ChatViewModel.preloadContent() 方法

新增方法，在 switchCourse 完成后自动调用：
```typescript
async preloadContent(courseId: string): Promise<void> {
  // 1. 查询 material 表中该课程的已有素材
  // 2. 将素材转为 ChatDisplayMessage 格式追加到 messages
  // 3. 若无素材，可选触发 AI 预请求（由调用方决定）
}
```

## Risks / Trade-offs

| 风险 | 影响 | 缓解措施 |
|------|------|---------|
| AIService.init() 增加 App 启动时间 | 冷启动慢 ~10ms | init() 仅赋值 context + 异步 ensureApiKeyStored，几乎无阻塞 |
| 预加载增加首屏数据量 | 内存占用略增 | LazyForEach 渲染 + 分页（material 通常 <10 条） |
| 自动预请求消耗 API 配额 | 用户未主动操作就产生费用 | 仅在有缓存时跳过预请求；添加开关控制 |
| CourseTitleBar 占用屏幕空间 | 内容区域变小 | 高度控制在 88vp 以内，与原 Stepper 区域合并而非叠加 |
