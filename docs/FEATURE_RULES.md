# 三问高效学习机 — 业务防呆规则

> 版本：v2.3 | 日期：2026-06-05 | 所有业务逻辑必须严格遵循本规则

---

## 1. 真人作答拦截

### 1.1 设计目标

确保第二问（见解输入）和第三问（答题）的作答内容为学习者真实手动输入，防止 AI 代答或复制粘贴。

### 1.2 多层防线

```
┌─────────────────────────────────────────────────┐
│ 第1层：粘贴拦截（技术层，最佳努力）                │
│ 第2层：输入速度检测（数据层，精确计算）            │
│ 第3层：Prompt 约束（AI 层，语义约束）             │
│ 第4层：评价报告标注（审计层，可追溯）              │
└─────────────────────────────────────────────────┘
```

### 1.3 第1层：粘贴拦截

**ManualInputBox 组件实现**：

```typescript
@Component
struct ManualInputBox {
  @State inputValue: string = ''
  private inputStartTime: number = 0
  private hasStartedInput: boolean = false

  build() {
    TextInput({
      text: this.inputValue,
      placeholder: '请手动输入您的答案',
    })
      .type(InputType.Normal)
      .enableKeyboard(true)
      .copyOption(CopyOptions.None)           // 禁止复制
      .onChange((value: string) => {
        // 首次输入（文本从空变为非空，或长度首次增加）时记录开始时间
        if (!this.hasStartedInput && value.length > 0) {
          this.inputStartTime = Date.now()
          this.hasStartedInput = true
        }
        this.inputValue = value
      })
      .onPaste(() => {
        // 拦截粘贴事件（最佳努力，部分系统可能绕过）
        return
      })
  }
}
```

**注意**：粘贴拦截为"最佳努力"措施，部分系统输入法可能绕过此限制。因此需要第2层速度检测作为补充。

### 1.4 第2层：输入速度检测

**核心算法**：

```typescript
// 在 onChange 首次触发时记录开始时间（排除用户思考时间）
private inputStartTime: number = 0
private hasStartedInput: boolean = false

onChange((value: string) => {
  if (!this.hasStartedInput && value.length > 0) {
    this.inputStartTime = Date.now()
    this.hasStartedInput = true
  }
  this.inputValue = value
})

// 提交时计算输入速度
onSubmit() {
  const textLength = this.inputValue.trim().length

  // 短文本豁免：若最终文本长度 < 10 字，is_suspect 强制为 false，不计算速度
  if (textLength < 10) {
    const record: QuestionRecord = {
      // ...其他字段
      is_suspect: false,
    }
    return
  }

  const elapsedSeconds = (Date.now() - this.inputStartTime) / 1000
  const speed = elapsedSeconds > 0 ? textLength / elapsedSeconds : 0  // 字/秒

  // 换算为字/分钟
  const speedPerMinute = speed * 60

  // 判定是否可疑
  const isSuspect = speedPerMinute > 150  // 超过 150 字/分钟视为可疑

  // 写入 QuestionRecord
  const record: QuestionRecord = {
    // ...其他字段
    is_suspect: isSuspect,
  }
}
```

**速度阈值说明**：

| 输入方式 | 典型速度 | 判定 |
|---------|---------|------|
| 手动键盘输入 | 20-80 字/分钟 | 正常 |
| 语音转文字 | 60-120 字/分钟 | 正常 |
| 复制粘贴 | >150 字/分钟 | **可疑** |
| AI 自动填充 | >300 字/分钟 | **高度可疑** |

**阈值选择依据**：
- 普通人键盘输入速度通常在 40-80 字/分钟
- 专业打字员可达 100-120 字/分钟
- 150 字/分钟作为阈值，兼顾误判率和检测率
- 该阈值为保守值，宁可漏检不可误判

**短文本豁免说明**：
- 文本长度 < 10 字时，速度计算无统计意义（少量字符即可瞬间完成）
- 此类情况强制 `is_suspect = false`，避免短答案被误判

**计时方式说明**：
- 使用 `onChange` 首次触发时间而非 `onFocus` 时间，排除用户在输入框聚焦后的思考时间
- 仅当文本从空变为非空（或长度首次增加）时才记录开始时间，确保计时起点为实际输入时刻

### 1.5 第3层：Prompt 约束

