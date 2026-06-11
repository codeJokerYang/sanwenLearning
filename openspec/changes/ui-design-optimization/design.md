## Context

三问高效学习机当前已实现全部 6 个页面和 11 个组件，功能流程可运行，但界面质量与项目规范存在系统性差距。经全面审查发现：

- **视觉体系**：15+ 语义颜色、5 档字号、4 档间距全部硬编码在 .ets 文件中，未抽取为设计 token，暗色模式不可用
- **国际化**：13+ 处面向用户的中文硬编码在页面和 ViewModel 中，无英文资源目录
- **无障碍**：10+ 处关键交互元素缺失 accessibilityText/Description，4 处可点击元素小于 44vp
- **功能缺陷**：HomePage 崩溃、知识图谱坐标错位、勋章粒子失效、定时器泄漏、DebateCard 可粘贴
- **架构违规**：2 个页面超过 300 行限制、冗余组件未清理
- **状态管理**：缺少 Loading/空态/错误态的统一 UI 体系

项目约束：HarmonyOS NEXT API 12+、ArkTS 声明式 UI、Stage 模型、严禁第三方 UI 库。

## Goals / Non-Goals

**Goals:**
- 建立完整的设计 token 体系（颜色/字号/间距/圆角），支持暗色模式切换
- 消除全部 i18n 违规，创建英文资源目录
- 补全全部无障碍属性，确保可点击区域 >= 44vp
- 修复全部已知 UI 缺陷（崩溃、坐标错位、粒子失效、定时器泄漏、粘贴漏洞）
- 建立统一的 Loading/空态/错误态 UI 模式
- 所有页面文件控制在 300 行以内

**Non-Goals:**
- 不重构 Service/DB 层接口
- 不修改业务逻辑（三问流程、AI 请求策略等）
- 不新增功能页面或功能模块
- 不实现完整的暗色模式视觉设计（仅建立 token 基础 + 基础可用映射，详见 D8）
- 不修改 init.sql 或数据库表结构

## Decisions

### D1: 设计 token 分层策略 — 三层 token 架构

**决策**：采用 Primitive → Semantic → Component 三层 token 架构

- **Primitive 层**（`color.json` / `float.json`）：定义原始值如 `blue_500: #007AFF`、`spacing_md: 16`
- **Semantic 层**（`color.json` / `float.json`）：定义语义引用如 `color_primary: $blue_500`、`spacing_page_horizontal: $spacing_md`
- **Component 层**（代码内通过 Semantic 引用）：如 `Button().backgroundColor($r('app.color.color_primary'))`

**替代方案**：仅使用单层 token（直接定义 `btn_primary_bg` 等）——放弃，因为无法支持暗色模式语义切换

**理由**：HarmonyOS 资源系统支持 `dark/element/color.json` 自动切换，三层架构允许 Primitive 层不变、仅修改 Semantic 层映射即可适配暗色模式

### D2: i18n 错误消息策略 — 错误码 + 资源映射

**决策**：ViewModel 层使用错误码字符串（如 `'ERR_COURSE_LOAD_FAILED'`），页面层通过映射函数将错误码转为 `$r('app.string.xxx')` 资源引用

**替代方案**：ViewModel 直接返回 Resource 类型——放弃，因为 ViewModel 严禁导入 UI 资源

**理由**：符合架构分层规则（ViewModel 不依赖 UI 资源），同时确保用户可见文案全部走 i18n

**错误码流转完整链路**：

```
ViewModel 抛出错误码 string
  ↓ 例: throw new Error('ERR_COURSE_LOAD_FAILED')
  ↓ 或 return { error: 'ERR_COURSE_LOAD_FAILED' }
Page catch 错误码
  ↓ 调用 errorCodeToResource(errorCode)
  ↓ 返回 Resource 类型 ($r('app.string.err_course_load'))
StatusLayout 接收 Resource
  ↓ @Prop errorMessage: Resource | string
  ↓ Error 状态显示 errorMessage
```

**ErrorCode 枚举与映射函数定义**：

