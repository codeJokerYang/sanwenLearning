# API Security

## ADDED Requirements

### REQ-SEC-001: API Key storage with HUKS AES-256 encryption

The API Key shall be encrypted using HUKS AES-256 before storage. The ciphertext shall be stored in preferences. No plaintext API Key shall ever be persisted.

#### Scenario: API Key encrypted before storage

WHEN the user saves an API Key through the settings page
THEN the system shall encrypt the key using HUKS AES-256-GCM
AND the resulting ciphertext shall be stored in preferences under a dedicated key
AND the plaintext API Key shall NOT be stored in preferences, files, or any persistent medium.

#### Scenario: API Key decrypted for request only

WHEN an AI service request needs the API Key
THEN the system shall decrypt the ciphertext from preferences using HUKS
AND the decrypted key shall exist ONLY within the request function's local scope
AND the decrypted key shall be discarded immediately after the request completes or fails.

---

### REQ-SEC-002: API Key UI — InputType.Password, no view saved key

The API Key input field shall use InputType.Password masking. CopyOptions shall be None. There shall be no "view saved key" feature.

#### Scenario: API Key input field masks characters

WHEN the user types into the API Key input field
THEN the characters shall be masked as dots (InputType.Password)
AND copyOption shall be set to CopyOptions.None
AND enableContextMenu shall be set to false.

#### Scenario: No feature to display saved API Key

WHEN the user navigates to the API Key settings
THEN there shall be no button, toggle, or mechanism to reveal the saved API Key in plaintext
AND the UI shall only indicate whether a key is configured (e.g., "已配置" / "未配置").

---

### REQ-SEC-003: Decrypted key only in request function scope

The decrypted API Key shall never be assigned to @State variables, global variables, or any property that persists beyond the request function scope.

#### Scenario: Decrypted key confined to function scope

WHEN the API Key is decrypted for use in an HTTP request
THEN the decrypted value shall be stored in a local const/let variable within the request function
AND the decrypted value shall NOT be assigned to any @State, @Prop, @Link, or global variable
AND the decrypted value shall NOT be passed as a parameter to any function that stores it externally.

#### Scenario: Request function completes and key is discarded

WHEN the HTTP request function completes (success or failure)
THEN the local variable holding the decrypted key shall go out of scope
AND no reference to the decrypted key shall remain in memory beyond normal garbage collection.

---

### REQ-SEC-004: API Key masking in logs

API Keys in log entries shall be masked: first 3 characters + last 4 characters visible, middle replaced with `***`. If the key length is ≤8 characters, the entire key shall be replaced with `***`.

#### Scenario: Standard-length API Key masked in logs

WHEN a log entry is written that references an API Key (e.g., ai_request_log)
THEN the key shall be masked as `{first3}***{last4}` (e.g., `sk-***4abc`)
AND the original plaintext key shall NOT appear in any log file or console output.

#### Scenario: Short API Key fully masked

WHEN the API Key length is 8 characters or fewer
THEN the key shall be masked as `***` in all log entries
AND no partial characters of the key shall be visible.

---

### REQ-SEC-005: Network circuit breaker — 10 requests/minute sliding window

The system shall implement a sliding window circuit breaker that tracks AI request timestamps. If more than 10 requests occur within any 60-second window, subsequent requests shall be blocked with a Toast notification.

#### Scenario: Requests within rate limit proceed normally

WHEN the number of AI requests in the past 60 seconds is ≤ 10
THEN the request shall proceed normally
AND no rate-limit warning shall be shown.

#### Scenario: Rate limit exceeded blocks request

WHEN the number of AI requests in the past 60 seconds exceeds 10
THEN the request shall be blocked immediately
AND a Toast notification shall inform the user: "请求过于频繁，请稍后再试"
AND the blocked request shall NOT be sent to the AI service
AND the request timestamp shall NOT be recorded in the sliding window.

---

### REQ-SEC-006: Offline interception — no AI requests when offline

When the device is offline, the system shall not allow any AI requests. An AlertDialog shall be shown to inform the user. No silent queuing of requests shall occur.

#### Scenario: Offline state blocks AI request

WHEN the user triggers an AI-dependent action while the device has no network connectivity
THEN the system shall detect the offline state before initiating the request
AND an AlertDialog shall be displayed with the message indicating no network connection
AND the AI request shall NOT be queued or sent
AND no silent retry mechanism shall be activated.

#### Scenario: Online state allows AI request

WHEN the device has network connectivity
THEN the AI request shall proceed normally without an offline warning
AND the circuit breaker and other security checks shall still apply.

---

### REQ-SEC-007: No auto-retry on network recovery

When network connectivity is restored after an offline period, the system shall NOT automatically retry previously blocked AI requests. The user must manually trigger any retry.

#### Scenario: Network restored without auto-retry

WHEN network connectivity is restored after a period of offline
THEN the system shall NOT automatically resend any previously blocked AI requests
AND the user shall manually re-trigger the desired action
AND the UI shall indicate that the network is available again.

#### Scenario: User manually retries after recovery

WHEN the user manually triggers an AI request after network recovery
THEN the request shall proceed with all standard security checks (circuit breaker, key validation, etc.)
AND no special retry logic or backoff shall be applied beyond normal request handling.
