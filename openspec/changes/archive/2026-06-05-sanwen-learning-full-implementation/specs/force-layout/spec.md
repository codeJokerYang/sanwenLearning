# Force Layout

## ADDED Requirements

### REQ-LAYOUT-001: Force-directed layout with 200 iterations and convergence threshold

The force-directed layout algorithm shall run a maximum of 200 iterations. If the maximum displacement across all nodes falls below 1vp, the algorithm shall stop early (convergence).

#### Scenario: Layout converges before 200 iterations

WHEN the force-directed layout algorithm runs and the maximum node displacement in an iteration is less than 1vp
THEN the algorithm shall stop immediately
AND the current node positions shall be used as the final layout
AND no further iterations shall execute.

#### Scenario: Layout runs full 200 iterations without convergence

WHEN the force-directed layout algorithm runs all 200 iterations without the maximum displacement falling below 1vp
THEN the algorithm shall stop after the 200th iteration
AND the final node positions from iteration 200 shall be used
AND a performance log shall note that convergence was not achieved.

---

### REQ-LAYOUT-002: Node minimum distance 60vp, edge preferred length 120vp

The force-directed layout shall enforce a minimum node-to-node distance of 60vp (repulsion) and a preferred edge length of 120vp (attraction along edges).

#### Scenario: Nodes too close experience repulsion

WHEN two nodes are closer than 60vp
THEN a repulsive force shall push them apart
AND the force magnitude shall increase as distance decreases below 60vp.

#### Scenario: Connected nodes pulled toward preferred edge length

WHEN two nodes are connected by an edge and their distance differs from 120vp
THEN an attractive/repulsive spring force shall pull/push them toward 120vp
AND the force shall be proportional to the displacement from the preferred length.

---

### REQ-LAYOUT-003: Coordinate initialization for new nodes

Nodes with x_pos=-1 and y_pos=-1 shall be randomized to coordinates between 100 and 500 on both axes. Already activated nodes (is_activated=true) shall have fixed positions and not be moved by the layout algorithm.

#### Scenario: New node with default coordinates gets randomized position

WHEN a knowledge node has x_pos=-1 and y_pos=-1
THEN the system shall assign random x and y coordinates in the range [100, 500]
AND the randomization shall occur before the first force-directed iteration
AND the node shall participate normally in the layout algorithm after initialization.

#### Scenario: Activated node position is fixed during layout

WHEN a knowledge node has is_activated=true
THEN the node's position shall NOT be modified by the force-directed layout algorithm
AND the node shall still exert repulsive forces on other nodes
AND edges connected to the fixed node shall pull the non-fixed endpoints.

#### Scenario: Node with valid coordinates not randomized

WHEN a knowledge node has x_pos and y_pos values that are not -1
THEN the existing coordinates shall be used as the starting position
AND no randomization shall occur.

---

### REQ-LAYOUT-004: Batch update — compute 200 iterations first, then one-time @State update

The force-directed layout shall complete all iterations in a background computation, then update the @State array exactly once. No @State updates shall occur during iteration.

#### Scenario: All iterations complete before @State update

WHEN the force-directed layout algorithm is invoked
THEN all iterations (up to 200 or convergence) shall be computed using local variables
AND the @State nodes array shall be updated exactly once after all iterations complete
AND no intermediate @State updates shall trigger UI re-renders during computation.

#### Scenario: UI remains responsive during layout computation

WHEN the layout computation is running
THEN the UI thread shall not be blocked
AND the user shall see a loading indicator if computation takes longer than 100ms
AND the final layout shall appear as a single visual update.

---

### REQ-LAYOUT-005: Performance target — 50 nodes 200 iterations <100ms

The force-directed layout for 50 nodes and 200 iterations shall complete in under 100ms. If the target is exceeded, the system shall reduce iterations or degrade the layout mode.

#### Scenario: Layout meets performance target

WHEN the force-directed layout runs with 50 nodes for 200 iterations
THEN the computation shall complete in less than 100ms
AND the full 200-iteration result shall be used.

#### Scenario: Layout exceeds performance target — reduce iterations

WHEN the force-directed layout with 50 nodes takes longer than 100ms
THEN the system shall reduce the iteration count (e.g., to 150, then 100)
AND a performance log entry shall be recorded with tag FORCE_LAYOUT
AND the reduced iteration count shall still produce a visually acceptable layout.

---

### REQ-LAYOUT-006: Degradation tiers based on node count

The system shall apply degradation based on node count: ≤50 nodes → normal mode (Canvas + @Component overlay); 51~100 nodes → no animation mode (Canvas only, no @Component overlay); >100 nodes → text list mode (no Canvas, no graph visualization).

#### Scenario: Normal mode for 50 or fewer nodes

WHEN the knowledge graph has 50 or fewer nodes
THEN the graph shall be rendered using Canvas for edges and @Component overlay for node labels
AND node interactions (tap, drag) shall be supported with animations
AND the full visual experience shall be available.

#### Scenario: No-animation mode for 51–100 nodes

WHEN the knowledge graph has between 51 and 100 nodes
THEN the graph shall be rendered using Canvas only (no @Component overlay)
AND node labels shall be drawn directly on Canvas
AND no node interaction animations shall be applied
AND tap detection shall still function via Canvas hit testing.

#### Scenario: Text list mode for over 100 nodes

WHEN the knowledge graph has more than 100 nodes
THEN the graph visualization shall be replaced by a text list (LazyForEach)
AND no Canvas rendering shall occur
AND each list item shall show the node label and activation status
AND the list shall be searchable/filterable.

---

### REQ-LAYOUT-007: Canvas redraw only on node state change

The Canvas shall be redrawn only when a node's state changes (activation, position, selection). No per-frame or timer-based redraws shall occur.

#### Scenario: Canvas redraws on node activation

WHEN a knowledge node's is_activated status changes from false to true
THEN the Canvas shall be redrawn to reflect the new visual state
AND the redraw shall be triggered by the @State change, not by a timer.

#### Scenario: No Canvas redraw during idle

WHEN no node state changes occur
THEN the Canvas shall NOT redraw
AND no requestAnimationFrame or setInterval shall drive Canvas rendering
AND the Canvas content shall remain static until the next state change.

---

### REQ-LAYOUT-008: onDisappear releases nodes and edges arrays

When the page containing the knowledge graph disappears, the nodes[] and edges[] arrays shall be released by setting them to empty arrays.

#### Scenario: Page disappear triggers array release

WHEN the knowledge graph page's onDisappear lifecycle hook is called
THEN nodes[] shall be set to an empty array []
AND edges[] shall be set to an empty array []
AND the Canvas shall be cleared
AND no references to large arrays shall persist in memory.

#### Scenario: Page reappear reinitializes arrays

WHEN the user navigates back to the knowledge graph page
THEN the nodes and edges shall be reloaded from the database
AND the force-directed layout shall be recomputed if needed
AND the Canvas shall be redrawn with the fresh data.