```typescript
// common/ErrorCode.ets
export enum ErrorCode {
  COURSE_TITLE_EMPTY = 'ERR_COURSE_TITLE_EMPTY',
  COURSE_NOT_FOUND = 'ERR_COURSE_NOT_FOUND',
  COURSE_LOAD_FAILED = 'ERR_COURSE_LOAD_FAILED',
  COURSE_DELETE_FAILED = 'ERR_COURSE_DELETE_FAILED',
  COURSE_CREATE_FAILED = 'ERR_COURSE_CREATE_FAILED',
  KNOWLEDGE_LOAD_FAILED = 'ERR_KNOWLEDGE_LOAD_FAILED',
  NODE_ACTIVATE_FAILED = 'ERR_NODE_ACTIVATE_FAILED',
  LEARNING_LOAD_FAILED = 'ERR_LEARNING_LOAD_FAILED',
  INSIGHT_SUBMIT_FAILED = 'ERR_INSIGHT_SUBMIT_FAILED',
  ASSESSMENT_LOAD_FAILED = 'ERR_ASSESSMENT_LOAD_FAILED',
  QUIZ_NOT_FOUND = 'ERR_QUIZ_NOT_FOUND',
  REPORT_NO_DATA = 'ERR_REPORT_NO_DATA',
  REPORT_NO_EXPORT = 'ERR_REPORT_NO_EXPORT',
  NETWORK_DISCONNECTED = 'ERR_NETWORK_DISCONNECTED',
  AI_TIMEOUT = 'ERR_AI_TIMEOUT',
  AI_FAILED = 'ERR_AI_FAILED',
  NO_VALID_MATERIAL = 'ERR_NO_VALID_MATERIAL',
}

// 错误码 → 资源引用映射
const ERROR_RESOURCE_MAP: Record<string, string> = {
  [ErrorCode.COURSE_TITLE_EMPTY]: 'app.string.err_course_title_empty',
  [ErrorCode.COURSE_NOT_FOUND]: 'app.string.err_course_not_found',
  // ... 全部映射
}

export function errorCodeToResource(code: string): Resource {
  const key = ERROR_RESOURCE_MAP[code]
  if (key) {
    return $r(key)
  }
  // Fallback：未知错误码返回通用错误提示
  return $r('app.string.err_unknown')
}
```

**关键约定**：
- `string.json` 中必须包含 `err_unknown` 通用兜底条目（"操作失败，请重试"）
- 新增错误码时必须同步更新 `ErrorCode` 枚举和 `ERROR_RESOURCE_MAP`，编译期类型检查覆盖枚举完整性
- `StatusLayout.errorMessage` 类型为 `Resource | string`，页面层负责将错误码转为 Resource 后传入

### D3: Loading/空态/错误态统一模式 — StatusLayout 组件

**决策**：创建通用 `StatusLayout` 组件，封装 Loading/Empty/Error/Content 四种状态视图，各页面通过 `@Prop` 控制显示

**替代方案**：每个页面各自实现——放弃，因为会导致样式不一致和代码重复

**理由**：统一状态视图确保视觉一致性，减少重复代码，符合组件化原则

**StatusLayout 类型定义**：

```typescript
// 状态枚举
export type StatusType = 'loading' | 'empty' | 'error' | 'content'

// 空态配置
export interface EmptyConfig {
  icon?: ResourceStr           // 空态图标，默认内置图标
  message: ResourceStr         // 主提示文案
  actionText?: ResourceStr     // 操作按钮文案（如"去创建"），不传则不显示按钮
  onAction?: () => void        // 操作按钮回调
}

// 错误态配置
export interface ErrorConfig {
  icon?: ResourceStr           // 错误图标，默认内置图标
  message: ResourceStr         // 错误描述（Resource 类型，由 errorCodeToResource 转换）
  retryText?: ResourceStr      // 重试按钮文案，默认"重试"
  onRetry?: () => void         // 重试回调
}

// StatusLayout 组件接口
@Component
export struct StatusLayout {
  @Prop status: StatusType = 'loading'
  @Prop emptyConfig: EmptyConfig | null = null
  @Prop errorConfig: ErrorConfig | null = null
  @BuilderParam contentSlot: () => void  // content 状态的内容插槽

  build() {
    Stack() {
      if (this.status === 'loading') {
        // 居中 LoadingProgress + 加载提示
      } else if (this.status === 'empty') {
        // 空态图标 + message + 可选操作按钮
      } else if (this.status === 'error') {
        // 错误图标 + message + 重试按钮
      } else {
        this.contentSlot()
      }
    }
    .width('100%')
    .height('100%')
  }
}
```

**页面接入示例**：

