# 三问高效学习机 — Trae 原子任务视图

> 本文件将 tasks.md 中的大任务拆分为 Trae 可一次完成的原子任务。
> 每个任务包含：依赖、输入、输出、验收标准。

---

## 阶段 1：基础设施（无依赖）

### T-1.1 RdbHelper 数据库封装

- **依赖**：无
- **输入**：`DATA_CONTRACT.md` 3.1~3.5 节（8 表 + 9 索引 + 级联删除）
- **输出**：`entry/src/main/ets/db/RdbHelper.ets`
- **验收标准**：
  - [ ] 执行 `init.sql` 建表（8 表 + 9 索引）
  - [ ] `init.sql` 仅在 `version === 0` 时执行
  - [ ] 通用 CRUD 方法：insert / query / update / delete / execute（参数化）
  - [ ] 事务方法：executeInTransaction（BEGIN/COMMIT/ROLLBACK）
  - [ ] 布尔转换：0/1 ↔ false/true
  - [ ] 时间戳读取：cursor.getLong(idx).valueOf() → number
  - [ ] NULL 判定：isColumnNull + 联合类型字段正确处理
  - [ ] DB_VERSION = 1，迁移框架（migrate + executeMigration）
  - [ ] 单文件 ≤ 300 行

### T-1.2 Models 数据模型定义

- **依赖**：无
- **输入**：`DATA_CONTRACT.md` 第 1~2 节（枚举 + 接口）
- **输出**：`entry/src/main/ets/models/Models.ets`
- **验收标准**：
  - [ ] 7 个枚举：CourseStatus / BloomLevel / NodeType / MaterialType / MaterialStatus / AiRequestStatus / CorrectStatus
  - [ ] 8 个接口：Course / KnowledgeNode / KnowledgeEdge / QuizQuestion / Controversy / QuestionRecord / Material / AiRequestLog
  - [ ] QuestionRecord.quiz_question_id: string | null
  - [ ] QuestionRecord.controversy_id: string | null
  - [ ] QuestionRecord.ai_evaluation: string | null
  - [ ] QuestionRecord.standard_answer: string | null
  - [ ] Material.parsed_content: string | null
  - [ ] Course.ai_summary_context: string | null
  - [ ] KnowledgeNode.x_pos / y_pos 初始值 -1
  - [ ] QuizQuestion.options 主观题为空字符串 ""（严禁 null）
  - [ ] 无方法实现，纯类型定义

### T-1.3 init.sql 建表脚本

- **依赖**：无
- **输入**：`DATA_CONTRACT.md` 第 3 节
- **输出**：`entry/src/main/ets/db/init.sql`
- **验收标准**：
  - [ ] 8 张表：course / knowledge_node / knowledge_edge / quiz_question / controversy / question_record / material / ai_request_log
  - [ ] 9 个索引（含 idx_qrecord_controversy）
  - [ ] 主键 TEXT (UUID)，严禁自增
  - [ ] 外键约束（无 ON DELETE CASCADE，controversy_id 用 ON DELETE SET NULL）
  - [ ] 布尔字段 INTEGER，时间戳字段 INTEGER

### T-1.4 Logger 工具类

- **依赖**：无
- **输入**：`ERROR_LOG_CONVENTIONS.md`
- **输出**：`entry/src/main/ets/common/Logger.ets`
- **验收标准**：
  - [ ] info / warn / error 三个级别
  - [ ] 格式：`[TAG] message`，TAG 大写下划线
  - [ ] 日志写入本地 Markdown 文件（7 天滚动）
  - [ ] 严禁 console.log

### T-1.5 Config 环境配置

- **依赖**：无
- **输入**：`RELEASE_AND_UPDATE_CONVENTIONS.md` 第 1 节
- **输出**：`entry/src/main/ets/common/Config.ets`
- **验收标准**：
  - [ ] APP_VERSION / APP_VERSION_CODE / DB_VERSION
  - [ ] 开发/生产环境切换
  - [ ] 日志级别配置

---

## 阶段 2：服务层（依赖阶段 1）

### T-2.1 CourseService 课程 CRUD

