## ADDED Requirements

### Requirement: 学习界面顶部展示课程标题栏

LearningSpace 页面顶部 SHALL 显示 CourseTitleBar 组件，包含：
1. 当前课程名称（如"量子力学""高等数学"）
2. 三问步骤指示器（复用 ThreeAskStepper 或内联步骤条）
3. 可选的操作按钮区域（设置/统计入口）

#### Scenario: 进入课程后显示课程名称
- **WHEN** 用户从 LearningHome 点击课程卡片进入 LearningSpace
- **THEN** 页面顶部标题栏显示该课程的名称（从路由参数或数据库获取）
- **AND** 标题文字颜色与深色主题协调（#FFFFFF 或 rgba(255,255,255,0.95)）

#### Scenario: 课程名称超长时截断显示
- **WHEN** 课程名称超过 12 个中文字符
- **THEN** 标题文字截断并显示省略号（...）
- **AND** 完整名称可通过长按或其他方式查看

### Requirement: CourseTitleBar 组件独立且可复用

CourseTitleBar SHALL 作为独立 @Component 组件实现，接收以下参数：
- `courseName: string` — 课程名称
- `currentStep: number` — 当前三问阶段 (1/2/3)
- `onSettingClick?: () => void` — 设置按钮回调（可选）

组件文件行数 SHALL ≤120 行。

#### Scenario: CourseTitleBar 正确渲染各元素
- **WHEN** CourseTitleBar 接收 courseName="量子力学", currentStep=2
- **THEN** 显示"量子力学"标题 + 步骤2高亮的三问指示器
- **AND** 组件高度 ≤88vp
