## 1. 基础设施与数据层

- [x] 1.1 完善 RdbHelper：内联 init.sql（8表+10索引）、queryCourseById（Long→number、0/1→boolean、NULL→联合类型）
- [x] 1.2 完善 Enums.ets：7个枚举（CourseStatus/BloomLevel/NodeType/MaterialType/MaterialStatus/AiRequestStatus/CorrectStatus）
- [x] 1.3 完善 Interfaces.ets：8个接口（Course/KnowledgeNode/KnowledgeEdge/QuizQuestion/Controversy/QuestionRecord/Material/AiRequestLog）
- [x] 1.4 实现 SafeJsonUtil.safeParseJsonArray：空字符串/null→[]，JSON.parse失败→Logger.error+[]，非数组→[]
- [x] 1.5 补充 EvaluationReport 接口及 ParsedResult 接口定义
- [x] 1.6 补充 analytics_event 表到 init.sql（id/event_name/timestamp/session_id/course_id/payload/synced + 3索引）

## 2. 服务层 — 基础服务

- [x] 2.1 实现 AIConcurrencyLock：Map锁 + acquireLock(开头调forceReleaseTimeout) + releaseLock + forceReleaseTimeout(120s) + clearAllOnColdStart
- [x] 2.2 实现 SSEStreamParser：SSEStreamCallbacks接口 + string buffer + \n\n截取 + JSON解析失败丢弃+Logger.error + 跨阶段超时15s + JSON缓冲5M字符数上限 + [DONE]处理
- [x] 2.3 实现 GlobalRateLimiter：滑动窗口10次/分钟 + canRequest + recordRequest + getRemainingCount
- [x] 2.4 实现 NetworkMonitor：@kit.NetworkKit connection + netAvailable/netLost监听 + isNetworkAvailable()
- [x] 2.5 实现 ApiKeyStore：HUKS AES-256加密存储 + saveApiKey + loadApiKey + 严禁明文

## 3. 服务层 — 业务服务

- [x] 3.1 实现 CourseService：createCourse(status=DRAFT) + getAllCourses(倒序) + getCourseById + updateCourseStep/Progress/Q1Counts + cascadeDeleteCourse(事务8表顺序删除)
- [x] 3.2 实现 AIService：@ohos.net.http + on('dataReceive')+on('dataEnd') + SSEStreamParser集成 + AIConcurrencyLock集成 + GlobalRateLimiter集成 + NetworkMonitor集成 + ApiKeyStore集成
- [x] 3.3 实现 AIService Prompt模板：注入parsed_content + 知识节点列表 + 防幻觉约束 + 禁止替代作答 + JSON禁止分片输出
- [x] 3.4 实现 AIService 日志：ai_request_log全量记录 + API Key脱敏(前3后4中间***) + duration_ms
- [x] 3.5 实现 FilePoolService：DocumentViewPicker + copyToSandbox(重名时间戳后缀) + deleteCourseFiles
- [x] 3.6 实现 MaterialParser：仅PDF/Markdown + ≤50MB + 扫描型PDF检测 + 解析超时10s + 失败status=failed
- [x] 3.7 实现 EvaluationService：五章节报告 + Q1:20%/Q2:40%/Q3:40%评分 + 布鲁姆层级得分 + 弱节点溯源 + Markdown导出
- [x] 3.8 实现 AnalyticsService：analytics_event表 + logEvent + sessionId管理 + 90天清理 + 与ERROR_LOG边界划分

## 4. ViewModel 层

- [x] 4.1 实现 HomeViewModel：@State courseList/isLoading/errorMessage + loadCourses + deleteCourse + selectCourse + try-catch + isLoading管理
- [x] 4.2 实现 CourseViewModel：课程详情加载 + 级联删除 + 进度计算(防除零) + try-catch + isLoading
- [x] 4.3 实现 ThreeAskViewModel：Q1激活节点→CORE全点亮判定 + Q2提交见解→AI评价→判定完成 + Q3请求9题→布鲁姆校验→作答→判定完成 + 状态流转严禁跳步 + 布鲁姆校验1/2/2/2/1/1 + 重试上限2次 + is_suspect计算
- [x] 4.4 实现 EvaluationViewModel：报告生成 + 导出 + 布鲁姆得分计算

## 5. 组件层

