# Three-Ask Engine — Q2 (Controversy & Insight)

## ADDED Requirements

### REQ-Q2-001: AI generates controversies via SSE

The system shall invoke the AI service to generate controversies for activated knowledge nodes. Each controversy must contain: title, view_a, evidence_a, view_b, evidence_b, and conclusion. The generation uses the two-phase SSE protocol.

#### Scenario: Successful controversy generation

WHEN the AI service receives a Q2 generation request for activated knowledge nodes
THEN the SSE connection is established
AND phase 1 streams text chunks with type="text"
AND phase 2 delivers structured JSON with type="json" containing an array of controversies
AND each controversy includes title, view_a, evidence_a, view_b, evidence_b, and conclusion
AND the connection closes with [DONE]

#### Scenario: Controversy generation failure

WHEN the AI service fails to generate controversies
THEN the error is logged to ai_request_log
AND the user is shown an error message with a retry option
AND the course status remains at Q2_ACTIVE(3)

---

### REQ-Q2-002: Learner submits insight via ManualInputBox with paste blocking and speed detection

The learner shall submit insights using a ManualInputBox component that blocks paste operations and detects typing speed to identify potential non-manual input.

#### Scenario: Manual input submission

WHEN a learner types an insight into the ManualInputBox
AND submits the insight
THEN the insight is recorded with the learner's text, timestamp, and typing metadata

#### Scenario: Paste operation blocked

WHEN a learner attempts to paste text into the ManualInputBox
THEN the paste event is intercepted and blocked
AND the long-press context menu is disabled
AND no pasted content appears in the input field

#### Scenario: Speed detection for suspected non-manual input

WHEN a learner submits an insight
AND the typing speed exceeds 150 characters per minute
AND the text length is 10 characters or more
THEN is_suspect is set to true on the insight record

#### Scenario: Short text exemption from speed detection

WHEN a learner submits an insight
AND the text length is less than 10 characters
THEN is_suspect is set to false regardless of typing speed

---

### REQ-Q2-003: AI evaluation of insight with skip option on timeout/failure

The system shall send the learner's insight to the AI for evaluation. If the AI evaluation times out or fails, the system shall display a "skip evaluation" button allowing the learner to proceed.

#### Scenario: Successful AI evaluation of insight

WHEN the learner submits an insight
AND the AI successfully evaluates the insight
THEN the AI evaluation result is stored alongside the insight
AND the learner sees the evaluation feedback

#### Scenario: AI evaluation timeout or failure

WHEN the learner submits an insight
AND the AI evaluation times out or returns an error
THEN the system displays a "skip evaluation" button
AND the learner can choose to skip the AI evaluation

#### Scenario: Learner skips AI evaluation

WHEN the learner clicks the "skip evaluation" button
THEN the ai_evaluation field is written with "AI评价失败，用户手动跳过"
AND Q2 can still complete
AND the course can proceed to Q3

---

### REQ-Q2-004: Q2 completion requires at least one insight

Q2 is considered complete when the learner has submitted at least one insight. The AI evaluation is optional (can be skipped), but at least one insight submission is mandatory.

#### Scenario: Q2 incomplete with no insights

WHEN no insights have been submitted for the course
THEN Q2 is not complete
AND the course status remains at Q2_ACTIVE(3)

#### Scenario: Q2 complete with at least one insight

WHEN at least one insight has been submitted for the course
THEN Q2 is complete
AND the course status transitions from Q2_ACTIVE(3) to Q3_ACTIVE(4)

#### Scenario: Q2 complete even with skipped AI evaluation

WHEN at least one insight has been submitted
AND the AI evaluation was skipped for that insight
THEN Q2 is still considered complete
AND the course status transitions to Q3_ACTIVE(4)