```typescript
// HomePage.ets
@State pageStatus: StatusType = 'loading'
@State emptyConfig: EmptyConfig = {
  message: $r('app.string.home_empty_message'),
  actionText: $r('app.string.home_empty_action'),
  onAction: () => { /* 聚焦搜索框 */ }
}
@State errorConfig: ErrorConfig | null = null

aboutToAppear() {
  this.pageStatus = 'loading'
  this.viewModel.loadCourses().then(() => {
    this.pageStatus = this.courseList.length > 0 ? 'content' : 'empty'
  }).catch((err: Error) => {
    this.errorConfig = {
      message: errorCodeToResource(err.message),
      onRetry: () => this.aboutToAppear()
    }
    this.pageStatus = 'error'
  })
}

build() {
  Column() {
    // 搜索框始终可见
    StatusLayout({
      status: this.pageStatus,
      emptyConfig: this.emptyConfig,
      errorConfig: this.errorConfig,
    }) {
      // content 插槽：课程列表
      List() { ... }
    }
  }
}
```

### D4: 知识图谱坐标映射统一 — 单一 scale 函数

**决策**：抽取 `mapToCanvas(pos: Position, canvasWidth: number, canvasHeight: number): Position` 工具函数，碎片节点叠加层和 Canvas 绘制统一调用此函数

**替代方案**：保持两套映射但修正参数——放弃，因为维护两套映射容易再次出现不一致

**理由**：单一来源的坐标映射消除错位风险，且便于后续力导向布局调整

**mapToCanvas 函数定义**：

```typescript
// common/utils.ets
export interface Position {
  x: number
  y: number
}

// 力导向布局的逻辑坐标空间为 0~600
const LAYOUT_SPACE = 600

export function mapToCanvas(
  pos: Position,
  canvasWidth: number,
  canvasHeight: number,
  layoutSpace: number = LAYOUT_SPACE
): Position {
  const scale = Math.min(canvasWidth / layoutSpace, canvasHeight / layoutSpace)
  const offsetX = (canvasWidth - layoutSpace * scale) / 2
  const offsetY = (canvasHeight - layoutSpace * scale) / 2
  return {
    x: pos.x * scale + offsetX,
    y: pos.y * scale + offsetY
  }
}
```

**使用约定**：
- Canvas `onReady` 回调中获取 `canvasWidth`/`canvasHeight`，存入组件私有变量
- Canvas 绘制节点/边时调用 `mapToCanvas(nodePos, w, h)` 获取屏幕坐标
- 碎片节点叠加层使用相同函数计算 `position({ x: mapped.x, y: mapped.y })`
- 严禁任何地方出现 `pos.x * 0.6 + 10` 等硬编码映射

### D5: 页面拆分策略 — Dialog 独立组件化

**决策**：将 HomePage 的 DeleteConfirmDialog 和 CreateCourseDialog 拆为独立组件文件；将 Assessment 的题目卡片拆为 QuizCard 组件

**替代方案**：使用 `@Builder` 函数内联——放弃，因为不能解决行数超标问题

**理由**：独立组件文件可复用、可测试，且符合 300 行限制

**拆分组件接口契约**：

```typescript
// components/DeleteConfirmDialog.ets
@CustomDialog
export struct DeleteConfirmDialog {
  controller: CustomDialogController
  @Prop courseName: string = ''
  onConfirm: () => void = () => {}
  onCancel: () => void = () => {}

  build() {
    Column() {
      Text($r('app.string.dialog_delete_title'))
      Text($r('app.string.dialog_delete_message', this.courseName))  // 带参数资源
      Row() {
        Button($r('app.string.btn_cancel')).onClick(() => { this.onCancel(); this.controller.close() })
        Button($r('app.string.btn_confirm_delete')).onClick(() => { this.onConfirm(); this.controller.close() })
      }
    }
    .accessibilityText($r('app.string.dialog_delete_title'))
  }
}
```

```typescript
// components/CreateCourseDialog.ets
@CustomDialog
export struct CreateCourseDialog {
  controller: CustomDialogController
  @Prop inputValue: string = ''
  onConfirm: (title: string) => void = () => {}
  onCancel: () => void = () => {}
  @State localInput: string = ''

  aboutToAppear() {
    this.localInput = this.inputValue
  }

  build() {
    Column() {
      Text($r('app.string.dialog_create_title'))
      TextInput({ text: this.localInput, placeholder: $r('app.string.placeholder_course_title') })
        .onChange((val) => { this.localInput = val })
        .accessibilityText($r('app.string.a11y_course_title_input'))
      Row() {
        Button($r('app.string.btn_cancel')).onClick(() => { this.onCancel(); this.controller.close() })
        Button($r('app.string.btn_create')).onClick(() => { this.onConfirm(this.localInput); this.controller.close() })
      }
    }
    .accessibilityText($r('app.string.dialog_create_title'))
  }
}
```

