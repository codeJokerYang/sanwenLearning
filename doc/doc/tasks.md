# 三问高效学习机 — 编码任务规划

> 版本：v1.0 | 日期：2026-06-03 | 基于 spec.md v2.1 + design.md v1.1

---

## 任务总览

| 统计项 | 数量 |
|--------|------|
| 主任务组 | 17 |
| 子任务总数 | 82 |
| P0（核心阻塞） | 31 |
| P1（重要） | 35 |
| P2（优化） | 16 |
| 覆盖需求 | REQ-FC-01~53 + REQ-NF全系列 |

---

## 1. 项目基础设施与配置

- [ ] **T01-01** 搭建HarmonyOS NEXT项目脚手架，配置Stage模型、API 12+目标版本
  - 涉及文件：`entry/src/main/module.json5`, `oh-package.json5`, `build-profile.json5`
  - 依赖任务：无
  - 优先级：P0
  - 验收标准：项目可编译运行，Stage模型生命周期正常
  - 预估复杂度：低

- [ ] **T01-02** 声明ohos.permission.INTERNET网络权限（REQ-NF-A01）
  - 涉及文件：`entry/src/main/module.json5`
  - 依赖任务：T01-01
  - 优先级：P0
  - 验收标准：module.json5中包含INTERNET权限声明
  - 预估复杂度：低

- [ ] **T01-03** 创建项目目录结构（pages/components/viewmodels/services/models/db/common）
  - 涉及文件：全部目录骨架
  - 依赖任务：T01-01
  - 优先级：P0
  - 验收标准：目录结构与design.md第6章一致
  - 预估复杂度：低

- [ ] **T01-04** 创建公共工具模块（constants.ets/Config.ets/Logger.ets/EventBus.ets/utils.ets）
  - 涉及文件：`entry/src/main/ets/common/`下全部文件
  - 依赖任务：T01-03
  - 优先级：P0
  - 验收标准：Logger可输出分级日志，EventBus可发布/订阅事件，utils含UUID生成
  - 预估复杂度：中

---

## 2. 数据库层（RdbHelper + init.sql）

- [ ] **T02-01** 编写database/init.sql建表脚本（8表+索引）（REQ-NF-D01/D02/D04）
  - 涉及文件：`database/init.sql`
  - 依赖任务：T01-03
  - 优先级：P0
  - 验收标准：8张表（course/material/knowledge_node/knowledge_edge/controversy/quiz_question/question_record/ai_request_log）+7个索引，外键不使用ON DELETE CASCADE
  - 预估复杂度：中

- [ ] **T02-02** 实现RdbHelper封装（getRdbStore/事务/executeSql/CRUD通用方法）（REQ-NF-R02/R03）
  - 涉及文件：`entry/src/main/ets/db/RdbHelper.ets`
  - 依赖任务：T02-01
  - 优先级：P0
  - 验收标准：首次启动执行init.sql建表，事务操作原子性保障，重启后数据不丢失
  - 预估复杂度：高

- [ ] **T02-03** 实现级联删除事务方法（cascadeDelete：按序删除7张关联表+course+物理文件）（REQ-FC-14, REQ-NF-R04）
  - 涉及文件：`entry/src/main/ets/db/RdbHelper.ets`
  - 依赖任务：T02-02
  - 优先级：P0
  - 验收标准：删除课程时事务内按序删除ai_request_log→question_record→quiz_question→controversy→knowledge_edge→knowledge_node→material→course，事务失败全部回滚
  - 预估复杂度：高

---

## 3. 模型层（ArkTS强类型接口）

- [ ] **T03-01** 定义全部ArkTS模型接口（CourseModel/MaterialModel/KnowledgeNodeModel/KnowledgeEdgeModel/ControversyModel/QuizQuestionModel/QuestionRecordModel/AiRequestLogModel）及枚举类型（CourseStatus/MaterialType/MaterialStatus/NodeType/BloomLevel/CorrectStatus/LogStatus）
  - 涉及文件：`entry/src/main/ets/models/Models.ets`
  - 依赖任务：T01-03
  - 优先级：P0
  - 验收标准：interface字段与init.sql表结构一一对应，枚举值域与spec.md数据约束一致
  - 预估复杂度：中

- [ ] **T03-02** 定义EvaluationReportModel接口及ParsedResult接口
  - 涉及文件：`entry/src/main/ets/models/Models.ets`
  - 依赖任务：T03-01
  - 优先级：P1
  - 验收标准：EvaluationReport包含五大章节字段，ParsedResult包含success/content/isScanned/error
  - 预估复杂度：低

---

## 4. 服务层 — 课程管理（CourseService）

