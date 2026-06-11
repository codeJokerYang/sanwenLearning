## Why

"三问高效学习机"是一款基于 HarmonyOS NEXT 平台的智能学习应用，需要从零构建完整的三问认知引擎闭环。当前项目仅有基础脚手架和部分数据层代码，尚未实现核心业务流程——从用户提问触发课程创建，到 AI 生成知识图谱（Q1）、争议分析（Q2）、布鲁姆9题测评（Q3），再到评价报告导出的完整学习闭环。项目需要严格遵循 14 份规范文档的约束，确保数据契约、AI 服务协议、业务防呆规则、安全标准等全面落地。

## What Changes

- 新增课程全生命周期管理：柔性课程创建、AI 异步补充、状态流转（DRAFT→GENERATING→Q1_ACTIVE→Q2_ACTIVE→Q3_ACTIVE→COMPLETED）、级联删除
- 新增三问引擎 Q1：AI 知识图谱生成（两阶段 SSE）、AI ID→UUID 替换、拼图碎片动画、心智塑成勋章、核心节点点亮判定
- 新增三问引擎 Q2：AI 争议分析生成、左右分栏争议卡片、真人见解输入（ManualInputBox 禁粘贴+速度检测）、AI 评价超时降级
- 新增三问引擎 Q3：AI 布鲁姆9题生成、分布校验（记1/理2/应2/分2/评1/创1）、自动重试上限2次、即时解析、错题溯源
- 新增三问流程管控：强制顺序不可跳步、Stepper 锁定/解锁、current_step 追踪
- 新增 AI 交互层：两阶段 SSE 流式传输、AI 并发锁（120s 超时）、Prompt 防幻觉注入、全局限流（10次/分钟）、离线拦截
- 新增文件池：系统 Picker 选择文件、沙箱存储、Markdown 解析、PDF 扫描型检测、50MB 限制
- 新增评价报告：五章节报告生成、Canvas 三维度雷达图、错题溯源、Markdown/PDF 导出
- 新增真人作答保障：4 层防线（粘贴拦截+速度检测+Prompt 约束+报告标注）
- 新增安全层：HUKS 加密 API Key 存储、网络熔断、日志脱敏
- 新增埋点与日志：analytics_event 表、7天错误日志滚动、90天埋点清理
- 新增国际化：$r 资源引用、中英文资源文件、无障碍描述

## Capabilities

### New Capabilities
- `course-management`: 课程 CRUD、状态流转、级联删除事务、进度计算（防除零）
- `three-ask-engine-q1`: 知识图谱 AI 生成、AI ID→UUID 替换、节点激活判定、碎片动画
- `three-ask-engine-q2`: 争议分析 AI 生成、见解输入、AI 评价超时降级流转
- `three-ask-engine-q3`: 布鲁姆9题 AI 生成、分布校验、重试机制、错题溯源
- `three-ask-flow-control`: 强制顺序管控、Stepper 锁定/解锁、步骤流转
- `ai-service`: 两阶段 SSE 流式传输、并发锁、全局限流、离线拦截、Prompt 防幻觉、日志脱敏
- `file-pool`: 文件选择、沙箱存储、Markdown 解析、PDF 扫描型检测、重名文件处理
- `evaluation-report`: 五章节报告生成、Canvas 雷达图、错题溯源、Markdown 导出
- `anti-cheat`: 粘贴拦截、输入速度检测、Prompt 禁代答约束、评价报告诚信标注
- `api-security`: HUKS 加密存储 API Key、网络熔断器、离线强拦截
- `analytics-logging`: 埋点事件记录、错误日志7天滚动、与错误日志边界划分
- `i18n-a11y`: 国际化资源文件、$r 引用、无障碍描述、44vp 最小点击区域
- `force-layout`: 力导向布局算法、200次迭代一次性更新、坐标初始化规则、降级策略
- `ui-components`: CourseCard/ProgressBar/ThreeAskStepper/ManualInputBox/ChatBubble/DebateCard/RadarChart/PuzzleFragmentAnim/MindBadgeAnim/AIRecommendBtn/ThreeAskIndicator

### Modified Capabilities
<!-- 无已有能力需修改 -->

## Impact

- **数据层**：8 表 + 10 索引 + analytics_event 表，RdbHelper 类型转换铁律（Long→number、0/1→boolean、NULL→联合类型）
- **服务层**：新增 10+ Service 类（CourseService/AIService/SSEStreamParser/AIConcurrencyLock/GlobalRateLimiter/NetworkMonitor/ApiKeyStore/EvaluationService/FilePoolService/MaterialParser/AnalyticsService）
- **ViewModel 层**：4 个 ViewModel（HomeViewModel/CourseViewModel/ThreeAskViewModel/EvaluationViewModel）
- **组件层**：11+ UI 组件，需遵循 @State/@Prop/@Link 决策树和 300 行红线
- **页面层**：5 个页面（HomePage/LearningSpace/KnowledgeGraph/Assessment/AssessmentResult）
- **网络层**：仅 @ohos.net.http，严禁第三方库；SSE 通过 on('dataReceive') + on('dataEnd') 接收
- **安全层**：API Key 必须通过 HUKS 加密存储，解密后仅存在于请求函数作用域
- **性能层**：力导向布局 <100ms、Canvas 仅状态变化时重绘、LazyForEach 大列表、@State ≤1MB
- **规范约束**：14 份规范文档全面约束，数值冲突以 AI_SERVICE_PROTOCOL.md 为准
