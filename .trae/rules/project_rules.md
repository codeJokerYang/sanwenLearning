# 三问高效学习机 — Trae 项目规则

> 本文件为 Trae 在本项目下的最高行为约束，与 00_CONVENTIONS_INDEX.md 保持一致。
> 若与本规则冲突，以本规则为准；若与 DATA_CONTRACT / AI_SERVICE_PROTOCOL / FEATURE_RULES 冲突，以这些更高优先级文档为准。

---

## 1. 规范体系与优先级

1. **必须先读**：00_CONVENTIONS_INDEX.md  
2. **核心三文档（宪法级）**：
   - DATA_CONTRACT.md
   - AI_SERVICE_PROTOCOL.md
   - FEATURE_RULES.md
3. **架构与分层**：ARCHITECTURE_CONVENTIONS.md
4. **其他规范（平级，必须同时满足）**：
   - API_SECURITY_CONVENTIONS.md
   - ERROR_LOG_CONVENTIONS.md
   - ANALYTICS_CONVENTIONS.md
   - PERFORMANCE_CONVENTIONS.md
   - UI_ROUTING_CONVENTIONS.md
   - I18N_AND_A11Y_CONVENTIONS.md
   - RELEASE_AND_UPDATE_CONVENTIONS.md

**数值冲突**：以 AI_SERVICE_PROTOCOL.md 为准（如锁超时 120s、SSE 超时 15s/60s、跨阶段等待 15s、5M 字符数上限等）。

---

## 2. 技术栈与平台红线

- 平台：HarmonyOS NEXT API 12+
- 语言：ArkTS（声明式 UI）
- 应用模型：Stage 模型
- 本地数据库：@ohos.data.relationalStore（RdbStore）
- 网络请求：仅 @ohos.net.http，严禁第三方 HTTP 库、WebView、WebSocket
- AI 接口：兼容 OpenAI Chat Completions 格式 + SSE
- UI 框架：ArkUI（@Component / @State / @Prop / @Link 等）

**严禁**：
- 使用 WebView 套壳
- 使用 axios / fetch / EventSource 等非鸿蒙原生网络库
- 在端侧实现 PDF 文本提取（当前版本仅支持 Markdown）

---

## 3. 核心业务铁律

1. **三问必须显性**：用户在任何时刻都能看到“是什么/为什么/怎么用”哪个阶段，不可跳步、不可隐含。
2. **学员是知识主体**：AI 只能补充和评价，禁止代替学员作答。
3. **课程必须柔性**：无预设课程体系，由学员自主创建和组装知识。
4. **对话必须留痕**：所有学员与 AI 交互必须完整记录（角色/时间戳/原文）。
5. **真人作答拦截**：Q2/Q3 仅允许手动输入，粘贴拦截（最佳努力）+ 速度检测 + Prompt 约束 + 评价报告标注。

---

## 4. 数据契约与类型红线（DATA_CONTRACT.md）

- 8 表结构：course / knowledge_node / knowledge_edge / quiz_question / controversy / question_record / material / ai_request_log
- 主键：`id TEXT`，UUID v4，严禁自增整数
- 外键：`FOREIGN KEY (course_id) REFERENCES course(id)`，**严禁 ON DELETE CASCADE**
- 唯一例外：`question_record.quiz_question_id` / `controversy_id` 使用 `ON DELETE SET NULL`
- 布尔字段：`INTEGER`（0=false,1=true），ArkTS 侧为 `boolean`
- 时间戳：`INTEGER`（毫秒），RdbHelper 读取必须用 `cursor.getLong(idx).valueOf()` → number
- 联合类型字段：`string | null`，SQLite 中 `NULL` 与空字符串 `""` 严格区分
- JSON 字段（linked_node_ids / options）：
  - 存储：JSON 数组字符串（主观题 options 为空字符串 `""`）
  - 读取：必须用 `safeParseJsonArray`，解析失败降级返回 `[]`
- KnowledgeNode 坐标：
  - 初始值 `x_pos = -1, y_pos = -1`
  - 力导向初始化时若为 -1，必须在 100~500 随机初始化，严禁从 (0,0) 开始

---

## 5. AI 服务协议红线（AI_SERVICE_PROTOCOL.md）

- **两阶段 SSE**：
  - 阶段1：`type="text"` → 逐字渲染
  - 阶段2：`type="json"` → 完整 JSON（一次 `JSON.parse`）
  - 结束：`[DONE]`
- **SSE 解析器**：
  - 维护 `string buffer`，仅遇 `\n\n` 截取
  - JSON 解析失败：丢弃 + Logger.error，不中断流程
  - 阶段2 防护：跨阶段等待超时 15s；JSON 缓冲上限 5M 字符数
- **AI 并发锁**：
  - 锁超时 120000ms（120s），唯一权威来源
  - 每次 acquireLock 开头必须调用 `forceReleaseTimeout()`
  - 冷启动 `clearAllOnColdStart()`
- **Prompt 防幻觉**：
  - 注入 `parsed_content` 作为上下文
  - 注入知识节点列表，禁止编造节点 ID
  - 禁止替代用户作答
