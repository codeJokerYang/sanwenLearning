# Anti-Cheat

## ADDED Requirements

### REQ-ANTI-001: ManualInputBox paste blocking (Layer 1)

The ManualInputBox component shall block all paste operations via onPaste interception, disable copy via CopyOptions.None, and disable the context menu via enableContextMenu=false.

#### Scenario: Paste action intercepted in ManualInputBox

WHEN a user attempts to paste text into the ManualInputBox via keyboard shortcut or long-press menu
THEN the onPaste handler shall intercept and discard the pasted content
AND the input field shall remain unchanged
AND no visual feedback of paste shall occur.

#### Scenario: Copy and context menu disabled in ManualInputBox

WHEN the ManualInputBox is rendered
THEN copyOption shall be set to CopyOptions.None
AND enableContextMenu shall be set to false
AND the user shall not be able to open the system context menu on the input field.

---

### REQ-ANTI-002: Input speed detection with startTime on first onChange (Layer 2)

The system shall record the start time on the first onChange event (not onFocus) of the ManualInputBox and calculate input speed at submit time.

#### Scenario: Start time recorded on first keystroke

WHEN the user types the first character into the ManualInputBox
THEN the system shall record startTime as the current timestamp in milliseconds
AND startTime shall NOT be recorded on onFocus or onEditChange events
AND startTime shall be reset when the input is cleared or submitted.

#### Scenario: Speed calculated at submit time

WHEN the user submits the answer from ManualInputBox
THEN the system shall calculate input speed as (character count / elapsed minutes) where elapsed minutes = (submitTime - startTime) / 60000
AND the speed value shall be stored in the question_record.

---

### REQ-ANTI-003: Speed threshold >150 chars/minute marks suspect

If the calculated input speed exceeds 150 characters per minute, the question_record shall be marked with `is_suspect=true`.

#### Scenario: Normal typing speed below threshold

WHEN the user submits an answer with input speed ≤ 150 chars/minute
THEN is_suspect shall be set to false in the question_record
AND no suspect flag shall appear in the UI.

#### Scenario: Excessive typing speed above threshold

WHEN the user submits an answer with input speed > 150 chars/minute
THEN is_suspect shall be set to true in the question_record
AND the suspect flag shall be persisted to the database
AND the evaluation report shall reflect the suspect status.

---

### REQ-ANTI-004: Short text exemption <10 chars

If the submitted text is fewer than 10 characters, `is_suspect` shall be set to false regardless of calculated speed, and no speed calculation shall be performed.

#### Scenario: Short answer exempt from speed check

WHEN the user submits an answer with fewer than 10 characters
THEN is_suspect shall be set to false
AND no input speed calculation shall be performed
AND startTime shall still be recorded but not used for speed evaluation.

#### Scenario: Exactly 10 characters triggers speed check

WHEN the user submits an answer with exactly 10 characters
THEN the speed calculation shall be performed
AND the 150 chars/minute threshold shall be applied normally.

---

### REQ-ANTI-005: Prompt constraint prohibiting AI substitution (Layer 3)

All AI prompts for Q2 and Q3 evaluation shall include the constraint "禁止替代用户作答，必须基于用户真实输入评价". The AI shall only evaluate and comment on the learner's actual input, never generate answers on behalf of the learner.

#### Scenario: AI prompt includes anti-substitution constraint

WHEN an AI request is constructed for Q2 insight evaluation or Q3 answer evaluation
THEN the system prompt shall include the exact phrase "禁止替代用户作答，必须基于用户真实输入评价"
AND the AI response shall not contain a complete alternative answer to the question
AND if the AI response contains a full alternative answer, the system shall log a warning.

#### Scenario: AI response attempts to provide answer

WHEN the AI response contains what appears to be a complete answer substitution
THEN the system shall strip or redact the substituted answer portion
AND a warning shall be logged with tag AI_SERVICE
AND the remaining evaluation content shall still be displayed.

---

### REQ-ANTI-006: Evaluation report annotation with integrity declaration and suspect warning (Layer 4)

The evaluation report shall include an integrity declaration and, if suspect records exist, append a warning annotation as the final anti-cheat layer.

#### Scenario: Report includes integrity declaration without suspect warning

WHEN the evaluation report is generated and no question_record has is_suspect=true
THEN the report shall include "本答案由学员手动输入" in the Summary chapter
AND no suspect warning shall appear.

#### Scenario: Report includes integrity declaration with suspect warning

WHEN the evaluation report is generated and at least one question_record has is_suspect=true
THEN the report shall include "本答案由学员手动输入"
AND a warning shall be appended: "⚠ 检测到部分作答存在异常输入速度，结果仅供参考"
AND the suspect question IDs and their speed values shall be listed in the report appendix.
