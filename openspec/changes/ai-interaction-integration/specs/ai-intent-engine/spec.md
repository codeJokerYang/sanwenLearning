# AI Intent Engine - 自然语言意图识别引擎规格说明

## ADDED Requirements

### Requirement: 意图分类与路由

系统 SHALL 对用户输入的自然语言文本进行意图分类，将输入映射至以下四种意图类型之一：`KNOWLEDGE_QA`（知识问答）、`LEARNING_ADVICE`（学习建议）、`OPERATION_ASSIST`（操作辅助）、`COURSE_NAVIGATION`（课程导航）。分类结果 SHALL 影响 AI Prompt 的上下文构建策略。

#### Scenario: 识别知识问答意图
- **WHEN** 用户输入包含"什么是""为什么""解释一下""...的意思是""怎么理解"等关键词
- **THEN** 意图分类结果为 `KNOWLEDGE_QA`
- **AND** 系统 Prompt 注入完整的已激活知识节点名称列表和课程资料摘要

#### Scenario: 识别学习建议意图
- **WHEN** 用户输入包含"怎么学""如何提高""建议""帮我想想""下一步""我的薄弱环节"等关键词
- **THEN** 意图分类结果为 `LEARNING_ADVICE`
- **AND** 系统 Prompt 注入学习进度摘要（当前阶段/已激活节点数/作答情况/布鲁姆层级得分分布）

#### Scenario: 识别操作辅助意图
- **WHEN** 用户输入包含"帮我创建""生成""删除""开启""导出""重新"等操作动词
- **THEN** 意图分类结果为 `OPERATION_ASSIST`
- **AND** 系统 Prompt 注入当前可用的操作选项列表
- **AND** AI 响应为操作建议文案（不直接执行操作），由用户确认后在主界面执行

#### Scenario: 识别课程导航意图
- **WHEN** 用户输入包含"回到""跳转""进入""去""Q1""Q2""Q3""首页""设置"等导航关键词
- **THEN** 意图分类结果为 `COURSE_NAVIGATION`
- **AND** AI 响应为导航指引文案（如"好的，你可以点击顶部步骤指示器回到'是什么'阶段"）
- **AND** 不自动执行页面跳转

#### Scenario: 无法匹配已知意图
- **WHEN** 用户输入不包含任何已知意图的关键词特征
- **THEN** 意图分类结果为 `null`（未知意图）
- **AND** 系统使用默认 Prompt 策略（注入基础课程上下文），由 AI 自行判断如何回应

---

### Requirement: 意图识别性能约束

意图识别过程 SHALL 在本地完成，不发起任何网络请求。单次意图识别耗时 SHALL 不超过 5ms。意图识别引擎 SHALL 作为纯函数实现，无副作用，便于单元测试。

#### Scenario: 大量文本输入的识别性能
- **WHEN** 用户输入接近 500 字符上限的长文本
- **THEN** 意图识别仍在 5ms 内完成
- **AND** 不阻塞 UI 主线程

#### Scenario: 特殊字符和混合输入
- **WHEN** 用户输入包含表情符号、英文混排、标点符号等特殊字符
- **THEN** 意图识别正常工作，不会因字符异常而崩溃或返回错误

---

### Requirement: 意图结果传递与记录

意图识别结果 SHALL 附加至每条用户消息记录的 `intent_type` 字段，持久化至 `ai_message` 表。AI 响应消息的 `intent_type` SHALL 继承对应用户消息的意图分类结果。

#### Scenario: 意图标签持久化
- **WHEN** 用户发送一条被识别为 `KNOWLEDGE_QA` 意图的消息并收到 AI 回复
- **THEN** 用户消息的 `ai_message.intent_type = 'KNOWLEDGE_QA'`
- **AND** AI 回复消息的 `ai_message.intent_type = 'KNOWLEDGE_QA'`
- **AND** 两条记录均写入数据库

#### Scenario: 后续数据分析用途
- **WHEN** 需要分析用户最常使用的对话意图分布
- **THEN** 可通过 SQL 查询 `SELECT intent_type, COUNT(*) FROM ai_message WHERE role='user' GROUP BY intent_type` 获取统计结果