```typescript
// components/QuizCard.ets
@Component
export struct QuizCard {
  @Prop quiz: QuizQuestionModel = {} as QuizQuestionModel
  @Prop questionIndex: number = 0
  @Prop isAnswered: boolean = false
  @Prop userAnswer: string = ''
  @Prop aiEvaluation: string = ''
  onSubmit: (answer: string) => void = () => {}

  build() {
    Column() {
      // 布鲁姆层级标签 + 题号
      Text(`${this.quiz.bloomLevel} #${this.questionIndex + 1}`)
      // 题目内容
      Text(this.quiz.content)
      // ManualInputBox 或已答解析
      if (!this.isAnswered) {
        ManualInputBox({
          placeholder: $r('app.string.placeholder_answer'),
          onSubmit: (answer: string) => { this.onSubmit(answer) }
        })
      } else {
        Text(this.aiEvaluation)
      }
    }
  }
}
```

### D6: MindBadgeAnim 动画修复策略 — 分阶段动画

**决策**：将 2000ms 整体动画拆分为：500ms 勋章缩放出现 + 500ms 粒子扩散 + 自动消失（无 animateTo），总 animateTo 时长不超过 500ms

**替代方案**：直接缩短为 500ms——放弃，因为勋章动画需要足够时间让用户感知

**理由**：拆分后每个 animateTo 调用均 <= 500ms 符合性能规范，同时保留视觉完整性

**动画 Curves 规范**：

| 阶段 | 时长 | 曲线 | 说明 |
|------|------|------|------|
| 勋章缩放出现 | 500ms | `Curves.springMotion(0.6, 0.8)` | 弹簧曲线，自然弹出感 |
| 粒子扩散 | 500ms | `Curve.EaseOut` | 减速扩散，自然消散 |
| 勋章+粒子淡出 | 300ms | `Curve.EaseIn` | 加速消失 |

**链式触发逻辑**：

```typescript
// 阶段1：勋章缩放出现
animateTo({
  duration: 500,
  curve: Curves.springMotion(0.6, 0.8),
  onFinish: () => {
    // 阶段2：粒子扩散
    animateTo({
      duration: 500,
      curve: Curve.EaseOut,
      onFinish: () => {
        // 阶段3：淡出消失
        animateTo({
          duration: 300,
          curve: Curve.EaseIn,
        }, () => {
          this.badgeOpacity = 0
          this.particleOpacity = 0
        })
      }
    }, () => {
      this.particles.forEach(p => p.active = true)
    })
  }
}, () => {
  this.badgeScale = 1.0
  this.badgeOpacity = 1.0
})
```

### D7: ThreeAskIndicator 处理 — 合并到 ThreeAskStepper

**决策**：删除 ThreeAskIndicator.ets，将其中"三段式圆点进度"作为 ThreeAskStepper 的 `mode: 'dots'` 可选模式

**替代方案**：保留两个组件——放弃，因为功能重叠且 Indicator 未被使用

**理由**：减少维护负担，统一三问进度展示入口

### D8: 暗色模式策略边界澄清

**决策**：采用"基础可用"策略——`dark/element/color.json` 中填入实际可用的暗色值（非简单复制亮色值），确保切换后界面可读，但不追求暗色模式下的视觉精细调优

**具体色值映射**：

| 语义 token | 亮色值 | 暗色值 | 说明 |
|-----------|--------|--------|------|
| color_bg_page | #F5F5F5 | #1A1A1A | 深色背景 |
| color_bg_card | #FFFFFF | #2C2C2C | 深色卡片 |
| color_bg_input | #F5F5F5 | #333333 | 深色输入框 |
| color_bg_search | #F0F0F0 | #333333 | 深色搜索框 |
| color_bg_bubble | #F0F0F0 | #333333 | 深色气泡 |
| color_text_primary | #1A1A1A | #E5E5E5 | 亮色文字 |
| color_text_secondary | #333333 | #CCCCCC | 次要亮色文字 |
| color_text_tertiary | #555555 | #AAAAAA | 辅助亮色文字 |
| color_text_disabled | #999999 | #666666 | 禁用态（暗色下加深确保对比度） |
| color_divider | #E5E5E5 | #3A3A3A | 深色分割线 |
| color_primary | #007AFF | #0A84FF | 暗色主色（系统蓝） |
| color_success | #34C759 | #30D158 | 暗色成功色 |
| color_warning | #FF9500 | #FF9F0A | 暗色警告色 |
| color_danger | #FF3B30 | #FF453A | 暗色危险色 |
| color_purple | #7C4DFF | #BF5AF2 | 暗色紫色 |

**验证标准**：暗色模式下所有文字与背景对比度 >= 4.5:1（WCAG AA），功能可用，无文字不可读或元素不可见的情况。不要求暗色模式下的阴影、渐变等视觉细节完美。

### D9: 网络状态检测与 AI 超时机制

**决策**：采用双层检测策略——`@ohos.net.connection` 主动监听 + 请求失败时错误类型判断

**网络断开检测**：

```typescript
// services/NetworkMonitor.ets（已有，需增强）
import connection from '@ohos.net.connection'

