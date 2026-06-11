# AI Service

## ADDED Requirements

### REQ-AI-001: Two-phase SSE protocol

The AI service shall use a two-phase SSE protocol. Phase 1 delivers type="text" chunks for character-by-character rendering. Phase 2 delivers type="json" with structured data. The stream ends with [DONE].

#### Scenario: Successful two-phase SSE stream

WHEN an AI request is initiated
THEN the SSE connection is established using @ohos.net.http
AND phase 1 delivers chunks with type="text" for real-time character rendering
AND phase 2 delivers a single chunk with type="json" containing structured data
AND the stream terminates with [DONE]

#### Scenario: Phase ordering

WHEN the SSE stream is active
THEN all type="text" chunks arrive before any type="json" chunk
AND [DONE] arrives after the type="json" chunk

---

### REQ-AI-002: Native HTTP with on('dataReceive') and on('dataEnd')

The system shall use only @ohos.net.http with on('dataReceive') and on('dataEnd') for SSE connections. Third-party HTTP libraries, WebView, WebSocket, axios, fetch, and EventSource are strictly prohibited.

#### Scenario: SSE connection using native HTTP

WHEN an SSE connection is established
THEN the system uses @ohos.net.http.HttpClient
AND registers on('dataReceive') callback for streaming data
AND registers on('dataEnd') callback for connection termination
AND no third-party HTTP library is used

#### Scenario: Rejection of third-party libraries

WHEN the codebase is analyzed
THEN no imports of axios, fetch, EventSource, or any third-party HTTP library exist in the AI service module
AND no WebView or WebSocket usage exists for AI communication

---

### REQ-AI-003: SSE parser with string buffer and \n\n delimiter

The SSE parser shall maintain a string buffer and only parse complete events upon encountering `\n\n`. JSON parse failures are discarded with Logger.error and do not interrupt the flow.

#### Scenario: Buffering partial SSE data

WHEN on('dataReceive') delivers a partial SSE event (no trailing \n\n)
THEN the data is appended to the string buffer
AND no parsing is attempted

#### Scenario: Parsing complete SSE event on \n\n

WHEN the string buffer contains data followed by \n\n
THEN the complete event is extracted from the buffer
AND the event is parsed as JSON
AND the parsed data is processed according to its type

#### Scenario: JSON parse failure handling

WHEN an SSE event is extracted but JSON.parse fails
THEN the event is discarded
AND Logger.error is called with the parse failure details
AND the SSE flow continues without interruption
AND no error is surfaced to the user

---

### REQ-AI-004: Cross-phase timeout of 15 seconds

The system shall enforce a 15-second timeout after the last text chunk. If no JSON chunk arrives within 15 seconds of the last text chunk, the connection is closed and onError is called.

#### Scenario: JSON arrives within 15 seconds

WHEN the last type="text" chunk is received
AND a type="json" chunk arrives within 15 seconds
THEN the cross-phase timeout is cleared
AND the JSON data is processed normally

#### Scenario: Cross-phase timeout triggers

WHEN the last type="text" chunk is received
AND no type="json" chunk arrives within 15 seconds
THEN the system calls onError
AND the SSE connection is closed
AND the error is logged to ai_request_log

---

### REQ-AI-005: JSON buffer limit of 5M characters

The system shall enforce a 5M character limit on the JSON buffer. If the buffer exceeds this limit, onError is called and the connection is closed.

#### Scenario: JSON buffer within limit

WHEN the JSON buffer accumulates data
AND the total character count is within 5M (5,000,000) characters
THEN the buffer continues to accumulate
AND processing continues normally

#### Scenario: JSON buffer exceeds 5M characters

WHEN the JSON buffer character count exceeds 5,000,000
THEN the system calls onError
AND the SSE connection is closed
AND the error is logged to ai_request_log

---

### REQ-AI-006: AI concurrency lock with 120000ms timeout

The system shall implement an AI concurrency lock with a 120000ms (120s) timeout. Each acquireLock call must invoke forceReleaseTimeout() at the start. On cold start, clearAllOnColdStart() must be called.

#### Scenario: Acquiring the AI lock

WHEN an AI request is initiated
THEN the system calls acquireLock
AND forceReleaseTimeout() is called at the start of acquireLock
AND if the lock is available, it is granted
AND the lock timeout is set to 120000ms

