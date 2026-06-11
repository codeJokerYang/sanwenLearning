# 三问高效学习机 — 项目计划书

> 版本：v1.0 | 日期：2026-06-05 | 基于 spec.md v2.1 + design.md v1.1 + tasks.md v1.0 + 三问学习法深度研究报告

---

## 一、项目概述

### 1.1 项目背景

"三问高效学习机"是一款基于HarmonyOS NEXT平台开发的智能学习应用，以"三问认知引擎"为核心驱动，实现从问题触发到深度测评的个性化认知闭环学习。项目根植于苏格拉底提问法、布鲁姆分类学和建构主义学习理论三大教育学理论源流，通过"描述性→分析性→创造性"的递进提问，引导学习者从低阶思维走向高阶思维。

# 三问高效学习机 — 编码指南

> 基于 spec.md v2.1 + design.md v1.1 + tasks.md v1.0

---

## 1. 项目定位

HarmonyOS NEXT原生应用 | ArkTS声明式UI + Stage模型 + RdbStore本地数据库 + DeepSeek/OpenAI兼容API

---

## 2. 分层架构

```
Pages: HomePage | LearningSpace | KnowledgeGraph | Assessment | AssessmentResult
Components: CourseCard | ThreeAskStepper | DebateCard | RadarChart | ProgressBar | ChatBubble | PuzzleFragmentAnim | MindBadgeAnim | ManualInputBox | AIRecommendBtn | ThreeAskIndicator
ViewModels: CourseViewModel | ThreeAskViewModel | EvaluationViewModel | HomeViewModel
Services: CourseService | AIService | EvaluationService | FilePoolService | MaterialParser | WebSearchService | SSEStreamHandler | AIConcurrencyLock
DB: RdbHelper | init.sql (8表+7索引)
Models: Course | Material | KnowledgeNode | KnowledgeEdge | Controversy | QuizQuestion | QuestionRecord | AiRequestLog | EvaluationReport
```

### 8张核心业务表

| 表名 | 核心字段 |
|------|---------|
| course | id, title, status, current_step, progress, q1_activated_count, q1_total_core_count |
| material | id, course_id, file_name, file_path, type, status, parsed_content |
| knowledge_node | id, course_id, label, type(core/auxiliary), is_activated, sort_order |
| knowledge_edge | id, course_id, source, target, relation |
| controversy | id, course_id, title, view_a, evidence_a, view_b, evidence_b, conclusion, is_selected |
| quiz_question | id, course_id, bloom_level, content, standard_answer, linked_node_ids(JSON数组) |
| question_record | id, course_id, step, quiz_question_id, user_original_answer, ai_evaluation, is_correct, is_suspect, create_time |
| ai_request_log | id, course_id, request_type, request_prompt, response_body, status, duration_ms |

---

## 3. 功能模块清单

| 模块 | 核心功能 |
|------|---------|
| 柔性课程生成 | 提问触发课程创建、AI异步补充、状态流转(已创建→活跃态→完成态)、级联删除 |
| 三问引擎-Q1 | 知识图谱生成、拼图碎片动画、心智塑成勋章、节点激活(核心节点全部点亮=Q1完成) |
| 三问引擎-Q2 | 争议分析左右分栏、争议逻辑链(争议-证据-结论)、争议点筛选、真人见解输入 |
| 三问引擎-Q3 | 布鲁姆9题(记忆1+理解2+应用2+分析2+评价1+创造1)、即时解析、错题溯源(linked_node_ids) |
| 三问流程管控 | 强制顺序(不可跳步)、Stepper锁定/解锁、current_step追踪(0→1→2→3→4) |
| AI交互 | parsed_content上下文注入防幻觉、两阶段SSE(阶段1逐字+阶段2 JSON)、并发锁(30秒超时) |
| 文件池 | 系统Picker选择PDF/Markdown、沙箱存储、扫描型PDF检测(文本长度<N×50)、50MB限制 |
| 评价报告 | 五章节报告、Canvas三维度雷达图(概念理解/批判思维/实践迁移)、Markdown/PDF导出 |
| 真人作答保障 | ManualInputBox禁粘贴、Prompt禁代答约束、诚信审计(is_suspect标记)、报告标注 |

