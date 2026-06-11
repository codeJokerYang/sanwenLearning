# Three-Ask Engine — Q1 (Knowledge Graph Generation)

## ADDED Requirements

### REQ-Q1-001: AI generates knowledge graph via two-phase SSE

The system shall invoke the AI service to generate a knowledge graph from course materials using two-phase SSE. Phase 1 streams text (type="text") for character-by-character rendering. Phase 2 delivers structured JSON (type="json") containing `nodes` and `edges` arrays.

#### Scenario: Successful knowledge graph generation

WHEN the AI service receives a Q1 generation request with parsed material content
THEN the SSE connection is established
AND phase 1 streams text chunks with type="text" for real-time rendering
AND phase 2 delivers a complete JSON object with type="json" containing `nodes` and `edges` arrays
AND the connection closes with [DONE]

#### Scenario: SSE connection failure during Q1

WHEN the SSE connection fails or times out during knowledge graph generation
THEN the system logs the error to ai_request_log
AND the course status remains at GENERATING(1)
AND the user is shown an error with a retry option

---

### REQ-Q1-002: AI-generated node IDs replaced with system UUID v4

The system shall replace all AI-generated node IDs with system-generated UUID v4 values before database insertion. The mapping between old and new IDs must be maintained so that edge references are updated accordingly.

#### Scenario: Node ID replacement during insertion

WHEN the AI returns a knowledge graph with nodes containing AI-generated IDs
THEN the system generates a UUID v4 for each node
AND replaces the AI-generated ID with the system UUID v4
AND updates all edge `source_id` and `target_id` references to use the new UUIDs
AND persists the nodes and edges with the system-generated IDs

#### Scenario: Edge reference consistency after ID replacement

WHEN node IDs are replaced with system UUIDs
THEN every edge's source_id and target_id are updated to reference the corresponding new node IDs
AND no edge references a stale AI-generated ID

---

### REQ-Q1-003: Core node activation required for Q1 completion

All knowledge nodes with type=CORE must have `is_activated = true` for Q1 to be considered complete. The learner activates nodes by reviewing and confirming them.

#### Scenario: Q1 incomplete with unactivated core nodes

WHEN one or more CORE type nodes have `is_activated = false`
THEN Q1 is not complete
AND the course status remains at Q1_ACTIVE(2)
AND the UI indicates which core nodes still need activation

#### Scenario: Q1 complete when all core nodes activated

WHEN all CORE type nodes have `is_activated = true`
THEN Q1 is complete
AND the course status transitions from Q1_ACTIVE(2) to Q2_ACTIVE(3)

#### Scenario: Non-core nodes do not block Q1 completion

WHEN all CORE type nodes are activated
AND some non-core (SUPPLEMENTARY) nodes are not activated
THEN Q1 is still considered complete
AND the course status transitions to Q2_ACTIVE(3)

---

### REQ-Q1-004: Coordinate initialization with force layout randomization

Knowledge nodes shall have initial coordinate values `x_pos = -1, y_pos = -1`. When the force-directed layout initializes, any node with x_pos or y_pos equal to -1 must be randomized to a value within the 100~500 range. Nodes must never start at (0, 0).

#### Scenario: Initial node creation

WHEN a knowledge node is created from AI generation
THEN x_pos is set to -1 and y_pos is set to -1

#### Scenario: Force layout initialization randomizes -1 coordinates

WHEN the force-directed layout runs
AND a node has x_pos = -1 or y_pos = -1
THEN the node's coordinates are randomized to values within the 100~500 range
AND the node never starts at position (0, 0)

#### Scenario: Nodes with valid coordinates are not randomized

WHEN the force-directed layout runs
AND a node has x_pos and y_pos values that are not -1
THEN the node's existing coordinates are used as the starting position for the layout

---

### REQ-Q1-005: Q1 completion triggers status flow to Q2_ACTIVE

Upon Q1 completion (all core nodes activated), the system shall automatically transition the course status from Q1_ACTIVE(2) to Q2_ACTIVE(3).

#### Scenario: Automatic status transition on Q1 completion

WHEN the last remaining unactivated core node is activated
THEN the system verifies all core nodes have is_activated = true
AND updates the course status from Q1_ACTIVE(2) to Q2_ACTIVE(3)
AND updates the course updated_at timestamp
AND the UI navigates to the Q2 phase
