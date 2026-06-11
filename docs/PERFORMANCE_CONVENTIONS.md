# 三问高效学习机 — 性能与内存监控约束

> 版本：v1.0 | 日期：2026-06-05 | 所有性能与内存相关实现必须严格遵循本规范

---

## 1. 渲染性能

### 1.1 知识图谱渲染

| 约束项 | 阈值 | 说明 |
|--------|------|------|
| 力导向布局迭代上限 | 200 次 | 超过即停止，使用当前坐标 |
| 图谱渲染帧率 | ≥30fps（50+ 节点） | 低于此值触发降级 |
| 一次性 @State 更新 | 力导向计算完毕后 | 严禁迭代过程中更新 @State |
| Canvas 重绘频率 | 仅节点状态变化时 | 严禁每帧重绘 |

**降级策略**：

```
节点数 ≤ 50  → 正常渲染（Canvas 连线 + @Component 节点动画）
节点数 51~100 → 关闭碎片动画，仅 Canvas 渲染 + 点击激活
节点数 > 100  → 降级为文本列表模式，提示"节点过多，已切换列表视图"
```

### 1.2 列表渲染

| 约束项 | 阈值 | 说明 |
|--------|------|------|
| 数据量 ≤ 20 | 使用 `ForEach` | 简单场景 |
| 数据量 > 20 | **必须**使用 `LazyForEach` | 按需渲染，减少内存 |
| 列表项组件 | 严禁超过 100 行 | 减少单帧渲染耗时 |

```typescript
// ✅ 正确：LazyForEach + IDataSource
class CourseDataSource implements IDataSource {
  private dataList: Course[] = []

  totalCount(): number { return this.dataList.length }
  getData(index: number): Course { return this.dataList[index] }

  registerDataChangeListener(listener: DataChangeListener): void { /* ... */ }
  unregisterDataChangeListener(listener: DataChangeListener): void { /* ... */ }
}

// 在页面中
List() {
  LazyForEach(this.dataSource, (item: Course) => {
    ListItem() {
      CourseCard({ course: item })
    }
  })
}
```

### 1.3 动画性能

| 约束项 | 阈值 | 说明 |
|--------|------|------|
| animateTo 时长 | ≤ 500ms | 过长影响交互响应 |
| 同时播放动画数 | ≤ 5 个 | 超出排队播放 |
| 动画曲线 | `Curve.EaseInOut` | 统一曲线，避免突兀 |

---

## 2. 内存管理

### 2.1 大对象红线

| 对象类型 | 内存上限 | 超限处理 |
|---------|---------|---------|
| `@State` 单变量 | 1MB | 拆分为分页/懒加载 |
| 单次 AI 响应 JSON 缓冲 | 5MB | SSE 解析器自动清空并触发 onError |
| 文件解析内容（parsed_content） | 10MB | 拒绝入库，提示文件过大 |
| 图片资源 | 严禁 base64 内嵌大图 | 使用 `$r()` 资源引用 |

### 2.2 页面生命周期内存释放

**硬性规则**：页面 `onDisappear` 必须释放对 `@State` 大对象的引用。

```typescript
@Entry
@Component
struct KnowledgeGraph {
  @State nodes: KnowledgeNode[] = []
  @State edges: KnowledgeEdge[] = []

  onDisappear(): void {
    // 释放大对象引用，允许 GC 回收
    this.nodes = []
    this.edges = []
  }
}
```

**必须释放的场景**：

| 场景 | 释放对象 | 说明 |
|------|---------|------|
| 知识图谱页离开 | `nodes[]`, `edges[]` | 可能含 100+ 节点 |
| 评价报告页离开 | `report` 对象 | 含雷达图 PNG 数据 |
| 课程删除后 | ViewModel 中对应课程数据 | 避免悬挂引用 |

### 2.3 闭包泄漏防护

```typescript
// ❌ 错误：闭包持有大对象引用
setTimeout(() => {
  this.processHugeData(this.largeDataset)  // largeDataset 无法释放
}, 1000)

// ✅ 正确：提取必要数据，避免闭包持有大对象
const summary = this.largeDataset.summary  // 只取需要的字段
setTimeout(() => {
  this.processSummary(summary)
}, 1000)
```

---

## 3. 耗时计算

### 3.1 主线程计算上限

| 操作 | 耗时上限 | 超限处理 |
|------|---------|---------|
| 力导向布局 200 次迭代 | 100ms | 超限时减少迭代次数或降级 |
| JSON.parse（AI 响应） | 50ms | 超限时分片解析 |
| 数据库批量插入（100 条） | 200ms | 超限时分批插入 |

### 3.2 TaskPool 使用规则

以下操作**建议**使用 `@ohos.taskpool` 移至子线程：

