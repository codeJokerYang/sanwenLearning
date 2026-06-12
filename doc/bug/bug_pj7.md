# BUG-PJ7：AI 对话面板发送按钮无响应 & Q2 快捷按钮"阻塞"

> 日期：2026-06-12 | 严重度：高（核心交互不可用） | 状态：已修复

## 一、现象

1. 「AI 学习伙伴」面板中输入文本后点击发送按钮（↑），界面无任何反应；
2. Q2 学习空间页"暂无争议点"空状态下的四个快捷按钮（检索相关知识 / 生成思维导图 / 生成学习文档 / 向 AI 提问）点击后面板打开，但始终停留在"已就绪"空状态，疑似按钮被阻塞。

## 二、定位过程

1. 检查 `AIChatPanel.ets` 事件绑定：发送按钮 `onClick` → `safeSend()` → `viewModel.sendMessage()`，绑定**正确存在**，排除事件未注册；
2. 检查 `LearningSpace.ets` 四个 `AiGuideButton` 的 `onClick`：均正确调用 `openAIChatPanel(mode)`，面板能打开（`chatOpen` 是 `@State`，可触发渲染），排除层级遮挡与 z-index 问题；
3. 审查 `ChatViewModel.ets`：类**未加 `@Observed` 装饰器**；`AIChatPanel` 中以 `private viewModel = ChatViewModel.getInstance()` 普通字段持有——两者均不在 ArkUI 状态管理体系内；
4. 结论：`sendMessage()` 实际执行了（消息已写入数组甚至数据库），但 **UI 永远不会重渲染**，用户感知为"按钮无响应"。

## 三、根本原因

**状态管理断链**（前端框架层问题，非业务逻辑或环境因素）：

- ArkUI（V1 状态管理）只观察被装饰器（@State/@ObjectLink/@Prop…）跟踪的数据；
- `ChatViewModel` 单例虽然规范地以"整体替换数组"方式更新 `messages`（正是为配合第一层观察语义而写），但类本身没有 `@Observed`，实例不是可观察代理；
- 组件持有方式为普通私有字段，框架不订阅其变化；
- 双重缺失导致所有 VM 状态变化（消息追加、流式输出、模式切换、错误提示）均不触发 UI 更新。两个"缺陷"实为同一根因。

附带缺陷：`TextInput` 未绑定 `text` 属性，发送后 `inputText=''` 无法清空输入框。

## 四、修复方案

| 文件 | 修改 |
|------|------|
| `viewmodels/ChatViewModel.ets` | 类声明加 `@Observed`，实例成为可观察代理，任意路径的第一层属性赋值都会通知订阅组件 |
| `components/AIChatPanel.ets` | `viewModel` 改为 `@State` 持有；`TextInput` 绑定 `text: viewModel.inputText` |
| `viewmodels/ChatViewModel.ets` | 错误映射补充 `ERR_API_KEY_MISSING` → 引导前往设置页的友好提示 |

发送按钮原有的加载反馈（流式期间禁用 + 降透明度）在修复后开始真正生效。

## 五、验证

- 编译通过（hvigor assembleHap）；
- 模拟器实测：发送消息后用户气泡立即上屏、AI 流式回复渲染、错误场景显示可重试提示（见测试报告）。

## 六、预防措施

1. **代码审查要点**：凡组件读取 ViewModel/共享单例状态渲染 UI，必须确认"类有 @Observed（或 V2 的 @ObservedV2/@Trace）+ 组件侧有状态装饰器"两端齐备；
2. **自测规约**：新增交互必须在模拟器点一遍真实链路，不能只验证"编译通过 + 逻辑执行"（本缺陷日志里 sendMessage 全程正常执行，仅 UI 不刷新）；
3. **架构约定**：`docs/ARCHITECTURE_CONVENTIONS.md` 应补充"共享 ViewModel 必须 @Observed"条款；
4. **后续优化**：中长期可迁移到状态管理 V2（@ComponentV2 + @ObservedV2/@Trace），获得深层观察能力，消除此类隐患。
