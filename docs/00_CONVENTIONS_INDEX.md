# 三问高效学习机 — 规范索引与冲突解决规则

> 版本：v1.0 | 日期：2026-06-05 | Trae 编码第一入口，必须首先阅读本文件

---

## 1. 文档优先级（从高到低）

当文档之间出现定义冲突时，优先级高的文档覆盖优先级低的文档：

1. **DATA_CONTRACT.md** — 数据与类型宪法（数据结构、类型转换、主外键约束）
2. **AI_SERVICE_PROTOCOL.md** — AI 交互最高法（SSE 协议、锁超时、Prompt 规范）
3. **FEATURE_RULES.md** — 业务防呆与流程法（三问流转、布鲁姆校验、文件处理）
4. **ARCHITECTURE_CONVENTIONS.md** — 分层与组件法（目录结构、调用方向、状态管理）
5. **其他规范**（平级，互不覆盖）：
   - API_SECURITY_CONVENTIONS.md
   - ERROR_LOG_CONVENTIONS.md
   - ANALYTICS_CONVENTIONS.md
   - PERFORMANCE_CONVENTIONS.md
   - UI_ROUTING_CONVENTIONS.md
   - I18N_AND_A11Y_CONVENTIONS.md
   - RELEASE_AND_UPDATE_CONVENTIONS.md

---

## 2. 冲突解决规则

- **数值冲突**：以优先级高的文档为准（如：锁超时时间以 `AI_SERVICE_PROTOCOL.md` 的 120s 为准，而非 `PERFORMANCE_CONVENTIONS.md`）
- **同一主题多文档描述**：以更专门的那份为准（如：AI 请求细节以 `AI_SERVICE_PROTOCOL.md` 为准，而非 `FEATURE_RULES.md`）
- **正交约束**：不同文档约束不同维度时，必须同时满足（如：业务防呆要求 + 性能阈值要求 + 安全脱敏要求）

---

## 3. Trae 工作流

在开始任何编码任务前，请严格遵循以下步骤：

1. **读本索引**：理解优先级和冲突解决规则
2. **读核心三文档**：`DATA_CONTRACT.md` + `AI_SERVICE_PROTOCOL.md` + `FEATURE_RULES.md`
3. **读架构约束**：`ARCHITECTURE_CONVENTIONS.md`（确保分层正确）
4. **根据任务读其他规范**：如涉及网络读安全规范，涉及 UI 读路由/国际化规范
5. **实现时遇冲突**：按优先级判断，并在代码注释中注明依据来源

---

## 4. 核心数值速查表

为避免在多文档中翻找，以下列出最易冲突或最常用的核心数值：

| 参数 | 值 | 唯一权威来源 |
|------|----|------------|
| AI 并发锁超时 | **120 秒** | AI_SERVICE_PROTOCOL.md |
| SSE 连接超时 | 15 秒 | AI_SERVICE_PROTOCOL.md |
| SSE 读取超时 | 60 秒 | AI_SERVICE_PROTOCOL.md |
| 跨阶段等待超时 | 15 秒 | AI_SERVICE_PROTOCOL.md |
| JSON 缓冲上限 | 5M 字符数 | AI_SERVICE_PROTOCOL.md |
| 布鲁姆 9 题分布 | 记1/理2/应2/分2/评1/创1 | FEATURE_RULES.md |
| 知识图谱坐标初始值 | -1 | DATA_CONTRACT.md |
| 坐标随机初始化范围 | 100~500 | DATA_CONTRACT.md / FEATURE_RULES.md |
| 真人作答速度阈值 | 150 字/分钟 | FEATURE_RULES.md |
| 课程状态枚举 | 0-5 | DATA_CONTRACT.md |
| 力导向布局最大迭代 | 200 次 | FEATURE_RULES.md / PERFORMANCE_CONVENTIONS.md |
| 全局限流 | 10 次/分钟 | API_SECURITY_CONVENTIONS.md |
| 文件大小限制 | 50MB | FEATURE_RULES.md |
| @State 单变量内存上限 | 1MB | PERFORMANCE_CONVENTIONS.md |
| 离线拦截 | 强制拦截，不排队 | API_SECURITY_CONVENTIONS.md |
| 日志保留天数 | 错误日志 7 天 / 埋点 90 天 | ERROR_LOG / ANALYTICS_CONVENTIONS |
| DB_VERSION 初始值 | 1 | RELEASE_AND_UPDATE_CONVENTIONS.md |

---

## 5. 文档清单与职责摘要

| 文档名 | 核心职责 |
|--------|---------|
| DATA_CONTRACT.md | 8 表结构、枚举、Long 转 number、ID 替换、JSON 解析兜底 |
| AI_SERVICE_PROTOCOL.md | 两阶段 SSE、onChunkReceived、120s 锁、Prompt 模板、防幻觉 |
| FEATURE_RULES.md | 三问强管控、真人拦截 4 层防线、布鲁姆校验重试、力导向初始化 |
| ARCHITECTURE_CONVENTIONS.md | Pages-ViewModel-Service 分层、严禁逆向依赖、300 行红线 |
| API_SECURITY_CONVENTIONS.md | HUKS 加密 Key、熔断器 10 次/分、离线强拦截 |
| ERROR_LOG_CONVENTIONS.md | 7 天滚动、Markdown 6 字段、全局异常捕获 |
| ANALYTICS_CONVENTIONS.md | 埋点事件表、与错误日志边界划分、90 天清理 |
| PERFORMANCE_CONVENTIONS.md | 帧率/耗时阈值、LazyForEach、内存释放、可验证指标 |
| UI_ROUTING_CONVENTIONS.md | 3 页面清单、router.back 严禁带参、@State/@Prop/@Link 决策树 |
| I18N_AND_A11Y_CONVENTIONS.md | 严禁硬编码中文（5 种例外）、accessibilityText、44vp 点击区 |
| RELEASE_AND_UPDATE_CONVENTIONS.md | 语义化版本、DB 迁移脚本红线、发布前检查清单 |
