## Why

当前项目虽已成功运行，但界面设计存在系统性缺陷：颜色/字号/间距全部硬编码未抽取设计 token，暗色模式不可用；i18n 覆盖不完整（8 处页面 errorMessage + 5 处 ViewModel errorMessage 硬编码中文）；无障碍属性大面积缺失（搜索框、对话框、Radio 选项等均无 accessibilityText）；多处可点击元素小于 44vp 最小可点击区域；HomePage 存在阻塞性崩溃（undefined.length）；动画时长违规（MindBadgeAnim 2000ms 超 500ms 上限）；知识图谱碎片节点与 Canvas 坐标映射不一致导致视觉错位；心智塑成勋章粒子效果失效；DebateCard 未使用 ManualInputBox 允许粘贴；多个页面超过 300 行限制。这些问题导致界面质量远低于项目规划与规范要求，亟需系统性优化。

## What Changes

- **修复阻塞性崩溃**：HomePage 第 181 行 `undefined.length` 导致应用启动白屏，需对 `@State` 数组初始化为 `[]` 并增加空值防护
- **建立设计 token 体系**：将全部硬编码颜色（15+ 语义色）、字号（5 档）、间距（4 档）、圆角（2 档）抽取为 `$r('app.color/float.xxx')` 资源引用，支持暗色模式
- **完善 i18n 覆盖**：将 13+ 处硬编码中文文案外提至 `string.json`，创建 `en_US` 英文资源目录
- **补全无障碍属性**：为搜索框、对话框、Radio 选项、Canvas 区域、DebateCard 提交按钮/输入框等 10+ 处缺失元素添加 accessibilityText/accessibilityDescription
- **修复最小可点击区域违规**：CourseCard 删除按钮(28vp)、ThreeAskIndicator(24-28vp)、ThreeAskStepper(32vp) 扩大至 >= 44vp
- **修复动画违规**：MindBadgeAnim animateTo 从 2000ms 缩短至 500ms，粒子效果修复（x/y 坐标计算）
- **修复知识图谱坐标映射**：统一碎片节点叠加层与 Canvas 的坐标映射逻辑，消除视觉错位
- **修复 ChatBubble 定时器泄漏**：aboutToDisappear 中清除 setTimeout
- **DebateCard 接入 ManualInputBox**：替换 TextArea 为防粘贴组件
- **页面文件拆分**：HomePage.ets(379 行) 拆出 DeleteConfirmDialog/CreateCourseDialog 为独立组件；Assessment.ets(322 行) 拆出 QuizCard 为独立组件
- **清理冗余组件**：移除未被使用的 ThreeAskIndicator 或合并到 ThreeAskStepper；清理 Index.ets 占位页
- **修复 Assessment 布鲁姆重试提示**：`$r()` 返回 Resource 类型不可直接模板字符串拼接
- **补全性能降级策略 UI**：知识图谱节点 >50/>100 的降级提示文案和列表视图
- **补全 Loading 状态管理**：所有异步操作页面增加 isLoading 状态和加载指示器
- **补全错误提示 UI**：网络断开/AI 超时/校验失败等场景的友好提示组件

## Capabilities

### New Capabilities
- `design-token-system`: 设计 token 体系（语义化颜色/字号/间距/圆角资源定义 + 暗色模式适配）
- `a11y-compliance`: 无障碍合规补全（accessibilityText/Description + 最小可点击区域 + 对比度）
- `i18n-completion`: 国际化补全（硬编码文案外提 + 英文资源目录创建）
- `ui-error-states`: UI 错误/空态/加载状态体系（Loading 指示器 + 网络断开提示 + AI 超时提示 + 空态占位）
- `knowledge-graph-rendering-fix`: 知识图谱渲染修复（坐标映射统一 + 粒子效果修复 + 性能降级 UI）

### Modified Capabilities
<!-- 无现有 spec 需要修改 -->

## Impact

- **页面文件**：全部 6 个页面（HomePage/KnowledgeGraph/LearningSpace/Assessment/AssessmentResult/Index）需修改
- **组件文件**：11 个组件中约 8 个需修改（CourseCard/ChatBubble/ManualInputBox/DebateCard/ThreeAskStepper/ThreeAskIndicator/RadarChart/MindBadgeAnim/PuzzleFragmentAnim）
- **资源文件**：`string.json` 需新增 13+ 条目；`color.json` 需新增 15+ 语义色；`float.json` 需新增 5+ 尺寸值；需创建 `en_US/string.json`
- **ViewModel 文件**：5 个 ViewModel 中硬编码中文需替换为错误码或资源引用
- **路由配置**：`main_pages.json` 需清理 Index.ets 占位页
- **无破坏性 API 变更**：所有修改均为 UI 层内部优化，不影响 Service/DB 层接口
