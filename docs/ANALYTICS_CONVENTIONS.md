# 三问高效学习机 — 埋点与使用统计规范

> 版本：v1.0 | 日期：2026-06-05 | 所有用户行为与系统事件必须按本规范记录

---

## 1. 设计目标

- 追踪用户在三问流程中的行为路径与流失率
- 监控 AI 请求成功率、失败率、耗时分布
- 为产品迭代提供数据支撑（如：Q2 流失率高 → 优化争议分析体验）

---

## 2. 事件清单

### 2.1 课程生命周期事件

| 事件名 | 触发时机 | 必带字段 | 可选字段 |
|--------|---------|---------|---------|
| `course_created` | 用户提交提问创建课程 | `course_id`, `title_length`, `material_count` | `has_ai_crawl` |
| `course_deleted` | 用户确认删除课程 | `course_id`, `status_at_delete`, `progress` | — |
| `course_completed` | 三问全部完成 | `course_id`, `total_duration_ms` | `q1_duration_ms`, `q2_duration_ms`, `q3_duration_ms` |

### 2.2 三问流程事件

| 事件名 | 触发时机 | 必带字段 | 可选字段 |
|--------|---------|---------|---------|
| `q1_started` | 课程进入 Q1_ACTIVE | `course_id`, `node_count`, `core_node_count` | — |
| `q1_node_activated` | 学习者点亮一个核心节点 | `course_id`, `node_id`, `activated_count`, `core_count` | `activation_duration_ms` |
| `q1_completed` | 所有核心节点点亮 | `course_id`, `total_activation_count`, `duration_ms` | — |
| `q2_started` | 课程进入 Q2_ACTIVE | `course_id`, `controversy_count` | — |
| `q2_controversy_selected` | 学习者选中一个争议点 | `course_id`, `controversy_id` | — |
| `q2_insight_submitted` | 学习者提交见解 | `course_id`, `controversy_id`, `answer_length`, `is_suspect` | `input_speed_per_min` |
| `q2_skipped_evaluation` | 用户跳过 AI 评价 | `course_id`, `controversy_id` | — |
| `q2_completed` | Q2 完成 | `course_id`, `insight_count`, `duration_ms` | `suspect_count` |
| `q3_started` | 课程进入 Q3_ACTIVE | `course_id`, `question_count` | — |
| `q3_question_answered` | 学习者回答一道题 | `course_id`, `question_id`, `bloom_level`, `is_correct`, `is_suspect` | `answer_duration_ms` |
| `q3_completed` | 9 题全部作答 | `course_id`, `correct_count`, `suspect_count`, `duration_ms` | `bloom_score_map` |

### 2.3 AI 请求事件

| 事件名 | 触发时机 | 必带字段 | 可选字段 |
|--------|---------|---------|---------|
| `ai_request_success` | AI 请求成功完成 | `course_id`, `request_type`, `duration_ms` | `retry_count` |
| `ai_request_failed` | AI 请求失败 | `course_id`, `request_type`, `error_message` | `retry_count` |
| `ai_request_timeout` | AI 请求超时 | `course_id`, `request_type`, `duration_ms` | — |
| `ai_bloom_validation_retry` | 布鲁姆9题校验失败重试 | `course_id`, `retry_attempt`, `missing_levels` | — |
| `ai_bloom_validation_failed` | 布鲁姆9题校验最终失败 | `course_id`, `total_retries` | — |

### 2.4 系统事件

| 事件名 | 触发时机 | 必带字段 | 可选字段 |
|--------|---------|---------|---------|
| `app_cold_start` | 应用冷启动 | `has_pending_locks`, `course_count` | — |
| `file_uploaded` | 用户上传文件 | `course_id`, `file_type`, `file_size_kb` | — |
| `file_parse_failed` | 文件解析失败 | `course_id`, `file_type`, `error_reason` | `is_scanned_pdf` |
| `report_exported` | 评价报告导出 | `course_id`, `export_format` | — |
| `network_status_changed` | 网络状态变化 | `is_online` | — |

---

## 3. 事件字段规范

