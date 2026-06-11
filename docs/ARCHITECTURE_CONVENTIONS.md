# 三问高效学习机 — 组件化与分层架构约束

> 版本：v1.0 | 日期：2026-06-05 | 所有代码组织必须严格遵循本规范

---

## 1. 目录结构约定

### 1.1 顶层目录

```
entry/src/main/ets/
├── common/                     # 公共工具模块
│   ├── constants.ets           # 全局常量（API_URL、阈值、枚举映射等）
│   ├── Config.ets              # 环境配置（开发/生产切换）
│   ├── Logger.ets              # 统一日志工具
│   ├── EventBus.ets            # 全局事件总线
│   └── utils.ets               # 通用工具函数（safeParseJsonArray、escapeRegExp 等）
│
├── models/                     # 纯数据模型层（无方法实现）
│   └── Models.ets              # 全部 interface / enum 定义（与 DATA_CONTRACT.md 一一对应）
│
├── db/                         # 数据持久层
│   ├── init.sql                # 建表脚本（8 表 + 9 索引）
│   └── RdbHelper.ets           # RdbStore 封装（CRUD / 事务 / 类型转换）
│
├── services/                   # 服务层（单一业务域）
│   ├── CourseService.ets       # 课程 CRUD + 级联删除
│   ├── AIService.ets           # AI 请求 + SSE + Prompt 构建
│   ├── SSEStreamParser.ets     # SSE 流解析器（两阶段 + 缓冲防护）
│   ├── AIConcurrencyLock.ets   # AI 并发锁
│   ├── GlobalRateLimiter.ets   # 全局限流器
│   ├── NetworkMonitor.ets      # 网络状态监听
│   ├── EvaluationService.ets   # 评价报告生成 + 导出
│   ├── FilePoolService.ets     # 文件选择 + 沙箱存储
│   ├── MaterialParser.ets      # PDF/Markdown 解析
│   └── ApiKeyStore.ets         # API Key 加密存储（HUKS）
│
├── viewmodels/                 # ViewModel 层（页面级状态 + 业务编排）
│   ├── HomeViewModel.ets       # 首页状态管理
│   ├── CourseViewModel.ets     # 课程详情状态管理
│   ├── ThreeAskViewModel.ets   # 三问流程编排
│   └── EvaluationViewModel.ets # 评价报告状态管理
│
├── components/                 # 可复用 UI 组件
│   ├── CourseCard.ets          # 课程卡片
│   ├── ProgressBar.ets         # 进度条
│   ├── ThreeAskStepper.ets     # 三问步骤条
│   ├── ThreeAskIndicator.ets   # 三问指示器
│   ├── ManualInputBox.ets      # 手动输入框（禁粘贴 + 速度检测）
│   ├── ChatBubble.ets          # AI 对话气泡（逐字渲染）
│   ├── DebateCard.ets          # 争议分析卡片（左右分栏）
│   ├── RadarChart.ets          # 能力雷达图（Canvas）
│   ├── AIRecommendBtn.ets      # AI 推荐提问按钮
│   ├── PuzzleFragmentAnim.ets  # 碎片动画
│   └── MindBadgeAnim.ets       # 勋章动画
│
├── pages/                      # 页面入口（仅 UI 渲染 + 事件分发）
│   ├── HomePage.ets            # 首页
│   ├── LearningSpace.ets       # 学习空间（Q2 主页面）
│   ├── KnowledgeGraph.ets      # 知识图谱（Q1 主页面）
│   ├── Assessment.ets          # 深度测评（Q3 主页面）
│   └── AssessmentResult.ets    # 评价报告
│
└── entryability/
    └── EntryAbility.ets        # 应用入口（冷启动初始化）
```

### 1.2 目录红线

| 规则 | 说明 |
|------|------|
| `pages/` 严禁放业务逻辑 | 页面文件只做 UI 渲染 + 调用 ViewModel 方法，严禁直接调用 Service |
| `components/` 严禁调用 Service | 组件只通过 `@Link` / 回调函数与父组件通信，不直接访问数据层 |
| `viewmodels/` 严禁导入 UI 组件 | ViewModel 不知道 UI 的存在，只管理状态和调用 Service |
| `services/` 严禁导入 `@State` | Service 返回数据，由 ViewModel 赋值给 `@State` |
| `models/` 严禁包含方法 | 纯数据定义，所有逻辑在 Service / ViewModel 中 |

---

## 2. 分层调用规则

### 2.1 调用方向（严禁逆向）

```
Pages ──→ ViewModels ──→ Services ──→ RdbHelper
  │            │              │            │
  │            │              └──→ Models（接口定义）
  │            └──→ Models
  └──→ Components（@Builder / 子组件）
```

**严禁的调用方向**：

```
❌ Pages ──→ Services       （跨层调用）
❌ Pages ──→ RdbHelper      （跨层调用）
❌ Components ──→ Services  （组件直接访问数据层）
❌ ViewModels ──→ Pages     （逆向依赖）
❌ Services ──→ ViewModels  （逆向依赖）
❌ Services ──→ @State      （Service 不感知 UI 状态）
```

