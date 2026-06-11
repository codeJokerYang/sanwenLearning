# 三问高效学习机 — Trae 验收清单

> 本清单与 tasks_trae.md 一一对应，每项可独立验证。

---

## 阶段 1：基础设施

### T-1.1 RdbHelper
- [ ] 执行 init.sql 建表（8 表 + 9 索引）
- [ ] init.sql 仅 version=0 时执行
- [ ] CRUD 方法参数化（? 占位符）
- [ ] 事务方法 BEGIN/COMMIT/ROLLBACK
- [ ] 布尔转换 0/1 ↔ false/true
- [ ] 时间戳 cursor.getLong(idx).valueOf() → number
- [ ] NULL 判定 isColumnNull
- [ ] DB_VERSION = 1 + 迁移框架
- [ ] 单文件 ≤ 300 行

### T-1.2 Models
- [ ] 7 个枚举完整定义
- [ ] 8 个接口完整定义
- [ ] QuestionRecord 3 个 | null 字段（quiz_question_id / controversy_id / standard_answer）
- [ ] QuestionRecord.ai_evaluation: string | null
- [ ] Course.ai_summary_context: string | null
- [ ] Material.parsed_content: string | null
- [ ] KnowledgeNode.x_pos / y_pos 初始值 -1
- [ ] QuizQuestion.options 主观题 "" 严禁 null
- [ ] 无方法实现

### T-1.3 init.sql
- [ ] 8 张表创建
- [ ] 9 个索引创建（含 idx_qrecord_controversy）
- [ ] 主键 TEXT，无自增
- [ ] 无 ON DELETE CASCADE
- [ ] controversy_id ON DELETE SET NULL

### T-1.4 Logger
- [ ] info / warn / error 三级别
- [ ] [TAG] 格式
- [ ] 本地 Markdown 写入 + 7 天滚动
- [ ] 无 console.log

### T-1.5 Config
- [ ] APP_VERSION / APP_VERSION_CODE / DB_VERSION
- [ ] 环境/日志级别配置

---

## 阶段 2：服务层

### T-2.1 CourseService
- [ ] CRUD 5 方法
- [ ] cascadeDeleteCourse 事务内 8 表顺序删除
- [ ] calcQ1Progress 防除零
- [ ] 返回 Promise<T>
- [ ] SQL 参数化

### T-2.2 SSEStreamParser
- [ ] SSEStreamCallbacks 接口（onTextChunk / onJsonData / onError / onDone）
- [ ] string buffer + \n\n 截取
- [ ] JSON 解析失败丢弃 + Logger.error + 不中断
- [ ] 阶段 2 防护：跨阶段超时 15s 或 >5MB → onError + 关闭
- [ ] 跨阶段超时 15s
- [ ] [DONE] 处理

### T-2.3 AIConcurrencyLock
- [ ] acquireLock 开头调 forceReleaseTimeout
- [ ] 锁超时 120000ms
- [ ] releaseLock / forceReleaseTimeout / clearAllOnColdStart
- [ ] 冷启动调用 clearAllOnColdStart

### T-2.4 GlobalRateLimiter
- [ ] canRequest / recordRequest / getRemainingCount
- [ ] 滑动窗口 10 次/分钟
- [ ] 超限返回 false

### T-2.5 NetworkMonitor
- [ ] connection.createNetConnection
- [ ] netAvailable / netLost 监听
- [ ] isNetworkAvailable()

### T-2.6 ApiKeyStore
- [ ] HUKS 加密存储
- [ ] saveApiKey / loadApiKey
- [ ] 无明文存储

### T-2.7 AIService
- [ ] @ohos.net.http + on('dataReceive') + on('dataEnd')
- [ ] SSEStreamParser 集成
- [ ] AIConcurrencyLock 集成
- [ ] GlobalRateLimiter 集成
- [ ] NetworkMonitor 集成（离线拦截）
- [ ] ApiKeyStore 集成（解密 → Header）
- [ ] Prompt 注入 parsed_content + 知识节点列表 + 防幻觉
- [ ] 日志脱敏 Key → ***
- [ ] ai_request_log 记录
- [ ] connectTimeout 15s, readTimeout 60s

### T-2.8 MaterialParser
- [ ] 仅 PDF / Markdown
- [ ] ≤50MB 限制
- [ ] 扫描型 PDF 检测 + 提示
- [ ] 解析超时 10s
- [ ] 失败 status=failed, parsed_content=null

### T-2.9 EvaluationService
- [ ] 评分比例 Q1:20% / Q2:40% / Q3:40%
- [ ] 布鲁姆层级得分
- [ ] 导出 Markdown

---

## 阶段 3：组件与 ViewModel

### T-3.1 ManualInputBox
- [ ] 禁止粘贴
- [ ] 禁止长按（.enableContextMenu(false)）
- [ ] 速度计算：speed = text.length / ((now - startTime) / 1000) * 60
- [ ] >150 字/分钟 → is_suspect = true
- [ ] ≤5 字 → is_suspect = false
- [ ] accessibilityDescription

