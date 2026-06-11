# 三问高效学习机 — 数据契约

> 版本：v2.1 | 日期：2026-06-05 | 严禁任何实现偏离本契约定义
>
> v2.1 变更：补全异步字段 null 联合类型、增加鸿蒙 RDB Long 转 number 强制规则

---

## 1. 枚举定义

### 1.1 CourseStatus — 课程状态

```typescript
enum CourseStatus {
  DRAFT = 0,        // 已创建，未开始三问
  GENERATING = 1,   // AI 正在生成知识图谱
  Q1_ACTIVE = 2,    // 第一问进行中
  Q2_ACTIVE = 3,    // 第二问进行中
  Q3_ACTIVE = 4,    // 第三问进行中
  COMPLETED = 5     // 三问全部完成
}
```

**状态流转规则**（严禁跳步）：

```
DRAFT ──→ GENERATING ──→ Q1_ACTIVE ──→ Q2_ACTIVE ──→ Q3_ACTIVE ──→ COMPLETED
 │                              ↑            ↑             ↑
 └── 用户提问触发          Q1完成触发    Q2完成触发     Q3完成触发
```

- Q1 完成条件：所有核心节点（type=CORE）is_activated === true
- Q2 完成条件：学习者提交至少一条见解
- Q3 完成条件：9 道测评题全部作答完成

### 1.2 BloomLevel — 布鲁姆认知层级

```typescript
enum BloomLevel {
  REMEMBER = 1,   // 记忆
  UNDERSTAND = 2, // 理解
  APPLY = 3,      // 应用
  ANALYZE = 4,    // 分析
  EVALUATE = 5,   // 评价
  CREATE = 6      // 创造
}
```

**9 题分布规则**（严禁偏离）：

| 层级 | 题数 | 枚举值 |
|------|------|--------|
| REMEMBER | 1 | 1 |
| UNDERSTAND | 2 | 2 |
| APPLY | 2 | 3 |
| ANALYZE | 2 | 4 |
| EVALUATE | 1 | 5 |
| CREATE | 1 | 6 |

### 1.3 NodeType — 知识节点类型

```typescript
enum NodeType {
  CORE = 'core',       // 核心节点：必须点亮才能完成 Q1
  SECONDARY = 'secondary' // 辅助节点：补充说明，不阻塞 Q1 完成
}
```

### 1.4 其他枚举

```typescript
enum MaterialType {
  USER_UPLOAD = 'user_upload',  // 用户上传
  AI_CRAWL = 'ai_crawl'        // AI 爬取
}

enum MaterialStatus {
  PENDING = 'pending',
  PARSING = 'parsing',
  SUCCESS = 'success',
  FAILED = 'failed'
}

enum AiRequestStatus {
  SUCCESS = 'success',
  FAILED = 'failed',
  TIMEOUT = 'timeout'
}

enum CorrectStatus {
  TRUE = 'true',
  FALSE = 'false',
  PENDING = 'pending',
  SUBJECTIVE = 'subjective'
}
```

---

## 2. 核心接口定义

### 2.1 Course — 课程

```typescript
interface Course {
  id: string                    // UUID，主键
  title: string                 // 课程标题，最大 200 字符
  status: CourseStatus          // 课程状态
  current_step: number          // 当前步骤（0-5，与 CourseStatus 对应）
  progress: number              // 进度百分比 0-100
  ai_summary_context: string | null  // AI 摘要上下文（异步生成未完成时为 null）
  q1_activated_count: number    // Q1 已点亮核心节点数
  q1_total_core_count: number   // Q1 核心节点总数
  create_time: number           // 创建时间戳（毫秒）
}
```

**进度映射**：

| current_step | progress | 含义 |
|:---:|:---:|------|
| 0 | 0% | DRAFT |
| 1 | 0% | GENERATING |
| 2 | 0%~33% | Q1_ACTIVE（按核心节点点亮比例） |
| 3 | 33% | Q2_ACTIVE |
| 4 | 66% | Q3_ACTIVE |
| 5 | 100% | COMPLETED |

**Q1 进度计算硬性规则**（防除零异常）：

```typescript
function calcQ1Progress(course: Course): number {
  // 若 q1_total_core_count 为 0，进度强制归为 0%，严禁执行除法运算
  if (course.q1_total_core_count === 0) {
    return 0
  }
  return Math.round((course.q1_activated_count / course.q1_total_core_count) * 33)
}
```

