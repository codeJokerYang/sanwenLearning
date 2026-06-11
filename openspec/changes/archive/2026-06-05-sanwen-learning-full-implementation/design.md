## Context

三问高效学习机是基于 HarmonyOS NEXT API 12+ 的原生应用，采用 ArkTS 声明式 UI + Stage 模型。项目当前状态：已有基础脚手架（EntryAbility、Config、Logger）、部分数据层代码（RdbHelper、Models、init.sql），但核心业务流程（三问引擎、AI 服务、文件池、评价报告等）尚未实现。

项目受 14 份规范文档严格约束，其中 DATA_CONTRACT.md、AI_SERVICE_PROTOCOL.md、FEATURE_RULES.md 为宪法级文档，数值冲突以 AI_SERVICE_PROTOCOL.md 为准。

## Goals / Non-Goals

**Goals:**
- 实现完整的三问认知引擎闭环：提问→知识图谱→争议分析→测评→评价报告
- 严格落实数据契约类型转换铁律（Long→number、0/1→boolean、NULL→联合类型）
- 实现 AI 两阶段 SSE 流式传输 + 并发锁 + 防幻觉机制
- 实现真人作答 4 层防线（粘贴拦截+速度检测+Prompt 约束+报告标注）
- 实现 API Key HUKS 加密存储 + 网络熔断 + 离线拦截
- 遵循 Pages→ViewModels→Services→RdbHelper 严格分层，单文件 ≤300 行

**Non-Goals:**
- 不实现 PDF 端侧文本提取（当前版本 parsed_content=null, status=FAILED）
- 不实现 WebSocket 通信（仅 SSE）
- 不实现服务端 API（纯端侧应用 + LLM API 调用）
- 不实现多用户/登录系统
- 不实现 WebView 套壳

## Decisions

### D1: 分层架构 — Pages→ViewModels→Services→RdbHelper

**选择**：严格单向依赖的4层架构
**替代方案**：MVVM + Repository 模式（多一层 Repository 抽象）
**理由**：项目规模中等，4层足够清晰。Repository 层在当前规模下增加复杂度但无实际收益。RdbHelper 已封装 CRUD + 事务，Service 层直接调用即可。

### D2: SSE 流式传输 — @ohos.net.http + on('dataReceive')

**选择**：使用鸿蒙原生 http 模块的 requestInStream + dataReceive 事件
**替代方案**：WebView + EventSource（跨平台兼容但违反技术红线）
**理由**：项目规则严禁 WebView 和第三方网络库。@ohos.net.http 是唯一合法方案，通过 on('dataReceive') 接收 ArrayBuffer，UTF-8 解码后交给 SSEStreamParser 处理。

### D3: AI 并发锁 — Map + 被动超时清理

**选择**：Map<courseId, {locked, acquireTime}> + 每次 acquireLock 开头调 forceReleaseTimeout()
**替代方案**：定时器主动扫描（Timer-based）
**理由**：被动清理比定时器更可靠——不依赖定时器是否存活，每次获取锁时必定检查。冷启动 clearAllOnColdStart() 确保无残留锁。120s 超时远大于 SSE readTimeout(60s)，防止活跃连接被误释放。

### D4: 力导向布局 — 主线程计算 + 一次性 @State 更新

**选择**：200次迭代在主线程计算，结果一次性赋值 @State
**替代方案**：TaskPool 子线程计算（JSON 序列化传递）
**理由**：50节点200迭代 <100ms，主线程可接受。TaskPool 需 JSON 序列化/反序列化，增加复杂度且 rdbStore 不可跨线程。若性能不达标再降级。

### D5: 知识图谱渲染 — Canvas + @Component 混合方案

**选择**：Canvas 画连线+已激活节点，@Component 画碎片态节点+动画
**替代方案**：纯 Canvas 渲染（含动画）或纯 @Component 渲染
**理由**：Canvas 处理连线高效但动画能力弱；@Component 动画能力强但大量节点性能差。混合方案各取所长：碎片动画用 @Component + animateTo，点亮后切 Canvas 绘制。

### D6: API Key 存储 — HUKS 加密 + preferences 存密文

**选择**：HUKS AES-256 加密 API Key，密文存 preferences
**替代方案**：明文 preferences（违反安全红线）
**理由**：API_SECURITY_CONVENTIONS.md 硬性要求。HUKS 是鸿蒙安全世界密钥管理，密钥不出 TEE，比应用层对称加密更安全。

### D7: 真人作答 — onChange 首次输入计时 + 150字/分钟阈值

**选择**：onChange 首次触发时记录 startTime，提交时计算字/分钟
**替代方案**：onFocus 计时（包含思考时间，不准确）
**理由**：onChange 首次输入排除思考时间，更精确反映实际输入速度。150字/分钟阈值保守，宁可漏检不可误判。短文本(<10字)豁免避免误判。

## Risks / Trade-offs

- **[SSE 网络不稳定]** → 跨阶段超时 15s + 继续生成/重试双按钮 + 网络中断友好提示
- **[力导向布局性能]** → 50节点200迭代 <100ms 目标；超限则降级（51~100关动画，>100文本列表）
- **[AI 生成质量不稳定]** → 布鲁姆9题校验 + 自动重试上限2次 + 手动重试按钮
- **[PDF 无法解析]** → 当前版本 parsed_content=null, status=FAILED, UI 强提示上传 Markdown
- **[Canvas 渲染失败]** → 降级为纯文本列表模式，仍支持节点点击激活
- **[AI 评价超时导致 Q2 死锁]** → 提供"跳过评价，继续学习"按钮，ai_evaluation 写入跳过标记
- **[单文件 300 行限制]** → 大 Service 拆分为核心 + 辅助模块（如 AIService + SSEStreamParser + AIConcurrencyLock）
