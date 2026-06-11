# Three-Ask Engine — Q3 (Quiz Questions)

## ADDED Requirements

### REQ-Q3-001: AI generates 9 quiz questions with Bloom distribution

The system shall invoke the AI service to generate exactly 9 quiz questions following the Bloom's taxonomy distribution: REMEMBER=1, UNDERSTAND=2, APPLY=2, ANALYZE=2, EVALUATE=1, CREATE=1.

#### Scenario: Successful quiz generation with correct Bloom distribution

WHEN the AI service generates quiz questions for Q3
THEN exactly 9 questions are generated
AND the bloom_level distribution is: REMEMBER=1, UNDERSTAND=2, APPLY=2, ANALYZE=2, EVALUATE=1, CREATE=1

#### Scenario: AI returns incorrect Bloom distribution

WHEN the AI service returns questions that do not match the required Bloom distribution
THEN the local validation detects the mismatch
AND the system triggers an automatic retry (up to 2 times)

---

### REQ-Q3-002: Local validation and auto-retry of Bloom distribution

The system shall locally validate the bloom_level distribution of generated questions. If validation fails, the system automatically retries generation up to 2 times. After 2 failed retries, a manual retry button is shown.

#### Scenario: First validation failure triggers auto-retry

WHEN the AI-generated questions fail Bloom distribution validation
AND no auto-retries have been attempted yet
THEN the system automatically retries the AI generation
AND increments the retry counter to 1

#### Scenario: Second validation failure triggers second auto-retry

WHEN the AI-generated questions fail Bloom distribution validation
AND 1 auto-retry has been attempted
THEN the system automatically retries the AI generation again
AND increments the retry counter to 2

#### Scenario: Third validation failure shows manual retry button

WHEN the AI-generated questions fail Bloom distribution validation
AND 2 auto-retries have been attempted
THEN the system stops auto-retrying
AND displays a manual retry button to the learner
AND the course status remains at Q3_ACTIVE(4)

#### Scenario: Validation passes on auto-retry

WHEN the AI-generated questions pass Bloom distribution validation on a retry
THEN the questions are persisted to the quiz_question table
AND the learner can proceed to answer them

---

### REQ-Q3-003: linked_node_ids validation

The system shall validate that all node IDs in the `linked_node_ids` field reference existing knowledge nodes in the course. Invalid node IDs are removed; valid ones are preserved. An empty array after validation is still allowed.

#### Scenario: Remove invalid node IDs from linked_node_ids

WHEN a quiz question has linked_node_ids containing IDs that do not exist in the knowledge_node table for the course
THEN the invalid node IDs are removed from the array
AND only valid node IDs remain

#### Scenario: All linked_node_ids are valid

WHEN a quiz question has linked_node_ids where all IDs exist in the knowledge_node table
THEN all node IDs are preserved as-is

#### Scenario: Empty linked_node_ids after validation

WHEN all node IDs in linked_node_ids are invalid and removed
THEN the linked_node_ids becomes an empty array []
AND the quiz question is still persisted (empty array is allowed)

---

### REQ-Q3-004: options field format for objective and subjective questions

The `options` field shall be stored as a JSON array string for objective questions and as an empty string `""` for subjective questions. The options field must NEVER be null.

#### Scenario: Objective question options

WHEN a quiz question is of objective type (e.g., multiple choice)
THEN the options field is stored as a JSON array string (e.g., '["option A","option B","option C","option D"]')

#### Scenario: Subjective question options

WHEN a quiz question is of subjective type (e.g., essay)
THEN the options field is stored as an empty string ""
AND the options field is NEVER null

#### Scenario: Reading options from database

WHEN the options field is read from the database
THEN the system uses safeParseJsonArray to parse it
AND if parsing fails, the system degrades to returning an empty array []

---

### REQ-Q3-005: Q3 completion requires all 9 questions answered with question_record insertion

Q3 is considered complete only when all 9 quiz questions have been answered and a `question_record` has been inserted for each answer.

#### Scenario: Q3 incomplete with unanswered questions

WHEN one or more of the 9 quiz questions have not been answered
THEN Q3 is not complete
AND the course status remains at Q3_ACTIVE(4)

#### Scenario: Q3 complete with all questions answered

WHEN all 9 quiz questions have been answered
AND a question_record has been inserted for each answer
THEN Q3 is complete
AND the course status transitions from Q3_ACTIVE(4) to COMPLETED(5)
AND the evaluation report generation is triggered

#### Scenario: question_record insertion for each answer

WHEN a learner submits an answer to a quiz question
THEN a question_record is created with the learner's answer, timestamp, quiz_question_id, and course_id
AND is_suspect is set based on typing speed detection (same rules as Q2)
AND the question_record is persisted to the database