- **严禁**在 `q1_total_core_count === 0` 时执行 `q1_activated_count / q1_total_core_count`
- `q1_total_core_count` 为 0 的场景：课程刚创建、AI 知识图谱生成失败、AI 返回空节点列表

### 2.2 KnowledgeNode — 知识节点

```typescript
interface KnowledgeNode {
  id: string                    // UUID，主键
  course_id: string             // 所属课程 ID（FK → course.id）
  label: string                 // 节点标签，最大 100 字符
  type: NodeType                // 节点类型
  description: string           // 节点描述
  is_activated: boolean         // 是否已点亮（false=碎片态, true=点亮态）
  x_pos: number                 // 力导向布局 X 坐标（-1=未计算）
  y_pos: number                 // 力导向布局 Y 坐标（-1=未计算）
  sort_order: number            // 排序序号
}
```

**坐标规则**：
- `x_pos` / `y_pos` 初始值为 **-1**（表示未计算），**严禁使用 0 作为初始值**
- 力导向算法初始化时，若 `x_pos === -1` 或 `y_pos === -1`，**必须**在 100~500 范围内随机赋予初始坐标，严禁所有节点从 (0,0) 开始迭代（所有节点从同一坐标出发会导致斥力计算灾难性崩溃）
- 节点被激活后（is_activated=true），坐标锁定，不再参与力导向迭代
- 坐标单位为逻辑像素（vp），原点为 Canvas 左上角

**力导向初始化伪代码**：

```typescript
function initNodePositions(nodes: KnowledgeNode[]): void {
  for (const node of nodes) {
    if (node.x_pos === -1 || node.y_pos === -1) {
      node.x_pos = 100 + Math.random() * 400  // 100~500
      node.y_pos = 100 + Math.random() * 400  // 100~500
    }
    // 已有坐标的节点（如已激活节点）保持不变
  }
}
```

### 2.3 KnowledgeEdge — 知识边

```typescript
interface KnowledgeEdge {
  id: string                    // UUID，主键
  course_id: string             // 所属课程 ID（FK → course.id）
  source: string                // 起始节点 ID（FK → knowledge_node.id）
  target: string                // 终止节点 ID（FK → knowledge_node.id）
  relation: string              // 关系描述，最大 200 字符
}
```

### 2.4 QuizQuestion — 测评题目

```typescript
interface QuizQuestion {
  id: string                    // UUID，主键
  course_id: string             // 所属课程 ID（FK → course.id）
  bloom_level: BloomLevel       // 布鲁姆认知层级（1-6）
  linked_node_ids: string       // 关联知识节点 ID，JSON 数组字符串，如 '["id1","id2"]'
  question_text: string         // 题目文本
  options: string               // 选项，客观题为 JSON 数组字符串，主观题为空字符串 ""
  correct_answer: string        // 标准答案
  sort_order: number            // 排序序号
}
```

**linked_node_ids 格式**：
```json
["550e8400-e29b-41d4-a716-446655440000", "6ba7b810-9dad-11d1-80b4-00c04fd430c8"]
```
存储为字符串，使用时 `JSON.parse()` 解析为数组。

**options 格式**：
- 客观题：`'["A. 选项1", "B. 选项2", "C. 选项3", "D. 选项4"]'` — 标准 JSON 数组字符串，一次 `JSON.parse()` 直接解析为 `string[]`
- 主观题（应用/分析/评价/创造层级）：`""`（空字符串，**严禁为 null**）
- **严禁**使用字符串套数组格式（如 `"'[\"A.选项1\"]'"`），大模型极易输出单双引号混乱的无效 JSON

### 2.5 Controversy — 争议

```typescript
interface Controversy {
  id: string                    // UUID，主键
  course_id: string             // 所属课程 ID（FK → course.id）
  title: string                 // 争议标题，最大 200 字符
  view_a: string                // 观点 A
  evidence_a: string            // 观点 A 证据
  view_b: string                // 观点 B
  evidence_b: string            // 观点 B 证据
  conclusion: string            // 结论
  is_selected: boolean          // 是否被学习者选中
  sort_order: number            // 排序序号
}
```

### 2.6 QuestionRecord — 作答记录

