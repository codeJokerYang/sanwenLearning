# 三问高效学习机 — UI 路由与状态管理约定

> 版本：v1.0 | 日期：2026-06-05 | 所有 UI 架构必须严格遵循本约定

---

## 1. 核心页面清单

| 页面 | 路由路径 | 职责 | 关键组件 |
|------|---------|------|---------|
| 首页（课程列表） | `/pages/Index` | 展示课程卡片列表，新建/删除课程入口 | `List` + `CourseCard` |
| 课程详情页 | `/pages/CourseDetail` | 承载三问 Stepper 流程，知识图谱渲染 | `Stepper` + `KnowledgeGraph` + `ManualInputBox` |
| 设置页 | `/pages/Settings` | API Key 配置、日志导出、关于信息 | `Column` + 表单项 |

**页面关系**：

```
首页（课程列表）
  │
  ├── 点击课程卡片 → 课程详情页
  │                     │
  │                     └── 三问 Stepper（Q1 → Q2 → Q3）
  │
  └── 设置入口 → 设置页
```

---

## 2. 路由跳转硬性规则

### 2.1 严禁 router.back 带复杂参数

```typescript
// ❌ 严禁
router.back({ url: 'pages/Index', params: { deletedCourseId: 'xxx', refreshList: true } })

// ✅ 正确：back 不带参数，目标页在 onPageShow 中自行刷新
router.back()
```

**原因**：`router.back` 的 `params` 在部分鸿蒙版本上存在序列化丢失和内存泄漏风险。目标页的数据刷新应通过 `onPageShow` 生命周期回调中重新查询数据库实现。

### 2.2 删除课程后必须 back 回首页

```typescript
// 删除课程后的路由处理
async function onCourseDeleted(context: Context): Promise<void> {
  // 1. 级联删除数据（遵循 FEATURE_RULES 第5节）
  await deleteCourseCascade(courseId)

  // 2. 必须返回首页，不得停留在已删除课程的详情页
  router.back()

  // 3. 首页在 onPageShow 中重新加载课程列表
}
```

**硬性约束**：
- 删除课程后，**严禁**留在课程详情页
- **严禁**使用 `router.replaceUrl` 跳转其他页面（会导致导航栈混乱）
- **严禁**在 `router.back` 后通过全局变量传递删除结果

### 2.3 路由参数传递规范

| 场景 | 传参方式 | 示例 |
|------|---------|------|
| 首页 → 课程详情 | `router.pushUrl` 携带 `courseId` | `{ courseId: 'xxx' }` |
| 课程详情 → 首页 | `router.back()`，不带参数 | — |
| 首页 → 设置页 | `router.pushUrl`，无参数 | — |
| 设置页 → 首页 | `router.back()`，不带参数 | — |

**参数传递红线**：
- 路由参数仅允许基本类型（`string`、`number`、`boolean`）
- **严禁**传递对象、数组等复杂类型
- **严禁**通过路由参数传递业务数据（应从数据库查询）

---

## 3. ArkUI 状态管理分层

### 3.1 装饰器适用场景

| 装饰器 | 适用场景 | 数据流向 | 典型用途 |
|--------|---------|---------|---------|
| `@State` | 组件内部私有状态 | 组件内双向 | 输入框文本、开关状态、加载标志 |
| `@Prop` | 父→子单向传递（值拷贝） | 父→子 | 课程卡片中的课程名称、进度值 |
| `@Link` | 父↔子双向绑定（引用） | 父↔子 | Stepper 当前步骤索引、表单字段 |
| `@Provide` / `@Consume` | 跨层级共享（祖先→后代） | 祖先↔后代 | 课程 ID、全局主题色 |
| `@ObjectLink` | 观测类对象属性变化 | 父↔子 | 知识节点对象、题目对象 |

### 3.2 严禁场景

#### 严禁 1：深层对象监听丢失

```typescript
// ❌ 严禁：@State 无法观测嵌套对象属性变化
@State course: Course = new Course()
// this.course.q1_activated_count = 5  ← 不会触发 UI 刷新！

// ✅ 正确方案 A：使用 @ObjectLink + @Observed 类
@Observed
class Course {
  q1_activated_count: number = 0
}

@Component
struct CourseDetail {
  @ObjectLink course: Course
  // this.course.q1_activated_count = 5  ← 触发 UI 刷新
}

// ✅ 正确方案 B：整体替换 @State 对象
@State course: Course = new Course()
// this.course = { ...this.course, q1_activated_count: 5 }  ← 触发 UI 刷新
```

#### 严禁 2：Canvas 重渲染死循环

```typescript
// ❌ 严禁：Canvas 的 onDraw 回调中读取 @State 变量
@State nodes: KnowledgeNode[] = []

Canvas(this.context)
  .onDraw(() => {
    // 读取 this.nodes → 若 nodes 变化触发重渲染 → onDraw 再次执行 → 死循环
    for (const node of this.nodes) { ... }
  })

// ✅ 正确：Canvas 使用组件私有变量绘制，@State 变化时手动触发重绘
private drawNodes: KnowledgeNode[] = []

build() {
  Canvas(this.context)
    .onReady(() => {
      this.drawGraph()
    })
}

// @State 变化时，显式调用重绘
onNodesChanged() {
  this.drawNodes = [...this.nodes]  // 拷贝到私有变量
  this.context.invalidate()         // 手动触发 Canvas 重绘
}
```

#### 严禁 3：@Link 滥用

```typescript
// ❌ 严禁：仅用于展示、不需要回传数据的场景使用 @Link
@Component
struct CourseCard {
  @Link courseName: string  // 卡片仅展示，无需回传
}

// ✅ 正确：仅展示场景使用 @Prop
@Component
struct CourseCard {
  @Prop courseName: string
}
```

### 3.3 状态管理决策树

```
需要状态管理？
  │
  ├── 仅组件内部使用 → @State
  │
  └── 需要跨组件传递
        │
        ├── 父→子，子不需要回传 → @Prop
        │
        ├── 父↔子，子需要回传 → @Link
        │
        ├── 跨多层传递 → @Provide / @Consume
        │
        └── 需要观测对象属性变化 → @ObjectLink + @Observed
```