- [x] 5.1 实现 CourseCard：@Prop course + 回调onCardClick/onDeleteClick + 严禁Service调用
- [x] 5.2 实现 ProgressBar：@Prop progress(0~100) + 动画过渡
- [x] 5.3 实现 ThreeAskStepper：3步显示 + 当前高亮 + 已完成打勾 + 未到达DISABLE
- [x] 5.4 实现 ManualInputBox：禁粘贴(onPaste拦截) + 禁长按(enableContextMenu=false) + 速度检测(>150字/分→is_suspect=true, <10字→false) + accessibilityDescription
- [x] 5.5 实现 ChatBubble：逐字渲染(@State textContent追加) + 光标闪烁 + accessibilityText
- [x] 5.6 实现 DebateCard：左右分栏view_a/view_b + 证据展示 + Checkbox + ManualInputBox + accessibilityText
- [x] 5.7 实现 RadarChart：Canvas 6轴雷达图(布鲁姆6层级) + 数据驱动 + 严禁每帧重绘
- [x] 5.8 实现 PuzzleFragmentAnim：碎片→点亮动画 + animateTo≤500ms EaseInOut + 同时≤5个
- [x] 5.9 实现 MindBadgeAnim：勋章解锁动画 + animateTo≤500ms + 失败降级静态展示
- [x] 5.10 实现 AIRecommendBtn：复合知识库非空时展示
- [x] 5.11 实现 ThreeAskIndicator：三段式进度(绿色对勾+紫色脉冲+灰色)

## 6. 力导向布局算法

- [x] 6.1 实现力导向布局：斥力+引力+200迭代+收敛阈值1vp + 节点最小间距60vp + 边偏好长度120vp
- [x] 6.2 实现坐标初始化：x_pos/y_pos=-1→100~500随机 + 已激活节点fixed
- [x] 6.3 实现一次性@State更新：200迭代计算完毕后一次性赋值，严禁迭代中更新
- [x] 6.4 实现降级策略：≤50正常(Canvas+@Component) / 51~100关动画(Canvas only) / >100文本列表

## 7. 页面层

- [x] 7.1 实现 HomePage：课程列表(LazyForEach>20时) + 创建课程入口 + 卡片点击跳转 + 删除确认AlertDialog + aboutToAppear加载 + onDisappear释放
- [x] 7.2 实现 KnowledgeGraph(Q1)：Canvas连线+@Component节点 + 力导向200迭代一次性@State + 节点点击激活+碎片动画 + 降级 + onDisappear释放 + [PERF]日志
- [x] 7.3 实现 LearningSpace(Q2)：争议卡片列表+见解输入 + AI评价逐字渲染 + ManualInputBox + 跳过评价(15s超时后显示)
- [x] 7.4 实现 Assessment(Q3)：9题逐题作答 + 客观题选项+主观题ManualInputBox + 布鲁姆校验失败Toast + is_suspect标记
- [x] 7.5 实现 AssessmentResult：雷达图布鲁姆得分 + Q1/Q2/Q3分项得分 + 导出Markdown + onDisappear释放大对象

## 8. 集成与验证

- [x] 8.1 修改 EntryAbility：onCreate调clearAllOnColdStart() + NetworkMonitor.startMonitoring() + RdbHelper初始化
- [x] 8.2 实现页面路由：5页面注册 + router.pushUrl跳转 + router.back()严禁带参 + 删除课程后back回首页
- [x] 8.3 实现国际化资源：$r引用 + 资源键命名(btn_/page_title_/placeholder_/dialog_/toast_/label_/error_/status_/a11y_/a11y_desc_) + 中英文资源文件
- [x] 8.4 实现无障碍：按钮accessibilityText + 输入框accessibilityDescription + 知识图谱节点accessibilityText + 44vp最小点击区域
- [x] 8.5 端到端验证：创建课程→AI生成图谱→Q1点亮→Q2见解→Q3测评→评价报告完整闭环
- [x] 8.6 真人作答拦截验证：粘贴被拦 + >150字/分标记suspect + 短文本豁免
- [x] 8.7 布鲁姆校验验证：分布1/2/2/2/1/1 + 重试上限2次
- [x] 8.8 安全验证：离线拦截 + 全局限流 + API Key加密存储 + 日志脱敏
- [x] 8.9 级联删除验证：删课程后8表数据清除 + 物理文件清理
- [x] 8.10 冷启动验证：关闭重开数据不丢失 + 锁状态清空