- **依赖**：T-1.1, T-1.2
- **输入**：`DATA_CONTRACT.md` 2.1 Course + 3.4 级联删除
- **输出**：`entry/src/main/ets/services/CourseService.ets`
- **验收标准**：
  - [ ] getCourses / getCourseById / createCourse / updateCourse / deleteCourse
  - [ ] cascadeDeleteCourse：事务内按 8 表顺序删除
  - [ ] calcQ1Progress：q1_total_core_count === 0 时返回 0（严禁除法）
  - [ ] 所有方法返回 Promise<T>
  - [ ] SQL 参数化，严禁字符串拼接

### T-2.2 SSEStreamParser SSE 流解析器

- **依赖**：T-1.4
- **输入**：`AI_SERVICE_PROTOCOL.md` 第 2~3 节
- **输出**：`entry/src/main/ets/services/SSEStreamParser.ets`
- **验收标准**：
  - [ ] 实现 SSEStreamCallbacks 接口：onTextChunk / onJsonData / onError / onDone
  - [ ] string buffer 机制：仅遇 \n\n 截取解析
  - [ ] JSON 解析失败：丢弃 + Logger.error，不中断流程
  - [ ] 阶段 2 防护：jsonBufferStartTime + jsonBufferLength，跨阶段超时 15s 或超 5MB → onError + 关闭连接
  - [ ] 跨阶段超时：text 流结束后 15s 未收到 json → onError
  - [ ] [DONE] 标志处理
  - [ ] 单文件 ≤ 300 行

### T-2.3 AIConcurrencyLock 并发锁

- **依赖**：无
- **输入**：`AI_SERVICE_PROTOCOL.md` 第 5 节
- **输出**：`entry/src/main/ets/services/AIConcurrencyLock.ets`
- **验收标准**：
  - [ ] acquireLock：开头先调用 forceReleaseTimeout()
  - [ ] 锁超时 120000ms (120s)
  - [ ] releaseLock / forceReleaseTimeout / clearAllOnColdStart
  - [ ] 冷启动 EntryAbility.onCreate() 中调用 clearAllOnColdStart()

### T-2.4 GlobalRateLimiter 全局限流器

- **依赖**：无
- **输入**：`API_SECURITY_CONVENTIONS.md` 1.3.2
- **输出**：`entry/src/main/ets/services/GlobalRateLimiter.ets`
- **验收标准**：
  - [ ] canRequest / recordRequest / getRemainingCount
  - [ ] 滑动窗口：10 次/分钟
  - [ ] 超限拦截 + 返回 false

### T-2.5 NetworkMonitor 网络监听

- **依赖**：无
- **输入**：`API_SECURITY_CONVENTIONS.md` 1.3.3
- **输出**：`entry/src/main/ets/services/NetworkMonitor.ets`
- **验收标准**：
  - [ ] 使用 @kit.NetworkKit connection 模块
  - [ ] netAvailable / netLost 事件监听
  - [ ] isNetworkAvailable() 返回 boolean

### T-2.6 ApiKeyStore API Key 加密存储

- **依赖**：无
- **输入**：`API_SECURITY_CONVENTIONS.md` 1.1~1.2
- **输出**：`entry/src/main/ets/services/ApiKeyStore.ets`
- **验收标准**：
  - [ ] 使用 @ohos.security.huks 加密存储
  - [ ] saveApiKey / loadApiKey
  - [ ] 严禁明文存储

### T-2.7 AIService AI 请求服务

- **依赖**：T-2.2, T-2.3, T-2.4, T-2.5, T-2.6
- **输入**：`AI_SERVICE_PROTOCOL.md` 全文 + `FEATURE_RULES.md` 防幻觉规则
- **输出**：`entry/src/main/ets/services/AIService.ets`
- **验收标准**：
  - [ ] 使用 @ohos.net.http 的 on('dataReceive') + on('dataEnd')
  - [ ] SSEStreamParser 集成
  - [ ] AIConcurrencyLock 集成（acquireLock → 请求 → releaseLock）
  - [ ] GlobalRateLimiter 集成（canRequest → recordRequest）
  - [ ] NetworkMonitor 集成（离线拦截）
  - [ ] ApiKeyStore 集成（解密读取 Key → Header）
  - [ ] Prompt 模板：注入 parsed_content + 知识节点列表 + 防幻觉约束
  - [ ] 日志脱敏：Key → ***
  - [ ] ai_request_log 记录（含 duration_ms）
  - [ ] connectTimeout 15s, readTimeout 60s

