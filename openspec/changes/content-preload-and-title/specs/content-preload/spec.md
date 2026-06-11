## ADDED Requirements

### Requirement: 进入学习页面时自动加载已有素材

当用户进入 LearningSpace 并打开 AIChatPanel 时，ChatViewModel SHALL 自动查询 material 表中属于当前课程的已缓存素材，并将其转换为 ChatDisplayMessage 格式渲染到消息列表中。

#### Scenario: 课程已有缓存素材时自动展示
- **WHEN** 用户进入某课程的学习界面
- **AND** 该课程在 material 表中有 3 条已缓存的素材（1 条 knowledge + 1 条 mindmap + 1 条 studydoc）
- **THEN** AIChatPanel 打开后立即显示这 3 条素材的内容预览卡片
- **AND** 无需用户手动点击任何按钮

#### Scenario: 课程无缓存素材时显示引导状态
- **WHEN** 用户进入某课程的学习界面
- **AND** 该课程在 material 表中没有缓存素材
- **THEN** AIChatPanel 显示欢迎语和快捷模式选择（保持现有行为）
- **AND** 不显示错误提示

### Requirement: ChatViewModel 提供 preloadContent() 方法

ChatViewModel SHALL 新增 `preloadContent(courseId: string): Promise<void>` 方法，该方法：
1. 查询 `material WHERE course_id = ? ORDER BY created_at DESC`
2. 将每条记录的 `parsed_content` JSON 解析为结构化数据
3. 创建对应的 ChatDisplayMessage（role='assistant', contentType 匹配 type 字段）
4. 追加到 this.messages 列表

#### Scenario: preloadContent 正确解析多种类型素材
- **WHEN** material 表中有 type='mindmap' 的记录，parsed_content 为合法 JSON
- **THEN** 生成 contentType='mindmap' 的 ChatDisplayMessage
- **AND** contentData 包含解析后的思维导图节点数据

#### Scenario: preloadContent 解析失败时降级
- **WHEN** 某条 material 记录的 parsed_content 为 null 或非法 JSON
- **THEN** 跳过该条记录，不中断整体加载流程
- **AND** Logger 记录警告日志