- [ ] **T04-01** 实现CourseService.createCourse()（创建课程，status=已创建, current_step=0）（REQ-FC-01）
  - 涉及文件：`entry/src/main/ets/services/CourseService.ets`
  - 依赖任务：T02-02, T03-01
  - 优先级：P0
  - 验收标准：提交问题→课程记录创建（status=1, current_step=0, progress=0），返回CourseModel
  - 预估复杂度：中

- [ ] **T04-02** 实现CourseService.getAllCourses()/getCourseById()（查询课程列表/详情）（REQ-FC-04）
  - 涉及文件：`entry/src/main/ets/services/CourseService.ets`
  - 依赖任务：T04-01
  - 优先级：P0
  - 验收标准：返回课程列表，按create_time倒序
  - 预估复杂度：低

- [ ] **T04-03** 实现CourseService.updateCourseStep()/updateCourseProgress()/updateQ1Counts()（进度与状态更新）（REQ-FC-05~13, REQ-FC-21）
  - 涉及文件：`entry/src/main/ets/services/CourseService.ets`
  - 依赖任务：T04-01
  - 优先级：P0
  - 验收标准：current_step按0→1→2→3→4流转，progress按Q1=33/Q2=66/Q3=100更新，q1计数正确递增
  - 预估复杂度：中

- [ ] **T04-04** 实现CourseService.cascadeDeleteCourse()（级联删除+物理文件清理）（REQ-FC-14, REQ-NF-R04）
  - 涉及文件：`entry/src/main/ets/services/CourseService.ets`
  - 依赖任务：T02-03, T04-01
  - 优先级：P0
  - 验收标准：删除课程→事务内删除7张关联表记录→调用FilePoolService删除物理文件→全部成功commit，任一失败rollback
  - 预估复杂度：高

- [ ] **T04-05** 实现CourseService.updateAiSummaryContext()（AI摘要上下文异步更新）（REQ-FC-03）
  - 涉及文件：`entry/src/main/ets/services/CourseService.ets`
  - 依赖任务：T04-01
  - 优先级：P1
  - 验收标准：AI Agent回调后ai_summary_context字段正确更新
  - 预估复杂度：低

---

## 5. 服务层 — AI服务与SSE流式传输

- [ ] **T05-01** 实现AIConcurrencyLock（Map锁状态管理 + acquireLock/releaseLock/forceReleaseTimeout/clearAllOnColdStart）（REQ-FC-35/36, REQ-NF-CC01/02）
  - 涉及文件：`entry/src/main/ets/services/AIConcurrencyLock.ets`
  - 依赖任务：T01-04
  - 优先级：P0
  - 验收标准：同课程同时仅一个AI请求，锁超时30秒自动释放，冷启动清空Map
  - 预估复杂度：中

- [ ] **T05-02** 实现SSEStreamHandler（connect/onTextChunk/onJsonComplete/onError/onInterrupt/retry/close）（REQ-FC-34, REQ-NF-R01）
  - 涉及文件：`entry/src/main/ets/services/SSEStreamHandler.ets`
  - 依赖任务：T01-04
  - 优先级：P0
  - 验收标准：阶段1逐字回调text片段，阶段2缓冲JSON至json_end后回调完整JSON，网络中断回调onInterrupt，JSON缓冲超时10秒触发onError，分片乱序丢弃旧缓冲，JSON最大长度5MB；"继续生成"保持当前连接尝试恢复SSE流，"重试"关闭当前连接重新发起完整请求
  - 预估复杂度：高

- [ ] **T05-03** 实现AIService核心方法（requestKnowledgeGraph/requestControversy/requestQuizQuestions/requestEvaluation/requestInsightEvaluation）（REQ-FC-15/22/25/27, REQ-FC-33/34）
  - 涉及文件：`entry/src/main/ets/services/AIService.ets`
  - 依赖任务：T05-01, T05-02, T03-01
  - 优先级：P0
  - 验收标准：每个方法获取并发锁→构建Prompt（含parsed_content上下文注入）→建立SSE连接→两阶段回调→释放锁→记录日志
  - 预估复杂度：高

- [ ] **T05-04** 实现AIService.logRequest()（AI请求日志记录至ai_request_log表）（REQ-NF-M01）
  - 涉及文件：`entry/src/main/ets/services/AIService.ets`
  - 依赖任务：T05-03, T02-02
  - 优先级：P0
  - 验收标准：日志包含request_type/request_prompt/response_body/status/duration_ms/create_time全部字段
  - 预估复杂度：低

