# Analytics & Logging

## ADDED Requirements

### REQ-LOG-001: analytics_event table schema

The system shall maintain an `analytics_event` table with columns: id (INTEGER AUTOINCREMENT PRIMARY KEY), event_name (TEXT NOT NULL), timestamp (INTEGER NOT NULL), session_id (TEXT NOT NULL), course_id (TEXT), payload (TEXT — JSON string), synced (INTEGER DEFAULT 0).

#### Scenario: Analytics event inserted with all fields

WHEN a business milestone event occurs (e.g., course created, Q1 completed, report generated)
THEN a row shall be inserted into analytics_event with event_name, timestamp (ms), session_id, course_id, and payload as JSON string
AND synced shall default to 0
AND id shall be auto-generated.

#### Scenario: Analytics event with null course_id

WHEN an analytics event is not associated with a specific course (e.g., app launch)
THEN course_id shall be stored as NULL
AND all other fields shall be populated normally.

---

### REQ-LOG-002: Indexes on analytics_event table

The system shall create three indexes on the analytics_event table: idx_analytics_event_name on event_name, idx_analytics_event_time on timestamp, idx_analytics_event_course on course_id.

#### Scenario: Indexes created during database initialization

WHEN the analytics_event table is created during database initialization
THEN idx_analytics_event_name shall be created on event_name
AND idx_analytics_event_time shall be created on timestamp
AND idx_analytics_event_course shall be created on course_id
AND all indexes shall be verified to exist.

#### Scenario: Query performance benefits from indexes

WHEN the system queries analytics_event by event_name, timestamp range, or course_id
THEN the query planner shall utilize the corresponding index
AND query performance shall be measurably improved over a full table scan.

---

### REQ-LOG-003: Session ID generation and reset

A session_id shall be generated as a UUID v4 on app start and reset on cold start. The same session_id shall be used for all analytics events within that session.

#### Scenario: Session ID generated on cold start

WHEN the application performs a cold start
THEN a new session_id (UUID v4) shall be generated
AND all subsequent analytics events in this session shall use this session_id
AND the previous session_id shall be discarded.

#### Scenario: Session ID persists across warm starts

WHEN the application returns from background (warm start)
THEN the existing session_id shall be retained
AND no new session_id shall be generated
AND analytics events shall continue using the same session_id.

---

### REQ-LOG-004: 90-day cleanup on cold start

On cold start, the system shall delete all analytics_event rows where timestamp is older than 90 days from the current time.

#### Scenario: Old analytics events cleaned up on cold start

WHEN the application performs a cold start
THEN all rows in analytics_event with timestamp < (currentTime - 90 × 86400000) shall be deleted
AND the deletion shall complete before any new analytics events are inserted.

#### Scenario: No old events to clean up

WHEN the application performs a cold start and no analytics_event rows are older than 90 days
THEN the cleanup query shall execute but delete zero rows
AND no error or warning shall be generated.

---

### REQ-LOG-005: Boundary rule for logging destinations

The system shall strictly follow the boundary rule: AI failure/timeout → ai_request_log + analytics (NOT error_log); UI/DB error → error_log (NOT analytics); business milestones → analytics (NOT error_log).

#### Scenario: AI failure logged to ai_request_log and analytics

WHEN an AI service request fails or times out
THEN the failure shall be recorded in ai_request_log with duration_ms and error details
AND an analytics event shall be emitted with event_name like "ai_request_failed"
AND NO entry shall be written to the error_log (local Markdown).

#### Scenario: UI or database error logged to error_log only

WHEN a UI rendering error or database operation error occurs
THEN the error shall be recorded in the local Markdown error_log with all 6 fields
AND NO analytics event shall be emitted for this error
AND no ai_request_log entry shall be created.

#### Scenario: Business milestone logged to analytics only

WHEN a business milestone occurs (e.g., course created, Q1 completed, evaluation report generated)
THEN an analytics event shall be emitted
AND NO entry shall be written to the error_log
AND no ai_request_log entry shall be created.

---

### REQ-LOG-006: Error log — local Markdown, 7-day rolling, 6 fields

Error logs shall be written to local Markdown files with 7-day rolling rotation. Each entry shall contain 6 fields: time, Tag, action, error message, stack trace, and business context.

#### Scenario: Error log entry written with all 6 fields

WHEN an error occurs that falls under the error_log boundary rule
THEN a Markdown entry shall be appended to the current day's error log file
AND the entry shall include: time (ISO 8601), Tag (from defined tag set), action (what was being done), error message, stack trace, and business context
AND the file shall be named with the current date (e.g., `error_2026-06-05.md`).

#### Scenario: 7-day rolling cleanup removes old log files

WHEN the application starts and error log files older than 7 days exist
THEN those files shall be deleted
AND only the most recent 7 days of error logs shall be retained.

---

### REQ-LOG-007: Defined tag set for error logging

All error log entries shall use one of the defined tags: AI_SERVICE, BLOOM_VALIDATOR, FORCE_LAYOUT, COURSE_DB, FILE_UPLOAD, INPUT_GUARD, FLOW_CONTROL, NETWORK, SECURITY.

#### Scenario: Error logged with valid tag

WHEN an error is written to the error log
THEN the Tag field shall be one of: AI_SERVICE, BLOOM_VALIDATOR, FORCE_LAYOUT, COURSE_DB, FILE_UPLOAD, INPUT_GUARD, FLOW_CONTROL, NETWORK, SECURITY
AND no other tag values shall be used.

#### Scenario: Database error uses COURSE_DB tag

WHEN a relational database operation fails
THEN the error log entry shall use Tag=COURSE_DB
AND the action field shall describe the specific DB operation (e.g., "INSERT knowledge_node")
AND the business context shall include the relevant course_id or node_id if available.
