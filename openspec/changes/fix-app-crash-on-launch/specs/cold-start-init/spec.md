## ADDED Requirements

### Requirement: Cold start initialization chain
The system SHALL initialize services in the following order during `EntryAbility.onCreate()`: Logger → RdbHelper → AIConcurrencyLock → NetworkMonitor → AnalyticsService. Logger and RdbHelper MUST be initialized before any other service or page accesses them.

#### Scenario: Normal cold start
- **WHEN** application launches for the first time
- **THEN** Logger.init(context) is called first, followed by RdbHelper.init(context), then AIConcurrencyLock, NetworkMonitor, and AnalyticsService in sequence

#### Scenario: Database initialization completes before page load
- **WHEN** EntryAbility.onWindowStageCreate() is called
- **THEN** the system SHALL await the RdbHelper.init() Promise before calling windowStage.loadContent('pages/HomePage')

#### Scenario: Database initialization fails
- **WHEN** RdbHelper.init() rejects (throws exception)
- **THEN** the system SHALL still load the HomePage (with degraded UX), and the page SHALL display an error message instead of crashing

### Requirement: RdbHelper inline INIT_SQL
RdbHelper SHALL contain an inline `INIT_SQL` constant with the complete DDL for all 9 tables (course, knowledge_node, knowledge_edge, quiz_question, controversy, question_record, material, ai_request_log, analytics_event) and 10 indexes. The `init()` method's `initSql` parameter SHALL be optional, defaulting to the inline `INIT_SQL` when not provided.

#### Scenario: First launch with no existing database
- **WHEN** RdbHelper.init(context) is called and store.version === 0
- **THEN** all 9 tables and 10 indexes are created via executeInitScript(), and store.version is set to DB_VERSION

#### Scenario: Init called without initSql argument
- **WHEN** RdbHelper.getInstance().init(context) is called without a second argument
- **THEN** the inline INIT_SQL is used as the initialization script

### Requirement: HUKS session handle type correctness
The system SHALL use `huks.HuksSessionHandle` as the return type of `huks.initSession()`, and `huks.HuksReturnResult` as the return type of `huks.finishSession()`. The IV for AES-CBC encryption SHALL be generated client-side (16 random bytes) and passed via `HUKS_TAG_IV`.

#### Scenario: API key encryption
- **WHEN** ApiKeyStore.saveApiKey() is called
- **THEN** a random 16-byte IV is generated, passed to HUKS via HUKS_TAG_IV, and stored alongside the ciphertext in preferences

#### Scenario: API key decryption
- **WHEN** ApiKeyStore.loadApiKey() is called
- **THEN** the stored IV is retrieved from preferences and passed to HUKS via HUKS_TAG_IV for decryption

### Requirement: ArkTS type safety compliance
All code SHALL comply with ArkTS strict mode requirements: no `any`/`unknown` types, no untyped object literals in Map constructors, no const declarations inside build() methods, and explicit type annotations for Map.get() return values.

#### Scenario: JSON.parse result typing
- **WHEN** JSON.parse() is called
- **THEN** the result SHALL have an explicit type annotation (e.g., `const parsed: string[] = JSON.parse(x) as string[]`)

#### Scenario: Map initialization
- **WHEN** a Map with object values is needed
- **THEN** the Map SHALL be initialized with `new Map()` followed by individual `set()` calls, not with a constructor array argument

### Requirement: Permission declarations
The application SHALL declare `ohos.permission.INTERNET` and `ohos.permission.GET_NETWORK_INFO` in module.json5's requestPermissions array.

#### Scenario: Network access
- **WHEN** the application makes an HTTP request or checks network status
- **THEN** the required permissions are already declared and granted at install time