- [ ] **T05-05** 实现AIService Prompt上下文注入（防幻觉）+ 禁止替代用户作答约束指令（REQ-FC-33, REQ-FC-46）
  - 涉及文件：`entry/src/main/ets/services/AIService.ets`
  - 依赖任务：T05-03（逻辑依赖T06-04：Prompt上下文注入需要从material表查询parsed_content，依赖T06-04中资料入库后parsed_content字段有值）
  - 优先级：P0
  - 验收标准：Prompt包含parsed_content上下文段+"请严格基于以下参考资料回答"约束指令+"禁止替代用户作答"约束指令
  - 预估复杂度：中

- [ ] **T05-06** 实现WebSearchService.crawlRelatedMaterials()（AI Agent异步联网检索）（REQ-FC-02）
  - 涉及文件：`entry/src/main/ets/services/WebSearchService.ets`
  - 依赖任务：T05-03
  - 优先级：P1
  - 验收标准：课程创建后异步触发，不阻塞UI，回调后融合资料至复合知识库
  - 预估复杂度：中

---

## 6. 服务层 — 文件池与资料解析

- [ ] **T06-01** 实现FilePoolService.selectFileByPicker()（系统Picker文件选择）（REQ-FC-37, REQ-NF-A02）
  - 涉及文件：`entry/src/main/ets/services/FilePoolService.ets`
  - 依赖任务：T01-04
  - 优先级：P0
  - 验收标准：长按课程卡片弹出DocumentViewPicker，仅允许PDF/Markdown格式
  - 预估复杂度：中

- [ ] **T06-02** 实现FilePoolService.copyToSandbox()（复制文件至沙箱+重名时间戳后缀）（REQ-FC-42, REQ-NF-S01）
  - 涉及文件：`entry/src/main/ets/services/FilePoolService.ets`
  - 依赖任务：T06-01
  - 优先级：P0
  - 验收标准：文件复制至context.filesDir，重名追加时间戳，存储路径在沙箱内
  - 预估复杂度：中

- [ ] **T06-03** 实现MaterialParser.parsePDF()/parseMarkdown()/isScannedPDF()（资料解析+扫描型检测）（REQ-NF-C02/C03）
  - 涉及文件：`entry/src/main/ets/services/MaterialParser.ets`
  - 依赖任务：T01-04
  - 优先级：P0
  - 验收标准：文本型PDF提取纯文本成功，Markdown去除格式标记保留纯文本，扫描型PDF（文本长度<页数×50）检测正确并提示"该PDF为图片格式，暂不支持解析"
  - 预估复杂度：高

- [ ] **T06-04** 实现FilePoolService.parseMaterial()/saveMaterialRecord()（解析入库+50MB限制）（REQ-FC-38/39/41/43）
  - 涉及文件：`entry/src/main/ets/services/FilePoolService.ets`
  - 依赖任务：T06-02, T06-03, T02-02
  - 优先级：P0
  - 验收标准：文件>50MB拒绝上传，解析成功status=success，解析失败status=failed，type标识user_upload/ai_crawl，重上传覆盖同file_name记录
  - 预估复杂度：中

- [ ] **T06-05** 实现FilePoolService.deleteCourseFiles()（删除课程关联物理文件）（REQ-FC-14）
  - 涉及文件：`entry/src/main/ets/services/FilePoolService.ets`
  - 依赖任务：T06-02
  - 优先级：P0
  - 验收标准：遍历material记录的file_path，删除沙箱内全部物理文件
  - 预估复杂度：低

---

## 7. 服务层 — 评价报告

- [ ] **T07-01** 实现EvaluationService.generateReport()（五大章节评价报告生成）（REQ-FC-48/51）
  - 涉及文件：`entry/src/main/ets/services/EvaluationService.ets`
  - 依赖任务：T04-02, T03-01
  - 优先级：P1
  - 验收标准：报告包含学习课题+复合知识库构成+三问交互原始记录+能力维度分析+错题溯源与复习建议，标注"本答案由学员手动输入"
  - 预估复杂度：高

- [ ] **T07-02** 实现EvaluationService.drawRadarChart()（Canvas三维度雷达图绘制+PNG保存）（REQ-FC-49）
  - 涉及文件：`entry/src/main/ets/services/EvaluationService.ets`
  - 依赖任务：T07-01
  - 优先级：P1
  - 验收标准：Canvas绘制概念理解/批判思维/实践迁移三维度雷达图，保存为{course_id}_radar.png
  - 预估复杂度：中

- [ ] **T07-03** 实现EvaluationService.traceWeakNodes()（错题溯源关联薄弱节点）（REQ-FC-28）
  - 涉及文件：`entry/src/main/ets/services/EvaluationService.ets`
  - 依赖任务：T07-01
  - 优先级：P1
  - 验收标准：遍历is_correct=false的question_record，通过linked_node_ids关联知识图谱薄弱节点
  - 预估复杂度：中