### 2.2 各层职责边界

| 层 | 职责 | 允许导入 | 严禁导入 |
|---|------|---------|---------|
| **Pages** | UI 渲染 + 事件分发 | ViewModels, Components, Models | Services, RdbHelper |
| **Components** | 可复用 UI 片段 | Models（仅类型） | ViewModels, Services, RdbHelper |
| **ViewModels** | 状态管理 + 业务编排 | Services, Models | Pages, Components |
| **Services** | 单一业务域数据操作 | RdbHelper, Models | Pages, Components, ViewModels |
| **RdbHelper** | 数据库 CRUD 封装 | Models | Pages, Components, ViewModels, Services 之外的一切 |
| **Models** | 纯数据定义 | 无 | 所有其他模块 |

### 2.3 跨层通信方式

| 通信方向 | 通信方式 | 示例 |
|---------|---------|------|
| Page → ViewModel | 方法调用 | `this.viewModel.loadCourses()` |
| ViewModel → Page | `@State` 驱动渲染 | `@State courseList: Course[]` 变化触发 UI 更新 |
| Page → Component | `@Prop` / `@Link` 传递数据 | `<CourseCard course={item} />` |
| Component → Page | 回调函数 | `onCardClick: (id: string) => void` |
| ViewModel → Service | 方法调用 + `Promise` 返回 | `await this.courseService.getCourses()` |
| Service → ViewModel | `Promise<T>` 返回值 | `return courses` |
| ViewModel → ViewModel | `EventBus` 事件 | 课程删除后通知首页刷新 |

---

## 3. 组件化规则

### 3.1 组件拆分原则

| 原则 | 说明 |
|------|------|
| **单一职责** | 每个 `@Component` 只负责一个 UI 片段 |
| **300 行红线** | 单个 `@Component` 文件严禁超过 300 行（含 import / 类型 / 样式） |
| **可复用优先** | 出现 2 次以上的 UI 片段必须提取为独立组件 |
| **状态最小化** | 组件内部 `@State` 仅管理自身 UI 状态（如展开/折叠），业务数据通过 `@Prop` / `@Link` 传入 |

### 3.2 组件通信模式

```
┌─────────────────────────────────────────────────┐
│                  Page（页面）                     │
│  @State courseList: Course[]                     │
│  @State isLoading: boolean                       │
│                                                  │
│  ┌─────────────────────────────────────────┐    │
│  │  ForEach(courseList) {                   │    │
│  │    CourseCard({                          │    │
│  │      course: $item,        // @Prop      │    │
│  │      onCardClick: (id) => {  // 回调     │    │
│  │        this.viewModel.deleteCourse(id)   │    │
│  │      }                                   │    │
│  │    })                                    │    │
│  │  }                                       │    │
│  └─────────────────────────────────────────┘    │
└─────────────────────────────────────────────────┘
```

**数据流向**：`ViewModel.@State` → `Page.@State` → `Component.@Prop`（单向数据流）

**事件流向**：`Component.回调` → `Page.方法` → `ViewModel.方法` → `Service.方法`

### 3.3 组件分类

| 分类 | 命名规范 | 状态管理 | 示例 |
|------|---------|---------|------|
| **展示型组件** | 名词，如 `CourseCard` | 仅 `@Prop`，无 `@State` | `ProgressBar`, `RadarChart` |
| **交互型组件** | 动名/名动，如 `ManualInputBox` | `@Prop` + 内部 `@State` | `ManualInputBox`, `DebateCard` |
| **容器型组件** | 页面级，如 `HomePage` | `@State` + ViewModel | `LearningSpace`, `Assessment` |
| **动画型组件** | `XxxAnim`，如 `PuzzleFragmentAnim` | 内部 `@State` 控制动画状态 | `PuzzleFragmentAnim`, `MindBadgeAnim` |

### 3.4 @State 使用红线

| 规则 | 说明 |
|------|------|
| **严禁在 Service 中使用 @State** | Service 返回 `Promise<T>`，由 ViewModel 赋值给 `@State` |
| **严禁跨组件共享 @State** | 跨组件共享状态使用 `@Provide` / `@Consume` 或 ViewModel |
| **@State 大对象上限** | 单个 `@State` 变量严禁超过 1MB，大列表使用 LazyForEach + 分页 |
| **@State 嵌套深度** | `@State` 对象嵌套层级不超过 3 层，深层嵌套使用扁平化结构 |
| **@Watch 谨慎使用** | `@Watch` 仅用于派生状态计算，严禁在 `@Watch` 中发起网络请求 |

---

## 4. ViewModel 规则

### 4.1 ViewModel 职责

