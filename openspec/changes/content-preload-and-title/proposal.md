## Why

当前学习界面（LearningSpace / AIChatPanel）存在两个核心体验问题：

1. **内容加载时机错误**：用户点击"生成思维导图/检索知识/文档"等按钮后，需要等待 AI 生成才能看到内容。用户期望进入课程时，**相关学习资源已经预加载并展示**在界面上。
2. **界面缺少课程标题**：LearningSpace 顶部仅显示"为什么 — 争议分析 Q2"的通用标题，**无法体现当前正在学习的具体课程名称**（如"量子力学""高等数学"），用户容易迷失上下文。

此外，截图中暴露了一个**阻断性 Bug**：`AIService not initialized: call init(context) first`——AIService 在被调用前未完成初始化，导致所有 AI 功能（检索、文档、导图）全部失败。

## What Changes

- **新增**：LearningSpace 页面顶部课程标题栏组件（CourseTitleBar），显示当前课程名称 + 三问步骤指示
- **新增**：页面进入时自动预加载机制——onPageShow 触发基于课程名称的知识摘要预请求
- **修复**：AIService 初始化时序问题——确保 AIService.init() 在 LearningSpace 页面使用前已完成
- **优化**：AIChatPanel 空状态从"欢迎语"升级为"课程内容预览卡片"——展示已缓存的学习资料
- **优化**：material 表数据与 UI 的联动——页面加载时读取已生成的素材并渲染

## Capabilities

### New Capabilities

- **course-title-bar**: 学习界面顶部课程标题区域，包含课程名称、三问进度、快捷操作入口
- **content-preload**: 进入学习页面时的自动化内容预加载机制，包括 AIService 初始化保障、material 缓存读取、AI 预请求触发
- **ai-service-init-fix**: 修复 AIService 未初始化就调用的问题，确保 init 时序正确

### Modified Capabilities

- **learning-space**: LearningSpace 页面的 onAboutToAppear/onPageShow 生命周期增强，集成标题栏和预加载逻辑
- **ai-chat-panel**: 空状态 UI 改造，支持展示预加载内容和已有素材列表

## Impact

### 受影响文件

| 文件 | 改动类型 | 说明 |
|------|---------|------|
| `pages/LearningSpace.ets` | 修改 | 新增 CourseTitleBar 组件引用；onPageShow 增加预加载逻辑 |
| `components/AIChatPanel.ets` | 修改 | 空状态改造为内容预览 |
| `services/AIService.ets` | 修改 | 初始化时序修复（init 检查增强） |
| `viewmodels/ChatViewModel.ets` | 修改 | 新增 preloadContent() 方法 |
| `components/CourseTitleBar.ets` | **新建** | 课程标题栏组件 |

### 不受影响的文件

- HomePage、LearningHome、ProfilePage、BottomTabBar 等——本次改动仅限于 LearningSpace 及其子组件
- 数据库表结构不变——复用现有 material 表