- [ ] **T07-04** 实现EvaluationService.exportMarkdown()/exportPDF()（报告导出）（REQ-FC-50）
  - 涉及文件：`entry/src/main/ets/services/EvaluationService.ets`
  - 依赖任务：T07-01, T07-02
  - 优先级：P1
  - 验收标准：Markdown直接写入.md文件，PDF经HTML转换后生成.pdf文件，雷达图以相对路径嵌入
  - 预估复杂度：中

---

## 8. ViewModel层

- [ ] **T08-01** 实现HomeViewModel（搜索框输入校验+课程列表加载+AI推荐提问列表）
  - 涉及文件：`entry/src/main/ets/viewmodels/HomeViewModel.ets`
  - 依赖任务：T04-02, T05-03
  - 优先级：P0
  - 验收标准：空输入拦截提示"请输入您想学习的领域问题"，课程列表正确加载，AI推荐提问列表生成
  - 预估复杂度：中

- [ ] **T08-02** 实现CourseViewModel（课程CRUD+级联删除+进度更新+状态流转）
  - 涉及文件：`entry/src/main/ets/viewmodels/CourseViewModel.ets`
  - 依赖任务：T04-01, T04-03, T04-04
  - 优先级：P0
  - 验收标准：创建/查询/删除/进度更新/状态流转全部可用
  - 预估复杂度：中

- [ ] **T08-03** 实现ThreeAskViewModel（三问流程编排：startQ1/startQ2/startQ3/activateNode/submitAnswer）
  - 涉及文件：`entry/src/main/ets/viewmodels/ThreeAskViewModel.ets`
  - 依赖任务：T05-03, T04-03, T05-01
  - 优先级：P0
  - 验收标准：三问强制顺序执行，AI请求前获取并发锁，Q1完成后解锁Q2，Q2完成后解锁Q3，Q3完成后触发评价报告生成
  - 预估复杂度：高

- [ ] **T08-04** 实现EvaluationViewModel（报告生成+导出+雷达图+错题溯源）
  - 涉及文件：`entry/src/main/ets/viewmodels/EvaluationViewModel.ets`
  - 依赖任务：T07-01, T07-04
  - 优先级：P1
  - 验收标准：生成报告→绘制雷达图→错题溯源→支持Markdown/PDF导出
  - 预估复杂度：中

---

## 9. 组件层 — 基础组件

- [ ] **T09-01** 实现CourseCard组件（课程名称+进度条+雷达图缩略图+长按事件）（REQ-FC-04）
  - 涉及文件：`entry/src/main/ets/components/CourseCard.ets`
  - 依赖任务：T03-01
  - 优先级：P0
  - 验收标准：卡片展示课程名称、进度条百分比、雷达图缩略图，长按触发文件上传
  - 预估复杂度：中

- [ ] **T09-02** 实现ProgressBar组件（0~100进度条）（REQ-FC-05~07）
  - 涉及文件：`entry/src/main/ets/components/ProgressBar.ets`
  - 依赖任务：无
  - 优先级：P0
  - 验收标准：进度条正确显示0/33/66/100等百分比
  - 预估复杂度：低

- [ ] **T09-03** 实现ThreeAskStepper组件（三问进度Stepper+锁定/解锁逻辑）（REQ-FC-30~32）
  - 涉及文件：`entry/src/main/ets/components/ThreeAskStepper.ets`
  - 依赖任务：无
  - 优先级：P0
  - 验收标准：前序未完成时后续步骤DISABLE，完成后解锁NEXT步骤
  - 预估复杂度：中

- [ ] **T09-04** 实现ManualInputBox组件（真人手动输入框+粘贴拦截最佳努力）（REQ-FC-24/29/44/45）
  - 涉及文件：`entry/src/main/ets/components/ManualInputBox.ets`
  - 依赖任务：无（弱依赖：T14-02/T14-03，onSubmit回调需预留与ThreeAskViewModel.submitAnswer()对接的接口）
  - 优先级：P0
  - 验收标准：TextInput type=Normal, enableKeyboard=true, copyOption=CopyOptions.None, onPaste事件拦截，onSubmit回调预留与ThreeAskViewModel.submitAnswer()对接的接口
  - 预估复杂度：中

- [ ] **T09-05** 实现ChatBubble组件（AI对话气泡+逐字渲染+流式状态）（REQ-FC-34）
  - 涉及文件：`entry/src/main/ets/components/ChatBubble.ets`
  - 依赖任务：无
  - 优先级：P0
  - 验收标准：isStreaming=true时逐字追加渲染，isStreaming=false时完整显示
  - 预估复杂度：中

