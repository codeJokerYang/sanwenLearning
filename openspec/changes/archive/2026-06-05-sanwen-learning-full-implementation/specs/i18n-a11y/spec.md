# Internationalization & Accessibility

## ADDED Requirements

### REQ-I18N-001: No hardcoded Chinese in .ets files

No hardcoded Chinese text shall appear in .ets files, with 5 exceptions: Prompt text, log messages, SQL statements, enum internal representations, and development-period placeholders.

#### Scenario: User-facing text uses resource reference

WHEN a .ets file contains text that is displayed to the user
THEN the text shall be referenced via `$r('app.string.xxx')` format
AND the actual Chinese string shall exist in the string resource file
AND no raw Chinese characters shall appear in the .ets source code.

#### Scenario: Prompt text exception allows hardcoded Chinese

WHEN Chinese text is used in an AI prompt string (system prompt or user prompt)
THEN the Chinese text may be hardcoded in the .ets file
AND this shall be documented with a comment indicating it is a Prompt exception.

#### Scenario: Log message exception allows hardcoded Chinese

WHEN Chinese text is used in a Logger.error or Logger.info call for debugging purposes
THEN the Chinese text may be hardcoded
AND this shall be documented with a comment indicating it is a log exception.

---

### REQ-I18N-002: All user-facing text via $r('app.string.xxx')

Every piece of text visible to the user shall be loaded through the HarmonyOS resource system using `$r('app.string.xxx')`.

#### Scenario: Button label loaded from resources

WHEN a Button component displays text to the user
THEN the label shall be set via `$r('app.string.btn_xxx')`
AND the corresponding entry shall exist in base/element/string.json.

#### Scenario: Dialog message loaded from resources

WHEN an AlertDialog or Toast displays a message
THEN the message text shall be loaded via `$r('app.string.dialog_xxx')` or `$r('app.string.toast_xxx')`
AND no hardcoded string shall be passed to the dialog builder.

---

### REQ-I18N-003: Resource key prefixes

All string resource keys shall use the following prefixes: btn_, page_title_, placeholder_, dialog_, toast_, label_, error_, status_, a11y_, a11y_desc_.

#### Scenario: Resource key follows prefix convention

WHEN a new string resource is added to string.json
THEN the key shall start with one of the defined prefixes: btn_, page_title_, placeholder_, dialog_, toast_, label_, error_, status_, a11y_, a11y_desc_
AND the key name after the prefix shall be descriptive in English (e.g., btn_submit_answer).

#### Scenario: Accessibility resource uses a11y_ prefix

WHEN an accessibilityText or accessibilityDescription string is defined
THEN the resource key shall use the a11y_ or a11y_desc_ prefix respectively
AND the value shall be a descriptive phrase in the target language.

---

### REQ-I18N-004: Resource files — base, en_US, zh_Hans

The project shall maintain string resource files in three locations: base/element/string.json (default Chinese), en_US/element/string.json (English), zh_Hans/element/string.json (Simplified Chinese).

#### Scenario: Default resource file contains Chinese strings

WHEN the base/element/string.json file is examined
THEN all string values shall be in Chinese as the default language
AND every key used in the application shall have an entry in this file.

#### Scenario: English resource file provides translations

WHEN the en_US/element/string.json file is examined
THEN all keys present in base/element/string.json shall also exist in en_US
AND the values shall be English translations of the corresponding Chinese strings.

#### Scenario: Missing key in locale falls back to base

WHEN a key referenced in code does not exist in the current locale's string.json
THEN the system shall fall back to the base/element/string.json value
AND no crash or empty string shall result from the missing locale key.

---

### REQ-I18N-005: Accessibility — buttons and inputs

All interactive Button components shall have accessibilityText set. All TextInput components shall have accessibilityDescription set.

#### Scenario: Button has accessibilityText

WHEN a Button component is rendered in the UI
THEN accessibilityText shall be set to a descriptive string via `$r('app.string.a11y_xxx')`
AND screen readers shall announce the accessibility text when the button receives focus.

#### Scenario: TextInput has accessibilityDescription

WHEN a TextInput component is rendered in the UI
THEN accessibilityDescription shall be set to describe the input's purpose via `$r('app.string.a11y_desc_xxx')`
AND screen readers shall announce the description when the input receives focus.

---

### REQ-I18N-006: Knowledge graph node accessibility

Each knowledge graph node rendered on Canvas shall have accessibilityText that includes the node label and activated status (e.g., "知识节点：光合作用，已激活").

#### Scenario: Activated node accessibility text

WHEN a knowledge graph node with is_activated=true is rendered
THEN the node's accessibilityText shall be "知识节点：{label}，已激活"
AND screen readers shall convey both the label and activated status.

#### Scenario: Inactive node accessibility text

WHEN a knowledge graph node with is_activated=false is rendered
THEN the node's accessibilityText shall be "知识节点：{label}，未激活"
AND the accessibility text shall be loaded from string resources.

---

### REQ-I18N-007: Minimum touch target 44vp × 44vp

All interactive components shall have a minimum touch target area of 44vp × 44vp to ensure usability.

#### Scenario: Small icon button meets minimum touch target

WHEN an icon button is rendered with an icon size smaller than 44vp
THEN the button's hit test area (width/height or padding) shall be at least 44vp × 44vp
AND the visual icon may remain smaller while the touch area is expanded.

#### Scenario: List item meets minimum touch target

WHEN a list item or row contains a tappable area
THEN the tappable area shall be at least 44vp in height
AND adjacent tappable areas shall not overlap.

---

### REQ-I18N-008: Contrast ratio ≥ 4.5:1

Text color versus background color shall maintain a minimum contrast ratio of 4.5:1 as defined by WCAG 2.1 AA.

#### Scenario: Normal text meets contrast requirement

WHEN text is rendered on a colored background
THEN the contrast ratio between text color and background color shall be at least 4.5:1
AND this shall be verified for all theme modes (light/dark).

#### Scenario: Large text contrast requirement

WHEN text with font size ≥ 18pt (or ≥ 14pt bold) is rendered
THEN the contrast ratio between text and background shall be at least 3:1
AND all other text shall meet the 4.5:1 minimum.