```typescript
// ✅ 正确的 ViewModel 示例
class ThreeAskViewModel {
  // 1. 持有页面级状态
  @State currentStep: number = 0
  @State nodes: KnowledgeNode[] = []
  @State isLoading: boolean = false
  @State errorMessage: string = ''

  // 2. 编排业务流程（调用 Service）
  async activateNode(courseId: string, nodeId: string): Promise<void> {
    this.isLoading = true
    try {
      await this.courseService.updateNodeActivation(nodeId, true)
      const course = await this.courseService.getCourseById(courseId)
      this.currentStep = course.current_step
      this.nodes = await this.courseService.getNodes(courseId)
    } catch (e) {
      this.errorMessage = e.message
    } finally {
      this.isLoading = false
    }
  }

  // 3. 计算派生状态
  getQ1Progress(): number {
    if (this.q1TotalCoreCount === 0) return 0
    return Math.round((this.q1ActivatedCount / this.q1TotalCoreCount) * 33)
  }
}
```

### 4.2 ViewModel 红线

| 规则 | 说明 |
|------|------|
| **严禁导入 UI 组件** | ViewModel 不知道 `CourseCard`、`ManualInputBox` 的存在 |
| **严禁直接操作 DOM/Canvas** | 所有渲染逻辑在 Page / Component 层 |
| **异步操作必须 try-catch** | Service 调用必须包裹 try-catch，错误写入 `errorMessage` |
| **Loading 状态必须管理** | 异步操作前 `isLoading = true`，finally 中 `isLoading = false` |

---

## 5. Service 规则

### 5.1 Service 职责

```typescript
// ✅ 正确的 Service 示例
class CourseService {
  private rdbHelper: RdbHelper

  // 返回 Promise<T>，不感知 UI
  async getCourses(): Promise<Course[]> {
    const resultSet = await this.rdbHelper.query('SELECT * FROM course ORDER BY create_time DESC')
    const courses: Course[] = []
    while (resultSet.goToNextRow()) {
      courses.push(this.mapToCourse(resultSet))
    }
    resultSet.close()
    return courses
  }

  // 事务操作
  async cascadeDeleteCourse(courseId: string): Promise<void> {
    await this.rdbHelper.executeInTransaction(async () => {
      await this.rdbHelper.execute('DELETE FROM ai_request_log WHERE course_id = ?', [courseId])
      await this.rdbHelper.execute('DELETE FROM question_record WHERE course_id = ?', [courseId])
      // ... 其余删除步骤
      await this.rdbHelper.execute('DELETE FROM course WHERE id = ?', [courseId])
    })
  }
}
```

### 5.2 Service 红线

| 规则 | 说明 |
|------|------|
| **严禁持有 @State** | Service 不感知 UI 状态，只返回数据 |
| **严禁直接操作 UI** | 不弹 Toast、不跳转路由，由 ViewModel / Page 负责 |
| **必须返回 Promise** | 所有异步方法返回 `Promise<T>`，调用方自行处理异常 |
| **数据库操作必须参数化** | SQL 使用 `?` 占位符，严禁字符串拼接 |
| **事务操作必须包裹** | 级联删除等多步写操作必须使用事务 |

---

## 6. 页面规则

### 6.1 页面职责

```typescript
// ✅ 正确的页面示例
@Entry
@Component
struct HomePage {
  // 1. 持有 ViewModel
  private viewModel: HomeViewModel = new HomeViewModel()

  // 2. 生命周期
  aboutToAppear() {
    this.viewModel.loadCourses()
  }

  // 3. UI 渲染 + 事件分发
  build() {
    Column() {
      if (this.viewModel.isLoading) {
        LoadingIndicator()
      } else {
        List() {
          ForEach(this.viewModel.courseList, (item: Course) => {
            CourseCard({
              course: item,
              onCardClick: (id: string) => this.viewModel.selectCourse(id),
              onDeleteClick: (id: string) => this.confirmDelete(id)
            })
          })
        }
      }
    }
  }

  // 4. 用户交互确认（UI 层职责）
  private confirmDelete(courseId: string): void {
    AlertDialog.show({
      message: '确认删除该课程？',
      primaryButton: { value: '取消' },
      secondaryButton: {
        value: '删除',
        action: () => this.viewModel.deleteCourse(courseId)
      }
    })
  }
}
```

### 6.2 页面红线

| 规则 | 说明 |
|------|------|
| **严禁直接调用 Service** | 必须通过 ViewModel 中转 |
| **严禁直接操作数据库** | 必须通过 ViewModel → Service → RdbHelper |
| **build() 严禁复杂计算** | 复杂计算在 ViewModel 中提前完成，build() 只做条件渲染 |
| **生命周期必须管理** | `aboutToAppear` 加载数据，`onDisappear` 释放资源 |

---

## 7. 新增文件检查清单

每次新增 `.ets` 文件时，必须通过以下检查：

| 检查项 | 检查方式 | 违规等级 |
|--------|---------|---------|
| 文件放置目录正确 | Page → pages/, Component → components/, 等 | P0 |
| 无逆向依赖 | 检查 import 是否违反分层规则 | P0 |
| 单文件不超过 300 行 | 行数统计 | P0 |
| 无 @State 跨层使用 | Service/RdbHelper 中无 @State | P0 |
| 异步操作有 try-catch | ViewModel/Service 中异步方法 | P1 |
| Loading 状态已管理 | 异步操作前后 isLoading 切换 | P1 |
| 组件通过回调通信 | 无直接调用父组件方法 | P1 |
