# 三问高效学习机（sanwenLearning）

基于 HarmonyOS NEXT 的智能学习应用，以「三问认知引擎」为核心：通过「描述性 → 分析性 → 创造性」的递进提问，引导学习者从低阶思维走向高阶思维，实现从问题触发到深度测评的个性化认知闭环学习。

## 核心功能

- **柔性课程生成**：提问触发课程创建，AI 异步补充内容，课程状态流转（已创建 → 活跃态 → 完成态）
- **三问引擎 Q1**：知识图谱生成与节点激活，核心节点全部点亮即完成第一问
- **三问引擎 Q2**：争议分析左右分栏，呈现「争议-证据-结论」逻辑链，支持真人见解输入
- **三问引擎 Q3**：布鲁姆分类学九题测评（记忆/理解/应用/分析/评价/创造），即时解析与错题溯源
- **AI 交互**：上下文注入防幻觉、SSE 流式输出、并发锁保护
- **文件池**：系统 Picker 导入 PDF/Markdown 学习资料，沙箱存储
- **评价报告**：五章节学习报告，Canvas 三维度雷达图（概念理解/批判思维/实践迁移）

## 技术栈

| 项 | 说明 |
|------|------|
| 平台 | HarmonyOS NEXT（Stage 模型） |
| 语言 / UI | ArkTS 声明式 UI |
| 本地存储 | RdbStore（8 张业务表，见 `entry/src/main/ets/db/init.sql`） |
| AI 服务 | DeepSeek / OpenAI 兼容 API（SSE 流式） |
| 构建 | hvigor |
| 测试 | @ohos/hypium + @ohos/hamock |

## 目录结构

```
entry/src/main/ets/
├── pages/        页面（HomePage、LearningSpace、KnowledgeGraph、Assessment 等）
├── components/   UI 组件（ThreeAskStepper、DebateCard、RadarChart 等）
├── viewmodels/   视图模型（Course/ThreeAsk/Evaluation/Home/Chat）
├── services/     业务服务（AIService、CourseService、FilePoolService 等）
├── models/       数据模型与接口定义
├── db/           RdbHelper 与 init.sql
└── common/       公共工具（Logger、Config、ErrorCode 等）
```

## 开发与运行

1. 安装 [DevEco Studio](https://developer.huawei.com/consumer/cn/deveco-studio/)（HarmonyOS NEXT / API 12+）
2. 用 DevEco Studio 打开本项目根目录，等待 ohpm 依赖同步完成
3. 在「设置」页面配置 AI 服务的 API Key 后即可体验完整功能（见下方「API Key 配置」）
4. 连接模拟器或真机，点击 Run 运行 `entry` 模块

## API Key 配置

应用**不内置任何 API Key**（`entry/src/main/ets/common/Config.ets` 中 `DEFAULT_API_KEY` 恒为空字符串），AI 功能（知识图谱、争议分析、测评、对话）需要用户自行配置：

1. 前往 [DeepSeek 开放平台](https://platform.deepseek.com/) 注册并创建 API Key
2. 启动应用，首页检测到未配置密钥时会弹窗引导；也可随时通过「我的 → 设置」或学习页右上角设置入口进入设置页
3. 在设置页「配置 API Key」输入框中粘贴密钥并保存

密钥安全说明：

- 密钥经 **HUKS AES-256-CBC 加密**后存储于应用沙箱（`ApiKeyStore.ets`），明文仅在发起请求时短暂解密
- 日志与请求记录中的密钥自动脱敏（前 3 后 4，中间 `***`）
- **严禁**将真实密钥硬编码进 `Config.ets` 或任何源码文件并提交到版本库；`DEFAULT_API_KEY` 仅作本地调试便利保留，提交前必须清空
- 若密钥曾被提交，须立即到服务商控制台作废并更换，git 历史中的密钥应视为已泄露

## 文档

- 项目规划与编码指南：`doc/project_plan.md`
- 需求与设计：`doc/doc/spec.md`、`doc/doc/design.md`
- 开发约定：`docs/`（架构、数据契约、错误日志、性能等约定）