AI 评价请求的 Prompt 中必须包含：

```
禁止替代用户作答，必须基于用户真实输入评价。
如果用户输入过于简短或空洞，请指出不足而非替其补充。
```

### 1.6 第4层：评价报告标注

评价报告必须包含以下标注：

```markdown
> 本答案由学员手动输入（诚信声明）

⚠ 部分作答输入极快（可能使用了语音输入或复制粘贴），可能未经过深度思考，建议重新复盘
```

- 若存在 `is_suspect = true` 的记录，追加警告标注
- 标注位置：评价报告"三问交互原始记录"章节末尾

---

## 2. 布鲁姆 9 题校验

### 2.1 校验规则

LLM 返回 9 道测评题目后，**本地必须校验** `bloom_level` 分布：

```typescript
function validateBloomDistribution(questions: QuizQuestion[]): boolean {
  // 规则1：总数必须为 9
  if (questions.length !== 9) {
    Logger.error('Bloom validation failed: count=' + questions.length)
    return false
  }

  // 规则2：各层级分布必须符合要求
  const expected: Map<BloomLevel, number> = new Map([
    [BloomLevel.REMEMBER, 1],
    [BloomLevel.UNDERSTAND, 2],
    [BloomLevel.APPLY, 2],
    [BloomLevel.ANALYZE, 2],
    [BloomLevel.EVALUATE, 1],
    [BloomLevel.CREATE, 1],
  ])

  const actual: Map<BloomLevel, number> = new Map()
  for (const q of questions) {
    const count = actual.get(q.bloom_level) ?? 0
    actual.set(q.bloom_level, count + 1)
  }

  for (const [level, expectedCount] of expected) {
    const actualCount = actual.get(level) ?? 0
    if (actualCount !== expectedCount) {
      Logger.error(`Bloom validation failed: level=${level} expected=${expectedCount} actual=${actualCount}`)
      return false
    }
  }

  return true
}
```

### 2.2 校验失败处理

```
LLM 返回 9 题
      │
      ▼
本地校验 bloom_level 分布
      │
      ├── 校验通过 → 批量入库 → 展示题目
      │
      └── 校验失败（缺失层级或总数非 9）
              │
              ▼
         自动重试（重新发起 AI 请求）
              │
              ├── 第 1 次重试成功 → 入库展示
              ├── 第 1 次重试失败 → 第 2 次重试
              ├── 第 2 次重试成功 → 入库展示
              └── 第 2 次重试失败 → Toast 提示
                    "AI 生成题目质量不足，请重试"
                    [重试] 按钮（手动触发，不计入自动重试次数）
```

### 2.3 重试上限

- **自动重试上限：2 次**
- 超过自动重试上限后，不再自动重试，显示 Toast 提示
- 用户可手动点击"重试"按钮再次请求
- 每次重试必须释放并重新获取 AI 并发锁
- 每次重试的请求和响应必须记录至 `ai_request_log`

### 2.4 linked_node_ids 校验

每道题目的 `linked_node_ids` 必须校验（注意：校验发生在 LLM 返回数据入库前，此时 `linked_node_ids` 为原始数组 `string[]`，而非 JSON 字符串）：

```typescript
function validateLinkedNodeIds(rawLinkedNodeIds: string[], validNodeIds: Set<string>): boolean {
  for (const nodeId of rawLinkedNodeIds) {
    if (!validNodeIds.has(nodeId)) {
      Logger.error(`Invalid linked_node_id: ${nodeId}`)
      return false
    }
  }
  return true
}
```

- 校验失败的题目：移除非法 node_id，保留合法 node_id
- 若移除后 `linked_node_ids` 为空数组，该题目仍可入库（溯源时无法关联节点）
- 入库时再将 `linked_node_ids` 序列化为 JSON 字符串存储

---

## 3. 图谱渲染性能

### 3.1 力导向布局计算

**核心原则**：力导向布局 200 次迭代计算完毕后，再一次性更新 `@State` 渲染。

