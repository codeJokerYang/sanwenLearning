# Evaluation Report

## ADDED Requirements

### REQ-EVAL-001: Generate 5-chapter evaluation report after Q3 completion

The system shall generate a structured 5-chapter evaluation report after the learner completes all three questions (Q1/Q2/Q3) of a course. The report chapters are: 1) Overview, 2) Concept Understanding (Q1), 3) Critical Thinking (Q2), 4) Practical Transfer (Q3), 5) Summary & Recommendations.

#### Scenario: Q3 completion triggers full evaluation report generation

WHEN all 9 Bloom quiz questions in Q3 have been answered and all question_record entries are persisted
THEN the system shall generate a 5-chapter Markdown evaluation report covering Overview, Concept Understanding, Critical Thinking, Practical Transfer, and Summary & Recommendations
AND the report shall be saved to the device storage associated with the course_id.

#### Scenario: Incomplete Q3 does not trigger report

WHEN the learner has not yet completed all 9 quiz questions in Q3
THEN the system shall NOT generate the evaluation report
AND the UI shall indicate remaining questions to complete.

---

### REQ-EVAL-002: Weighted scoring with Q1=20%, Q2=40%, Q3=40%

The evaluation report shall compute a composite score using the weighted formula: Q1_score × 20% + Q2_score × 40% + Q3_score × 40%.

#### Scenario: Composite score calculation with weighted percentages

WHEN the evaluation report is generated
THEN the composite score shall be calculated as Q1_score × 0.20 + Q2_score × 0.40 + Q3_score × 0.40
AND each phase score shall be displayed individually alongside the composite score
AND the composite score shall be rounded to one decimal place.

#### Scenario: Missing phase score defaults to zero

WHEN a phase score is unavailable (e.g., Q2 was skipped without AI evaluation)
THEN that phase score shall default to 0 for composite calculation
AND the report shall note the missing phase evaluation.

---

### REQ-EVAL-003: Canvas radar chart with 3 dimensions

The system shall render a Canvas-based radar chart with 3 dimensions: Concept Understanding (概念理解), Critical Thinking (批判性思维), and Practical Transfer (实践迁移). Each axis ranges from 0 to 100.

#### Scenario: Radar chart renders 3 dimensions from phase scores

WHEN the evaluation report is generated
THEN a Canvas radar chart shall be drawn with 3 axes: Concept Understanding (Q1 score), Critical Thinking (Q2 score), and Practical Transfer (Q3 score)
AND each axis shall be labeled and scaled from 0 to 100
AND the data polygon shall be filled with a semi-transparent color.

#### Scenario: All-zero scores produce degenerate radar

WHEN all three phase scores are 0
THEN the radar chart shall still render the 3 axes and labels
AND the data polygon shall collapse to the center point
AND the chart shall remain visually readable.

---

### REQ-EVAL-004: Save radar chart as {course_id}_radar.png

The rendered radar chart shall be saved as a PNG image file named `{course_id}_radar.png` in the application's file storage directory.

#### Scenario: Radar chart image saved after rendering

WHEN the Canvas radar chart has been rendered
THEN the chart image shall be saved as `{course_id}_radar.png` in the course's file directory
AND if a previous radar image exists for the same course, it shall be overwritten.

#### Scenario: Image save failure does not block report

WHEN the radar chart image save fails due to storage error
THEN the evaluation report shall still be generated and displayed
AND an error log shall be recorded with tag EVALUATION_REPORT
AND the report shall indicate the radar chart image is unavailable.

---

### REQ-EVAL-005: Weak node tracing from incorrect answers

For each quiz question where `is_correct=false`, the system shall trace the `linked_node_ids` to identify weak knowledge nodes and include them in the evaluation report.

#### Scenario: Incorrect answer triggers node tracing

WHEN a question_record has is_correct=false
THEN the system shall retrieve the linked_node_ids from the associated quiz_question
AND for each linked node, the system shall look up the node label and type
AND all traced weak nodes shall be listed in the evaluation report under the relevant chapter.

#### Scenario: Multiple incorrect answers trace overlapping nodes

WHEN multiple incorrect questions share the same linked_node_id
THEN that node shall appear only once in the weak node list
AND the report shall indicate the number of incorrect questions linked to that node.

---

### REQ-EVAL-006: Export Markdown format with radar chart relative path

The evaluation report shall be exported in Markdown format with the radar chart image embedded using a relative path.

#### Scenario: Markdown export includes radar chart relative path

WHEN the evaluation report is exported as Markdown
THEN the report shall include an image reference `![雷达图](./{course_id}_radar.png)` in the Overview chapter
AND all other content shall use standard Markdown formatting (headings, lists, tables)
AND the file shall be saved as `{course_id}_report.md`.

#### Scenario: Radar chart image missing from storage

WHEN the radar chart PNG file does not exist at the expected path
THEN the Markdown shall include the image reference regardless
AND a note shall be appended below the image reference indicating the chart is unavailable.

---

### REQ-EVAL-007: Integrity declaration with suspect warning

The evaluation report shall include an integrity declaration "本答案由学员手动输入". If any question_record in the course has `is_suspect=true`, a warning shall be appended.

#### Scenario: No suspect records — clean integrity declaration

WHEN the evaluation report is generated and no question_record has is_suspect=true
THEN the report shall include the declaration "本答案由学员手动输入" at the end of the Summary chapter
AND no warning shall be appended.

#### Scenario: Suspect records exist — integrity declaration with warning

WHEN the evaluation report is generated and at least one question_record has is_suspect=true
THEN the report shall include the declaration "本答案由学员手动输入"
AND a warning shall be appended: "⚠ 检测到部分作答存在异常输入速度，结果仅供参考"
AND the warning shall list the number of suspect records.
