## ADDED Requirements

### Requirement: 上下文感知的多轮对话

AI 对话系统 MUST 支持基于课程上下文的智能多轮对话，能够理解学习场景并提供专业指导。

#### Scenario: 课程上下文自动注入
- **WHEN** 用户在课程详情页打开 AI 对话并发送消息
- **THEN** 系统 MUST 自动加载该课程的已学知识点、当前三问阶段、已有争议点和测评记录作为上下文
- **THEN** AI 的回复 MUST 参考这些上下文信息，避免重复已知内容或推荐已完成的学习活动

#### Scenario: 多轮追问引导
- **WHEN** AI 回答完一个问题后
- **THEN** AI MAY 在回复末尾追加 1-2 个引导性问题（如"你想深入了解哪个方面？"）
- **THEN** 用户点击引导问题 OR 手动输入均可继续对话
- **THEN** 对话历史 MUST 保持完整的角色/时间戳/原文记录（符合 DATA_CONTRACT 要求）

#### Scenario: 斜杠指令扩展
- **WHEN** 用户在输入框输入 `/help`
- **THEN** 系统 MUST 显示所有可用指令列表，包括新增的 `/mindmap` `/doc` `/framework` `/search <主题>`
- **WHEN** 用户输入 `/clear`
- **THEN** 当前对话 MUST 被清空（保持原有行为不变）

---

### Requirement: 对话消息类型扩展

ChatViewModel MUST 支持除纯文本外的结构化内容消息类型。

#### Scenario: 结构化消息的接收与存储
- **WHEN** AI 返回阶段 2 的 JSON 数据（type 为 mindmap/studydoc/framework/knowledge）
- **THEN** ChatViewModel MUST 将其解析为对应的 TypeScript 接口对象
- **THEN** 该消息 MUST 以特殊 UI 形式渲染（非普通 ChatBubble），支持展开/收起/预览
- **THEN** 消息 MUST 持久化到 ai_message 表的 content 字段（JSON 字符串格式）

#### Scenario: 混合内容对话流
- **WHEN** 对话中同时包含文本消息和结构化内容消息
- **THEN** 消息列表 MUST 按时间顺序交替渲染
- **THEN** 文本消息继续使用 ChatBubble 组件
- **THEN** 结构化消息使用对应的专用组件（ContentPreviewCard）

---

### Requirement: AI 对话错误处理增强

生成类 AI 请求的错误处理 MUST 符合 AI_SERVICE_PROTOCOL 规范。

#### Scenario: 生成请求超时
- **WHEN** 内容生成请求超过读超时时间（60s）
- **THEN** 系统 MUST 取消请求并显示超时提示
- **THEN** MUST 记录 ai_request_log（status=TIMEOUT）
- **THEN** MUST 写 ERROR_LOG（UI/DB 异常写 ERROR_LOG，严禁写埋点 —— 按 ERROR_LOG_CONVENTIONS）

#### Scenario: 生成请求失败
- **WHEN** 内容生成请求因网络/AI 服务异常失败
- **THEN** 系统 MUST 显示友好的错误提示（不展示技术堆栈）
- **THEN** MUST 提供"重试"按钮
- **THEN** MUST 记录 ai_request_log（status=FAILED）+ 埋点（按 ANALYTICS_CONVENTIONS）
