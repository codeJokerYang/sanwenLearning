# Course Management

## ADDED Requirements

### REQ-CM-001: Course CRUD with UUID v4 primary keys and status flow

The system shall manage course entities with UUID v4 primary keys and enforce a strict linear status flow: DRAFT(0) → GENERATING(1) → Q1_ACTIVE(2) → Q2_ACTIVE(3) → Q3_ACTIVE(4) → COMPLETED(5). No step skipping is allowed.

#### Scenario: Create a new course

WHEN a learner creates a new course
THEN the system generates a UUID v4 as the course `id`
AND sets `status = 0` (DRAFT)
AND sets `created_at` and `updated_at` to current epoch milliseconds
AND persists the course to the `course` table

#### Scenario: Transition course status sequentially

WHEN a course at status DRAFT(0) completes material upload and AI generation is triggered
THEN the status transitions to GENERATING(1)

WHEN a course at status GENERATING(1) completes knowledge graph generation
THEN the status transitions to Q1_ACTIVE(2)

WHEN a course at status Q1_ACTIVE(2) completes all core node activations
THEN the status transitions to Q2_ACTIVE(3)

WHEN a course at status Q2_ACTIVE(3) completes at least one insight submission
THEN the status transitions to Q3_ACTIVE(4)

WHEN a course at status Q3_ACTIVE(4) completes all 9 quiz questions
THEN the status transitions to COMPLETED(5)

#### Scenario: Reject status skip

WHEN a status transition request attempts to skip a step (e.g., DRAFT directly to Q2_ACTIVE)
THEN the system rejects the transition
AND returns an error indicating invalid status flow

---

### REQ-CM-002: Progress mapping from course status and Q1 activation

The system shall calculate course progress as follows: step0→0%, step1→0%, step2→0~33%, step3→33%, step4→66%, step5→100%. Q1 progress uses the formula: if q1_total_core_count === 0, return 0 (avoid division by zero); else Math.round((activated / total) * 33).

#### Scenario: Progress at DRAFT and GENERATING

WHEN a course is at status DRAFT(0) or GENERATING(1)
THEN the progress percentage is 0%

#### Scenario: Progress at Q1_ACTIVE with no core nodes

WHEN a course is at status Q1_ACTIVE(2)
AND q1_total_core_count === 0
THEN the progress percentage is 0%

#### Scenario: Progress at Q1_ACTIVE with partial activation

WHEN a course is at status Q1_ACTIVE(2)
AND q1_total_core_count > 0
AND some core nodes are activated
THEN the progress percentage equals Math.round((activated_core_count / total_core_count) * 33)

#### Scenario: Progress at Q2_ACTIVE, Q3_ACTIVE, and COMPLETED

WHEN a course is at status Q2_ACTIVE(3)
THEN the progress percentage is 33%

WHEN a course is at status Q3_ACTIVE(4)
THEN the progress percentage is 66%

WHEN a course is at status COMPLETED(5)
THEN the progress percentage is 100%

---

### REQ-CM-003: Cascade delete with 8-table ordered transaction

The system shall delete a course and all related data within a single database transaction, following the strict 8-table order: ai_request_log → question_record → quiz_question → controversy → knowledge_edge → knowledge_node → material → course. Physical file deletion occurs only after the transaction commits successfully.

#### Scenario: Delete a course with all related data

WHEN a learner deletes a course
THEN the system begins a database transaction
AND deletes rows from `ai_request_log` WHERE course_id matches
AND deletes rows from `question_record` WHERE course_id matches
AND deletes rows from `quiz_question` WHERE course_id matches
AND deletes rows from `controversy` WHERE course_id matches
AND deletes rows from `knowledge_edge` WHERE course_id matches
AND deletes rows from `knowledge_node` WHERE course_id matches
AND deletes rows from `material` WHERE course_id matches
AND deletes the row from `course` WHERE id matches
AND commits the transaction
AND after successful commit, deletes all physical files associated with the course's materials

#### Scenario: Transaction failure during cascade delete

WHEN a database error occurs during the cascade delete transaction
THEN the entire transaction is rolled back
AND no data or physical files are deleted
AND an error is logged and reported to the user

---

### REQ-CM-004: Foreign key constraints without ON DELETE CASCADE

The system shall enforce `FOREIGN KEY(course_id) REFERENCES course(id)` on all related tables without ON DELETE CASCADE. The only exceptions are `question_record.quiz_question_id` and `question_record.controversy_id`, which use `ON DELETE SET NULL`.

#### Scenario: Foreign key enforcement on insert

WHEN a row is inserted into any child table (knowledge_node, knowledge_edge, etc.)
AND the referenced course_id does not exist in the course table
THEN the insert is rejected with a foreign key constraint error

#### Scenario: ON DELETE SET NULL for quiz_question_id

WHEN a quiz_question is deleted
THEN all question_record rows referencing that quiz_question_id have their quiz_question_id set to NULL
AND the question_record rows themselves are preserved

#### Scenario: ON DELETE SET NULL for controversy_id

WHEN a controversy is deleted
THEN all question_record rows referencing that controversy_id have their controversy_id set to NULL
AND the question_record rows themselves are preserved

#### Scenario: No ON DELETE CASCADE on course_id foreign keys

WHEN a course is deleted
THEN no child rows are automatically deleted by the database
AND the application must handle cascade deletion via the ordered 8-table transaction