```typescript
interface QuestionRecord {
  id: string                        // UUID，主键
  course_id: string                 // 所属课程 ID（FK → course.id）
  step: number                      // 三问步骤（1/2/3）
  quiz_question_id: string | null   // 关联测评题目 ID（FK → quiz_question.id，Q3 时必填，Q1/Q2 时为 null）
  controversy_id: string | null     // 关联争议 ID（FK → controversy.id，Q2 时必填，Q1/Q3 时为 null）
  question_content: string          // 题目/争议点原文
  user_original_answer: string      // 用户真实作答原文
  ai_evaluation: string | null     // AI 评价反馈原文（AI 评价未返回或用户手动跳过时为 null）
  standard_answer: string | null    // 标准答案（Q3 时必填，Q1/Q2 时为 null）
  is_correct: CorrectStatus         // 作答是否正确
  is_suspect: boolean               // 诚信审计标记（输入速度 >150 字/分钟时为 true）
  create_time: number               // 创建时间戳（毫秒）
}
```

**空值字段说明**：

| 字段 | Q1 | Q2 | Q3 |
|------|:---:|:---:|:---:|
| `quiz_question_id` | null | null | 必填（关联测评题） |
| `controversy_id` | null | 必填（关联争议点） | null |
| `standard_answer` | null | null | 必填（标准答案） |

**Q2 见解-争议关联**：Q2 提交见解时，`controversy_id` 必须指向学习者所评论的争议点，确保见解可溯源到具体争议。一条争议可对应多条见解。

### 2.7 Material — 资料

```typescript
interface Material {
  id: string                        // UUID，主键
  course_id: string                 // 所属课程 ID（FK → course.id）
  file_name: string                 // 文件名，最大 255 字符
  file_path: string                 // 沙箱存储路径，最大 500 字符
  type: MaterialType                // 来源类型
  status: MaterialStatus            // 资料状态
  parsed_content: string | null     // 解析后纯文本（解析失败或未解析时为 null）
}
```

**parsed_content 空值场景**：
- `status === PENDING`：尚未解析，`parsed_content = null`
- `status === PARSING`：正在解析，`parsed_content = null`
- `status === FAILED`：解析失败（如扫描型 PDF），`parsed_content = null`
- `status === SUCCESS`：解析成功，`parsed_content` 为非空字符串

### 2.8 AiRequestLog — AI 请求日志

```typescript
interface AiRequestLog {
  id: string                    // UUID，主键
  course_id: string             // 关联课程 ID（FK → course.id）
  request_type: string          // 请求类型：knowledge_graph / controversy / quiz / evaluation
  request_prompt: string        // 请求 Prompt 内容
  response_body: string         // 响应内容
  status: AiRequestStatus       // 执行状态
  duration_ms: number           // 耗时毫秒数
  create_time: number           // 创建时间戳（毫秒）
}
```

---

## 3. 数据库约束

### 3.1 命名规则

- 表名：小写下划线（snake_case），如 `knowledge_node`、`quiz_question`
- 字段名：小写下划线（snake_case），如 `course_id`、`bloom_level`
- 索引名：`idx_` + 表名缩写 + 字段名，如 `idx_knode_course`

### 3.2 主键

- 所有表主键为 `id`，类型 `TEXT`，值为 UUID v4
- 严禁使用自增整数作为主键（分布式场景不安全）

### 3.3 外键

- 外键约束：`FOREIGN KEY (course_id) REFERENCES course(id)`
- **严禁使用 `ON DELETE CASCADE`**，级联删除由代码事务控制
- 唯一例外：`question_record.quiz_question_id` 使用 `ON DELETE SET NULL`
- `question_record.controversy_id`：`FOREIGN KEY (controversy_id) REFERENCES controversy(id) ON DELETE SET NULL`

### 3.4 级联删除逻辑

删除课程时，**必须**在单个事务内按以下顺序删除关联数据：

```
1. DELETE FROM ai_request_log WHERE course_id = ?
2. DELETE FROM question_record WHERE course_id = ?
3. DELETE FROM quiz_question WHERE course_id = ?
4. DELETE FROM controversy WHERE course_id = ?
5. DELETE FROM knowledge_edge WHERE course_id = ?
6. DELETE FROM knowledge_node WHERE course_id = ?
7. DELETE FROM material WHERE course_id = ?
8. DELETE FROM course WHERE id = ?
9. 删除文件池物理文件（事务提交后执行）
```

事务失败必须全部回滚，严禁部分删除。

### 3.5 索引

