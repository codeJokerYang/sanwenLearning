## ADDED Requirements

### Requirement: Design token 资源定义
系统 SHALL 在 `resources/base/element/color.json` 中定义全部语义化颜色 token，在 `resources/base/element/float.json` 中定义全部字号/间距/圆角 token，在 `resources/dark/element/color.json` 中定义暗色模式颜色映射。

#### Scenario: 语义化颜色 token 完整定义
- **WHEN** 开发者查看 `color.json`
- **THEN** 包含以下语义色：`color_primary`(主色)、`color_success`(成功)、`color_warning`(警告)、`color_danger`(危险)、`color_purple`(知识紫)、`color_text_primary`(主文字)、`color_text_secondary`(次要文字)、`color_text_tertiary`(辅助文字)、`color_text_disabled`(禁用文字)、`color_bg_page`(页面背景)、`color_bg_card`(卡片背景)、`color_bg_input`(输入框背景)、`color_bg_search`(搜索框背景)、`color_bg_bubble`(气泡背景)、`color_divider`(分割线)

#### Scenario: 字号 token 定义
- **WHEN** 开发者查看 `float.json`
- **THEN** 包含以下字号 token：`font_size_title`(20fp)、`font_size_subtitle`(18fp)、`font_size_body`(14fp)、`font_size_caption`(12fp)、`font_size_micro`(11fp)

#### Scenario: 间距 token 定义
- **WHEN** 开发者查看 `float.json`
- **THEN** 包含以下间距 token：`spacing_page_horizontal`(16vp)、`spacing_card_padding`(16vp)、`spacing_card_gap`(8vp)、`spacing_section_gap`(12vp)

#### Scenario: 圆角 token 定义
- **WHEN** 开发者查看 `float.json`
- **THEN** 包含以下圆角 token：`border_radius_card`(12vp)、`border_radius_button`(8vp)、`border_radius_capsule`(22vp)

#### Scenario: 暗色模式颜色映射
- **WHEN** 系统切换到暗色模式
- **THEN** `dark/element/color.json` 中定义的语义色自动生效，页面背景变深、文字变亮、卡片背景适配暗色

### Requirement: 硬编码颜色替换为资源引用
系统 SHALL 将全部 .ets 文件中的硬编码十六进制颜色值替换为 `$r('app.color.xxx')` 资源引用。

#### Scenario: 页面文件颜色替换完成
- **WHEN** 开发者搜索 .ets 文件中的 `#` 十六进制颜色值
- **THEN** 除 Canvas 绘制代码外的所有颜色值均已替换为 `$r('app.color.xxx')` 引用

#### Scenario: Canvas 绘制颜色处理
- **WHEN** Canvas 代码需要使用颜色值
- **THEN** 通过组件 `@State` 变量接收从 `$r()` 获取的颜色值，在 Canvas 回调中读取该变量

### Requirement: 硬编码字号和间距替换为资源引用
系统 SHALL 将全部 .ets 文件中的硬编码字号和间距数值替换为 `$r('app.float.xxx')` 资源引用。

#### Scenario: 字号替换完成
- **WHEN** 开发者搜索 .ets 文件中的硬编码 `fp` 字号值
- **THEN** 所有字号值均已替换为 `$r('app.float.font_size_xxx')` 引用

#### Scenario: 间距替换完成
- **WHEN** 开发者搜索 .ets 文件中的硬编码 `vp` 间距值
- **THEN** 所有间距值均已替换为 `$r('app.float.spacing_xxx')` 引用
