基于项目规范和任务清单，我为您设计了一套系统化的 Trae 提示词策略。这套策略的核心是：**每次只聚焦一个原子任务，严格注入规范上下文，明确验收标准，强调红线约束**。
以下是按阶段划分的详细提示词模板，您可以直接复制使用：
---
## 🧱 阶段 1：基础设施（无依赖）
### T-1.1 RdbHelper 数据库封装
```markdown
# 任务：实现 RdbHelper 数据库封装
## 依赖
- 无
## 输入规范（必须遵循）
- `DATA_CONTRACT.md` 第 3.1~3.5 节（8表+9索引+级联删除）
- `RELEASE_AND_UPDATE_CONVENTIONS.md` 第 2 节（迁移策略）
## 输出文件
- `entry/src/main/ets/db/RdbHelper.ets`
## 验收标准（严格对照 checklist）
1. 执行 `init.sql` 建表（8表+9索引）
2. `init.sql` 仅在 `version === 0` 时执行
3. 通用 CRUD 方法：insert / query / update / delete / execute（参数化，严禁字符串拼接）
4. 事务方法：executeInTransaction（BEGIN/COMMIT/ROLLBACK）
5. 布尔转换：0/1 ↔ false/true
6. 时间戳读取：cursor.getLong(idx).valueOf() → number（严禁 getString 后 parseInt）
7. NULL 判定：isColumnNull + 联合类型字段正确处理
8. DB_VERSION = 1，迁移框架（migrate + executeMigration）
9. 单文件 ≤ 300 行
## 红线约束
- 严禁使用 ON DELETE CASCADE，级联删除由代码事务控制
- 外键约束：仅 `question_record.quiz_question_id` 和 `controversy_id` 使用 ON DELETE SET NULL
- 迁移脚本：`init.sql` 仅在全新安装时执行，升级必须走 ALTER TABLE
## 实现要求
- 先读取 `DATA_CONTRACT.md` 和 `RELEASE_AND_UPDATE_CONVENTIONS.md`
- 基于 `DATA_CONTRACT.md` 第 3.5 节的级联删除顺序实现事务方法
- 基于 `DATA_CONTRACT.md` 第 3.3 节的命名规则实现表和索引
- 所有方法必须参数化，返回 Promise<T>
```
### T-1.2 Models 数据模型定义
```markdown
# 任务：定义全部数据模型
## 依赖
- 无
## 输入规范
- `DATA_CONTRACT.md` 第 1~2 节（枚举+接口）
## 输出文件
- `entry/src/main/ets/models/Models.ets`
## 验收标准
1. 7 个枚举：CourseStatus / BloomLevel / NodeType / MaterialType / MaterialStatus / AiRequestStatus / CorrectStatus
2. 8 个接口：Course / KnowledgeNode / KnowledgeEdge / QuizQuestion / Controversy / QuestionRecord / Material / AiRequestLog
3. QuestionRecord 的 3 个 | null 字段：quiz_question_id / controversy_id / standard_answer
4. QuestionRecord.ai_evaluation: string | null
5. Course.ai_summary_context: string | null
6. Material.parsed_content: string | null
7. KnowledgeNode.x_pos / y_pos 初始值 -1
8. QuizQuestion.options 主观题为空字符串 ""（严禁 null）
9. 无方法实现，纯类型定义
## 红线约束
- 字段类型必须与 `DATA_CONTRACT.md` 完全一致
- 枚举值必须与规范中的值域完全一致
- 联合类型字段（如 string | null）必须明确标注
## 实现要求
- 先读取 `DATA_CONTRACT.md` 第 1~2 节
- 按照规范定义所有枚举和接口
- 确保字段名使用 snake_case（与数据库字段一致）
```
### T-1.3 init.sql 建表脚本
```markdown
# 任务：编写 init.sql 建表脚本
## 依赖
- 无
## 输入规范
- `DATA_CONTRACT.md` 第 3.1~3.5 节
## 输出文件
- `entry/src/main/ets/db/init.sql`
## 验收标准
1. 8 张表：course / knowledge_node / knowledge_edge / quiz_question / controversy / question_record / material / ai_request_log
2. 9 个索引（含 idx_qrecord_controversy）
3. 主键 TEXT (UUID)，严禁自增
4. 外键约束（无 ON DELETE CASCADE，controversy_id 用 ON DELETE SET NULL）
5. 布尔字段 INTEGER，时间戳字段 INTEGER
## 红线约束
- 严禁使用 ON DELETE CASCADE
- 主键必须为 TEXT 类型，值为 UUID v4
- 布尔字段存储为 INTEGER（0=false, 1=true）
- 时间戳存储为 INTEGER（毫秒级13位数字）
## 实现要求
- 先读取 `DATA_CONTRACT.md` 第 3.1~3.5 节
- 按照规范中的表结构、字段名、类型、约束编写 SQL
- 索引命名遵循：idx_ + 表名缩写 + 字段名
```
### T-1.4 Logger 工具类
```markdown
# 任务：实现 Logger 工具类
## 依赖
- 无
## 输入规范
- `ERROR_LOG_CONVENTIONS.md`
## 输出文件
- `entry/src/main/ets/common/Logger.ets`
## 验收标准
1. info / warn / error 三个级别
2. 格式：`[TAG] message`，TAG 大写下划线
3. 日志写入本地 Markdown 文件（7天滚动）
4. 严禁 console.log
## 红线约束
- 日志必须包含6个字段：时间、Tag、动作、错误信息、堆栈、业务上下文
- Tag 必须使用规范中定义的清单（如 [AI_SERVICE], [BLOOM_VALIDATOR] 等）
- 严禁将堆栈信息弹窗给用户
- 严禁空 catch 块
## 实现要求
- 先读取 `ERROR_LOG_CONVENTIONS.md`
- 实现分级日志输出
- 实现本地 Markdown 文件写入（按天生成，7天保留）
- 实现全局异常捕获（UIAbility 中拦截）
```
### T-1.5 Config 环境配置
```markdown
# 任务：实现 Config 环境配置
## 依赖
- 无
## 输入规范
- `RELEASE_AND_UPDATE_CONVENTIONS.md` 第 1 节
## 输出文件
- `entry/src/main/ets/common/Config.ets`
## 验收标准
1. APP_VERSION / APP_VERSION_CODE / DB_VERSION
2. 开发/生产环境切换
3. 日志级别配置
## 实现要求
- 先读取 `RELEASE_AND_UPDATE_CONVENTIONS.md`
- 按照规范定义版本号和配置项
```
---
## 🔧 阶段 2：服务层（依赖阶段1）
### T-2.1 CourseService 课程 CRUD
```markdown
# 任务：实现 CourseService 课程 CRUD
## 依赖
- T-1.1, T-1.2
## 输入规范
- `DATA_CONTRACT.md` 2.1 Course + 3.4 级联删除
- `ARCHITECTURE_CONVENTIONS.md` Service 规则
## 输出文件
- `entry/src/main/ets/services/CourseService.ets`
## 验收标准
1. getCourses / getCourseById / createCourse / updateCourse / deleteCourse
2. cascadeDeleteCourse：事务内按 8 表顺序删除
3. calcQ1Progress：q1_total_core_count === 0 时返回 0（严禁除法）
4. 所有方法返回 Promise<T>
5. SQL 参数化，严禁字符串拼接
## 红线约束
- 级联删除必须在单个事务内按序执行：ai_request_log → question_record → quiz_question → controversy → knowledge_edge → knowledge_node → material → course
- 事务失败必须全部回滚
- 物理文件删除在事务提交后执行
- 严禁在 Service 中使用 @State
## 实现要求
- 先读取 `DATA_CONTRACT.md` 和 `ARCHITECTURE_CONVENTIONS.md`
- 使用 RdbHelper 提供的 CRUD 和事务方法
- 实现级联删除事务（注意顺序和事务包裹）
- 实现 Q1 进度计算（防除零）
```
### T-2.2 SSEStreamParser SSE 流解析器
```markdown
# 任务：实现 SSEStreamParser SSE 流解析器
## 依赖
- T-1.4
## 输入规范
- `AI_SERVICE_PROTOCOL.md` 第 2~3 节
## 输出文件
- `entry/src/main/ets/services/SSEStreamParser.ets`
## 验收标准
1. 实现 SSEStreamCallbacks 接口：onTextChunk / onJsonData / onError / onDone
2. string buffer 机制：仅遇 \n\n 截取解析
3. JSON 解析失败：丢弃 + Logger.error，不中断流程
4. 阶段 2 防护：jsonBufferStartTime + jsonBufferLength，跨阶段超时 15s 或超 5MB → onError + 关闭连接
5. 跨阶段超时：text 流结束后 15s 未收到 json → onError
6. [DONE] 标志处理
7. 单文件 ≤ 300 行
## 红线约束
- 必须维护 string buffer，仅当遇到 \n\n 时才截取解析
- JSON 解析失败时，必须丢弃并记日志，不能中断流程
- 跨阶段超时检测：text 流结束后 15s 未收到 json 事件 → 触发 onError
- JSON 体积检测：单次 JSON 字符数超过 5M → 触发 onError
- 分片乱序防护：若前一个 JSON 事件未处理完毕又收到新的 JSON 事件，丢弃旧数据
## 实现要求
- 先读取 `AI_SERVICE_PROTOCOL.md` 第 2~3 节
- 实现缓冲区机制（粘包/半包处理）
- 实现阶段流转判定（自动根据 type 字段分发）
- 实现防护校验（跨阶段超时、JSON 体积）
```
### T-2.3 AIConcurrencyLock 并发锁
```markdown
# 任务：实现 AIConcurrencyLock 并发锁
## 依赖
- 无
## 输入规范
- `AI_SERVICE_PROTOCOL.md` 第 5 节
## 输出文件
- `entry/src/main/ets/services/AIConcurrencyLock.ets`
## 验收标准
1. acquireLock：开头先调用 forceReleaseTimeout()
2. 锁超时 120000ms (120s)
3. releaseLock / forceReleaseTimeout / clearAllOnColdStart
4. 冷启动 EntryAbility.onCreate() 中调用 clearAllOnColdStart()
## 红线约束
- 锁超时时间必须为 120000ms，这是唯一权威值
- forceReleaseTimeout 必须在每次 acquireLock 开头调用
- 冷启动时必须调用 clearAllOnColdStart
## 实现要求
- 先读取 `AI_SERVICE_PROTOCOL.md` 第 5 节
- 实现 Map 锁状态管理
- 实现超时检测和强制释放
```
### T-2.4 GlobalRateLimiter 全局限流器
```markdown
# 任务：实现 GlobalRateLimiter 全局限流器
## 依赖
- 无
## 输入规范
- `API_SECURITY_CONVENTIONS.md` 1.3.2
## 输出文件
- `entry/src/main/ets/services/GlobalRateLimiter.ets`
## 验收标准
1. canRequest / recordRequest / getRemainingCount
2. 滑动窗口：10 次/分钟
3. 超限拦截 + 返回 false
## 实现要求
- 先读取 `API_SECURITY_CONVENTIONS.md`
- 实现滑动窗口限流逻辑
```
### T-2.5 NetworkMonitor 网络监听
```markdown
# 任务：实现 NetworkMonitor 网络监听
## 依赖
- 无
## 输入规范
- `API_SECURITY_CONVENTIONS.md` 1.3.3
## 输出文件
- `entry/src/main/ets/services/NetworkMonitor.ets`
## 验收标准
1. 使用 @kit.NetworkKit connection 模块
2. netAvailable / netLost 事件监听
3. isNetworkAvailable() 返回 boolean
## 实现要求
- 先读取 `API_SECURITY_CONVENTIONS.md`
- 实现网络状态监听
```
### T-2.6 ApiKeyStore API Key 加密存储
```markdown
# 任务：实现 ApiKeyStore API Key 加密存储
## 依赖
- 无
## 输入规范
- `API_SECURITY_CONVENTIONS.md` 1.1~1.2
## 输出文件
- `entry/src/main/ets/services/ApiKeyStore.ets`
## 验收标准
1. 使用 @ohos.security.huks 加密存储
2. saveApiKey / loadApiKey
3. 严禁明文存储
## 红线约束
- API Key 必须加密存储，严禁明文
- 解密后的明文 Key 仅存在于请求发起的函数作用域内
- 严禁将解密后的 API Key 赋值给任何 @State 或全局变量
- 日志中 API Key 必须脱敏
## 实现要求
- 先读取 `API_SECURITY_CONVENTIONS.md`
- 实现 HUKS 加密存储方案
```
### T-2.7 AIService AI 请求服务
```markdown
# 任务：实现 AIService AI 请求服务
## 依赖
- T-2.2, T-2.3, T-2.4, T-2.5, T-2.6
## 输入规范
- `AI_SERVICE_PROTOCOL.md` 全文 + `FEATURE_RULES.md` 防幻觉规则
## 输出文件
- `entry/src/main/ets/services/AIService.ets`
## 验收标准
1. 使用 @ohos.net.http 的 on('dataReceive') + on('dataEnd')
2. SSEStreamParser 集成
3. AIConcurrencyLock 集成（acquireLock → 请求 → releaseLock）
4. GlobalRateLimiter 集成（canRequest → recordRequest）
5. NetworkMonitor 集成（离线拦截）
6. ApiKeyStore 集成（解密读取 Key → Header）
7. Prompt 模板：注入 parsed_content + 知识节点列表 + 防幻觉约束
8. 日志脱敏：Key → ***
9. ai_request_log 记录（含 duration_ms）
10. connectTimeout 15s, readTimeout 60s
## 红线约束
- 必须使用 @ohos.net.http，严禁第三方网络库
- AI 并发锁：acquireLock 开头必须调用 forceReleaseTimeout
- Prompt 必须注入 parsed_content 和防幻觉约束
- AI 请求日志必须记录（含 duration_ms）
- API Key 必须脱敏
## 实现要求
- 先读取 `AI_SERVICE_PROTOCOL.md` 和 `FEATURE_RULES.md`
- 实现 SSE 连接建立、数据接收、连接关闭
- 集成各种服务（锁、限流、网络、Key存储）
- 实现 Prompt 模板和防幻觉校验
```
### T-2.8 MaterialParser 文件解析
```markdown
# 任务：实现 MaterialParser 文件解析
## 依赖
- T-1.1
## 输入规范
- `FEATURE_RULES.md` 2.1~2.2
## 输出文件
- `entry/src/main/ets/services/MaterialParser.ets`
## 验收标准
1. 仅支持 PDF / Markdown
2. 文件大小 ≤50MB
3. 扫描型 PDF 检测 + 强提示
4. 解析超时 10s
5. 解析失败 status=failed, parsed_content=null
## 红线约束
- 当前版本严禁端侧 PDF 解析，上传 PDF 将 status=FAILED，parsed_content=null
- 当所有资料 parsed_content 为 null 时，禁止启动三问
## 实现要求
- 先读取 `FEATURE_RULES.md`
- 实现文件格式校验、大小校验
- 实现扫描型 PDF 检测（当前版本：上传 PDF 即标记为失败）
```
### T-2.9 EvaluationService 评价报告
```markdown
# 任务：实现 EvaluationService 评价报告
## 依赖
- T-1.1, T-1.2
## 输入规范
- `FEATURE_RULES.md` 第 4 节
## 输出文件
- `entry/src/main/ets/services/EvaluationService.ets`
## 验收标准
1. 生成评价报告：Q1 占 20% / Q2 占 40% / Q3 占 40%
2. 布鲁姆层级得分计算
3. 导出 Markdown 格式
## 实现要求
- 先读取 `FEATURE_RULES.md`
- 实现评价报告生成和布鲁姆得分计算
- 实现 Markdown 导出
```
---
## 🧩 阶段 3：组件与 ViewModel（依赖阶段2）
### T-3.1 ManualInputBox 手动输入框
```markdown
# 任务：实现 ManualInputBox 手动输入框
## 依赖
- 无
## 输入规范
- `FEATURE_RULES.md` 1.1~1.2
## 输出文件
- `entry/src/main/ets/components/ManualInputBox.ets`
## 验收标准
1. 禁止粘贴（onPaste 拦截）
2. 禁止长按（.enableContextMenu(false)）
3. 速度检测：speed = text.length / ((Date.now() - startTime) / 1000) * 60
4. >150 字/分钟 → is_suspect = true
5. ≤5 字 → is_suspect = false（短文本豁免）
6. accessibilityDescription 设置
7. 单文件 ≤ 300 行
## 红线约束
- 严禁使用 copyOption，必须用 onPaste 拦截
- 速度检测必须从首次输入开始计时（排除思考时间）
- 短文本（≤5字）豁免，强制 is_suspect=false
## 实现要求
- 先读取 `FEATURE_RULES.md`
- 实现粘贴拦截、长按禁用
- 实现输入速度检测和可疑判定
- 添加无障碍描述
```
（后续组件提示词类似，此处省略以节省篇幅，完整版本请查看最终输出的完整提示词集合）
---
## 🖥️ 阶段 4：页面集成（依赖阶段3）
### T-4.1 HomePage 首页
```markdown
# 任务：实现 HomePage 首页
## 依赖
- T-3.6, T-3.7, T-3.10
## 输入规范
- `UI_ROUTING_CONVENTIONS.md` + `ARCHITECTURE_CONVENTIONS.md`
## 输出文件
- `entry/src/main/ets/pages/HomePage.ets`
## 验收标准
1. 课程列表（LazyForEach，数据 >20 时）
2. 创建课程入口
3. 课程卡片点击跳转详情
4. 删除确认 AlertDialog
5. aboutToAppear 加载数据，onDisappear 释放
6. 严禁直接调用 Service
## 红线约束
- 页面严禁直接调用 Service，必须通过 ViewModel
- 删除课程后必须 back 回首页，严禁 router.back 带参数
- 路由参数仅允许基本类型
## 实现要求
- 先读取 `UI_ROUTING_CONVENTIONS.md` 和 `ARCHITECTURE_CONVENTIONS.md`
- 使用 HomeViewModel 管理状态
- 实现课程列表渲染、创建入口、删除确认
```
（后续页面提示词类似）
---
## ✅ 阶段 5：集成与验证
### T-5.5 端到端流程验证
```markdown
# 任务：执行端到端流程验证
## 依赖
- T-5.1~T-5.4
## 输入规范
- 全部规范文档
## 输出
- 验证报告
## 验收标准
1. 创建课程 → AI 生成图谱 → Q1 点亮 → Q2 见解 → Q3 测评 → 评价报告 完整闭环
2. 真人作答拦截生效
3. 布鲁姆校验生效
4. 离线拦截生效
5. 全局限流生效
6. 课程级联删除数据完整
7. 冷启动后数据不丢失
## 实现要求
- 按照 checklist 逐项验证
- 记录验证结果和问题
```
---
## 📝 使用建议
1. **按顺序执行**：严格按照阶段1→2→3→4→5的顺序，因为存在依赖关系。
2. **每次一个任务**：每次只输入一个任务的提示词，完成后再进行下一个。
3. **注入规范上下文**：每个提示词都包含了必须遵循的规范文件，Trae 需要先读取这些文件再开始实现。
4. **检查验收标准**：每个任务完成后，对照验收标准进行检查。
5. **记录问题**：如果遇到规范冲突或实现问题，记录下来，并按照 `00_CONVENTIONS_INDEX.md` 中的优先级解决。
这套提示词策略将确保 Trae 能够高效、合规地完成项目开发，每个原子任务都有明确的输入、输出和验收标准，大大降低出错概率。