```sql
CREATE INDEX idx_material_course ON material(course_id);
CREATE INDEX idx_knode_course ON knowledge_node(course_id);
CREATE INDEX idx_kedge_course ON knowledge_edge(course_id);
CREATE INDEX idx_controversy_course ON controversy(course_id);
CREATE INDEX idx_quiz_course ON quiz_question(course_id);
CREATE INDEX idx_qrecord_course ON question_record(course_id);
CREATE INDEX idx_ailog_course ON ai_request_log(course_id);
CREATE INDEX idx_knode_activated ON knowledge_node(course_id, is_activated);
CREATE INDEX idx_qrecord_time ON question_record(create_time);
CREATE INDEX idx_qrecord_controversy ON question_record(controversy_id);
```

### 3.6 NULL 值存储

- SQLite 中 `NULL` 与空字符串 `""` 是不同值
- 联合类型 `string | null` 字段：在 SQLite 中 `null` 存储为 `NULL`，ArkTS 侧为 `null`
- RdbHelper 层读取时：`cursor.getColumnIndex('field')` + `cursor.isColumnNull(idx)` 判空
- 严禁将 `null` 存储为空字符串 `""` 或字符串 `"null"`

---

## 4. 数据流转规则

### 4.1 AI 返回 ID 替换

AI 返回的知识图谱 JSON 中包含 AI 生成的节点 ID，**入库前必须替换为系统 UUID**：

1. 遍历 `nodes` 数组，为每个节点建立 `aiId → systemUUID` 映射
2. 用系统 UUID 覆盖每个节点的 `id` 字段
3. 遍历 `edges` 数组，将 `source` 和 `target` 替换为对应系统 UUID
4. 替换完成后批量插入数据库

### 4.2 JSON 字段存储与解析

**存储规则**：
- `QuizQuestion.linked_node_ids`：存储为 JSON 数组字符串，如 `'["id1","id2"]'`
- `QuizQuestion.options`：客观题存储为 JSON 数组字符串，如 `'["A.选项1","B.选项2"]'`；主观题存储为空字符串 `""`
- 严禁在数据库中存储格式不合法的 JSON 字符串

**解析防御性规则**（硬性约束）：

前端从数据库读取 `linked_node_ids` 和 `options` 并执行 `JSON.parse()` 时，**必须**包裹在 try-catch 中。若解析失败，严禁抛出异常中断应用，必须降级返回空数组 `[]`。

```typescript
function safeParseJsonArray(jsonStr: string): string[] {
  // 空字符串直接返回空数组（主观题 options 场景）
  if (jsonStr === '' || jsonStr === null) {
    return []
  }
  try {
    const parsed = JSON.parse(jsonStr)
    // 校验解析结果必须为数组
    if (Array.isArray(parsed)) {
      return parsed as string[]
    }
    // 非数组降级返回空数组
    Logger.error('safeParseJsonArray: parsed result is not array', jsonStr)
    return []
  } catch (e) {
    // 解析失败降级返回空数组，严禁抛出异常中断应用
    Logger.error('safeParseJsonArray: JSON.parse failed', jsonStr, e.message)
    return []
  }
}
```

### 4.3 布尔值存储

- SQLite 无布尔类型，布尔字段使用 `INTEGER` 存储：`0 = false, 1 = true`
- ArkTS 接口定义为 `boolean` 类型，RdbHelper 层负责 `0/1 ↔ false/true` 转换

### 4.4 时间戳存储

- SQLite 中时间戳存储为 `INTEGER`（毫秒级 13 位数字），如 `1717545600000`
- **鸿蒙 RDB 类型陷阱**：`@ohos.data.relationalStore` 读取 `INTEGER` 时返回 `Long` 类型，**严禁直接赋值给 ArkTS 的 `number`**
- RdbHelper 层读取 `create_time`、`duration_ms` 等时间戳/数值字段时，**必须**使用 `cursor.getLong(idx)` 并显式转换为 `number`：

```typescript
// 正确：显式 Long → number 转换
const createTime: number = cursor.getLong(cursor.getColumnIndex('create_time')).valueOf()

// 错误：直接赋值，ArkTS 严格类型校验报错或运行时精度丢失
// const createTime: number = cursor.getLong(...)  // Long ≠ number
```

- **严禁**使用 `cursor.getString(idx)` 读取数值字段后再 `parseInt()`，此方式存在精度丢失风险
- `Long.valueOf()` 确保类型安全，防止 ArkTS 编译期类型校验崩溃和运行时精度丢失