- [ ] **T09-06** 实现AIRecommendBtn组件（AI推荐提问按钮列表）（REQ-FC-40/53）
  - 涉及文件：`entry/src/main/ets/components/AIRecommendBtn.ets`
  - 依赖任务：无
  - 优先级：P1
  - 验收标准：复合知识库非空时展示推荐提问按钮，点击触发课程创建
  - 预估复杂度：低

- [ ] **T09-07** 实现ThreeAskIndicator组件（三段式进度条：已完成绿色对勾 + 当前阶段紫色脉冲动画 + 未到达灰色）（REQ-FC-30~32）
  - 涉及文件：`entry/src/main/ets/components/ThreeAskIndicator.ets`
  - 依赖任务：T01-04
  - 优先级：P1
  - 验收标准：三段式进度条正确显示，已完成步骤绿色对勾，当前步骤紫色脉冲动画，未到达步骤灰色
  - 预估复杂度：中

---

## 10. 组件层 — 争议与测评组件

- [ ] **T10-01** 实现DebateCard组件（左右分栏争议观点+争议逻辑链+筛选Checkbox）（REQ-FC-22/23）
  - 涉及文件：`entry/src/main/ets/components/DebateCard.ets`
  - 依赖任务：T03-01
  - 优先级：P0
  - 验收标准：左侧观点A+证据A，右侧观点B+证据B，下方结论，Checkbox控制is_selected
  - 预估复杂度：中

---

## 11. 组件层 — 知识图谱动画组件

- [ ] **T11-01** 实现PuzzleFragmentAnim组件（拼图碎片动画：@Component碎片态渲染+animateTo飞向连线+变形为圆形点亮态+onAnimated回调）（REQ-FC-16/17）
  - 涉及文件：`entry/src/main/ets/components/PuzzleFragmentAnim.ets`
  - 依赖任务：无
  - 优先级：P0
  - 验收标准：碎片态@Component渲染，点击触发animateTo(duration=500ms, curve=EaseInOut)，动画完成后onAnimated回调，移除@Component节点
  - 预估复杂度：高

- [ ] **T11-02** 实现MindBadgeAnim组件（心智塑成勋章动画：全屏遮罩+勋章图标+粒子扩散+2秒自动消失）（REQ-FC-18）
  - 涉及文件：`entry/src/main/ets/components/MindBadgeAnim.ets`
  - 依赖任务：无
  - 优先级：P1
  - 验收标准：最后一个核心节点点亮触发，全屏遮罩+中央勋章+粒子扩散，2秒后自动消失；动画资源加载失败时降级为直接显示最终状态（勋章图标静态展示）
  - 预估复杂度：中

- [ ] **T11-03** 实现力导向布局算法（节点斥力+边引力+200次迭代/收敛条件+节点位置锁定）（REQ-FC-52）
  - 涉及文件：`entry/src/main/ets/common/ForceDirectedLayout.ets`
  - 依赖任务：T01-04
  - 优先级：P0
  - 验收标准：节点最小间距60px，边偏好长度120px，200次迭代或所有节点位移<1px时终止，fixed=true节点不参与迭代
  - 预估复杂度：高

---

## 12. 组件层 — 雷达图组件

- [ ] **T12-01** 实现RadarChart组件（Canvas三维度雷达图绘制）（REQ-FC-49）
  - 涉及文件：`entry/src/main/ets/components/RadarChart.ets`
  - 依赖任务：无
  - 优先级：P1
  - 验收标准：Canvas绘制概念理解/批判思维/实践迁移三维度雷达图，支持自定义scores和labels
  - 预估复杂度：中

---

## 13. 页面层

- [ ] **T13-01** 实现HomePage页面（搜索框+引导语+课程卡片列表+AI推荐提问）（REQ-FC-08, REQ-FC-04, REQ-FC-53）
  - 涉及文件：`entry/src/main/ets/pages/home/HomePage.ets`
  - 依赖任务：T08-01, T09-01, T09-06
  - 优先级：P0
  - 验收标准：仅搜索框+引导语+课程卡片列表+AI推荐提问按钮，无其他冗余元素
  - 预估复杂度：中

- [ ] **T13-02** 实现LearningSpace页面（三问Stepper容器+Q1/Q2/Q3面板）（REQ-FC-30~32）
  - 涉及文件：`entry/src/main/ets/pages/learning/LearningSpace.ets`
  - 依赖任务：T08-03, T09-03, T09-05
  - 优先级：P0
  - 验收标准：Stepper管控三问强制顺序，Q1面板含知识图谱，Q2面板含争议分析，Q3面板含测评答题
  - 预估复杂度：高

