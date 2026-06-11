## MODIFIED Requirements

### Requirement: AIChatPanel 空状态支持条件渲染

AIChatPanel 的消息列表区域 SHALL 根据当前状态条件渲染不同内容：

| 状态 | 渲染内容 |
|------|---------|
| 有 messages | 消息列表（ChatBubble + ContentPreviewCard） |
| 无消息 + 非加载中 | 欢迎语 + 模式选择提示 |
| isStreaming=true | 加载动画/Skeleton |
| errorMessage 非空 | 错误提示 + 重试按钮 |

#### Scenario: 预加载后有内容时隐藏欢迎语
- **WHEN** preloadContent() 成功追加 2 条消息到列表
- **THEN** AIChatPanel 不再显示欢迎语
- **AND** 直接显示 2 条 ContentPreviewCard

#### Scenario: AI 请求失败时显示可重试错误
- **WHEN** AI 请求抛出异常且 errorMessage 非空
- **THEN** 显示红色错误文本 + "重试"按钮
- **AND** 点击重试按钮重新触发最后一次请求