| 操作 | 是否必须 TaskPool | 说明 |
|------|:---:|------|
| 力导向布局计算 | 建议 | 纯计算，无 UI 依赖 |
| PDF 文本提取 | 建议 | IO 密集 + 解析 |
| Markdown 解析 | 否 | 通常很快 |
| AI 响应 JSON 解析 | 否 | 已由 SSE 分片处理 |

**TaskPool 红线**：

- TaskPool 函数必须是 `@Concurrent` 装饰的顶层函数
- 严禁在 TaskPool 函数中访问 `@State` / `@Link` 等 UI 状态
- 严禁在 TaskPool 函数中调用 `rdbStore`（数据库操作在主线程）
- TaskPool 函数参数和返回值必须是可序列化类型（`string`, `number`, `boolean`, `Array`, `Object`）

```typescript
import { taskpool } from '@kit.ArkTS'

@Concurrent
function computeForceLayout(params: string): string {
  // 纯计算：接收 JSON 字符串，返回计算后的 JSON 字符串
  const nodes: KnowledgeNode[] = JSON.parse(params)
  // ... 力导向迭代计算
  return JSON.stringify(nodes)
}

// 在 ViewModel 中调用
async computeLayout(nodes: KnowledgeNode[]): Promise<KnowledgeNode[]> {
  const params = JSON.stringify(nodes)
  const result = await taskpool.execute(computeForceLayout, params) as string
  return JSON.parse(result)
}
```

---

## 4. 网络与 IO

### 4.1 文件操作

| 约束项 | 阈值 | 说明 |
|--------|------|------|
| 单文件上传大小 | 50MB | 超限拒绝上传 |
| 文件复制到沙箱超时 | 10 秒 | 超限取消并提示 |
| PDF 解析超时 | 10 秒 | 超限标记 status=failed |

### 4.2 AI 请求

| 约束项 | 阈值 | 说明 |
|--------|------|------|
| 连接超时 | 15 秒 | HTTP connectTimeout |
| 读取超时 | 60 秒 | SSE 长连接 readTimeout |
| 并发锁超时 | 120 秒 | 自动释放（遵循 `AI_SERVICE_PROTOCOL.md`） |
| 全局限流 | 10 次/分钟 | 超限拦截 |

---

## 5. 性能监控埋点

关键性能指标写入 `analytics_event` 表（见 `ANALYTICS_CONVENTIONS.md`）：

| 事件名 | 记录内容 | 阈值告警 |
|--------|---------|---------|
| `perf_force_layout` | 迭代次数、耗时 ms、节点数 | >100ms 告警 |
| `perf_canvas_render` | 帧率 fps、节点数 | <30fps 告警 |
| `perf_file_parse` | 文件类型、大小、耗时 ms | >10s 告警 |
| `perf_ai_request` | 请求类型、耗时 ms | >15s 告警 |
| `perf_db_batch_insert` | 表名、条数、耗时 ms | >200ms 告警 |

---

## 6. 可验证指标

Trae 在实现性能相关代码后，必须按照以下方式提供可验证的测试/日志输出，确保阈值不是空谈。

### 6.1 力导向布局耗时验证

- **测试方式**：在 `computeForceDirectedLayout` 函数首尾记录时间戳
- **期望**：50 节点迭代 200 次耗时 < 100ms
- **实现要求**：
  ```typescript
  const startTime = Date.now()
  const result = computeForceDirectedLayout(nodes, edges, width, height)
  const elapsed = Date.now() - startTime
  Logger.info(`[PERF] Force layout computed in ${elapsed}ms for ${nodes.length} nodes`)
  if (elapsed > 100) {
    Logger.warn(`[PERF] Force layout slow: ${elapsed}ms > 100ms threshold`)
  }
  ```

### 6.2 知识图谱渲染帧率验证

- **测试方式**：进入 KnowledgeGraph 页后，通过 `performance.now()` 或开发者选项 GPU 呈现模式分析
- **期望**：50 节点平均 fps ≥ 30
- **实现要求**：力导向计算结果一次性赋值给 `@State` 时，记录日志：
  ```typescript
  Logger.info(`[PERF] Applying force layout result to @State, node count: ${nodes.length}`)
  ```

### 6.3 列表懒加载验证

- **测试方式**：首页插入 30 条课程数据，滑动列表
- **期望**：内存无陡增，无卡顿
- **实现要求**：`LazyForEach` 的 `IDataSource` 必须实现 `totalCount()` 和 `getData()`，严禁在 `getData` 中执行耗时操作。

---

## 7. 性能检查清单

| 检查项 | 检查方式 | 违规等级 |
|--------|---------|---------|
| LazyForEach 使用 | 列表数据 >20 时检查 | P1 |
| onDisappear 释放大对象 | 页面离开后检查内存 | P1 |
| @State 大对象超限 | 单变量 >1MB | P0 |
| 力导向迭代中更新 @State | 代码审查 | P0 |
| 同时播放动画 >5 个 | 运行时检查 | P2 |
| TaskPool 访问 UI 状态 | 代码审查 | P0 |