### T-3.2 ChatBubble
- [ ] 逐字渲染
- [ ] 光标闪烁
- [ ] accessibilityText

### T-3.3 ThreeAskStepper
- [ ] 3 步显示 + 高亮 + 打勾 + 置灰

### T-3.4 RadarChart
- [ ] Canvas 6 轴雷达图
- [ ] 数据驱动
- [ ] 非每帧重绘

### T-3.5 DebateCard
- [ ] 左右分栏观点 A/B
- [ ] 证据展示
- [ ] Checkbox + ManualInputBox
- [ ] accessibilityText

### T-3.6 CourseCard
- [ ] 标题/状态/进度/步骤展示
- [ ] @Prop + 回调，无 Service 调用

### T-3.7 ProgressBar
- [ ] 0~100% + 动画过渡

### T-3.8 PuzzleFragmentAnim
- [ ] 碎片→点亮动画
- [ ] animateTo ≤500ms

### T-3.9 MindBadgeAnim
- [ ] 勋章解锁动画
- [ ] animateTo ≤500ms

### T-3.10 HomeViewModel
- [ ] @State courseList / isLoading / errorMessage
- [ ] loadCourses / deleteCourse / selectCourse
- [ ] try-catch + isLoading 管理
- [ ] 无 UI 组件导入

### T-3.11 ThreeAskViewModel
- [ ] Q1 激活节点 → CORE 全点亮判定
- [ ] Q2 提交见解 → AI 评价 → 判定完成
- [ ] Q3 请求 9 题 → 布鲁姆校验 → 作答 → 判定完成
- [ ] 状态流转严禁跳步
- [ ] 布鲁姆校验 1/2/2/2/1/1 + 重试上限 2 次
- [ ] is_suspect 计算
- [ ] 无 UI 组件导入

### T-3.12 CourseViewModel
- [ ] 课程详情加载 / 级联删除
- [ ] 进度计算防除零
- [ ] try-catch + isLoading

### T-3.13 EvaluationViewModel
- [ ] 报告生成 / 导出
- [ ] 布鲁姆得分计算

---

## 阶段 4：页面集成

### T-4.1 HomePage
- [ ] 课程列表 LazyForEach（>20 条时）
- [ ] 创建课程入口
- [ ] 卡片点击跳转
- [ ] 删除确认 AlertDialog
- [ ] aboutToAppear 加载 / onDisappear 释放
- [ ] 无直接 Service 调用

### T-4.2 KnowledgeGraph（Q1）
- [ ] Canvas 连线 + @Component 节点
- [ ] 力导向 200 次迭代后一次性 @State 更新
- [ ] 节点点击激活 + 碎片动画
- [ ] 降级：≤50 正常 / 51~100 关动画 / >100 文本列表
- [ ] onDisappear: nodes=[], edges=[]
- [ ] [PERF] Force layout 日志

### T-4.3 LearningSpace（Q2）
- [ ] 争议卡片 + 见解输入
- [ ] AI 评价逐字渲染
- [ ] ManualInputBox 禁粘贴 + 速度检测
- [ ] 跳过评价（15s 超时后显示）

### T-4.4 Assessment（Q3）
- [ ] 9 题逐题作答
- [ ] 客观题选项 + 主观题 ManualInputBox
- [ ] 布鲁姆校验失败 Toast
- [ ] is_suspect 标记

### T-4.5 AssessmentResult
- [ ] 雷达图布鲁姆得分
- [ ] Q1/Q2/Q3 分项得分
- [ ] 导出 Markdown
- [ ] onDisappear 释放大对象

---

## 阶段 5：集成与验证

### T-5.1 EntryAbility
- [ ] onCreate: clearAllOnColdStart()
- [ ] NetworkMonitor.startMonitoring()
- [ ] RdbHelper 初始化

### T-5.2 AnalyticsService
- [ ] analytics_event 表
- [ ] logEvent 方法
- [ ] sessionId 管理
- [ ] 90 天清理
- [ ] AI 失败→埋点，UI/DB 异常→ERROR_LOG（二选一）

### T-5.3 国际化资源
- [ ] $r 引用，无硬编码中文（5 种例外除外）
- [ ] 资源键命名规范
- [ ] 中英文资源齐全

### T-5.4 路由注册
- [ ] 5 页面注册
- [ ] router.back() 无参数
- [ ] 参数通过 ViewModel 传递

### T-5.5 端到端验证
- [ ] 创建→图谱→Q1→Q2→Q3→报告 完整闭环
- [ ] 真人作答拦截：粘贴被拦 + >150字/分标记 suspect
- [ ] 布鲁姆校验：分布 1/2/2/2/1/1 + 重试上限 2 次
- [ ] 离线拦截：断网后 AI 请求按钮置灰
- [ ] 全局限流：连续 11 次请求第 11 次被拦
- [ ] 级联删除：删课程后 8 表数据清除
- [ ] 冷启动：关闭重开数据不丢失 + 锁状态清空
