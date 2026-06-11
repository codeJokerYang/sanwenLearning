## ADDED Requirements

### Requirement: StatusLayout 通用状态组件
系统 SHALL 提供 `StatusLayout` 通用组件，封装 Loading/Empty/Error/Content 四种状态视图，各页面通过 `@Prop` 控制显示。

**类型定义**：
- `StatusType = 'loading' | 'empty' | 'error' | 'content'`
- `EmptyConfig { icon?: ResourceStr, message: ResourceStr, actionText?: ResourceStr, onAction?: () => void }`
- `ErrorConfig { icon?: ResourceStr, message: ResourceStr, retryText?: ResourceStr, onRetry?: () => void }`
- 组件 Props: `@Prop status: StatusType`, `@Prop emptyConfig: EmptyConfig | null`, `@Prop errorConfig: ErrorConfig | null`, `@BuilderParam contentSlot`

#### Scenario: Loading 状态显示
- **WHEN** 页面数据正在加载中
- **THEN** StatusLayout 显示居中的 LoadingProgress + 加载提示文字

#### Scenario: Empty 状态显示
- **WHEN** 页面数据为空（如课程列表为空）
- **THEN** StatusLayout 显示空态图标 + EmptyConfig.message + 可选操作按钮（EmptyConfig.actionText + onAction）

#### Scenario: Error 状态显示
- **WHEN** 页面数据加载失败
- **THEN** StatusLayout 显示错误图标 + ErrorConfig.message（Resource 类型，由 errorCodeToResource 转换）+ 重试按钮（ErrorConfig.retryText + onRetry）

#### Scenario: Content 状态显示
- **WHEN** 页面数据加载成功
- **THEN** StatusLayout 显示实际内容（通过 @BuilderParam contentSlot 传入）

#### Scenario: 错误码到 StatusLayout 的完整流转
- **WHEN** ViewModel 抛出错误码（如 `throw new Error(ErrorCode.COURSE_LOAD_FAILED)`）
- **THEN** Page 层 catch 错误码 → 调用 `errorCodeToResource(err.message)` 转为 Resource → 构造 ErrorConfig { message: Resource, onRetry } → StatusLayout Error 态显示

### Requirement: 页面 Loading 状态管理
系统 SHALL 在所有包含异步数据加载的页面中实现 pageStatus 状态管理（StatusType 类型），数据加载期间显示 StatusLayout Loading 状态。

#### Scenario: HomePage 加载状态
- **WHEN** HomePage 的 aboutToAppear 触发课程列表加载
- **THEN** pageStatus 设为 'loading'，显示 StatusLayout Loading 状态；加载完成后 pageStatus 设为 'content' 或 'empty'

#### Scenario: KnowledgeGraph 加载状态
- **WHEN** KnowledgeGraph 的 aboutToAppear 触发知识图谱数据加载
- **THEN** pageStatus 设为 'loading'；加载完成后切换为 'content'（含 renderMode 判断）

#### Scenario: Assessment 加载状态
- **WHEN** Assessment 的 aboutToAppear 触发测评题目加载
- **THEN** pageStatus 设为 'loading'；加载完成后切换为 'content' 或 'empty'

### Requirement: 网络断开提示
系统 SHALL 在检测到网络断开时，阻止 AI 请求并发弹窗提示用户。网络检测使用 `@ohos.net.connection` 主动监听（NetworkMonitor 单例），ViewModel 层在 AI 请求前调用 `NetworkMonitor.getInstance().isNetworkAvailable()` 检查。

#### Scenario: 断网时发起 AI 请求
- **WHEN** 用户在网络断开状态下尝试触发 AI 请求
- **THEN** ViewModel 抛出 `ErrorCode.NETWORK_DISCONNECTED`，Page 层弹窗提示"网络未连接，请检查网络设置"，不发起 AI 请求

#### Scenario: 运行中网络断开
- **WHEN** AI 请求进行中网络断开
- **THEN** NetworkMonitor 触发 netLost 事件，当前请求失败后 Service 层返回网络错误，Page 层显示 Error 态

### Requirement: AI 超时/失败友好提示
系统 SHALL 在 AI 请求超时或失败时显示友好错误提示并提供重试操作入口。超时检测在 Service 层（AIService）通过 setTimeout 120 秒实现。

#### Scenario: AI 请求超时
- **WHEN** AI 请求超过 120 秒未返回（Service 层 setTimeout 截断）
- **THEN** Service 层抛出 `ErrorCode.AI_TIMEOUT`，Page 层通过 errorCodeToResource 转换后 StatusLayout Error 态显示"AI服务响应超时，请检查网络后重试"+ 重试按钮

#### Scenario: AI 请求失败
- **WHEN** AI 请求返回错误
- **THEN** Service 层抛出 `ErrorCode.AI_FAILED`，Page 层显示"AI服务暂时不可用，请稍后重试"+ 重试按钮

#### Scenario: 页面已有内容时 AI 失败
- **WHEN** AI 请求失败但页面已有内容（pageStatus = 'content'）
- **THEN** 使用 Toast 提示而非 StatusLayout Error 态，不阻断用户浏览已有内容

### Requirement: 并发错误优先级
系统 SHALL 按以下优先级处理并发错误状态：全局弹窗（网络断开）> StatusLayout Error 态 > StatusLayout Empty 态。

#### Scenario: 网络断开弹窗与 StatusLayout Error 态并发
- **WHEN** 页面已在 StatusLayout Error 态时网络断开
- **THEN** 弹窗优先显示，关闭弹窗后 StatusLayout Error 态仍可见

#### Scenario: AI 请求失败与 StatusLayout Error 态并发
- **WHEN** 页面已在 StatusLayout Error 态时 AI 请求再次失败
- **THEN** 不再弹窗，直接在 Error 态更新错误信息和重试按钮

### Requirement: 空态占位 UI
系统 SHALL 在以下场景提供空态占位 UI：课程列表为空、知识图谱节点为空、测评题目为空。

#### Scenario: 课程列表空态
- **WHEN** 用户打开首页且无任何课程
- **THEN** StatusLayout Empty 态显示 EmptyConfig { message: "还没有课程，输入问题开始学习吧", actionText: "去创建", onAction: 聚焦搜索框 }

#### Scenario: 知识图谱节点空态
- **WHEN** 复合知识库内容不足以生成知识图谱
- **THEN** StatusLayout Empty 态显示"当前资料不足以生成知识图谱，请上传更多学习资料"

#### Scenario: 无有效资料拦截
- **WHEN** 所有资料 parsed_content 均为 null 时用户尝试开始三问
- **THEN** ViewModel 抛出 `ErrorCode.NO_VALID_MATERIAL`，Page 层提示"无有效学习资料，请上传 Markdown 文件"

### Requirement: 资源引用 Fallback 机制
系统 SHALL 确保资源引用失败时有兜底显示，不会出现空白或异常文本。

#### Scenario: 未知错误码 Fallback
- **WHEN** errorCodeToResource() 收到未定义的错误码
- **THEN** 返回 `$r('app.string.err_unknown')` 通用兜底提示（"操作失败，请重试"）

#### Scenario: 资源 key 拼写错误
- **WHEN** 开发者使用了不存在的 `$r('app.string.xxx')` key
- **THEN** HarmonyOS 编译期报错，阻止发布

#### Scenario: 英文资源漏配
- **WHEN** en_US/string.json 缺少某个 key
- **THEN** HarmonyOS 回退到 base/string.json 的值，不显示空白
