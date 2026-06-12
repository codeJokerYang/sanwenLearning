# BUG-PJ8：发送消息后 AI 占位气泡不出现 — 数据库缺表 + 异常静默吞没

> 日期：2026-06-12 | 严重度：高（对话持久化链路全断） | 状态：已修复
> 关联：BUG-PJ7（渲染失效）修复后暴露出的第二层缺陷

## 一、现象

修复 BUG-PJ7 后，发送消息时用户气泡正常上屏、输入框清空，但 AI 占位气泡不出现、无错误提示、无任何后续反应。日志文件无线索（文件日志本身亦有问题）。

## 二、定位过程

1. 模拟器 `uitest dumpLayout`：消息区只有用户气泡，**无流式光标、无 AI 占位气泡** → `sendMessage` 死于"追加用户消息"与"创建 AI 占位"之间；
2. 该区间只有数据库操作：`createConversation()` + `insertMessage()`，且**位于 try 块之外**；
3. 主机直连 DeepSeek API 验证（HTTP 200）排除密钥/模型/余额问题；
4. `hdc file recv` 拉取设备数据库 + Python sqlite3 检查：
   - 实际表：course、knowledge_node、…、ai_request_log、analytics_event（9 张）
   - **缺失：`ai_conversation`、`ai_message`**
   - `PRAGMA user_version = 2`（版本号已达标）

## 三、根本原因（两层叠加）

**1. 数据库演进缺陷——"加表忘升版本"：**
`ai_conversation`/`ai_message` 后来才追加进 `INIT_SQL`（位于索引块之后），但 `DB_VERSION` 仍为 2。于是：
- 全新安装（version 0 → 执行完整 INIT_SQL）：有表 ✓
- 存量 V2 库（版本号已是 2）：初始化跳过、迁移跳过 → **永远缺表** ✗

**2. 异常处理缺陷——三处静默吞没：**
- 会话/消息持久化代码在 `sendMessage` 的 try 块之外，"no such table" 异常直接逃逸；
- `safeSend()` 用同步 try-catch 包 async 调用，接不住 Promise 拒绝；
- 文件日志（Logger 写沙箱文件）当日文件 0 字节，错误无处可查。

## 四、修复方案

| 文件 | 修改 |
|------|------|
| `common/Config.ets` | `DB_VERSION` 2 → 3 |
| `db/RdbHelper.ets` | 新增 `migrateV3`：`CREATE TABLE IF NOT EXISTS` 补建两表 + `CREATE INDEX IF NOT EXISTS` 三索引，对新老库均幂等 |
| `viewmodels/ChatViewModel.ets` | 所有持久化操作包进独立 try-catch：失败仅记日志并降级（丢失历史记录），不阻断对话/检索流程 |
| `components/AIChatPanel.ets` | `safeSend` 与检索选择改用 `Promise.catch` 兜底，失败时给出可见错误提示 |

## 五、预防措施

1. **DB 演进规约**：任何对 `INIT_SQL` 的表结构改动，必须同步 ① 递增 `DB_VERSION` ② 编写对应幂等迁移 ③ 在 `docs/DB_MIGRATION_LOG.md` 登记；
2. **迁移幂等性**：迁移脚本一律使用 `IF NOT EXISTS` / `IF EXISTS`，保证"全新安装已含该结构"与"存量库补结构"两条路径都安全；
3. **异步异常规约**：组件事件回调调用 async 方法必须 `.catch`；ViewModel 中"主流程"与"持久化"必须分层容错——持久化失败降级，主流程失败给用户可见反馈；
4. **测试用例**：升级安装（保留数据 `install -r`）必须纳入回归路径，仅测全新安装会漏掉所有迁移缺陷。
