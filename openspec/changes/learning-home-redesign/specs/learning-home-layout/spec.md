## ADDED Requirements

### Requirement: FAB 与 AI 按钮完全分离

学习页 MUST 确保新建课程操作入口与 AI 对话入口在视觉上和操作上完全独立，不存在任何重叠或遮挡。

#### Scenario: 新建课程按钮位于 Header 内嵌位置
- **WHEN** 用户查看学习页顶部 Header 区域
- **THEN** 页面 MUST 在 Header 右侧显示一个圆形新建按钮（"+"图标，主色渐变背景，36x36vp）
- **THEN** 该按钮 MUST NOT 与页面内任何其他浮动按钮重叠

#### Scenario: AI 对话按钮位于右下角独立位置
- **WHEN** 用户查看学习页右下角区域
- **THEN** AI ChatFab MUST 定位在 BottomTabBar 上方（bottom ≥ 80vp）
- **THEN** AI ChatFab MUST NOT 与新建课程按钮或其他 UI 元素重叠

#### Scenario: 原有 FAB 浮层已移除
- **WHEN** 用户查看学习页右下角区域
- **THEN** 页面 MUST NOT 显示原有的绝对定位 FAB（"+ 新建"渐变按钮）
- **THEN** 新建功能 ONLY 通过 Header 内嵌按钮和空状态 CTA 按钮触发

---

### Requirement: 搜索栏吸顶固定

学习页的搜索栏 MUST 在用户滚动课程列表时始终保持可见，固定于页面顶部区域。

#### Scenario: 搜索栏初始状态位于 Header 下方
- **WHEN** 学习页首次加载且未滚动
- **THEN** 搜索栏 MUST 显示在品牌 Header 下方、课程列表上方
- **THEN** 搜索栏 MUST 具有完整的输入框样式（圆角、占位符、图标）

#### Scenario: 向下滚动时搜索栏保持固定
- **WHEN** 用户向下滚动浏览课程列表
- **THEN** 搜索栏 MUST 始终保持在屏幕可视区域内（顶部固定）
- **THEN** 搜索栏 MUST NOT 随列表内容一起向上滚出屏幕

#### Scenario: 滚动内容不被固定顶栏遮挡
- **WHEN** 用户滚动到课程列表最顶部
- **THEN** 列表第一条内容 MUST 完全可见，不被固定的 Header 或搜索栏遮挡
- **THEN** Scroll 内容区 MUST 有足够的顶部安全距（≥ Header + SearchBar 总高度）

#### Scenario: 搜索功能保持正常
- **WHEN** 用户在固定搜索栏中输入关键词
- **THEN** 搜索过滤行为 MUST 与修改前一致（实时过滤课程列表）
- **THEN** 清空搜索框后 MUST 显示完整课程列表

---

### Requirement: 所有现有功能保持不变

布局重构过程中 MUST 保证所有现有业务功能和交互逻辑不受影响。

#### Scenario: 课程 CRUD 功能正常
- **WHEN** 用户通过 Header 内嵌新建按钮点击创建课程
- **THEN** MUST 弹出 CreateCourseDialog 对话框
- **THEN** 创建成功后课程 MUST 出现在列表中
- **WHEN** 用户点击课程卡片的删除按钮
- **THEN** MUST 弹出 DeleteConfirmDialog 确认对话框
- **THEN** 确认删除后课程 MUST 从列表中移除

#### Scenario: 课程卡片点击跳转正常
- **WHEN** 用户点击任意课程卡片
- **THEN** MUST 跳转到 LearningSpace 页面并传递正确的 courseId

#### Scenario: AI 对话功能正常
- **WHEN** 用户点击 AI ChatFab
- **THEN** AIChatPanel MUST 正常展开/收起
- **THEN** AI 对话交互逻辑 MUST 与修改前完全一致

#### Scenario: 底部导航栏正常
- **WHEN** 用户点击 BottomTabBar 各 tab
- **THEN** 导航跳转逻辑 MUST 与修改前一致
- **THEN** 当前 tab MUST 高亮显示为"学习"

#### Scenario: 空/错误/加载状态正常
- **WHEN** 课程列表为空时
- **THEN** MUST 显示空状态视图（含 CTA 创建按钮）
- **WHEN** 加载失败时
- **THEN** MUST 显示错误状态视图（含重试按钮）
- **WHEN** 首次加载中时
- **THEN** MUST 显示骨架屏占位
