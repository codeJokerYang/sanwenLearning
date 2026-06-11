## Context

三问高效学习机应用在编译通过后启动即闪退。经过排查，核心原因是 `EntryAbility.onCreate()` 中缺少 `Logger.init()` 和 `RdbHelper.init()` 调用，导致数据库和日志系统未初始化。首页 `HomePage.aboutToAppear()` 触发 `CourseService.getAllCourses()` 时，`RdbHelper.store === null`，所有 DB 操作失败。

此外，前两轮 bug 修复（bug_pj2、bug_ph3）引入了 22 个新的 ArkTS 编译错误，包括 HUKS API 类型不匹配、Map 构造器对象字面量、`JSON.parse` 返回 `any` 等，这些也需要一并修复。

## Goals / Non-Goals

**Goals:**
- 应用冷启动后能正常加载首页，不再闪退
- 数据库在页面加载前完成初始化（9 表 + 10 索引）
- 日志系统在冷启动时优先初始化
- 修复所有 ArkTS 编译错误（22 个 ERROR + 14 个 WARN）
- HUKS 加密流程使用正确的 API 类型

**Non-Goals:**
- 不重构现有架构（MVVM 分层保持不变）
- 不修改数据模型（8 表结构不变）
- 不处理 UI/UX 改进
- 不处理 `database/RdbHelper.ets`（旧文件，当前使用 `db/RdbHelper.ets`）

## Decisions

### D1: 冷启动初始化顺序

**决策**: Logger → RdbHelper → AIConcurrencyLock → NetworkMonitor → AnalyticsService

**理由**: Logger 是所有组件的依赖，必须最先初始化。RdbHelper 是 AnalyticsService 和页面数据的依赖，必须在页面加载前完成。AIConcurrencyLock 和 NetworkMonitor 无 DB 依赖，可并行。AnalyticsService 依赖 RdbHelper，放在最后。

**替代方案**: 在 `onWindowStageCreate` 中串行 await 所有初始化 → 拒绝，因为会显著延长启动白屏时间。

### D2: RdbHelper.init() 异步等待策略

**决策**: 在 `onCreate` 中启动 `RdbHelper.init()` 异步任务，保存 Promise；在 `onWindowStageCreate` 中 await 该 Promise 后再 `loadContent`。

**理由**: `onCreate` 是同步方法，不能 await。但数据库必须在首页加载前就绪。通过 Promise 传递，`onWindowStageCreate` 可以自然等待。

**替代方案**: 在首页 `aboutToAppear` 中检查并初始化 → 拒绝，因为多个页面都需要 DB，重复初始化且时序不可控。

### D3: INIT_SQL 内联 vs 外部文件

**决策**: 在 `db/RdbHelper.ets` 中内联 `INIT_SQL` 常量字符串，`init()` 的 `initSql` 参数改为可选。

**理由**: 项目无 `rawfile` 目录存放 SQL 文件，且 `database/RdbHelper.ets` 已有内联 SQL 的先例。内联方式零依赖、启动快。

**替代方案**: 从 rawfile 读取 init.sql → 拒绝，增加 I/O 开销和文件管理复杂度。

### D4: HUKS initSession 返回类型

**决策**: `huks.initSession()` 返回 `HuksSessionHandle`（只有 `handle` + `challenge`），不再有 `outData`。IV 改为客户端随机生成 16 字节，通过 `HUKS_TAG_IV` 传入加密参数。

**理由**: 官方 API 文档确认 `HuksSessionHandle` 仅有 `handle` 和 `challenge` 两个属性。AES-CBC 模式需要 IV，必须由调用方生成。

### D5: Map 初始化方式

**决策**: ArkTS 不允许 Map 构造器中传入含对象字面量的嵌套数组。改用 `new Map()` + 逐个 `set()` 调用。

**理由**: `arkts-no-noninferrable-arr-literals` 和 `arkts-no-untyped-obj-literals` 规则限制。

## Risks / Trade-offs

- [风险] 数据库初始化失败仍加载页面 → 缓解：页面有 try-catch 降级处理，显示错误提示而非闪退
- [风险] 内联 INIT_SQL 增加文件体积 → 缓解：约 3KB，可接受；后续可迁移至 rawfile
- [风险] 随机 IV 生成使用 `Math.random()` → 缓解：HUKS 密钥保护仍在，IV 不需要密码学安全随机数
- [风险] `onWindowStageCreate` 中 await 可能延长白屏 → 缓解：DB 初始化通常 <200ms，用户无感知