---

## 4. 编码任务清单

### 阶段一：基础设施（Day 1-2）

| 编号 | 任务 | 优先级 | 复杂度 | 依赖 | 验收标准 |
|------|------|--------|--------|------|---------|
| T01-01 | 搭建项目脚手架，Stage模型、API 12+ | P0 | 低 | - | 项目可编译运行 |
| T01-02 | 声明INTERNET权限 | P0 | 低 | T01-01 | module.json5含权限声明 |
| T01-03 | 创建目录结构(pages/components/viewmodels/services/models/db/common) | P0 | 低 | T01-01 | 与design.md第6章一致 |
| T01-04 | 创建公共工具(Logger/EventBus/utils含UUID) | P0 | 中 | T01-03 | Logger分级输出，EventBus发布订阅 |
| T02-01 | 编写init.sql(8表+7索引，外键无ON DELETE CASCADE) | P0 | 中 | T01-03 | 8表完整 |
| T02-02 | RdbHelper封装(getRdbStore/事务/CRUD) | P0 | 高 | T02-01 | 首次启动自动建表，事务原子性 |
| T02-03 | 级联删除事务(按序删7表→course→物理文件) | P0 | 高 | T02-02 | 事务失败全部回滚 |
| T03-01 | 定义全部ArkTS模型接口及枚举 | P0 | 中 | T01-03 | 字段与init.sql一致 |
| T03-02 | 定义EvaluationReportModel及ParsedResult | P1 | 低 | T03-01 | ParsedResult含success/content/isScanned/error |
| T16-02 | 创建FIX_LOG.md模板 | P0 | 低 | - | 含问题ID/严重程度/触发条件/修复方案/测试结果 |

### 阶段二：服务层核心（Day 3-5）

| 编号 | 任务 | 优先级 | 复杂度 | 依赖 | 验收标准 |
|------|------|--------|--------|------|---------|
| T04-01 | CourseService.createCourse() | P0 | 中 | T02-02,T03-01 | status=1,current_step=0,progress=0 |
| T04-02 | getAllCourses()/getCourseById() | P0 | 低 | T04-01 | 按create_time倒序 |
| T04-03 | updateCourseStep/Progress/Q1Counts() | P0 | 中 | T04-01 | current_step:0→1→2→3→4, progress:33/66/100 |
| T04-04 | cascadeDeleteCourse() | P0 | 高 | T02-03,T04-01 | 7表+物理文件全部清理或全部回滚 |
| T04-05 | updateAiSummaryContext() | P1 | 低 | T04-01 | AI回调后字段更新 |
| T05-01 | AIConcurrencyLock(Map锁+超时30秒+冷启动清空) | P0 | 中 | T01-04 | 同课程仅一个请求，超时自动释放 |
| T05-02 | SSEStreamHandler(两阶段+缓冲超时10秒+乱序防护+5MB限制) | P0 | 高 | T01-04 | 阶段1逐字回调，阶段2 json_end回调，继续生成/重试双按钮 |
| T05-03 | AIService核心方法(5个AI请求) | P0 | 高 | T05-01,T05-02 | 获取锁→Prompt→SSE→回调→释放锁→日志 |
| T05-04 | AIService.logRequest() | P0 | 低 | T05-03 | 记录全部字段至ai_request_log |
| T05-05 | Prompt上下文注入(parsed_content+禁代答约束) | P0 | 中 | T05-03,逻辑依赖T06-04 | Prompt含"严格基于参考资料""禁止替代作答" |
| T06-01 | FilePoolService.selectFileByPicker() | P0 | 中 | T01-04 | DocumentViewPicker，仅PDF/Markdown |
| T06-02 | copyToSandbox()(重名时间戳后缀) | P0 | 中 | T06-01 | 沙箱内存储 |
| T06-03 | MaterialParser(PDF/Markdown解析+扫描型检测) | P0 | 高 | T01-04 | 文本长度<N×50→扫描型，提示不支持 |
| T06-04 | parseMaterial()/saveMaterialRecord()(50MB限制) | P0 | 中 | T06-02,T06-03,T02-02 | >50MB拒绝，失败status=failed，重上传覆盖 |
| T06-05 | deleteCourseFiles() | P0 | 低 | T06-02 | 删除沙箱全部物理文件 |

