# UI Components

## ADDED Requirements

### REQ-UI-001: CourseCard component

CourseCard shall be a display-only component using @Prop for course data. It shall expose onCardClick and onDeleteClick callbacks. It shall NOT import or call any Service or RdbHelper.

#### Scenario: CourseCard renders course information

WHEN a CourseCard is rendered with a course object via @Prop
THEN the card shall display the course name, creation date, and node count
AND tapping the card body shall invoke onCardClick callback
AND tapping the delete icon shall invoke onDeleteClick callback.

#### Scenario: CourseCard does not access Services

WHEN the CourseCard source code is examined
THEN there shall be no import statements for any Service or RdbHelper module
AND all data shall come from @Prop bindings
AND all actions shall be delegated via callbacks.

---

### REQ-UI-002: ProgressBar component

ProgressBar shall display a progress value from 0 to 100 with animated transition when the value changes.

#### Scenario: ProgressBar animates on value change

WHEN the @Prop progress value changes from one value to another
THEN the progress bar fill shall animate smoothly to the new width
AND the animation duration shall not exceed 500ms
AND the animation shall use EaseInOut curve.

#### Scenario: ProgressBar clamps out-of-range values

WHEN a progress value outside 0–100 is provided
THEN the value shall be clamped to the nearest bound (0 or 100)
AND the bar shall render at 0% or 100% accordingly.

---

### REQ-UI-003: ThreeAskStepper component

ThreeAskStepper shall display 3 steps (Q1/Q2/Q3). The current step shall be highlighted, completed steps shall show a checkmark, and future steps shall be DISABLED (not clickable).

#### Scenario: Current step highlighted in stepper

WHEN the learner is on step Q2
THEN Q2 shall be visually highlighted (e.g., bold, accent color)
AND Q1 shall show a checkmark indicating completion
AND Q3 shall be in a disabled state and not respond to taps.

#### Scenario: Step transition updates stepper state

WHEN the learner completes Q2 and moves to Q3
THEN Q2 shall transition from highlighted to checkmarked
AND Q3 shall transition from disabled to highlighted
AND the transition shall be animated.

---

### REQ-UI-004: ManualInputBox component

ManualInputBox shall block paste operations, disable the context menu, detect input speed, and include accessibilityDescription.

#### Scenario: Paste and context menu blocked

WHEN the ManualInputBox is rendered
THEN onPaste shall intercept and discard pasted content
AND copyOption shall be CopyOptions.None
AND enableContextMenu shall be false
AND accessibilityDescription shall be set via $r('app.string.a11y_desc_manual_input').

#### Scenario: Input speed detection active

WHEN the user types into ManualInputBox
THEN the first onChange event shall record startTime
AND upon submit, input speed shall be calculated
AND is_suspect shall be determined based on the 150 chars/minute threshold and 10-char exemption.

---

### REQ-UI-005: ChatBubble component

ChatBubble shall render text character-by-character via @State textContent with a cursor blink animation. It shall include accessibilityText.

#### Scenario: Character-by-character rendering

WHEN an AI response stream delivers text via SSE
THEN the ChatBubble shall append characters one at a time to @State textContent
AND a blinking cursor shall appear at the end of the text during streaming
AND the cursor shall stop blinking when streaming completes.

#### Scenario: ChatBubble accessibility

WHEN a ChatBubble is rendered
THEN accessibilityText shall be set to the full text content of the bubble
AND screen readers shall announce the complete message when the bubble receives focus
AND during streaming, accessibilityText shall update with the current partial text.

---

### REQ-UI-006: DebateCard component

DebateCard shall display a left-right split view (view_a / view_b) with evidence display, a Checkbox for selection, and a ManualInputBox for the learner's own input. It shall include accessibilityText.

#### Scenario: DebateCard renders two opposing views

WHEN a DebateCard is rendered with view_a and view_b data
THEN the left side shall display view_a content and the right side shall display view_b content
AND evidence for each view shall be displayed below the view text
AND a Checkbox shall allow the learner to indicate their position.

#### Scenario: DebateCard includes ManualInputBox for learner input

WHEN the DebateCard is rendered
THEN a ManualInputBox shall be provided below the split view for the learner to type their own analysis
AND the ManualInputBox shall have all anti-cheat features (paste blocking, speed detection)
AND accessibilityText shall describe the debate topic and the learner's current selection.

