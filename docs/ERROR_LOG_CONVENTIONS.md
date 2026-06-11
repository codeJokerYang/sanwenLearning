# 三问高效学习机 — 错误日志约定

> 版本：v1.0 | 日期：2026-06-05 | 所有日志记录必须严格遵循本约定

---

## 1. 本地错误日志存储

### 1.1 存储路径

```
应用沙箱路径：{sandbox}/logs/
```

- 使用 `context.filesDir` 获取沙箱根路径
- `logs` 目录不存在时，应用启动时自动创建

### 1.2 文件命名与轮转

- 按天生成日志文件，命名格式：`app_YYYYMMDD.md`
- 示例：`app_20260605.md`
- 每天首次写入时创建新文件
- **严禁**将所有日志写入单个文件

### 1.3 日志保留策略

- 保留最近 7 天的日志文件
- 超过 7 天的日志文件在应用启动时自动清理
- 清理失败时仅记录警告，不阻塞应用启动

---

## 2. Markdown 日志写入格式

### 2.1 文件结构

每份日志文件以日期为标题，按时间倒序追加写入：

```markdown
# App Log - 2026-06-05

## ERROR

### 14:32:05.123 | [AI_SERVICE] | 生成测评题目

- **动作**：调用 LLM 生成布鲁姆 9 题测评
- **错误信息**：SSE 读取超时，等待 60000ms 无响应
- **堆栈**：
  ```
  at AiService.generateQuiz (entry/src/main/ets/service/AiService.ets:142)
  at QuizManager.requestQuestions (entry/src/main/ets/manager/QuizManager.ets:58)
  at CourseDetail.onQ3Start (entry/src/main/ets/pages/CourseDetail.ets:210)
  ```
- **业务上下文**：courseId=abc123, retryCount=2, bloomValidation=failed

---

## WARN

### 10:15:22.456 | [FORCE_LAYOUT] | 力导向布局收敛

- **动作**：力导向布局迭代计算
- **错误信息**：迭代 200 次未收敛，maxDisplacement=2.3vp
- **堆栈**：无
- **业务上下文**：nodeCount=35, edgeCount=42, canvasSize=720x720

---
```

### 2.2 日志级别

| 级别 | 触发条件 | 示例 |
|------|---------|------|
| `ERROR` | 功能失败、异常捕获、数据校验不通过 | AI 请求失败、数据库写入失败、布鲁姆校验失败 |
| `WARN` | 非预期但可恢复的情况 | 力导向布局未收敛、输入速度可疑、旧文件清理失败 |
| `INFO` | 关键业务节点 | 课程创建、三问步骤流转、评价报告生成 |

### 2.3 写入格式硬性约束

每条日志**必须**包含以下 6 个字段，严禁省略：

| 字段 | 说明 | 示例 |
|------|------|------|
| 时间 | 精确到毫秒 | `14:32:05.123` |
| Tag | 模块标识，大写下划线 | `[AI_SERVICE]` |
| 动作 | 当前执行的操作 | 调用 LLM 生成布鲁姆 9 题测评 |
| 错误信息 | 人类可读的错误描述 | SSE 读取超时，等待 60000ms 无响应 |
| 堆栈 | 调用链，无堆栈时写"无" | 见上方示例 |
| 业务上下文 | 与错误相关的业务数据键值对 | `courseId=abc123, retryCount=2` |

**Tag 清单**（严禁自定义未在清单中的 Tag）：

| Tag | 模块 |
|-----|------|
| `[AI_SERVICE]` | AI 请求与响应 |
| `[BLOOM_VALIDATOR]` | 布鲁姆 9 题校验 |
| `[FORCE_LAYOUT]` | 力导向布局计算 |
| `[COURSE_DB]` | 课程数据库操作 |
| `[FILE_UPLOAD]` | 文件上传与解析 |
| `[INPUT_GUARD]` | 真人作答拦截 |
| `[FLOW_CONTROL]` | 三问流程管控 |
| `[NETWORK]` | 网络请求 |
| `[SECURITY]` | 安全相关（API Key 等） |

---

## 3. 全局异常捕获规则

### 3.1 UIAbility 中拦截

```typescript
// EntryAbility.ets
import { ErrorManager } from '@ohos.app.ability.ErrorManager'

export default class EntryAbility extends UIAbility {
  onCreate(want, launchParam) {
    // 捕获 JS 异常
    ErrorManager.on('error', {
      onUnhandledException(errorMsg: string) {
        LogWriter.writeGlobalError(errorMsg)
      }
    })
  }
}
```

### 3.2 异常处理硬性约束

1. **必须写入日志文件**：全局异常信息写入当天日志文件，级别为 `ERROR`，Tag 为应用级标识
2. **严禁将堆栈弹窗给用户**：

```typescript
// ❌ 严禁：向用户展示技术堆栈
AlertDialog.show({ message: errorMsg })

// ✅ 正确：展示友好提示，堆栈仅写入日志
LogWriter.writeGlobalError(errorMsg)
AlertDialog.show({ message: '应用出现异常，请稍后重试' })
```

3. **严禁吞掉异常**：捕获后必须写入日志，不允许空 `catch` 块

```typescript
// ❌ 严禁
try {
  await aiService.generateQuiz(courseId)
} catch (e) {
  // 吞掉异常
}

// ✅ 正确
try {
  await aiService.generateQuiz(courseId)
} catch (e) {
  LogWriter.write('ERROR', '[AI_SERVICE]', '生成测评题目', e.message, e.stack, { courseId })
  // 业务兜底处理...
}
```

---

## 4. 日志导出 UI 需求

### 4.1 入口位置

设置页 → "导出日志"按钮

### 4.2 导出流程

```
用户点击"导出日志"
      │
      ▼
选择导出范围（最近 1 天 / 3 天 / 7 天）
      │
      ▼
将选中日志文件打包为 .zip
      │
      ▼
调用系统分享面板（@ohos.share）
      │
      ├── 用户选择分享目标（邮件/微信/保存到本地）
      │
      └── 分享完成/取消 → 清理临时 .zip 文件
```

### 4.3 导出硬性约束

- **严禁**在导出前弹出日志内容预览（可能包含敏感信息）
- 导出的日志文件中，API Key 等敏感字段必须脱敏为 `***`（遵循 API_SECURITY_CONVENTIONS）
- 临时 `.zip` 文件存放在应用缓存目录，导出完成后立即删除
- 若无日志文件可导出，Toast 提示"暂无日志记录"
