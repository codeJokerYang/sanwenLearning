## Why

应用启动后立即闪退，用户无法操作任何功能。根因是 `RdbHelper.init()` 从未在 `EntryAbility.onCreate()` 中被调用，导致数据库未初始化（`store === null`）。首页加载时所有 DB 操作因 store 为空而失败，且部分未捕获异常直接导致进程崩溃。此外，`Logger.init()` 也未在冷启动时调用，导致日志系统无法正常写入文件。

## What Changes

- **BREAKING**: 在 `EntryAbility.onCreate()` 中添加 `Logger.init(context)` 和 `RdbHelper.init(context)` 调用，确保冷启动时数据库和日志系统优先初始化
- 在 `EntryAbility.onWindowStageCreate()` 中等待数据库初始化完成后再加载首页，避免页面访问未初始化的 DB
- 在 `db/RdbHelper.ets` 中内联 `INIT_SQL` 建表脚本（9 表 + 10 索引），`init()` 方法的 `initSql` 参数改为可选
- 修复 `db/RdbHelper.ets` 中 `safeParseJsonArray` 的 `JSON.parse` 返回 `any` 类型问题
- 修复 `services/ApiKeyStore.ets` 中 HUKS API 类型错误（`HuksSessionHandle` vs `HuksReturnResult`）及 IV 生成逻辑
- 修复 `services/EvaluationService.ets` 中 Map 构造器含不可推断对象字面量的问题
- 修复 `pages/KnowledgeGraph.ets` 中对象字面量类型声明和 build() 中 const 声明
- 修复 `pages/Assessment.ets` 中 `JSON.parse` 返回 `any` 类型问题
- 修复 `components/ManualInputBox.ets` 中 `onPaste` 回调参数类型不匹配
- 修复 `common/ForceLayoutUtil.ets` 中 `LayoutPosition` 接口未导出
- 修复 `services/AIService.ets` 中废弃的 `TextDecoder.decode()` API
- 修复 `common/Logger.ets` 中 `fileIo.openSync` 返回 `File` 类型而非 `number`
- 修复 `entry/src/main/module.json5` 缺少 `INTERNET` 和 `GET_NETWORK_INFO` 权限声明

## Capabilities

### New Capabilities
- `cold-start-init`: 冷启动初始化链 — 规范 Logger → RdbHelper → AIConcurrencyLock → NetworkMonitor → AnalyticsService 的初始化顺序和依赖关系

### Modified Capabilities
<!-- 无现有 spec 需要修改 -->

## Impact

- **EntryAbility.ets**: 冷启动生命周期变更，新增异步初始化等待逻辑
- **db/RdbHelper.ets**: 新增内联 INIT_SQL，init() 签名变更（initSql 可选）
- **services/ApiKeyStore.ets**: HUKS 加密流程重构（IV 生成方式变更）
- **services/EvaluationService.ets**: Map 初始化方式变更
- **pages/KnowledgeGraph.ets**: 类型声明变更（LayoutPosition 替代 NodePosition）
- **module.json5**: 新增权限声明
- **编译警告**: 约 22 个 ArkTS 编译错误已修复