```typescript
function computeForceDirectedLayout(
  nodes: KnowledgeNode[],
  edges: KnowledgeEdge[],
  canvasWidth: number,
  canvasHeight: number
): KnowledgeNode[] {
  const MIN_DISTANCE = 60    // 节点最小间距（vp）
  const EDGE_LENGTH = 120    // 边偏好长度（vp）
  const MAX_ITERATIONS = 200 // 最大迭代次数
  const CONVERGENCE_THRESHOLD = 1 // 收敛阈值（vp）

  // 初始化位置（对齐 DATA_CONTRACT 坐标规则）
  const positions: Map<string, { x: number; y: number; fixed: boolean }> = new Map()
  for (const node of nodes) {
    let x = node.x_pos
    let y = node.y_pos
    // 遵循数据契约：-1 表示未计算，需在 100~500 随机初始化
    if (x === -1 || y === -1) {
      x = 100 + Math.random() * 400
      y = 100 + Math.random() * 400
    }
    positions.set(node.id, {
      x: x,
      y: y,
      fixed: node.is_activated // 已激活节点位置锁定
    })
  }

  // 迭代计算
  for (let iter = 0; iter < MAX_ITERATIONS; iter++) {
    let maxDisplacement = 0

    // 计算斥力（节点间）
    // 计算引力（边连接的节点间）
    // 更新位置（fixed 节点跳过）
    // 记录最大位移

    // 收敛检测
    if (maxDisplacement < CONVERGENCE_THRESHOLD) {
      Logger.info(`Force layout converged at iteration ${iter}`)
      break
    }
  }

  // 一次性更新节点坐标
  return nodes.map(node => {
    const pos = positions.get(node.id)!
    return { ...node, x_pos: pos.x, y_pos: pos.y }
  })
}
```

**严禁**在迭代过程中更新 `@State`，否则会导致每帧触发 UI 重渲染，严重卡顿。

### 3.2 混合渲染方案

```
┌──────────────────────────────────────────────────┐
│                  Canvas 层（底层）                 │
│  - 绘制连线（edges）                              │
│  - 绘制已激活节点的圆形点亮态                      │
│  - 处理节点/连线的点击命中检测                     │
├──────────────────────────────────────────────────┤
│              @Component 层（上层）                 │
│  - 碎片态节点：PuzzleFragmentAnim @Component      │
│  - 点击碎片 → animateTo() 动画                    │
│  - 动画完成 → 移除 @Component → Canvas 绘制点亮态 │
└──────────────────────────────────────────────────┘
```

**渲染流程**：

1. **初始渲染**：Canvas 画连线 + @Component 画碎片态节点
2. **点击碎片**：触发 `animateTo(duration=500ms, curve=EaseInOut)`
3. **动画完成**：移除 @Component 碎片节点 → Canvas 重绘该节点为圆形点亮态
4. **后续交互**：节点/连线点击均在 Canvas 内处理

**性能保障**：
- Canvas 仅在节点状态变化时重绘，不每帧刷新
- @Component 节点数量控制在 50 以内（超过时降低动画精度）
- 力导向布局计算在主线程执行，但结果一次性更新，不阻塞渲染

### 3.3 Canvas 渲染失败降级

若 Canvas 上下文创建失败或 GPU 资源不足：

1. 降级为纯文本列表展示知识图谱节点信息
2. 提示用户："图形渲染异常，已切换为列表模式"
3. 列表模式下仍支持节点点击激活和进度追踪

---

## 4. 三问流程管控

### 4.1 强制顺序规则

```
Q1（未完成）→ Q2 锁定（DISABLE）
Q1（完成）  → Q2 解锁（NORMAL）
Q2（未完成）→ Q3 锁定（DISABLE）
Q2（完成）  → Q3 解锁（NORMAL）
```

**Stepper 组件实现**：

```typescript
Stepper() {
  StepperItem() { /* Q1 面板 */ }
    .status(ItemState.NORMAL)

  StepperItem() { /* Q2 面板 */ }
    .status(q1Completed ? ItemState.NORMAL : ItemState.DISABLE)

  StepperItem() { /* Q3 面板 */ }
    .status(q2Completed ? ItemState.NORMAL : ItemState.DISABLE)
}
```

### 4.2 Q1 完成判定

```typescript
// 当 q1_activated_count === q1_total_core_count 时，Q1 完成
function checkQ1Completion(course: Course): boolean {
  return course.q1_activated_count === course.q1_total_core_count
    && course.q1_total_core_count > 0
}
```

- 仅核心节点（type=CORE）计入完成条件
- 辅助节点（type=SECONDARY）不阻塞 Q1 完成
- `q1_total_core_count` 为 0 时，Q1 无法完成（需 AI 重新生成）