export class NetworkMonitor {
  private static instance: NetworkMonitor
  private isConnected: boolean = true
  private netConnection: connection.NetConnection | null = null

  static getInstance(): NetworkMonitor { ... }

  startMonitoring() {
    this.netConnection = connection.createNetConnection()
    this.netConnection.on('netAvailable', () => { this.isConnected = true })
    this.netConnection.on('netLost', () => { this.isConnected = false })
    this.netConnection.register(() => {})
  }

  isNetworkAvailable(): boolean {
    return this.isConnected
  }
}
```

**AI 请求前拦截**：

```typescript
// ViewModel 层调用前检查
if (!NetworkMonitor.getInstance().isNetworkAvailable()) {
  // 抛出错误码，由 Page 层弹窗提示
  throw new Error(ErrorCode.NETWORK_DISCONNECTED)
}
```

**AI 超时机制**：

- 超时检测在 **Service 层**（AIService）通过 `setTimeout` 实现，120 秒后主动中断 HTTP 请求
- Service 层超时后抛出 `ErrorCode.AI_TIMEOUT` 错误码
- ViewModel 层透传错误码，不额外处理超时逻辑
- Page 层通过 `errorCodeToResource()` 转换为用户提示 + 重试按钮

### D10: 知识图谱降级过渡策略

**决策**：采用"初始判断直接渲染"策略，避免运行中 Canvas→列表的突变

**降级判断时机**：在 `aboutToAppear` 数据加载完成后，根据节点数直接决定渲染模式，不出现运行中切换

```typescript
@State renderMode: 'full' | 'canvas_only' | 'list' = 'full'

aboutToAppear() {
  this.loadKnowledgeGraph().then((nodes) => {
    if (nodes.length > 100) {
      this.renderMode = 'list'
    } else if (nodes.length > 50) {
      this.renderMode = 'canvas_only'
    } else {
      this.renderMode = 'full'
    }
    this.pageStatus = 'content'
  })
}
```

**过渡方式**：如果因极端场景（如 AI 流式追加节点导致数量变化）需切换模式，使用 `animateTo({ duration: 300, curve: Curve.EaseInOut })` 淡入淡出过渡

### D11: 无障碍动态更新机制

**决策**：Canvas 区域的 `accessibilityText` 绑定 `@State` 计算属性，节点状态变更时自动触发重新朗读

```typescript
// KnowledgeGraph.ets
@State activatedCount: number = 0
@State totalNodeCount: number = 0

// 计算属性方式（ArkTS @State 驱动）
get canvasAccessibilityText(): string {
  return `知识图谱，共${this.totalNodeCount}个节点，${this.activatedCount}个已点亮`
}

build() {
  Stack() {
    Canvas(this.context)
      .accessibilityText(this.canvasAccessibilityText)
    // ...
  }
}