#### Scenario: Lock timeout after 120 seconds

WHEN an AI request holds the lock for more than 120000ms
THEN the lock is automatically released by the timeout mechanism
AND subsequent AI requests can acquire the lock

#### Scenario: Cold start lock cleanup

WHEN the application performs a cold start
THEN clearAllOnColdStart() is called
AND any stale locks from previous sessions are released

---

### REQ-AI-007: Prompt anti-hallucination measures

The system shall inject parsed_content as context, inject the knowledge node list, prohibit the AI from fabricating node IDs, and prohibit the AI from answering on behalf of the user.

#### Scenario: Injected context in AI prompts

WHEN an AI prompt is constructed
THEN parsed_content from the course materials is injected as context
AND the list of existing knowledge node IDs is injected
AND the prompt includes instructions prohibiting fabrication of node IDs
AND the prompt includes instructions prohibiting answering on behalf of the learner

#### Scenario: AI fabricates a node ID

WHEN the AI response contains a node ID that does not exist in the injected node list
THEN the fabricated node ID is flagged
AND the system handles the invalid reference gracefully (e.g., removes it from edges)

---

### REQ-AI-008: API Key security with HUKS encryption

The API Key shall be stored using HUKS encryption or encrypted preferences. The decrypted key must only exist within the request function scope. The key must NEVER be assigned to @State or global variables.

#### Scenario: API Key storage

WHEN the user configures an API Key
THEN the key is encrypted using HUKS before storage
AND the encrypted value is saved to preferences
AND the plaintext key is never persisted

#### Scenario: API Key decryption for request

WHEN an AI request is prepared
THEN the API Key is decrypted within the request function scope
AND the decrypted key is used to set the Authorization header
AND the decrypted key variable goes out of scope after the request function completes
AND the decrypted key is NEVER assigned to @State or any global variable

---

### REQ-AI-009: API Key masking in logs

The API Key in log entries must be masked: keep the first 3 and last 4 characters, replace the middle with `***`.

#### Scenario: API Key masking in log output

WHEN a log entry is created that includes the API Key
THEN the key is masked to show only the first 3 and last 4 characters
AND the middle portion is replaced with `***`
AND the full key is never written to any log

#### Scenario: Example masking

WHEN the API Key is "sk-abcdefghijklmnop"
THEN the masked version in logs is "sk-***mnop"

---

### REQ-AI-010: Rate limiting with 10 requests per minute sliding window

The system shall enforce a rate limit of 10 AI requests per minute using a sliding window. Requests exceeding the limit are intercepted.

#### Scenario: Request within rate limit

WHEN an AI request is initiated
AND fewer than 10 requests have been made in the last 60 seconds
THEN the request is allowed to proceed

#### Scenario: Request exceeds rate limit

WHEN an AI request is initiated
AND 10 or more requests have been made in the last 60 seconds
THEN the request is intercepted
AND the user is shown a rate limit warning
AND the request is not sent to the AI service

---

### REQ-AI-011: Offline interception with dialog

The system shall detect network connectivity status. When offline, AI requests must be blocked and a dialog must be shown to the user.

#### Scenario: AI request while offline

WHEN the device has no network connectivity
AND an AI request is attempted
THEN the request is blocked immediately
AND a dialog is shown to the user indicating no network connection
AND no HTTP request is sent

#### Scenario: AI request while online

WHEN the device has network connectivity
AND an AI request is attempted
THEN the request proceeds normally

---

### REQ-AI-012: ai_request_log for every request

Every AI request must be logged to the ai_request_log table, including duration_ms. This applies to both successful and failed requests.

#### Scenario: Log successful AI request

WHEN an AI request completes successfully
THEN an ai_request_log entry is created
AND the entry includes: course_id, request_type, prompt_hash, model, duration_ms, status, and timestamp

#### Scenario: Log failed AI request

WHEN an AI request fails (timeout, error, rate limit)
THEN an ai_request_log entry is still created
AND the entry includes the error details and duration_ms
AND the status field indicates the failure type

#### Scenario: duration_ms calculation

WHEN an AI request is logged
THEN duration_ms is calculated as the time difference between request initiation and response completion (or failure)
AND the value is stored as an INTEGER in milliseconds