### 4.3 Q2 完成判定

**正常完成条件**：
- 学习者提交至少一条见解（`user_original_answer` 非空）
- AI 评价反馈已返回

**异常兜底（防止 AI 评价失败导致死锁）**：

若 AI 评价失败（超时/网络错误），UI 需提供"跳过评价，继续学习"按钮。用户点击后：

1. `ai_evaluation` 字段写入 `"AI 评价失败，用户手动跳过"`
2. Q2 视为完成，状态流转至 Q3
3. 该跳过操作记录至 `ai_request_log`，标注 `status=failed`，并在 `response_body` 中记录 `User skipped evaluation due to AI timeout`

```
用户提交见解
      │
      ▼
发起 AI 评价请求
      │
      ├── 评价成功 → Q2 完成 → 流转至 Q3
      │
      └── 评价失败（超时/网络错误）
              │
              ▼
         UI 显示"跳过评价，继续学习"按钮
              │
              ├── 用户点击"跳过评价" → ai_evaluation 写入
              │   "AI 评价失败，用户手动跳过" → Q2 完成 → 流转至 Q3
              │
              └── 用户点击"重试评价" → 重新发起 AI 评价请求
```

### 4.4 Q3 完成判定

- 9 道测评题全部作答完成
- 每题的 `question_record` 已入库
- 全部完成后触发评价报告生成

---

## 5. 课程级联删除

### 5.1 删除流程

```
用户确认删除
      │
      ▼
beginTransaction()
      │
      ├── DELETE FROM ai_request_log WHERE course_id = ?
      ├── DELETE FROM question_record WHERE course_id = ?
      ├── DELETE FROM quiz_question WHERE course_id = ?
      ├── DELETE FROM controversy WHERE course_id = ?
      ├── DELETE FROM knowledge_edge WHERE course_id = ?
      ├── DELETE FROM knowledge_node WHERE course_id = ?
      ├── DELETE FROM material WHERE course_id = ?
      ├── DELETE FROM course WHERE id = ?
      │
      ▼
commit()
      │
      ▼
deleteCourseFiles(courseId)  // 删除沙箱物理文件
```

### 5.2 事务保障

- 任一 DELETE 失败 → 全部回滚 → 课程数据不受影响
- 物理文件删除在事务提交后执行（事务回滚时不删文件）
- 物理文件删除失败 → 记录日志，不影响课程记录删除结果

---

## 6. 文件上传校验

### 6.1 格式校验

- 仅允许 PDF（`.pdf`）和 Markdown（`.md`）格式
- 非法格式：拒绝上传，提示"仅支持 PDF 和 Markdown 格式文件"

### 6.2 大小校验

- 单个文件不超过 50MB
- 超过限制：拒绝上传，提示"文件大小超过 50MB 限制"

### 6.3 PDF 处理约束

**当前版本严禁在端侧尝试解析 PDF 提取文本。**

若用户上传 PDF 文件：

1. 仅将文件名和路径入库
2. `parsed_content` 置为 `null`
3. `status` 置为 `FAILED`
4. UI 强提示："暂不支持 PDF 内容解析，请上传 Markdown 文件"

**注意**：PDF 解析能力需等待服务端接口支持后方可启用，端侧不得自行实现 PDF 文本提取逻辑。

**AI 生成阻断约束**：当课程关联的所有资料 `parsed_content` 均为 `null` 时，严禁将课程状态从 `DRAFT` 流转至 `GENERATING`。UI 需拦截"开始三问"操作，并提示"无有效学习资料，请上传 Markdown 文件"。

### 6.4 重名文件处理

同一 `course_id` 下上传同名文件时，**必须先删除旧物理文件，再复制新文件，最后更新数据库记录**。

```
检测到同名文件
      │
      ▼
删除旧物理文件
      │
      ├── 删除成功 → 复制新文件至沙箱 → 更新数据库记录
      │
      └── 删除失败 → 阻止上传，提示"旧文件清理失败，请重试"
```

**严格约束**：
- 旧物理文件删除失败时，**严禁继续上传**，必须阻止操作并提示用户
- 严禁保留旧物理文件导致沙箱存储泄漏
- 数据库记录更新在物理文件操作成功后执行