// 节点点亮时更新 @State
onNodeActivated() {
  this.activatedCount += 1  // 触发 @State 更新 → accessibilityText 自动更新
}
```

**注意**：`accessibilityText` 接受 `string` 类型，无法直接使用 `$r()` + 参数拼接。对于需要 i18n 的动态文本，使用 `this.resourceManager.getStringSync()` 获取字符串后拼接，或使用格式化资源 `$r('app.string.a11y_canvas_status', this.totalNodeCount, this.activatedCount)`。

### D12: 资源引用 Fallback 与并发错误优先级

**资源引用 Fallback**：

- `errorCodeToResource()` 中对未知错误码返回 `$r('app.string.err_unknown')` 兜底
- `string.json` 中必须包含 `err_unknown` 条目
- 编译期校验：在 `ErrorCode` 枚举新增值时，TypeScript 编译器会检查 `ERROR_RESOURCE_MAP` 是否覆盖全部枚举值（通过 `Record<ErrorCode, string>` 类型约束）
- 资源 key 拼写错误：HarmonyOS 编译时会对 `$r()` 引用的 key 做校验，不存在的 key 会编译报错

**并发错误优先级**：

```
全局弹窗（网络断开/AI 超时） > StatusLayout Error 态 > StatusLayout Empty 态
```

- 网络断开弹窗为模态对话框，阻断一切交互，优先级最高
- AI 超时/失败：如果当前页面已在 StatusLayout Error 态，不再弹窗，直接在 Error 态显示重试按钮
- 如果 AI 请求失败但页面已有内容（content 态），使用 Toast 提示而非弹窗，不阻断用户浏览已有内容

## Risks / Trade-offs

- **[Risk] 设计 token 迁移可能引入视觉回归** → Mitigation：逐文件迁移，每完成一个文件截图对比验证；Primitive 值与当前硬编码值完全一致
- **[Risk] 错误码映射增加 ViewModel→Page 的间接性** → Mitigation：定义 `ErrorCode` 枚举和 `errorCodeToResource()` 工具函数，`Record<ErrorCode, string>` 类型约束确保编译期覆盖检查
- **[Risk] MindBadgeAnim 分阶段动画可能不够流畅** → Mitigation：使用 `animateTo` 的 `onFinish` 回调链式触发下一阶段，弹簧曲线 `Curves.springMotion()` 确保自然感
- **[Risk] 知识图谱坐标映射修改可能影响力导向布局** → Mitigation：映射函数仅改变坐标到屏幕的投影方式，不改变力导向算法内部的相对坐标
- **[Risk] 暗色模式基础可用映射可能不够美观** → Mitigation：当前优先保证可读性（对比度 >= 4.5:1），后续可精细调优
- **[Risk] 资源 key 拼写错误或英文资源漏配** → Mitigation：HarmonyOS 编译期校验 `$r()` key 存在性；`Record<ErrorCode, string>` 类型约束确保映射完整性
- **[Trade-off] 暗色模式仅"基础可用"不追求视觉精细** → 后续可基于 Semantic 层快速调优，当前优先保证亮色模式质量
- **[Trade-off] 知识图谱降级采用初始判断不运行中切换** → 牺牲了"节点动态增加时自动降级"的灵活性，换取避免运行中 Canvas→列表突变的体验问题

## Testing Strategy

### 单元测试覆盖（ArkTS Jest）

| 测试对象 | 测试内容 | 工具 |
|---------|---------|------|
| `errorCodeToResource()` | 全部 ErrorCode 枚举值均有映射、未知错误码返回 err_unknown | Jest |
| `mapToCanvas()` | 边界值（0,0/600,600/负数）、不同 canvas 尺寸的映射正确性 | Jest |
| `ErrorCode` 枚举 | `ERROR_RESOURCE_MAP` 的 key 集合 === `ErrorCode` 枚举值集合 | Jest |

### DevEco Studio 工具验证

| 验证项 | 工具/方法 |
|--------|----------|
| 暗色模式 | DevEco 预览器切换 Dark Mode，目视检查对比度 |
| 无障碍 | DevEco Accessibility Checker 检查 accessibilityText 覆盖率和对比度 |
| 最小点击区域 | DevEco Layout Inspector 检查可点击元素尺寸 |
| 资源完整性 | 编译期 `$r()` key 校验 + `en_US/string.json` 与 `base/string.json` key 对比脚本 |

### 人工验证

| 验证项 | 方法 |
|--------|------|
| 知识图谱碎片与 Canvas 对齐 | 运行应用，点亮节点观察碎片飞向位置与连线端点是否重合 |
| 勋章动画流畅度 | 触发心智塑成勋章，观察三阶段动画衔接是否自然 |
| 降级策略 | 构造 50+/100+ 节点数据，验证降级提示和渲染模式 |
| 断网提示 | 飞行模式下触发 AI 请求，验证弹窗 |
| 屏幕阅读器 | 开启 TalkBack，验证搜索框/对话框/Canvas 区域朗读 |