- [ ] **T13-03** 实现KnowledgeGraph页面（力导向布局+混合渲染：碎片态PuzzleFragmentAnim+点亮态Canvas+节点点击+连线查看）（REQ-FC-15~21, REQ-FC-52）
  - 涉及文件：`entry/src/main/ets/pages/learning/KnowledgeGraph.ets`
  - 依赖任务：T11-01, T11-02, T11-03, T08-03
  - 优先级：P0
  - 验收标准：力导向布局自动排列节点（200次迭代/收敛），碎片态@Component渲染，点击→动画→Canvas点亮态，点亮节点fixed=true不再参与布局，Canvas支持节点/连线点击交互，Q1进行中不动态加入新节点；Canvas渲染失败时降级为文本列表展示节点信息
  - 预估复杂度：高

- [ ] **T13-04** 实现Assessment页面（布鲁姆9题逐题展示+ManualInputBox答题+即时解析+错题溯源标注）（REQ-FC-25~29）
  - 涉及文件：`entry/src/main/ets/pages/assessment/Assessment.ets`
  - 依赖任务：T08-03, T09-04, T10-01
  - 优先级：P0
  - 验收标准：9题逐题展示含布鲁姆层级标签，ManualInputBox手动答题，提交后即时显示解析，答错题目通过linked_node_ids溯源标注薄弱节点
  - 预估复杂度：高

- [ ] **T13-05** 实现AssessmentResult页面（评价报告展示+雷达图+导出按钮）（REQ-FC-48~51）
  - 涉及文件：`entry/src/main/ets/pages/assessment/AssessmentResult.ets`
  - 依赖任务：T08-04, T12-01
  - 优先级：P1
  - 验收标准：报告五大章节完整展示，雷达图Canvas渲染，支持Markdown/PDF格式导出
  - 预估复杂度：中

---

## 14. 核心业务逻辑集成

- [ ] **T14-01** 集成第一问完整流程（进入Q1→AI请求知识图谱→两阶段SSE渲染→节点ID替换UUID→批量入库→拼图碎片动画→节点点亮→Q1完成判定→心智塑成勋章→解锁Q2）（REQ-FC-10/11/15~21）
  - 涉及文件：`ThreeAskViewModel.ets`, `KnowledgeGraph.ets`, `AIService.ets`, `CourseService.ets`
  - 依赖任务：T13-03, T05-03, T04-03
  - 优先级：P0
  - 验收标准：Q1完整流程可走通，AI返回JSON中节点ID替换为系统UUID，is_activated/q1_activated_count正确更新，q1_activated_count===q1_total_core_count时Q1完成
  - 预估复杂度：高

- [ ] **T14-02** 集成第二问完整流程（进入Q2→AI请求争议分析→两阶段SSE渲染→入库→左右分栏展示→争议点筛选→真人见解输入→见解评价）（REQ-FC-12/22~24）
  - 涉及文件：`ThreeAskViewModel.ets`, `LearningSpace.ets`, `DebateCard.ets`, `ManualInputBox.ets`
  - 依赖任务：T13-02, T10-01, T09-04, T05-03
  - 优先级：P0
  - 验收标准：Q2完整流程可走通，争议逻辑链入库，is_selected可筛选，ManualInputBox仅键盘输入
  - 预估复杂度：高

- [ ] **T14-03** 集成第三问完整流程（进入Q3→AI请求测评题目→布鲁姆分布校验→9题展示→手动答题→即时解析→错题溯源→Q3完成→触发评价报告）（REQ-FC-13/25~29）
  - 涉及文件：`ThreeAskViewModel.ets`, `Assessment.ets`, `ManualInputBox.ets`, `EvaluationService.ets`
  - 依赖任务：T13-04, T09-04, T05-03, T07-01
  - 优先级：P0
  - 验收标准：Q3完整流程可走通，布鲁姆分布校验（记忆1+理解2+应用2+分析2+评价1+创造1）不符合时拒绝入库重试（上限2次），即时解析+错题溯源正确
  - 预估复杂度：高

- [ ] **T14-04** 实现诚信审计逻辑（作答提交时间与AI响应返回时间间隔<2秒标记is_suspect=true）（REQ-FC-44/46/47）
  - 涉及文件：`ThreeAskViewModel.ets`, `EvaluationService.ets`
  - 依赖任务：T08-03
  - 优先级：P1
  - 验收标准：可疑记录is_suspect=true，评价报告中注明"⚠ 部分作答时间异常，已标记审计"
  - 预估复杂度：中

