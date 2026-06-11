# Three-Ask Flow Control

## ADDED Requirements

### REQ-FC-001: Forced sequential order with disabled states

The system shall enforce a strict sequential order for the three-ask phases. Q2 is DISABLED when Q1 is incomplete. Q3 is DISABLED when Q2 is incomplete. No phase can be accessed out of order.

#### Scenario: Q2 disabled when Q1 incomplete

WHEN the course has not completed Q1 (not all core nodes activated)
THEN the Q2 phase is DISABLED
AND the learner cannot access Q2 content or submit insights
AND the UI visually indicates Q2 is locked

#### Scenario: Q3 disabled when Q2 incomplete

WHEN the course has not completed Q2 (no insight submitted)
THEN the Q3 phase is DISABLED
AND the learner cannot access Q3 content or answer quiz questions
AND the UI visually indicates Q3 is locked

#### Scenario: Q2 enabled after Q1 completion

WHEN Q1 is complete (all core nodes activated)
THEN Q2 becomes ENABLED
AND the learner can access Q2 content and submit insights

#### Scenario: Q3 enabled after Q2 completion

WHEN Q2 is complete (at least one insight submitted)
THEN Q3 becomes ENABLED
AND the learner can access Q3 content and answer quiz questions

---

### REQ-FC-002: Stepper component with visual state tracking

The system shall display a stepper component showing the three-ask phases. The current step is highlighted, completed steps show a checkmark, and future steps are grayed out.

#### Scenario: Stepper at Q1 phase

WHEN the course is at Q1_ACTIVE(2) status
THEN the Q1 step is highlighted as the current step
AND any previously completed steps show a checkmark
AND Q2 and Q3 steps are grayed out

#### Scenario: Stepper at Q2 phase

WHEN the course is at Q2_ACTIVE(3) status
THEN the Q2 step is highlighted as the current step
AND the Q1 step shows a checkmark (completed)
AND the Q3 step is grayed out

#### Scenario: Stepper at Q3 phase

WHEN the course is at Q3_ACTIVE(4) status
THEN the Q3 step is highlighted as the current step
AND the Q1 and Q2 steps show checkmarks (completed)

#### Scenario: Stepper at COMPLETED

WHEN the course is at COMPLETED(5) status
THEN all three steps show checkmarks
AND the evaluation report is accessible

---

### REQ-FC-003: current_step tracking with no skipping

The system shall track the current step as an integer from 0 to 5 corresponding to the course status. Step transitions must be sequential with no skipping allowed.

#### Scenario: Step mapping to course status

WHEN the course status is DRAFT(0)
THEN current_step = 0

WHEN the course status is GENERATING(1)
THEN current_step = 1

WHEN the course status is Q1_ACTIVE(2)
THEN current_step = 2

WHEN the course status is Q2_ACTIVE(3)
THEN current_step = 3

WHEN the course status is Q3_ACTIVE(4)
THEN current_step = 4

WHEN the course status is COMPLETED(5)
THEN current_step = 5

#### Scenario: Step transition is always +1

WHEN a step transition occurs
THEN the new step value is exactly the previous step value + 1
AND transitions that skip steps (e.g., 2 → 4) are rejected

---

### REQ-FC-004: Q3 completion triggers evaluation report generation

When Q3 is completed (all 9 questions answered and question_records inserted), the system shall trigger the generation of an evaluation report.

#### Scenario: Evaluation report generation on Q3 completion

WHEN the last quiz question is answered
AND all 9 question_records are inserted
THEN the course status transitions to COMPLETED(5)
AND the evaluation report generation is triggered
AND the report includes Bloom-level performance analysis, insight quality, and overall assessment

#### Scenario: Evaluation report accessible after generation

WHEN the evaluation report has been generated
THEN the learner can view the report from the course detail page
AND the report reflects the learner's actual performance across all three phases
