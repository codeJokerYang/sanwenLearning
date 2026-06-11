# 三问高效学习机 — 国际化与无障碍规范

> 版本：v1.0 | 日期：2026-06-05 | 所有面向用户的文案与交互必须遵循本规范

---

## 1. 国际化（i18n）

### 1.1 文案外提红线

- **严禁**在 `.ets` 文件中硬编码面向用户的中文文案
- **所有**面向用户的文字必须通过资源文件引用：`$r('app.string.xxx')`

**违规示例**：

```typescript
// ❌ 硬编码中文
Text('创建课程')
Button('删除')
TextInput({ placeholder: '请输入您的问题' })
AlertDialog.show({ message: '确认删除该课程？' })
```

**合规示例**：

```typescript
// ✅ 资源文件引用
Text($r('app.string.btn_create_course'))
Button($r('app.string.btn_delete'))
TextInput({ placeholder: $r('app.string.placeholder_enter_question') })
AlertDialog.show({ message: $r('app.string.dialog_confirm_delete') })
```

### 1.2 资源文件结构

```
entry/src/main/resources/
├── base/
│   └── element/
│       └── string.json          # 默认语言（中文）
├── en_US/
│   └── element/
│       └── string.json          # 英文
└── zh_Hans/
    └── element/
        └── string.json          # 简体中文
```

### 1.3 资源键命名规范

| 分类 | 前缀 | 示例 |
|------|------|------|
| 按钮文案 | `btn_` | `btn_create_course`, `btn_delete`, `btn_retry` |
| 页面标题 | `page_title_` | `page_title_home`, `page_title_knowledge_graph` |
| 占位符 | `placeholder_` | `placeholder_enter_question`, `placeholder_enter_insight` |
| 对话框 | `dialog_` | `dialog_confirm_delete`, `dialog_network_unavailable` |
| 提示 | `toast_` | `toast_request_too_frequent`, `toast_file_too_large` |
| 标签 | `label_` | `label_q1_step`, `label_q2_step`, `label_q3_step` |
| 错误 | `error_` | `error_ai_timeout`, `error_pdf_scanned`, `error_bloom_validation` |
| 状态 | `status_` | `status_generating`, `status_parsing`, `status_completed` |

### 1.4 允许硬编码的文案范围（正面清单）

仅以下内容允许硬编码中文（或英文），其他所有面向用户的文案一律使用 `$r('app.string.xxx')`：

1. **AI Prompt 模板**（面向 LLM，不面向用户）
2. **日志输出**（`Logger.info` / `Logger.error` 等，不面向用户）
3. **数据库字段名 / SQL 语句**（内部逻辑）
4. **枚举值的内部表示**（如 `CourseStatus.DRAFT = 0`，不面向用户）
5. **开发期占位符**（如 `TODO: 待替换`，上线前必须清除）

**严禁**在除上述 5 种情况外的任何 `.ets` 文件中出现中文字面量。

---

## 2. 无障碍（Accessibility）

### 2.1 无障碍描述红线

- **关键交互组件**（按钮、输入框、知识图谱节点）**必须**设置 `accessibilityText` 或 `accessibilityDescription`
- 信息展示组件（纯文本、图标）建议设置但不强制

### 2.2 必须设置无障碍的组件

| 组件 | 无障碍属性 | 说明 |
|------|-----------|------|
| `Button` | `accessibilityText` | 描述按钮功能，如"创建新课程" |
| `TextInput` | `accessibilityDescription` | 描述输入目的，如"输入您想学习的问题" |
| 知识图谱节点 | `accessibilityText` | 描述节点内容，如"核心概念：量子纠缠，未点亮" |
| 争议卡片 Checkbox | `accessibilityText` | 如"选择争议：量子测量是否导致坍缩" |
| `ManualInputBox` | `accessibilityDescription` | 如"手动输入您的见解，禁止粘贴" |
| AI 对话气泡 | `accessibilityText` | 如"AI 正在分析知识结构" |

### 2.3 实现示例

```typescript
// 按钮
Button($r('app.string.btn_create_course'))
  .accessibilityText($r('app.string.a11y_btn_create_course'))

// 输入框
TextInput({ placeholder: $r('app.string.placeholder_enter_question') })
  .accessibilityDescription($r('app.string.a11y_input_question'))

// 知识图谱节点
Text(node.label)
  .accessibilityText(
    node.is_activated
      ? `${node.label}，已点亮`
      : `${node.label}，未点亮，点击激活`
  )

// 争议卡片 Checkbox
Checkbox()
  .accessibilityText(`${controversy.title}，${controversy.is_selected ? '已选中' : '未选中'}`)
```

### 2.4 无障碍资源键

| 分类 | 前缀 | 示例 |
|------|------|------|
| 无障碍文本 | `a11y_` | `a11y_btn_create_course`, `a11y_node_activated` |
| 无障碍描述 | `a11y_desc_` | `a11y_desc_input_question`, `a11y_desc_manual_input` |

### 2.5 对比度与字体

| 约束项 | 要求 | 说明 |
|--------|------|------|
| 文字与背景对比度 | ≥ 4.5:1 | WCAG AA 标准 |
| 最小可点击区域 | 44vp × 44vp | 符合无障碍触摸目标 |
| 字体缩放支持 | 跟随系统设置 | 使用 fp 单位，不硬编码 px |

---

## 3. 检查清单

| 检查项 | 检查方式 | 违规等级 |
|--------|---------|---------|
| 硬编码用户文案 | 全局搜索中文字面量在 .ets 中 | P1 |
| 资源键命名规范 | 检查 string.json 键名前缀 | P2 |
| 按钮缺少 accessibilityText | 代码审查 | P1 |
| 输入框缺少 accessibilityDescription | 代码审查 | P1 |
| 知识图谱节点缺少无障碍 | 代码审查 | P1 |
| 对比度不足 | 视觉检查 / 工具检测 | P2 |
| 点击区域 < 44vp | 布局检查 | P2 |