- [ ] **T14-05** 集成课程级联删除完整流程（删除课程→事务级联删除7表+物理文件清理）（REQ-FC-14）
  - 涉及文件：`CourseViewModel.ets`, `CourseService.ets`, `FilePoolService.ets`
  - 依赖任务：T04-04, T06-05
  - 优先级：P0
  - 验收标准：删除课程→关联数据全部清理→物理文件全部删除→UI课程列表刷新
  - 预估复杂度：中

---

## 15. 应用入口与冷启动初始化

- [ ] **T15-01** 实现EntryAbility.onCreate()冷启动初始化（AIConcurrencyLock清空Map→RdbHelper初始化→init.sql建表→CourseService.getAllCourses()→渲染主界面）（REQ-NF-D01, REQ-NF-CC02）
  - 涉及文件：`entry/src/main/ets/entryability/EntryAbility.ets`
  - 依赖任务：T05-01, T02-02, T04-02
  - 优先级：P0
  - 验收标准：首次启动执行init.sql建表，非首次启动跳过建表，冷启动清空并发锁Map，课程数据就绪后渲染主界面
  - 预估复杂度：中

- [ ] **T15-02** 在module.json5中注册页面路由 + 实现页面间router.pushUrl跳转逻辑
  - 涉及文件：`entry/src/main/module.json5` + 各页面调用router.pushUrl的代码
  - 依赖任务：T13-01, T13-02, T13-03, T13-04, T13-05
  - 优先级：P0
  - 验收标准：5个页面路由配置正确，页面间router.pushUrl跳转正常
  - 预估复杂度：低

---

## 16. 交付物与文档

- [ ] **T16-01** 创建DemoFilePool/预置示例资料文件夹（sample_course_01.pdf + sample_course_01.md）（REQ-NF-D03/D04）
  - 涉及文件：`DemoFilePool/sample_course_01.pdf`, `DemoFilePool/sample_course_01.md`
  - 依赖任务：无
  - 优先级：P1
  - 验收标准：DemoFilePool/包含示例PDF和Markdown文件，可供演示和测试
  - 预估复杂度：低

- [ ] **T16-02** 创建docs/FIX_LOG.md文档（Bug修复记录模板）（REQ-NF-F01/F02）
  - 涉及文件：`docs/FIX_LOG.md`
  - 依赖任务：无
  - 优先级：P0
  - 验收标准：文档包含Fix记录模板（问题ID/严重程度/触发条件/修复方案/测试结果），阶段一即创建模板，开发过程中遇到Bug随时记录
  - 预估复杂度：低

- [ ] **T16-03** 确认database/init.sql作为交付物存在（REQ-NF-D02/D04）
  - 涉及文件：`database/init.sql`
  - 依赖任务：T02-01
  - 优先级：P1
  - 验收标准：init.sql包含8表+索引完整建表脚本
  - 预估复杂度：低

---

## 任务依赖关系图

```
T01-01 → T01-02, T01-03
T01-03 → T01-04, T02-01, T03-01
T01-04 → T09-07, T11-03
T02-01 → T02-02
T02-02 → T02-03, T04-01, T06-04
T03-01 → T03-02, T09-01, T10-01
T04-01 → T04-02, T04-03, T04-04, T04-05
T05-01 → T05-03, T15-01
T05-02 → T05-03
T05-03 → T05-04, T05-05, T05-06
T05-05 → T06-04（逻辑依赖：Prompt上下文注入需parsed_content有值）
T06-01 → T06-02
T06-02 → T06-05
T06-03 → T06-04
T07-01 → T07-02, T07-03, T07-04
T08-01 → T13-01
T08-03 → T14-01, T14-02, T14-03, T14-04
T09-01 → T13-01
T09-03 → T13-02
T09-04 → T13-04（弱依赖：onSubmit回调需预留与ThreeAskViewModel.submitAnswer()对接接口）
T09-05 → T13-02
T09-06 → T13-01
T10-01 → T13-04
T11-01 → T13-03
T11-02 → T13-03
T11-03 → T13-03
T12-01 → T13-05
T13-01 → T15-02
T13-02 → T14-02
T13-03 → T14-01
T13-04 → T14-03
T13-05 → T15-02
T14-01~05 → 集成验证
T15-01 → 集成验证
全部P0+P1 → T17-01, T17-02
```

---

## 任务执行顺序建议

### 阶段一：基础设施（P0，预计2天）
1. T01-01 → T01-02 → T01-03 → T01-04（项目脚手架+公共工具）
2. T02-01 → T02-02 → T02-03（数据库层）
3. T03-01 → T03-02（模型层）
4. T16-02（FIX_LOG.md模板，阶段一即创建，开发过程中遇到Bug随时记录）

