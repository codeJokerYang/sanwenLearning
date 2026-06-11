# File Pool

## ADDED Requirements

### REQ-FP-001: File selection via DocumentViewPicker with format restriction

The system shall allow file selection using DocumentViewPicker, restricted to PDF (.pdf) and Markdown (.md, .markdown) formats only.

#### Scenario: Select a supported file

WHEN a learner opens the file picker
THEN only PDF (.pdf) and Markdown (.md, .markdown) files are selectable
AND other file types are filtered out or disabled in the picker

#### Scenario: Reject unsupported file format

WHEN a learner attempts to select a file with an unsupported format (e.g., .docx, .txt)
THEN the file is rejected
AND the user is informed that only PDF and Markdown formats are supported

---

### REQ-FP-002: File size limit of 50MB

The system shall reject any file that exceeds 50MB in size.

#### Scenario: Upload file within size limit

WHEN a learner selects a file that is 50MB or smaller
THEN the file is accepted for upload
AND the upload process proceeds

#### Scenario: Reject file exceeding 50MB

WHEN a learner selects a file larger than 50MB
THEN the file is rejected
AND the user is shown an error message indicating the file exceeds the 50MB limit
AND no upload is initiated

---

### REQ-FP-003: Copy to sandbox with timestamp suffix for duplicate names

The system shall copy selected files to the application sandbox. If a file with the same name already exists in the sandbox, a timestamp suffix is appended to the new file name.

#### Scenario: Copy file with unique name

WHEN a file is selected and its name does not exist in the sandbox
THEN the file is copied to the sandbox with its original name

#### Scenario: Copy file with duplicate name

WHEN a file is selected and a file with the same name already exists in the sandbox
THEN the new file is copied with a timestamp suffix appended to the name
AND both the original and the new file coexist in the sandbox

---

### REQ-FP-004: PDF handling with no text parsing

PDF files in the current version shall NOT have their text extracted. The parsed_content is set to null and status is set to FAILED. The UI must warn the learner to upload Markdown instead.

#### Scenario: Upload a PDF file

WHEN a learner uploads a PDF file
THEN the file is copied to the sandbox
AND parsed_content is set to null
AND status is set to FAILED
AND the UI displays a warning: "当前版本不支持PDF文本提取，请上传Markdown文件"

#### Scenario: PDF file stored in database

WHEN a PDF file record is created in the material table
AND the file_name field contains the original file name
AND the file_path field contains the sandbox path
AND the parsed_content field is null
AND the status field is FAILED

---

### REQ-FP-005: Markdown parsing to plain text

Markdown files shall be parsed to extract plain text content for AI processing.

#### Scenario: Upload a Markdown file

WHEN a learner uploads a Markdown file
THEN the file is copied to the sandbox
AND the Markdown content is parsed to plain text
AND parsed_content is set to the extracted plain text
AND status is set to SUCCESS

#### Scenario: Markdown parsing result

WHEN a Markdown file is parsed
AND the file contains headings, lists, code blocks, and links
THEN the parsed_content contains the plain text without Markdown syntax
AND the content is suitable for AI prompt injection

---

### REQ-FP-006: Scanned PDF detection

The system shall detect scanned PDFs by checking if the extracted text length is less than N×50 characters (where N is the number of pages). If detected, the file is marked as scanned and the user is warned that scanned PDFs are not supported.

#### Scenario: Detect scanned PDF

WHEN a PDF file is processed
AND the extracted text length is less than N × 50 characters (N = number of pages)
THEN the file is marked as a scanned PDF
AND the user is warned that scanned PDFs are not supported in the current version

#### Scenario: Non-scanned PDF with sufficient text

WHEN a PDF file is processed
AND the extracted text length is N × 50 characters or more
THEN the file is not flagged as scanned
AND normal processing continues (though parsed_content is still null per REQ-FP-004)

---

### REQ-FP-007: Same-name file replacement with old file deletion

When uploading a file with the same name as an existing material, the system must first delete the old physical file, then copy the new file, then update the database. If the old file deletion fails, the upload is blocked.

#### Scenario: Replace existing file with same name

WHEN a learner uploads a file with the same name as an existing material
THEN the system first deletes the old physical file from the sandbox
AND if the old file deletion succeeds, copies the new file to the sandbox
AND updates the material record in the database with the new file path and metadata

#### Scenario: Old file deletion failure blocks upload

WHEN a learner uploads a file with the same name as an existing material
AND the deletion of the old physical file fails
THEN the upload is blocked
AND the user is shown an error message
AND the existing material record remains unchanged
AND no new file is copied to the sandbox

---

### REQ-FP-008: AI generation block when all materials have null parsed_content

The system shall block the transition from DRAFT to GENERATING if all course materials have parsed_content = null. At least one material with valid parsed_content is required.

#### Scenario: Block generation with no parseable materials

WHEN a learner attempts to trigger AI generation for a course
AND all materials in the course have parsed_content = null
THEN the transition from DRAFT(0) to GENERATING(1) is blocked
AND the user is shown a message indicating that at least one Markdown file with parseable content is required

#### Scenario: Allow generation with at least one parseable material

WHEN a learner attempts to trigger AI generation for a course
AND at least one material has parsed_content that is not null
THEN the transition from DRAFT(0) to GENERATING(1) is allowed
AND the AI generation process begins

#### Scenario: Mixed materials with some parseable

WHEN a course has both PDF (parsed_content=null) and Markdown (parsed_content=text) materials
AND the learner triggers AI generation
THEN the transition is allowed
AND only the materials with non-null parsed_content are used as AI context