### 3.1 公共字段（所有事件自动携带）

| 字段 | 类型 | 说明 |
|------|------|------|
| `event_name` | string | 事件名称 |
| `timestamp` | number | 事件时间戳（毫秒） |
| `session_id` | string | 会话 ID（应用启动生成，冷启动重置） |
| `app_version` | string | 应用版本号 |

### 3.2 字段类型约束

| 字段类型 | 存储格式 | 示例 |
|---------|---------|------|
| `course_id` | string | UUID v4 |
| `bloom_level` | number | 1-6 |
| `is_suspect` | number | 0 或 1（SQLite 无布尔） |
| `duration_ms` | number | 毫秒数 |
| `is_correct` | string | `'true'` / `'false'` / `'pending'` / `'subjective'` |

---

## 4. 日志落盘方案

### 4.1 本地存储（当前版本）

事件记录写入本地 `analytics_event` 表，定期导出为 Markdown 文件：

```sql
CREATE TABLE IF NOT EXISTS analytics_event (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  event_name TEXT NOT NULL,
  timestamp INTEGER NOT NULL,
  session_id TEXT NOT NULL,
  course_id TEXT,
  payload TEXT NOT NULL,  -- JSON 字符串，包含事件特有字段
  synced INTEGER DEFAULT 0  -- 0=未同步, 1=已同步（预留）
);

CREATE INDEX idx_analytics_event_name ON analytics_event(event_name);
CREATE INDEX idx_analytics_event_time ON analytics_event(timestamp);
CREATE INDEX idx_analytics_event_course ON analytics_event(course_id);
```

### 4.2 AnalyticsService 接口

```typescript
class AnalyticsService {
  private sessionId: string = ''

  init(): void {
    this.sessionId = generateUUID()
  }

  logEvent(eventName: string, payload: Record<string, Object>): void {
    const event = {
      event_name: eventName,
      timestamp: Date.now(),
      session_id: this.sessionId,
      course_id: payload['course_id'] as string ?? '',
      payload: JSON.stringify(payload),
      synced: 0
    }
    this.rdbHelper.insert('analytics_event', event)
  }
}
```

### 4.3 数据清理

- 本地事件记录保留 **90 天**，超期自动清理
- 清理时机：应用冷启动时执行 `DELETE FROM analytics_event WHERE timestamp < ?`
- 导出后标记 `synced = 1`，不影响清理策略

---

## 5. 与错误日志的分工

- **错误日志（ERROR_LOG_CONVENTIONS.md）**：面向开发与排查，记录详细堆栈、系统状态、业务上下文。
- **埋点（analytics_event）**：面向产品指标与统计，只记录关键事件名称和量化指标。

**硬性约束**：

- 同一个错误/事件，严禁既写错误日志又写埋点，必须按以下规则二选一：
  - **AI 请求失败/超时** → 只写 `ai_request_log` 表 + 埋点 `ai_request_failed` / `ai_request_timeout`，**严禁**再写一遍 ERROR_LOG。
  - **UI 渲染异常/数据库操作失败** → 只写 ERROR_LOG，**严禁**写埋点。
  - **业务关键节点（如 Q1 完成、文件上传）** → 只写埋点，**严禁**写 ERROR_LOG。

---

## 6. 关键指标定义

| 指标 | 计算公式 | 业务含义 |
|------|---------|---------|
| Q1 完成率 | `q1_completed / q1_started * 100%` | 知识图谱点亮体验是否顺畅 |
| Q2 流失率 | `1 - q2_completed / q2_started * 100%` | 争议分析是否吸引人 |
| Q3 完成率 | `q3_completed / q3_started * 100%` | 测评体验是否合理 |
| AI 成功率 | `ai_request_success / (ai_request_success + ai_request_failed + ai_request_timeout) * 100%` | AI 服务稳定性 |
| 诚信可疑率 | `q3_question_answered(is_suspect=1) / q3_question_answered * 100%` | 真人作答拦截有效性 |
| 平均课程完成时长 | `avg(course_completed.total_duration_ms)` | 学习效率 |