---

### REQ-UI-007: RadarChart component

RadarChart shall render a 6-axis radar chart on Canvas representing Bloom's 6 taxonomy levels. It shall be data-driven and shall NOT redraw per frame.

#### Scenario: RadarChart renders 6 Bloom axes

WHEN a RadarChart is rendered with score data for 6 Bloom levels (Remember, Understand, Apply, Analyze, Evaluate, Create)
THEN the Canvas shall draw 6 axes with labels
AND the data polygon shall connect the 6 score points
AND the polygon shall be filled with semi-transparent color.

#### Scenario: RadarChart redraws only on data change

WHEN the score data changes
THEN the Canvas shall redraw once with the new data
AND no requestAnimationFrame or timer shall drive redraws
AND the chart shall remain static when data is unchanged.

---

### REQ-UI-008: PuzzleFragmentAnim component

PuzzleFragmentAnim shall animate a fragment transitioning to a lit state. The animation shall use animateTo with duration ≤500ms and EaseInOut curve. A maximum of 5 animations shall play simultaneously.

#### Scenario: Fragment lights up with animation

WHEN a puzzle fragment transitions from unlit to lit state
THEN an animateTo call shall animate the visual change with duration ≤500ms and EaseInOut curve
AND the fragment shall glow or change color to indicate the lit state.

#### Scenario: Simultaneous animation limit enforced

WHEN more than 5 fragments attempt to animate simultaneously
THEN only the first 5 animations shall play
AND the remaining fragments shall skip animation and immediately show the lit state
AND no visual glitch shall occur from the skipped animations.

---

### REQ-UI-009: MindBadgeAnim component

MindBadgeAnim shall play a badge unlock animation using animateTo with duration ≤500ms. If the animation fails, it shall fall back to displaying the badge in a static state.

#### Scenario: Badge unlock animation plays successfully

WHEN a mind badge is unlocked
THEN an animateTo call shall animate the badge appearance with duration ≤500ms
AND the animation shall include scale and opacity transitions.

#### Scenario: Animation failure falls back to static badge

WHEN the badge unlock animation fails (e.g., due to system animation limit)
THEN the badge shall be displayed immediately in its final static state
AND no error shall be shown to the user
AND a performance log entry shall note the animation fallback.

---

### REQ-UI-010: AIRecommendBtn component

AIRecommendBtn shall only be visible when the composite knowledge base (all knowledge nodes in the course) is non-empty.

#### Scenario: Button visible when knowledge base has nodes

WHEN the course has at least one knowledge node
THEN the AIRecommendBtn shall be visible and tappable
AND tapping it shall trigger the AI recommendation flow.

#### Scenario: Button hidden when knowledge base is empty

WHEN the course has zero knowledge nodes
THEN the AIRecommendBtn shall be hidden (visibility: None)
AND no space shall be reserved for the button in the layout.

---

### REQ-UI-011: ThreeAskIndicator component

ThreeAskIndicator shall display a 3-segment progress indicator: completed segments show a green checkmark, the current segment shows a purple pulse animation, and future segments are gray.

#### Scenario: Q1 completed, Q2 in progress

WHEN the learner has completed Q1 and is currently on Q2
THEN segment 1 shall display a green checkmark
AND segment 2 shall display a purple pulse animation
AND segment 3 shall be gray and static.

#### Scenario: All three segments completed

WHEN the learner has completed Q1, Q2, and Q3
THEN all three segments shall display green checkmarks
AND no pulse animation shall be active
AND the indicator shall convey full completion.

---

### REQ-UI-012: All components follow state management rules

All UI components shall use @Prop for display-only data, @Link for two-way binding, and shall NOT import Service or RdbHelper modules directly.

#### Scenario: Display component uses @Prop only

WHEN a component only needs to display data and does not need to modify it
THEN the component shall use @Prop for all data bindings
AND no @Link or @State shall be used for display-only data.

#### Scenario: Two-way component uses @Link

WHEN a component needs to modify data and propagate changes back to the parent
THEN the component shall use @Link for the mutable data
AND @Prop shall be used for read-only data within the same component.

#### Scenario: No Service or RdbHelper imports in components

WHEN any UI component source file is examined
THEN there shall be no import statements for Service or RdbHelper modules
AND all data operations shall be delegated to the ViewModel layer via callbacks or @Link bindings.