- **日志与脱敏**：
  - 每次请求必须记录 `ai_request_log`（含 duration_ms）
  - 日志中 API Key 必须脱敏（保留前 3 后 4，中间 `***`）

---

## 6. 业务防呆与流程红线（FEATURE_RULES.md）

- **真人作答**：
  - ManualInputBox：禁粘贴（onPaste 拦截）、禁长按菜单
  - 速度检测：首次输入记录 startTime，提交时计算字/分钟
  - 阈值：>150 字/分钟 → `is_suspect = true`
  - 短文本豁免：<10 字 → `is_suspect = false`
- **布鲁姆 9 题校验**：
  - 分布：记1/理2/应2/分2/评1/创1
  - 自动重试上限 2 次；失败后提供手动重试按钮
  - linked_node_ids 必须校验，非法 node_id 移除，保留合法
- **三问流程管控**：
  - Q1 完成：所有核心节点（type=CORE）`is_activated === true`
  - Q2 完成：至少一条见解 + AI 评价（或跳过评价）
  - Q3 完成：9 题全部作答 + question_record 入库
- **课程级联删除**：
  - 事务内按 8 表顺序删除
  - 物理文件删除在事务提交后执行
- **文件上传**：
  - 仅 PDF / Markdown，≤50MB
  - PDF 当前版本不解析文本，`parsed_content = null`，`status = FAILED`
  - 同名文件：先删旧物理文件，再复制新文件，再更新 DB

---

## 7. 性能与内存红线（PERFORMANCE_CONVENTIONS.md）

- @State 单变量 ≤1MB；大列表用 LazyForEach + 分页
- 力导向布局：200 次迭代后一次性更新 @State，严禁迭代中更新
- Canvas：仅在节点状态变化时重绘，严禁每帧重绘
- 页面 onDisappear 必须释放大对象（nodes/edges/report）
- 耗时计算：
  - 力导向 200 次迭代 <100ms（否则降级）
  - JSON.parse <50ms
  - 批量插入 100 条 <200ms
- 动画：animateTo ≤500ms，同时播放 ≤5 个

---

## 8. 安全与日志红线

- API Key：
  - 严禁硬编码、明文存储、URL 参数传递
  - 必须使用 HUKS 或加密后 preferences 存储
  - 解密后 Key 仅存在于请求函数作用域，严禁赋值给 @State / 全局变量
- 网络熔断：10 次/分钟，超限拦截
- 离线拦截：断网时严禁发起 AI 请求，必须弹窗提示
- 错误日志：
  - 本地 Markdown，7 天滚动
  - 每条日志 6 字段：时间/Tag/动作/错误信息/堆栈/业务上下文
  - 严禁向用户展示技术堆栈
- 埋点：
  - AI 失败/超时 → ai_request_log + 埋点，**严禁**再写 ERROR_LOG
  - UI/DB 异常 → ERROR_LOG，**严禁**写埋点
  - 业务关键节点 → 埋点，**严禁**写 ERROR_LOG

---

## 9. 国际化与无障碍

- 严禁在 .ets 中硬编码面向用户的中文（5 种例外：Prompt/日志/SQL/枚举内部表示/开发期占位符）
- 所有用户文案必须 `$r('app.string.xxx')`
- 关键交互组件必须设置 accessibilityText / accessibilityDescription
- 最小可点击区域 44vp × 44vp

---

## 10. 分层与架构红线（ARCHITECTURE_CONVENTIONS.md）

- 目录：pages / components / viewmodels / services / db / models / common
- 严禁：
  - Pages 直接调用 Services / RdbHelper
  - Components 直接调用 Services / RdbHelper
  - ViewModels 导入 UI 组件
  - Services 持有 @State / 导入 ViewModels / Pages
- 单文件 ≤300 行
- @State 严禁跨组件共享；@Link 仅用于需要回传的场景；展示型组件只用 @Prop

---

## 11. 版本与迁移（RELEASE_AND_UPDATE_CONVENTIONS.md）

- 语义化版本：major.minor.patch
- DB_VERSION 独立于 APP_VERSION 递增
- init.sql 仅在 version=0 时执行；升级严禁执行 init.sql，必须走 ALTER TABLE
- 迁移脚本：
  - 严禁 DROP TABLE
  - 必须向后兼容（新增字段允许 NULL 或有默认值）
  - 必须在代码中有 `[DB_MIGRATION] Vx->Vy:` 注释
  - 必须在 docs/DB_MIGRATION_LOG.md 记录

---

## 12. UI 路由与状态管理（UI_ROUTING_CONVENTIONS.md）

- 页面：首页 / 课程详情 / 设置页
- router.back() 严禁带参数；删除课程后必须 back 回首页
- 路由参数仅基本类型，严禁对象/数组
- @State/@Prop/@Link/@Provide/@Consume/@ObjectLink 使用决策树：
  - 组件内部 → @State
  - 父→子且不需要回传 → @Prop
  - 父↔子且需要回传 → @Link
  - 跨多层 → @Provide/@Consume
  - 需要观测对象属性 → @ObjectLink + @Observed
