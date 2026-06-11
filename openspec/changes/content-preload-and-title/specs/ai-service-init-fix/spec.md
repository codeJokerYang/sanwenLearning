## ADDED Requirements

### Requirement: AIService 必须在应用启动时完成初始化

系统 SHALL 在 `EntryAbility.onCreate()` 中调用 `AIService.getInstance().init(context)`，确保 AIService 的 `context` 属性在首次使用前已赋值。

#### Scenario: 应用启动时 AIService 初始化成功
- **WHEN** 应用冷启动，`EntryAbility.onCreate()` 执行
- **THEN** `AIService.getInstance().init(this.context)` 被调用
- **AND** `AIService.context` 不为 null

#### Scenario: AI 方法调用时 context 已可用
- **WHEN** 用户在 LearningSpace 中触发任意 AI 功能（chat/generateContent/retrieve）
- **THEN** AIService 内部的 `if (!this.context)` 检查通过（不抛出 "not initialized" 异常）
- **AND** AI 请求正常发起

### Requirement: AIService.init() 不得阻塞主线程

`AIService.init(context)` SHALL 仅执行同步赋值操作（`this.context = context`），异步的 API Key 存储检查（`ensureApiKeyStored`） SHALL 在后台异步执行，不阻塞 onCreate 返回。

#### Scenario: init() 同步部分即时完成
- **WHEN** `AIService.init(context)` 被调用
- **THEN** `this.context = context` 在同一线程同步完成
- **THEN** 方法调用耗时 <1ms