### T-2.8 MaterialParser 文件解析

- **依赖**：T-1.1
- **输入**：`FEATURE_RULES.md` 2.1~2.2
- **输出**：`entry/src/main/ets/services/MaterialParser.ets`
- **验收标准**：
  - [ ] 仅支持 PDF / Markdown
  - [ ] 文件大小 ≤50MB
  - [ ] 扫描型 PDF 检测 + 强提示
  - [ ] 解析超时 10s
  - [ ] 解析失败 status=failed, parsed_content=null

### T-2.9 EvaluationService 评价报告

- **依赖**：T-1.1, T-1.2
- **输入**：`FEATURE_RULES.md` 第 4 节
- **输出**：`entry/src/main/ets/services/EvaluationService.ets`
- **验收标准**：
  - [ ] 生成评价报告：Q1 占 20% / Q2 占 40% / Q3 占 40%
  - [ ] 布鲁姆层级得分计算
  - [ ] 导出 Markdown 格式

---

## 阶段 3：组件与 ViewModel（依赖阶段 2）

### T-3.1 ManualInputBox 手动输入框

- **依赖**：无
- **输入**：`FEATURE_RULES.md` 1.1~1.2
- **输出**：`entry/src/main/ets/components/ManualInputBox.ets`
- **验收标准**：
  - [ ] 禁止粘贴（onPaste 拦截）
  - [ ] 禁止长按（.enableContextMenu(false)）
  - [ ] 速度检测：speed = text.length / ((Date.now() - startTime) / 1000) * 60
  - [ ] >150 字/分钟 → is_suspect = true
  - [ ] ≤5 字 → is_suspect = false（短文本豁免）
  - [ ] accessibilityDescription 设置
  - [ ] 单文件 ≤ 300 行

### T-3.2 ChatBubble AI 对话气泡

- **依赖**：无
- **输入**：`FEATURE_RULES.md` 1.3
- **输出**：`entry/src/main/ets/components/ChatBubble.ets`
- **验收标准**：
  - [ ] 逐字渲染效果（@State textContent 逐字追加）
  - [ ] 光标闪烁动画
  - [ ] accessibilityText 设置

### T-3.3 ThreeAskStepper 三问步骤条

- **依赖**：无
- **输入**：`FEATURE_RULES.md` 三问流转
- **输出**：`entry/src/main/ets/components/ThreeAskStepper.ets`
- **验收标准**：
  - [ ] 3 步显示：Q1 知识探索 / Q2 深度思辨 / Q3 深度测评
  - [ ] 当前步骤高亮，已完成步骤打勾
  - [ ] 未到达步骤置灰

### T-3.4 RadarChart 能力雷达图

- **依赖**：无
- **输入**：`FEATURE_RULES.md` 4.2
- **输出**：`entry/src/main/ets/components/RadarChart.ets`
- **验收标准**：
  - [ ] Canvas 绘制 6 轴雷达图（布鲁姆 6 层级）
  - [ ] 数据驱动渲染
  - [ ] 严禁每帧重绘

### T-3.5 DebateCard 争议分析卡片

- **依赖**：无
- **输入**：`FEATURE_RULES.md` Q2 争议分析
- **输出**：`entry/src/main/ets/components/DebateCard.ets`
- **验收标准**：
  - [ ] 左右分栏展示观点 A / 观点 B
  - [ ] 证据展示区
  - [ ] Checkbox 选择 + ManualInputBox 见解输入
  - [ ] accessibilityText 设置

### T-3.6 CourseCard 课程卡片

- **依赖**：无
- **输入**：`DATA_CONTRACT.md` 2.1 Course
- **输出**：`entry/src/main/ets/components/CourseCard.ets`
- **验收标准**：
  - [ ] 展示：标题 / 状态标签 / 进度条 / 三问步骤指示
  - [ ] @Prop course 传入，回调 onCardClick / onDeleteClick
  - [ ] 严禁直接调用 Service

### T-3.7 ProgressBar 进度条

- **依赖**：无
- **输入**：`DATA_CONTRACT.md` 2.1 进度映射
- **输出**：`entry/src/main/ets/components/ProgressBar.ets`
- **验收标准**：
  - [ ] 0~100% 进度展示
  - [ ] @Prop progress 传入
  - [ ] 动画过渡

