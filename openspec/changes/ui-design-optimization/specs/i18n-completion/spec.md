## ADDED Requirements

### Requirement: 页面 errorMessage 硬编码中文替换
系统 SHALL 将全部页面 .ets 文件中硬编码的中文 errorMessage 替换为 `$r('app.string.xxx')` 资源引用。

#### Scenario: HomePage 错误消息外提
- **WHEN** 开发者搜索 HomePage.ets 中的硬编码中文
- **THEN** `'加载课程失败'`、`'删除课程失败'`、`'创建课程失败'` 均已替换为 `$r('app.string.xxx')` 引用，且 `string.json` 中包含对应条目

#### Scenario: KnowledgeGraph 错误消息外提
- **WHEN** 开发者搜索 KnowledgeGraph.ets 中的硬编码中文
- **THEN** `'加载知识图谱失败'`、`'点亮节点失败'` 均已替换为资源引用

#### Scenario: LearningSpace 错误消息外提
- **WHEN** 开发者搜索 LearningSpace.ets 中的硬编码中文
- **THEN** `'加载学习空间失败'`、`'提交见解失败'` 均已替换为资源引用

#### Scenario: Assessment 错误消息外提
- **WHEN** 开发者搜索 Assessment.ets 中的硬编码中文
- **THEN** `'加载测评题目失败'` 已替换为资源引用

### Requirement: ViewModel 硬编码中文替换为错误码
系统 SHALL 将全部 ViewModel .ets 文件中硬编码的中文错误消息替换为错误码字符串，页面层通过映射函数将错误码转为资源引用。

#### Scenario: HomeViewModel 错误码
- **WHEN** 开发者搜索 HomeViewModel.ets 中的硬编码中文
- **THEN** `'课程标题不可为空'` 已替换为错误码 `'ERR_COURSE_TITLE_EMPTY'`

#### Scenario: CourseViewModel 错误码
- **WHEN** 开发者搜索 CourseViewModel.ets 中的硬编码中文
- **THEN** `'课程不存在'` 已替换为错误码 `'ERR_COURSE_NOT_FOUND'`

#### Scenario: ThreeAskViewModel 错误码
- **WHEN** 开发者搜索 ThreeAskViewModel.ets 中的硬编码中文
- **THEN** `'题目不存在'` 已替换为错误码 `'ERR_QUIZ_NOT_FOUND'`

#### Scenario: EvaluationViewModel 错误码
- **WHEN** 开发者搜索 EvaluationViewModel.ets 中的硬编码中文
- **THEN** `'生成报告失败：暂无作答数据'`、`'暂无报告可导出'` 已替换为错误码

### Requirement: Canvas 绘制文字外提
系统 SHALL 将 RadarChart 和 PuzzleFragmentAnim 中 Canvas 绘制的硬编码中文替换为从资源获取的字符串。

#### Scenario: RadarChart 布鲁姆标签外提
- **WHEN** 开发者查看 RadarChart.ets 中的 BLOOM_LABELS
- **THEN** 标签文字通过 `$r('app.string.bloom_remember')` 等资源引用获取，而非硬编码中文

#### Scenario: PuzzleFragmentAnim accessibilityText 外提
- **WHEN** 开发者查看 PuzzleFragmentAnim.ets 中的 accessibilityText
- **THEN** 文案通过资源引用组合，而非硬编码中文

### Requirement: 英文资源目录创建
系统 SHALL 创建 `resources/en_US/element/string.json` 英文资源文件，包含全部 string.json 条目的英文翻译。

#### Scenario: 英文资源完整性
- **WHEN** 系统切换到英文语言
- **THEN** 所有用户可见文案均显示为英文，无缺失条目

### Requirement: Assessment 布鲁姆重试提示修复
系统 SHALL 修复 Assessment 页面中 `$r()` 返回值与模板字符串拼接导致显示 `[object Object]` 的问题。

#### Scenario: 布鲁姆重试提示正确显示
- **WHEN** 布鲁姆题目校验失败触发重试
- **THEN** 提示文字正确显示为"AI生成题目质量不足 (1/2)"，而非 `[object Object]`
