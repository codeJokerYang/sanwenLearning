## 1. FAB 移入 Header（消除与 AI 按钮重叠）

- [x] 1.1 在 LearningHome 的 Header Row 中，在设置按钮右侧新增圆形新建按钮：36x36vp，主色渐变背景 `#5C6BC0→#3949AB`，"+"图标 18sp 白色
- [x] 1.2 新建按钮 onClick 绑定 `this.onFabClick()`（复用现有逻辑）
- [x] 1.3 删除原绝对定位 FAB 浮层代码（`Button() { Row() { Text('+') Text('新建') } }` 整段 position 代码块）
- [ ] 1.4 验证 Header 行内 4 个元素（品牌区 + 计数圆 + 设置 + 新建）不溢出屏幕宽度

## 2. 搜索栏吸顶固定

- [x] 2.1 将 Header 区域（品牌标题行）和 SearchBar 从 Scroll 内部提取到独立的固定 Column 中，使用 `.position({ top:0, left:0 })` 固定于 Stack 顶层
- [x] 2.2 固定顶栏 Column 设置 `.width('100%')` 和合适的背景色以遮挡滚动内容（保持深色主题一致性）
- [x] 2.3 在 Scroll 内容区的最顶部添加 `Blank().height(120)` 作为安全距，确保首条内容不被固定顶栏遮挡
- [ ] 2.4 验证滚动时搜索栏始终可见、课程列表正常滚动不被遮挡

## 3. AIChatFab 位置调整

- [x] 3.1 将 AIChatFab 的 position 从 `{ x: '80%', y: '90%' }` 改为 `{ right: 16, bottom: 88 }`
- [ ] 3.2 验证 AI 按钮在 BottomTabBar 上方且不与其他元素重叠
- [ ] 3.3 验证 AIChatFab 点击展开/收起动画正常工作

## 4. 功能回归验证

- [ ] 4.1 验证 Header 新建按钮点击 → CreateCourseDialog 弹出 → 创建成功 → 列表刷新
- [ ] 4.2 验证搜索框输入关键词 → 实时过滤课程列表 → 清空恢复完整列表
- [ ] 4.3 验证课程卡片点击 → 跳转 LearningSpace 并传递 courseId
- [ ] 4.4 验证删除课程 → DeleteConfirmDialog → 确认后移除
- [ ] 4.5 验证空状态/错误状态/加载状态的显示和交互均正常
- [ ] 4.6 验证 BottomTabBar 导航功能正常（学习 tab 高亮）
- [ ] 4.7 编译通过，零错误；确认文件行数 ≤300 行