### T-3.8 PuzzleFragmentAnim 碎片动画

- **依赖**：无
- **输入**：`FEATURE_RULES.md` 3.2
- **输出**：`entry/src/main/ets/components/PuzzleFragmentAnim.ets`
- **验收标准**：
  - [ ] 碎片态 → 点亮态动画
  - [ ] animateTo 时长 ≤500ms
  - [ ] 同时播放动画 ≤5 个

### T-3.9 MindBadgeAnim 勋章动画

- **依赖**：无
- **输入**：`FEATURE_RULES.md` 3.2
- **输出**：`entry/src/main/ets/components/MindBadgeAnim.ets`
- **验收标准**：
  - [ ] 勋章解锁动画
  - [ ] animateTo 时长 ≤500ms

### T-3.10 HomeViewModel 首页状态管理

- **依赖**：T-2.1
- **输入**：`ARCHITECTURE_CONVENTIONS.md` ViewModel 规则
- **输出**：`entry/src/main/ets/viewmodels/HomeViewModel.ets`
- **验收标准**：
  - [ ] @State courseList / isLoading / errorMessage
  - [ ] loadCourses / deleteCourse / selectCourse
  - [ ] 异步操作 try-catch + isLoading 管理
  - [ ] 严禁导入 UI 组件

### T-3.11 ThreeAskViewModel 三问流程编排

- **依赖**：T-2.1, T-2.7, T-2.9
- **输入**：`FEATURE_RULES.md` 三问流转 + `AI_SERVICE_PROTOCOL.md`
- **输出**：`entry/src/main/ets/viewmodels/ThreeAskViewModel.ets`
- **验收标准**：
  - [ ] Q1：激活节点 → 判定完成（CORE 全点亮）
  - [ ] Q2：提交见解 → AI 评价 → 判定完成
  - [ ] Q3：请求 9 题 → 布鲁姆校验 → 作答 → 判定完成
  - [ ] 状态流转：严禁跳步
  - [ ] 布鲁姆校验：分布 1/2/2/2/1/1，重试上限 2 次
  - [ ] 真人作答：is_suspect 计算
  - [ ] 严禁导入 UI 组件

### T-3.12 CourseViewModel 课程详情状态管理

- **依赖**：T-2.1
- **输入**：`ARCHITECTURE_CONVENTIONS.md` ViewModel 规则
- **输出**：`entry/src/main/ets/viewmodels/CourseViewModel.ets`
- **验收标准**：
  - [ ] 课程详情加载 / 级联删除
  - [ ] 进度计算（防除零）
  - [ ] 异步操作 try-catch + isLoading

### T-3.13 EvaluationViewModel 评价报告状态管理

- **依赖**：T-2.9
- **输入**：`FEATURE_RULES.md` 第 4 节
- **输出**：`entry/src/main/ets/viewmodels/EvaluationViewModel.ets`
- **验收标准**：
  - [ ] 报告生成 / 导出
  - [ ] 布鲁姆得分计算

---

## 阶段 4：页面集成（依赖阶段 3）

### T-4.1 HomePage 首页

- **依赖**：T-3.6, T-3.7, T-3.10
- **输入**：`UI_ROUTING_CONVENTIONS.md` + `ARCHITECTURE_CONVENTIONS.md`
- **输出**：`entry/src/main/ets/pages/HomePage.ets`
- **验收标准**：
  - [ ] 课程列表（LazyForEach，数据 >20 时）
  - [ ] 创建课程入口
  - [ ] 课程卡片点击跳转详情
  - [ ] 删除确认 AlertDialog
  - [ ] aboutToAppear 加载数据，onDisappear 释放
  - [ ] 严禁直接调用 Service

### T-4.2 KnowledgeGraph 知识图谱页（Q1）

- **依赖**：T-3.8, T-3.11
- **输入**：`FEATURE_RULES.md` 3.1 力导向 + `PERFORMANCE_CONVENTIONS.md`
- **输出**：`entry/src/main/ets/pages/KnowledgeGraph.ets`
- **验收标准**：
  - [ ] Canvas 画连线 + @Component 画节点
  - [ ] 力导向布局：200 次迭代后一次性更新 @State
  - [ ] 节点点击激活 + 碎片动画
  - [ ] 降级策略：≤50 正常 / 51~100 关闭动画 / >100 文本列表
  - [ ] onDisappear: nodes=[], edges=[]
  - [ ] 性能日志：[PERF] Force layout computed in Xms