### 阶段三：组件与ViewModel（Day 6-8）

| 编号 | 任务 | 优先级 | 复杂度 | 依赖 | 验收标准 |
|------|------|--------|--------|------|---------|
| T09-01 | CourseCard(名称+进度条+雷达图缩略图+长按) | P0 | 中 | T03-01 | 长按触发文件上传 |
| T09-02 | ProgressBar(0~100) | P0 | 低 | - | 正确显示0/33/66/100 |
| T09-03 | ThreeAskStepper(锁定/解锁) | P0 | 中 | - | 前序未完成后续DISABLE |
| T09-04 | ManualInputBox(禁粘贴+onSubmit预留接口) | P0 | 中 | - | copyOption=None, onPaste拦截 |
| T09-05 | ChatBubble(逐字渲染+流式状态) | P0 | 中 | - | isStreaming逐字追加 |
| T09-07 | ThreeAskIndicator(绿色对勾+紫色脉冲+灰色) | P1 | 中 | T01-04 | 三段式进度条正确 |
| T10-01 | DebateCard(左右分栏+Checkbox) | P0 | 中 | T03-01 | 观点A/B左右，结论下方，is_selected更新 |
| T11-01 | PuzzleFragmentAnim(@Component碎片+animateTo) | P0 | 高 | - | 500ms EaseInOut，onAnimated回调移除节点 |
| T11-02 | MindBadgeAnim(全屏遮罩+勋章+粒子+2秒) | P1 | 中 | - | 动画失败降级为静态展示 |
| T11-03 | 力导向布局算法(斥力+引力+200迭代+锁定) | P0 | 高 | T01-04 | 节点间距60px，边120px，fixed不参与 |
| T08-01 | HomeViewModel(输入校验+课程列表+AI推荐) | P0 | 中 | T04-02,T05-03 | 空输入拦截，列表正确加载 |
| T08-02 | CourseViewModel(CRUD+级联删除+进度) | P0 | 中 | T04-01,T04-03,T04-04 | 全流程可用 |
| T08-03 | ThreeAskViewModel(三问流程编排) | P0 | 高 | T05-03,T04-03,T05-01 | 强制顺序+并发锁+Q3完成触发评价 |

### 阶段四：页面与集成（Day 9-11）

| 编号 | 任务 | 优先级 | 复杂度 | 依赖 | 验收标准 |
|------|------|--------|--------|------|---------|
| T13-01 | HomePage(搜索框+引导语+课程列表+AI推荐) | P0 | 中 | T08-01,T09-01,T09-06 | 仅搜索框+引导语，无冗余元素 |
| T13-02 | LearningSpace(三问Stepper容器) | P0 | 高 | T08-03,T09-03,T09-05 | Q1知识图谱，Q2争议，Q3测评 |
| T13-03 | KnowledgeGraph(力导向+混合渲染+交互) | P0 | 高 | T11-01~03,T08-03 | 碎片→动画→Canvas点亮，节点/连线可交互，Canvas失败降级文本列表 |
| T13-04 | Assessment(9题+即时解析+溯源) | P0 | 高 | T08-03,T09-04,T10-01 | 布鲁姆标签，ManualInputBox，错题溯源 |
| T14-01 | 集成Q1完整流程 | P0 | 高 | T13-03,T05-03,T04-03 | AI_ID→UUID替换，q1_activated===q1_total→Q1完成 |
| T14-02 | 集成Q2完整流程 | P0 | 高 | T13-02,T10-01,T09-04,T05-03 | 争议入库，is_selected，仅键盘输入 |
| T14-03 | 集成Q3完整流程(布鲁姆校验+重试上限2次) | P0 | 高 | T13-04,T09-04,T05-03,T07-01 | 分布校验，不符合拒绝入库重试 |
| T14-05 | 集成级联删除完整流程 | P0 | 中 | T04-04,T06-05 | 数据+物理文件全清理，UI刷新 |
| T15-01 | EntryAbility冷启动(清锁→DB→课程→UI) | P0 | 中 | T05-01,T02-02,T04-02 | 首次启动建表，非首次跳过 |
| T15-02 | 页面路由(module.json5+router.pushUrl) | P0 | 低 | T13-01~05 | 5页面跳转正常 |

