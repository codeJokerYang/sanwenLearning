## 1. 阻塞性缺陷修复（P0）

- [x] 1.1 修复 HomePage 崩溃：将 `@State courseList` 初始化为 `[]`，增加 isDestroyed 防护，空值防护
- [x] 1.2 修复 ChatBubble 定时器泄漏：在 aboutToDisappear 中清除 setTimeout，记录 timerId 并 clearTimeout

## 2. 设计 Token 体系建立（P0）

- [x] 2.1 在 `resources/base/element/color.json` 中定义 26 个颜色 token（8 Primitive + 18 Semantic）
- [x] 2.2 在 `resources/base/element/float.json` 中定义字号 token（6 档）、间距 token（4 档）、圆角 token（3 档）
- [x] 2.3 在 `resources/dark/element/color.json` 中定义暗色模式颜色映射（18 个语义色暗色值）
- [x] 2.4 替换 HomePage.ets 中所有硬编码颜色为 `$r('app.color.xxx')` 引用
- [x] 2.5 替换 KnowledgeGraph.ets 中非 Canvas 硬编码颜色为资源引用
- [x] 2.6 替换 LearningSpace.ets 中所有硬编码颜色为资源引用
- [x] 2.7 替换 Assessment.ets 中所有硬编码颜色为资源引用（Canvas 内 getBloomColor 保留）
- [x] 2.8 替换 AssessmentResult.ets 中所有硬编码颜色为资源引用（getScoreColor 函数保留）
- [x] 2.9 替换全部 11 个组件中硬编码颜色为资源引用（Canvas 绘制色保留）
- [x] 2.10 替换全部页面和组件中硬编码字号为 `$r('app.float.font_size_xxx')` 引用
- [x] 2.11 替换全部页面和组件中硬编码间距为 `$r('app.float.spacing_xxx')` 引用
- [x] 2.12 替换全部页面和组件中硬编码圆角为 `$r('app.float.border_radius_xxx')` 引用

## 3. 国际化与错误码体系（P0）

- [x] 3.1 定义 ErrorCode 枚举和 errorCodeToResource() 映射工具函数（common/ErrorCode.ets），包含全部 17 个错误码 + `err_unknown` 兜底条目
- [x] 3.2 在 `resources/base/element/string.json` 中新增全部错误消息条目（18 个错误码 + 6 布鲁姆标签 + 7 无障碍 + 2 空态 + 2 降级提示）
- [x] 3.3 替换 HomePage.ets 中 3 处硬编码 errorMessage 为 errorCodeToResource()，errorMessage 类型改为 ResourceStr
- [x] 3.4 替换 KnowledgeGraph.ets 中 2 处硬编码 errorMessage 为 errorCodeToResource()
- [x] 3.5 替换 LearningSpace.ets 中 2 处硬编码 errorMessage 为 errorCodeToResource()
- [x] 3.6 替换 Assessment.ets 中 1 处硬编码 errorMessage 为 errorCodeToResource()
- [x] 3.7 替换 HomeViewModel.ets 中 `'课程标题不可为空'` 为错误码 `ErrorCode.COURSE_TITLE_EMPTY`
- [x] 3.8 替换 CourseViewModel.ets 中 `'课程不存在'` 为错误码 `ErrorCode.COURSE_NOT_FOUND`
- [x] 3.9 替换 ThreeAskViewModel.ets 中 `'题目不存在'` 为错误码 `ErrorCode.QUIZ_NOT_FOUND`
- [x] 3.10 替换 EvaluationViewModel.ets 中 2 处硬编码中文为错误码
- [x] 3.11 在 string.json 中新增 RadarChart 布鲁姆标签条目
- [x] 3.12 替换 RadarChart.ets 中 BLOOM_LABELS 硬编码中文为 resourceManager.getStringByNameSync() 动态加载
- [x] 3.13 替换 PuzzleFragmentAnim.ets 中 accessibilityText 硬编码中文为 getStringByNameSync() + %s 占位符
- [x] 3.14 修复 Assessment 布鲁姆重试提示：将 `$r()` + 模板字符串拼接改为 Row 内独立 Text 组件；修复 errorMessage.indexOf() 对 Resource 类型无效问题
- [x] 3.15 创建 `resources/en_US/element/string.json` 英文资源文件，包含全部 78 个条目英文翻译
- [x] 3.16 编写 ErrorCode 枚举与 ERROR_RESOURCE_MAP 映射完整性单元测试 + mapToCanvas 单元测试

## 4. 无障碍合规补全（P1）