### T-4.3 LearningSpace 学习空间页（Q2）

- **依赖**：T-3.5, T-3.2, T-3.1, T-3.11
- **输入**：`FEATURE_RULES.md` Q2 争议分析
- **输出**：`entry/src/main/ets/pages/LearningSpace.ets`
- **验收标准**：
  - [ ] 争议卡片列表 + 见解输入
  - [ ] AI 评价逐字渲染
  - [ ] ManualInputBox 禁粘贴 + 速度检测
  - [ ] 跳过评价功能（超时 15s 后显示）

### T-4.4 Assessment 深度测评页（Q3）

- **依赖**：T-3.1, T-3.11
- **输入**：`FEATURE_RULES.md` Q3 测评 + 布鲁姆校验
- **输出**：`entry/src/main/ets/pages/Assessment.ets`
- **验收标准**：
  - [ ] 9 题逐题作答
  - [ ] 客观题选项 + 主观题 ManualInputBox
  - [ ] 布鲁姆校验失败 Toast 提示
  - [ ] is_suspect 标记

### T-4.5 AssessmentResult 评价报告页

- **依赖**：T-3.4, T-3.13
- **输入**：`FEATURE_RULES.md` 第 4 节
- **输出**：`entry/src/main/ets/pages/AssessmentResult.ets`
- **验收标准**：
  - [ ] 雷达图展示布鲁姆得分
  - [ ] Q1/Q2/Q3 分项得分
  - [ ] 导出 Markdown 按钮
  - [ ] onDisappear 释放大对象

---

## 阶段 5：集成与验证（依赖阶段 4）

### T-5.1 EntryAbility 冷启动初始化

- **依赖**：T-2.3, T-2.5
- **输入**：`AI_SERVICE_PROTOCOL.md` 5.4
- **输出**：修改 `entry/src/main/ets/entryability/EntryAbility.ets`
- **验收标准**：
  - [ ] onCreate: clearAllOnColdStart()
  - [ ] NetworkMonitor.startMonitoring()
  - [ ] RdbHelper 初始化

### T-5.2 AnalyticsService 埋点服务

- **依赖**：T-1.1
- **输入**：`ANALYTICS_CONVENTIONS.md`
- **输出**：`entry/src/main/ets/services/AnalyticsService.ets`
- **验收标准**：
  - [ ] analytics_event 表创建
  - [ ] logEvent 方法
  - [ ] sessionId 管理
  - [ ] 90 天清理逻辑
  - [ ] 与 ERROR_LOG 边界：AI 失败→埋点，UI/DB 异常→ERROR_LOG

### T-5.3 资源文件国际化

- **依赖**：无
- **输入**：`I18N_AND_A11Y_CONVENTIONS.md`
- **输出**：`entry/src/main/resources/base/element/string.json` + `en_US/` + `zh_Hans/`
- **验收标准**：
  - [ ] 所有面向用户文案通过 $r 引用
  - [ ] 资源键命名：btn_ / page_title_ / placeholder_ / dialog_ / toast_ / label_ / error_ / status_ / a11y_ / a11y_desc_
  - [ ] 中英文资源文件齐全

### T-5.4 路由注册与页面跳转

- **依赖**：T-4.1~T-4.5
- **输入**：`UI_ROUTING_CONVENTIONS.md`
- **输出**：修改 `main_pages.json` + 各页面 router 调用
- **验收标准**：
  - [ ] 5 个页面注册
  - [ ] router.back() 严禁带参
  - [ ] 页面跳转参数通过 ViewModel 传递

### T-5.5 端到端流程验证

- **依赖**：T-5.1~T-5.4
- **输入**：全部规范文档
- **输出**：验证报告
- **验收标准**：
  - [ ] 创建课程 → AI 生成图谱 → Q1 点亮 → Q2 见解 → Q3 测评 → 评价报告 完整闭环
  - [ ] 真人作答拦截生效
  - [ ] 布鲁姆校验生效
  - [ ] 离线拦截生效
  - [ ] 全局限流生效
  - [ ] 课程级联删除数据完整
  - [ ] 冷启动后数据不丢失