### 阶段五：评价报告（Day 12-13）

| 编号 | 任务 | 优先级 | 复杂度 | 依赖 | 验收标准 |
|------|------|--------|--------|------|---------|
| T07-01 | EvaluationService.generateReport() | P1 | 高 | T04-02,T03-01 | 五章节完整，标注"本答案由学员手动输入" |
| T07-02 | drawRadarChart()(Canvas+PNG保存) | P1 | 中 | T07-01 | 保存为{course_id}_radar.png |
| T07-03 | traceWeakNodes() | P1 | 中 | T07-01 | is_correct=false→linked_node_ids溯源 |
| T07-04 | exportMarkdown()/exportPDF() | P1 | 中 | T07-01,T07-02 | 雷达图相对路径嵌入 |
| T08-04 | EvaluationViewModel | P1 | 中 | T07-01,T07-04 | 报告→雷达图→溯源→导出 |
| T12-01 | RadarChart组件 | P1 | 中 | - | 三维度Canvas绘制 |
| T13-05 | AssessmentResult页面 | P1 | 中 | T08-04,T12-01 | 报告展示+导出按钮 |
| T14-04 | 诚信审计(is_suspect标记) | P1 | 中 | T08-03 | 作答间隔<2秒→is_suspect=true |
| T05-06 | WebSearchService.crawlRelatedMaterials() | P1 | 中 | T05-03 | 异步触发，不阻塞UI |

### 阶段六：交付物（Day 14）

| 编号 | 任务 | 优先级 | 复杂度 | 依赖 | 验收标准 |
|------|------|--------|--------|------|---------|
| T16-01 | 创建DemoFilePool/预置资料 | P1 | 低 | - | 含示例PDF+Markdown |
| T16-03 | 确认init.sql交付 | P1 | 低 | T02-01 | 8表+索引完整 |
| T09-06 | AIRecommendBtn组件 | P1 | 低 | - | 复合知识库非空时展示 |

### 阶段七：集成验证（Day 15-16）

| 验证项 | 验收标准 |
|--------|---------|
| 全流程端到端 | 创建课程→三问→报告导出→级联删除，无阻断 |
| 冷启动 | 重启后数据不丢失 |
| 性能 | 知识图谱50+节点≥30fps |
| SSE鲁棒性 | 网络中断友好提示+继续生成/重试 |
| 异常场景 | AI超时/失败、扫描型PDF、空知识库、跳步操作，友好提示 |
| 自评学习流程(T17-02) | 手动完成三问→报告含五章节+雷达图+错题溯源+诚信声明 |
| 效果视频(T17-01) | 覆盖三问显性化+柔性课程+AI爬取+鸿蒙运行+评价报告 |

---

## 5. 任务依赖关系

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
T05-05 → T06-04(逻辑依赖)
T06-01 → T06-02
T06-02 → T06-05
T06-03 → T06-04
T07-01 → T07-02, T07-03, T07-04
T08-01 → T13-01
T08-03 → T14-01~04
T09-01 → T13-01
T09-03 → T13-02
T09-04 → T13-04(弱依赖)
T09-05 → T13-02
T09-06 → T13-01
T10-01 → T13-04
T11-01~03 → T13-03
T12-01 → T13-05
T13-01~05 → T15-02
T13-02 → T14-02
T13-03 → T14-01
T13-04 → T14-03
T14-01~05 → 集成验证
T15-01 → 集成验证
全部P0+P1 → T17-01, T17-02
```