- [x] 4.1 为 HomePage 搜索框 TextInput 添加 accessibilityText
- [x] 4.2 为 HomePage DeleteConfirmDialog 添加 accessibilityText
- [x] 4.3 为 HomePage CreateCourseDialog 添加 accessibilityText + TextInput accessibilityText
- [x] 4.4 为 Assessment QuizCard Radio 选项添加 accessibilityText
- [x] 4.5 为 DebateCard 提交按钮添加 accessibilityText
- [x] 4.6 为 DebateCard ManualInputBox 已内置 accessibilityDescription（无需额外修改）
- [x] 4.7 为 KnowledgeGraph Canvas 区域添加 accessibilityText，绑定 @State activatedCount/totalNodeCount 实现动态更新
- [x] 4.8 为 ManualInputBox 添加 accessibilityDescription
- [x] 4.9 扩大 CourseCard 删除按钮触摸区域至 >= 44vp x 44vp
- [x] 4.10 扩大 ThreeAskStepper 步骤圆触摸区域至 >= 44vp x 44vp
- [ ] 4.11 验证 color_text_disabled(#999999) 在白色背景上的对比度，若 < 4.5:1 则调整颜色值（需 DevEco 工具）
- [ ] 4.12 验证暗色模式下所有文字与背景对比度 >= 4.5:1（需 DevEco 工具）

## 5. 知识图谱渲染修复（P0）

- [x] 5.1 抽取 `mapToCanvas(pos, canvasWidth, canvasHeight, layoutSpace=600)` 坐标映射工具函数到 common/utils.ets
- [x] 5.2 统一 KnowledgeGraph.ets 中碎片节点叠加层使用 mapToCanvas() 函数
- [x] 5.3 统一 Canvas 绘制使用 mapToCanvas() 函数
- [x] 5.4 编写 mapToCanvas() 单元测试：边界值（0,0/600,600/负数）、不同 canvas 尺寸映射正确性
- [x] 5.5 修复 MindBadgeAnim 粒子 x/y 坐标：替换为 `cx + dist * Math.cos(angle), cy + dist * Math.sin(angle)`
- [x] 5.6 重构 MindBadgeAnim 动画：3 阶段链式（500ms FastOutSlowIn + 500ms EaseOut + 300ms EaseIn）
- [x] 5.7 实现知识图谱节点数 51~100 降级：renderMode='canvas_only'
- [x] 5.8 实现知识图谱节点数 >100 降级：renderMode='list'
- [x] 5.9 实现降级过渡：运行中切换使用 animateTo 300ms EaseInOut 淡入淡出

## 6. DebateCard 防粘贴修复（P1）

- [x] 6.1 将 DebateCard.ets 中的 TextArea 替换为 ManualInputBox 组件
- [ ] 6.2 验证 Q2 阶段见解输入粘贴被拦截（需真机验证）

## 7. UI 状态体系与网络检测（P1）

- [x] 7.1 创建 StatusLayout 通用组件（Loading/Empty/Error/Content 四种状态）
- [x] 7.2 创建 NetworkMonitor 单例：使用 @ohos.net.connection 监听 netAvailable/netLost 事件
- [x] 7.3 HomePage 接入 StatusLayout：pageStatus 驱动 loading/empty/content/error 状态切换
- [x] 7.4 KnowledgeGraph 接入 StatusLayout
- [x] 7.5 Assessment 接入 StatusLayout
- [x] 7.6 ViewModel 层 AI 请求前检查 NetworkMonitor，断网时设置 ErrorCode.NETWORK_DISCONNECTED
- [x] 7.7 AI 超时/失败处理：Service 层 120s setTimeout 截断 + ErrorCode.AI_TIMEOUT/AI_FAILED
- [x] 7.8 实现无有效资料拦截：ViewModel 抛出 ErrorCode.NO_VALID_MATERIAL
- [x] 7.9 实现并发错误优先级：网络断开弹 AlertDialog > StatusLayout Error 态 > Empty 态

## 8. 页面拆分与冗余清理（P1）

- [x] 8.1 将 DeleteConfirmDialog 拆为独立组件 components/DeleteConfirmDialog.ets
- [x] 8.2 将 CreateCourseDialog 拆为独立组件 components/CreateCourseDialog.ets
- [x] 8.3 将 QuizCard 拆为独立组件 components/QuizCard.ets
- [x] 8.4 删除 ThreeAskIndicator.ets
- [x] 8.5 从 main_pages.json 移除 Index 页面注册，删除 Index.ets
- [x] 8.6 移除 KnowledgeGraph.ets 中无效的 `.decoration()` 代码
- [x] 8.7 验证 HomePage.ets 行数 262 行 <= 300、Assessment.ets 行数 172 行 <= 300

## 9. 集成验证（P1）

### 单元测试
- [x] 9.1 errorCodeToResource() 测试：全部 ErrorCode 枚举值均有映射、未知错误码返回 err_unknown
- [x] 9.2 mapToCanvas() 测试：边界值、不同 canvas 尺寸映射正确性
- [x] 9.3 ERROR_RESOURCE_MAP 覆盖完整性测试

### DevEco Studio 工具验证（需 DevEco 环境）
- [ ] 9.4 暗色模式验证：DevEco 预览器切换 Dark Mode，目视检查对比度 >= 4.5:1
- [ ] 9.5 无障碍验证：DevEco Accessibility Checker 检查 accessibilityText 覆盖率和对比度
- [ ] 9.6 最小点击区域验证：DevEco Layout Inspector 检查可点击元素尺寸 >= 44vp
- [ ] 9.7 资源完整性验证：编译期 `$r()` key 校验 + en_US/string.json 与 base/string.json key 对比

### 人工验证（需真机/模拟器）
- [ ] 9.8 验证 HomePage 启动不崩溃，空态/有数据态/错误态均正常渲染
- [ ] 9.9 验证知识图谱碎片节点与 Canvas 连线位置一致，无视觉错位
- [ ] 9.10 验证心智塑成勋章粒子正确扩散，三阶段动画衔接流畅
- [ ] 9.11 验证知识图谱 50+/100+ 节点降级策略正确触发，降级过渡无闪烁
- [ ] 9.12 验证断网提示弹窗、AI 超时/失败 Toast 提示、并发错误优先级正确
- [ ] 9.13 验证 DebateCard 见解输入粘贴被拦截
- [ ] 9.14 验证屏幕阅读器可正确朗读搜索框/对话框/Canvas 区域的无障碍文本
- [ ] 9.15 验证全部页面文件行数 <= 300