### 阶段二：服务层核心（P0，预计3天）
5. T04-01 → T04-02 → T04-03 → T04-04 → T04-05（CourseService）
6. T05-01 → T05-02 → T05-03 → T05-04 → T05-05（AIService+SSE+并发锁）
7. T06-01 → T06-02 → T06-03 → T06-04 → T06-05（FilePoolService+MaterialParser）

### 阶段三：组件与ViewModel层（P0，预计3天）
8. T09-01 → T09-02 → T09-03 → T09-04 → T09-05 → T09-07（基础组件+ThreeAskIndicator）
9. T10-01（DebateCard）
10. T11-01 → T11-02 → T11-03（知识图谱动画组件+力导向布局算法）
11. T08-01 → T08-02 → T08-03（ViewModel层）

### 阶段四：页面层与流程集成（P0，预计3天）
12. T13-01 → T13-02 → T13-03 → T13-04（页面层）
13. T14-01 → T14-02 → T14-03 → T14-05（三问流程集成）
14. T07-01（EvaluationService.generateReport骨架，与T14-03并行开发）
15. T15-01 → T15-02（应用入口+路由）

### 阶段五：评价报告完整实现与P1任务（P1，预计2天）
16. T07-02 → T07-03 → T07-04（EvaluationService完整报告生成+雷达图+错题溯源+导出）
17. T08-04（EvaluationViewModel）
18. T12-01（RadarChart组件）
19. T13-05（AssessmentResult页面）
20. T14-04（诚信审计）
21. T05-06（WebSearchService）

### 阶段六：交付物与P2优化（P1/P2，预计1天）
22. T16-01 → T16-03（交付物）
23. T09-06（AIRecommendBtn）

### 阶段七：集成验证与优化（P2，预计2天）
24. 全流程端到端验证（三问完整流程→评价报告导出→级联删除→冷启动）
25. 性能优化（知识图谱50+节点30fps保障、SSE渲染流畅度、文件解析10秒内完成）
26. 异常场景覆盖（AI超时/失败重试、网络中断、扫描型PDF、空知识库）

- [ ] **T17-01** 录制效果视频（覆盖：创建课程→三问完整流程→知识图谱拼图动画→心智塑成勋章→评价报告导出→级联删除）
  - 依赖任务：全部P0+P1完成
  - 优先级：P1
  - 验收标准：视频展示三问显性化+柔性课程+AI爬取+鸿蒙运行+评价报告全部核心功能
  - 预估复杂度：中

- [ ] **T17-02** 执行自评学习流程并导出评价报告（选择一门测试课程→手动完成三问全流程→生成评价报告→导出Markdown/PDF→确认对话原始记录完整+标注"本答案由学员手动输入"）
  - 依赖任务：全部P0+P1完成
  - 优先级：P0
  - 验收标准：评价报告包含五大章节+能力雷达图+错题溯源+对话原始记录+诚信声明，学员答案均为手动输入
  - 预估复杂度：中

---

## 需求覆盖追溯

| 需求范围 | 覆盖任务 |
|----------|----------|
| REQ-FC-01~03 | T04-01, T04-05, T05-06 |
| REQ-FC-04 | T09-01, T13-01 |
| REQ-FC-05~07 | T04-03, T09-02 |
| REQ-FC-08 | T13-01 |
| REQ-FC-09 | T03-01 |
| REQ-FC-10~13 | T04-03, T14-01~03 |
| REQ-FC-14 | T02-03, T04-04, T06-05, T14-05 |
| REQ-FC-15~21 | T13-03, T14-01 |
| REQ-FC-22~24 | T10-01, T14-02 |
| REQ-FC-25~29 | T13-04, T14-03 |
| REQ-FC-30~32 | T09-03, T09-07, T13-02 |
| REQ-FC-33~36 | T05-03, T05-05, T05-01 |
| REQ-FC-37~43 | T06-01~04 |
| REQ-FC-44~47 | T09-04, T14-04, T05-05 |
| REQ-FC-48~51 | T07-01~04, T13-05, T17-02 |
| REQ-FC-52 | T11-03, T13-03 |
| REQ-FC-53 | T09-06, T13-01 |
| REQ-NF-P01~04 | 阶段七性能优化 |
| REQ-NF-R01~04 | T05-02, T02-02, T02-03, T04-04 |
| REQ-NF-S01~03 | T06-02, T05-03, T09-04 |
| REQ-NF-M01~02 | T05-04, T01-01 |
| REQ-NF-C01~03 | T01-01, T06-03 |
| REQ-NF-A01~02 | T01-02, T06-01 |
| REQ-NF-D01~04 | T02-01, T15-01, T16-01, T16-03 |
| REQ-NF-CC01~02 | T05-01, T15-01 |
| REQ-NF-F01~02 | T16-02 |