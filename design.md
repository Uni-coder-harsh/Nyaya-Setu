# Nyaya-Setu: Technical Design Document

## 1. High-Level Architecture

### Architecture Overview

```
┌─────────────────┐
│  Mobile Client  │
│   (Flutter)     │
│  + WhatsApp Bot │
└────────┬────────┘
         │
         │ HTTPS
         ▼
┌─────────────────────────────────────────────────────────────┐
│                        AWS Cloud                             │
│                                                              │
│  ┌──────────────────┐         ┌─────────────────┐          │
│  │  Amazon API      │────────▶│  AWS Lambda     │          │
│  │  Gateway         │         │  (Python 3.11)  │          │
│  │  (REST API)      │         │                 │          │
│  └──────────────────┘         └────────┬────────┘          │
│                                         │                    │
│                    ┌────────────────────┼────────────────┐  │
│                    │                    │                │  │
│                    ▼                    ▼                ▼  │
│         ┌──────────────────┐  ┌─────────────┐  ┌──────────┐│
│         │ Amazon Transcribe│  │   Amazon    │  │ Amazon   ││
│         │ (Speech-to-Text) │  │  Textract   │  │  Polly   ││
│         │ Multi-language   │  │    (OCR)    │  │  (TTS)   ││
│         └──────────────────┘  └─────────────┘  └──────────┘│
│                    │                    │                │  │
│                    └────────────────────┼────────────────┘  │
│                                         │                    │
│                                         ▼                    │
│                            ┌─────────────────────┐          │
│                            │  Amazon Bedrock     │          │
│                            │  Agents Framework   │          │
│                            │                     │          │
│                            │  • Claude 3.5       │          │
│                            │    Sonnet (LLM)     │          │
│                            │  • Action Groups    │          │
│                            │  • Knowledge Base   │          │
│                            └──────────┬──────────┘          │
│                                       │                      │
│                    ┌──────────────────┼──────────────────┐  │
│                    │                  │                  │  │
│                    ▼                  ▼                  ▼  │
│         ┌──────────────────┐  ┌─────────────┐  ┌──────────┐│
│         │ Amazon OpenSearch│  │  Amazon S3  │  │ DynamoDB ││
│         │   Serverless     │  │  (Storage)  │  │ (Cases)  ││
│         │ (Vector Store)   │  │             │  │          ││
│         │ • BNS Laws       │  │ • Voice     │  │          ││
│         │ • Embeddings     │  │ • Images    │  │          ││
│         │   (Titan)        │  │ • PDFs      │  │          ││
│         └──────────────────┘  └─────────────┘  └──────────┘│
│                                       │                      │
│                                       ▼                      │
│                            ┌─────────────────────┐          │
│                            │  PDF Generation     │          │
│                            │  (ReportLab/WeasyPr)│          │
│                            └──────────┬──────────┘          │
│                                       │                      │
└───────────────────────────────────────┼──────────────────────┘
                                        │
                                        ▼
                            ┌─────────────────────┐
                            │  WhatsApp Business  │
                            │  API (Twilio/Meta)  │
                            │  Document Delivery  │
                            └─────────────────────┘
```

### Component Responsibilities

**API Gateway**: Request routing, authentication, rate limiting, CORS handling  
**Lambda Functions**: Serverless compute for business logic, orchestration  
**Bedrock Agents**: AI orchestration, legal reasoning, document generation  
**Transcribe**: Multi-language voice-to-text conversion  
**Textract**: OCR for handwritten and printed documents  
**Polly**: Text-to-speech for voice responses  
**OpenSearch Serverless**: Vector database for BNS law retrieval (RAG)  
**S3**: Object storage for audio, images, generated PDFs  
**DynamoDB**: NoSQL database for case metadata and user sessions  
**WhatsApp API**: Message delivery and bot interface

---

## 2. Tech Stack

### 2.1 Frontend Layer

**Mobile Application**
- **Framework**: Flutter 3.16+
- **Language**: Dart
- **State Management**: Riverpod / Bloc
- **UI Components**: Material Design 3
- **Audio Recording**: flutter_sound
- **Image Capture**: image_picker, camera
- **HTTP Client**: dio
- **Local Storage**: shared_preferences, sqflite

**WhatsApp Bot Interface**
- **Platform**: WhatsApp Business API
- **Provider**: Twilio / Meta Cloud API
- **Webhook Handler**: AWS Lambda (Python)
- **Message Types**: Text, Voice Notes, Images, Documents

### 2.2 Backend Layer

**Compute**
- **Runtime**: AWS Lambda (Python 3.11)
- **Framework**: FastAPI (for local dev), AWS Lambda Powertools
- **Async Processing**: asyncio, aioboto3
- **API Gateway**: Amazon API Gateway (REST API)

**AI/ML Services**
- **LLM**: Amazon Bedrock - Claude 3.5 Sonnet (anthropic.claude-3-5-sonnet-20241022-v2:0)
- **Embeddings**: Amazon Bedrock - Titan Embeddings V2 (amazon.titan-embed-text-v2:0)
- **Orchestration**: Amazon Bedrock Agents
- **Speech-to-Text**: Amazon Transcribe (Hindi, English, + regional languages)
- **Text-to-Speech**: Amazon Polly (Neural voices - Aditi for Hindi, Kajal for English)
- **OCR**: Amazon Textract (Document Analysis API)

**Data Layer**
- **Vector Database**: Amazon OpenSearch Serverless (for BNS law embeddings)
- **NoSQL Database**: Amazon DynamoDB (case metadata, user sessions)
- **Object Storage**: Amazon S3 (audio files, images, PDFs)
- **Caching**: Amazon ElastiCache (Redis) - optional for session management

**Document Generation**
- **PDF Library**: ReportLab (Python) or WeasyPrint
- **Templates**: Jinja2 for document templates
- **Bilingual Support**: Unicode fonts (Noto Sans Devanagari)

### 2.3 Infrastructure & DevOps

**Infrastructure as Code**
- **IaC Tool**: AWS CDK (Python) or Terraform
- **CI/CD**: AWS CodePipeline, GitHub Actions
- **Monitoring**: Amazon CloudWatch, AWS X-Ray
- **Logging**: CloudWatch Logs, structured JSON logging
- **Secrets Management**: AWS Secrets Manager

**Security**
- **Authentication**: Amazon Cognito (phone-based OTP)
- **Authorization**: IAM roles and policies
- **Encryption**: KMS for data at rest, TLS 1.3 for data in transit
- **WAF**: AWS WAF for API protection

---

## 3. Data Flow

### 3.1 Voice Grievance Submission Flow

```
Step 1: User Records Voice Complaint
├─ User speaks in Hindi/regional language via Flutter app or WhatsApp
├─ Audio recorded in AAC/MP3 format
└─ Audio file uploaded to S3 (pre-signed URL)

Step 2: Speech-to-Text Conversion
├─ Lambda triggers Amazon Transcribe job
├─ Language auto-detection or user-specified
├─ Transcribe outputs JSON with text + confidence scores
└─ Transcript stored in DynamoDB with case_id

Step 3: Bedrock Agent Analysis
├─ Lambda invokes Bedrock Agent with transcript
├─ Agent performs:
│   ├─ Intent classification (FIR, complaint, notice, etc.)
│   ├─ Entity extraction (names, dates, locations, amounts)
│   ├─ Legal issue identification
│   └─ RAG query to OpenSearch for relevant BNS sections
├─ Agent uses Claude 3.5 Sonnet for reasoning
└─ Returns structured legal analysis + applicable laws

Step 4: Interactive Clarification (if needed)
├─ Agent identifies missing information
├─ Generates clarifying questions in user's language
├─ Lambda converts questions to speech via Polly
├─ User responds via voice (loop back to Step 2)
└─ Repeat until all required info collected

Step 5: Legal Document Generation
├─ Bedrock Agent generates formal legal document
├─ Includes:
│   ├─ Proper legal formatting
│   ├─ Cited BNS sections with explanations
│   ├─ Bilingual content (English + user language)
│   └─ Next steps and filing instructions
├─ Lambda renders document using ReportLab
└─ PDF saved to S3 with case_id

Step 6: Document Delivery
├─ Lambda generates pre-signed S3 URL (24-hour expiry)
├─ Polly generates voice summary of document
├─ WhatsApp API sends:
│   ├─ PDF document attachment
│   ├─ Voice note summary
│   └─ Text message with next steps
└─ Case status updated in DynamoDB

Step 7: Post-Processing
├─ CloudWatch logs all interactions
├─ User feedback collected (thumbs up/down)
├─ Analytics event sent to CloudWatch Metrics
└─ Case marked as "completed" in DynamoDB
```

### 3.2 Image/Document Upload Flow

```
Step 1: User Uploads Document Image
├─ User captures photo or selects from gallery
├─ Image uploaded to S3 (JPEG/PNG, max 10MB)
└─ Lambda triggered on S3 upload event

Step 2: OCR Processing
├─ Lambda invokes Amazon Textract (AnalyzeDocument API)
├─ Textract extracts:
│   ├─ Raw text (handwritten + printed)
│   ├─ Key-value pairs (form fields)
│   ├─ Tables (if present)
│   └─ Signatures and dates
├─ Confidence scores for each extracted element
└─ Structured JSON output stored in DynamoDB

Step 3: Document Classification
├─ Extracted text sent to Bedrock Agent
├─ Agent classifies document type:
│   ├─ Legal notice
│   ├─ Property document
│   ├─ Witness statement
│   ├─ Police complaint copy
│   └─ Other
├─ Extracts key entities (names, case numbers, dates)
└─ Returns structured metadata

Step 4: Integration with Case
├─ Document linked to existing case_id or creates new case
├─ Metadata stored in DynamoDB
├─ User notified via WhatsApp with extracted summary
└─ User confirms accuracy or requests corrections

Step 5: Legal Analysis (if standalone document)
├─ If document is a legal notice received by user
├─ Bedrock Agent analyzes implications
├─ Suggests response strategy and applicable BNS sections
├─ Generates draft response document
└─ Follows Steps 5-6 from Voice Flow for delivery
```

### 3.3 Case Status Retrieval Flow

```
Step 1: User Requests Case Status
├─ User sends "Check Status" via WhatsApp or app
├─ API Gateway receives GET /case-status request
└─ Lambda authenticates user (phone number)

Step 2: Database Query
├─ Lambda queries DynamoDB by user_id
├─ Retrieves all cases with metadata:
│   ├─ case_id, creation_date, status
│   ├─ Document type, language
│   └─ S3 URLs for generated documents
└─ Returns list of cases

Step 3: Response Formatting
├─ Lambda formats response in user's language
├─ Polly generates voice summary (optional)
├─ WhatsApp API sends:
│   ├─ List of cases with status
│   ├─ Quick action buttons (View, Download, Delete)
│   └─ Voice summary if requested
└─ User can select case for detailed view
```

---

## 4. API Endpoints

### 4.1 Grievance Submission API

**Endpoint**: `POST /submit-grievance`

**Description**: Submit a new legal grievance via voice or text

**Request Headers**:
```
Authorization: Bearer <cognito_token>
Content-Type: multipart/form-data
X-User-Language: hi-IN
```

**Request Body**:
```json
{
  "user_id": "string (phone number)",
  "input_type": "voice | text",
  "audio_file": "file (if voice)",
  "text_input": "string (if text)",
  "language": "hi-IN | en-IN | mr-IN | ta-IN | te-IN | kn-IN | bn-IN",
  "grievance_type": "fir | complaint | notice | rti | consumer",
  "metadata": {
    "location": "string",
    "incident_date": "ISO 8601 date",
    "urgency": "low | medium | high"
  }
}
```

**Response** (202 Accepted):
```json
{
  "case_id": "uuid",
  "status": "processing",
  "message": "Your grievance is being processed",
  "estimated_completion": "ISO 8601 timestamp",
  "next_steps": [
    "We will analyze your complaint",
    "You may receive clarifying questions",
    "Document will be ready in 2-3 minutes"
  ]
}
```

**Error Responses**:
- `400 Bad Request`: Invalid input format
- `401 Unauthorized`: Invalid or missing token
- `413 Payload Too Large`: Audio file exceeds 50MB
- `429 Too Many Requests`: Rate limit exceeded
- `500 Internal Server Error`: Processing failure

---

### 4.2 Case Status API

**Endpoint**: `GET /case-status`

**Description**: Retrieve status of user's legal cases

**Request Headers**:
```
Authorization: Bearer <cognito_token>
X-User-Language: hi-IN
```

**Query Parameters**:
```
case_id (optional): Filter by specific case
status (optional): Filter by status (processing | completed | failed)
limit (optional): Number of results (default: 10, max: 50)
offset (optional): Pagination offset
```

**Response** (200 OK):
```json
{
  "user_id": "string",
  "total_cases": 5,
  "cases": [
    {
      "case_id": "uuid",
      "created_at": "ISO 8601 timestamp",
      "updated_at": "ISO 8601 timestamp",
      "status": "completed",
      "grievance_type": "fir",
      "language": "hi-IN",
      "summary": "Complaint against moneylender harassment",
      "bns_sections": ["BNS Section 308", "BNS Section 351"],
      "documents": [
        {
          "type": "pdf",
          "url": "https://s3.amazonaws.com/...",
          "expires_at": "ISO 8601 timestamp"
        }
      ],
      "voice_summary_url": "https://s3.amazonaws.com/...",
      "next_actions": [
        "Visit nearest police station",
        "Carry printed copy and ID proof",
        "Request FIR number and acknowledgment"
      ]
    }
  ]
}
```

**Error Responses**:
- `401 Unauthorized`: Invalid token
- `404 Not Found`: Case ID not found
- `500 Internal Server Error`: Database error

---

### 4.3 Document Upload API

**Endpoint**: `POST /upload-document`

**Description**: Upload scanned/photographed legal documents for OCR

**Request Headers**:
```
Authorization: Bearer <cognito_token>
Content-Type: multipart/form-data
X-User-Language: hi-IN
```

**Request Body**:
```json
{
  "user_id": "string",
  "case_id": "uuid (optional, links to existing case)",
  "document_type": "notice | property_doc | witness_statement | other",
  "images": ["file1.jpg", "file2.jpg"],
  "description": "string (optional user description)"
}
```

**Response** (202 Accepted):
```json
{
  "document_id": "uuid",
  "case_id": "uuid",
  "status": "processing",
  "message": "Document is being analyzed",
  "images_uploaded": 2,
  "estimated_completion": "ISO 8601 timestamp"
}
```

**Webhook Callback** (when processing complete):
```json
{
  "document_id": "uuid",
  "case_id": "uuid",
  "status": "completed",
  "extracted_text": "string",
  "document_classification": "legal_notice",
  "key_entities": {
    "names": ["Ramesh Kumar", "Vijay Singh"],
    "dates": ["2026-01-15"],
    "case_numbers": ["CR-123/2026"],
    "amounts": ["₹50,000"]
  },
  "confidence_score": 0.87,
  "legal_analysis": {
    "summary": "Legal notice for loan repayment",
    "applicable_sections": ["BNS Section 316"],
    "recommended_action": "Draft response within 15 days",
    "urgency": "high"
  },
  "response_document_url": "https://s3.amazonaws.com/..."
}
```

**Error Responses**:
- `400 Bad Request`: Invalid image format or size
- `401 Unauthorized`: Invalid token
- `415 Unsupported Media Type`: File type not supported
- `500 Internal Server Error`: OCR processing failure

---

### 4.4 Additional Endpoints

**Health Check**
```
GET /health
Response: {"status": "healthy", "version": "1.0.0"}
```

**Language Support**
```
GET /languages
Response: {
  "supported_languages": [
    {"code": "hi-IN", "name": "Hindi", "voice": true, "ocr": true},
    {"code": "en-IN", "name": "English", "voice": true, "ocr": true},
    {"code": "mr-IN", "name": "Marathi", "voice": true, "ocr": false}
  ]
}
```

**Feedback Submission**
```
POST /feedback
Body: {
  "case_id": "uuid",
  "rating": 1-5,
  "comments": "string",
  "helpful": true/false
}
Response: {"message": "Thank you for your feedback"}
```

---

## 5. Amazon Bedrock Agent Configuration

### 5.1 Agent Architecture

**Agent Name**: NyayaSetuLegalAgent  
**Foundation Model**: Claude 3.5 Sonnet  
**Agent Type**: Conversational with Action Groups

**Agent Instructions**:
```
You are a legal assistant for rural Indian citizens. Your role is to:
1. Understand legal grievances in simple Hindi/regional languages
2. Identify applicable BNS (Bharatiya Nyaya Sanhita) sections
3. Draft formal legal documents in proper format
4. Explain legal concepts in 5th-grade language
5. Provide step-by-step filing guidance

Always be empathetic, patient, and culturally sensitive. Prioritize user safety and legal accuracy.
```

### 5.2 Knowledge Base Configuration

**Knowledge Base Name**: BNS-Legal-Corpus  
**Data Source**: Amazon S3 bucket with BNS law documents  
**Embedding Model**: Titan Embeddings V2  
**Vector Store**: Amazon OpenSearch Serverless  
**Chunking Strategy**: 500 tokens with 50-token overlap

**Indexed Documents**:
- Bharatiya Nyaya Sanhita (BNS) - Full text
- Bharatiya Nagarik Suraksha Sanhita (BNSS) - Procedures
- Bharatiya Sakshya Adhiniyam - Evidence law
- IPC to BNS section mapping
- Legal document templates
- State-specific procedures

### 5.3 Action Groups

**Action Group 1: Document Generation**
- `generate_fir`: Create FIR document
- `generate_complaint`: Create civil complaint
- `generate_legal_notice`: Create legal notice
- `generate_affidavit`: Create affidavit

**Action Group 2: Legal Research**
- `search_bns_sections`: Query BNS provisions
- `map_ipc_to_bns`: Convert old IPC sections
- `get_precedents`: Fetch similar cases
- `explain_legal_term`: Simplify legal jargon

**Action Group 3: Case Management**
- `create_case`: Initialize new case
- `update_case`: Add information to case
- `get_case_details`: Retrieve case info
- `list_required_documents`: Identify missing docs

### 5.4 Guardrails

**Content Filters**:
- Block harmful legal advice
- Prevent generation of false evidence
- Filter personally identifiable information in logs
- Detect and warn about statute of limitations

**Response Validation**:
- Verify BNS section citations
- Check document format compliance
- Validate dates and legal timelines
- Ensure bilingual output quality

---

## 6. Data Models

### 6.1 DynamoDB Tables

**Table: Cases**
```
Partition Key: user_id (String)
Sort Key: case_id (String)

Attributes:
- created_at (Number, timestamp)
- updated_at (Number, timestamp)
- status (String: processing | completed | failed)
- grievance_type (String)
- language (String)
- input_type (String: voice | text | document)
- transcript (String)
- legal_analysis (Map)
- bns_sections (List)
- document_urls (List)
- metadata (Map)

GSI: StatusIndex (status, created_at)
```

**Table: Documents**
```
Partition Key: document_id (String)
Sort Key: case_id (String)

Attributes:
- user_id (String)
- uploaded_at (Number)
- document_type (String)
- s3_keys (List)
- ocr_text (String)
- extracted_entities (Map)
- confidence_score (Number)
- processed (Boolean)
```

**Table: UserSessions**
```
Partition Key: user_id (String)
Sort Key: session_id (String)

Attributes:
- started_at (Number)
- last_activity (Number)
- language_preference (String)
- conversation_history (List)
- current_case_id (String)
- TTL (Number, 24 hours)
```

### 6.2 S3 Bucket Structure

```
nyaya-setu-data/
├── audio/
│   ├── {user_id}/
│   │   └── {case_id}/
│   │       └── input_{timestamp}.mp3
├── images/
│   ├── {user_id}/
│   │   └── {document_id}/
│   │       ├── page_1.jpg
│   │       └── page_2.jpg
├── documents/
│   ├── {user_id}/
│   │   └── {case_id}/
│   │       ├── fir_{case_id}_en.pdf
│   │       └── fir_{case_id}_hi.pdf
├── voice-summaries/
│   └── {case_id}/
│       └── summary_{language}.mp3
└── templates/
    ├── fir_template.html
    ├── complaint_template.html
    └── notice_template.html
```

---

## 7. Security Architecture

### 7.1 Authentication Flow

```
1. User enters phone number in app
2. Cognito sends OTP via SMS
3. User enters OTP
4. Cognito returns JWT tokens (ID, Access, Refresh)
5. App stores tokens securely (Flutter Secure Storage)
6. API Gateway validates JWT on each request
7. Lambda extracts user_id from token claims
```

### 7.2 Data Encryption

**At Rest**:
- S3: SSE-KMS with customer-managed key
- DynamoDB: Encryption enabled with AWS managed key
- OpenSearch: Encryption at rest enabled
- Secrets Manager: Automatic encryption

**In Transit**:
- TLS 1.3 for all API calls
- Certificate pinning in Flutter app
- VPC endpoints for AWS service communication

### 7.3 IAM Roles

**Lambda Execution Role**:
- Transcribe: StartTranscriptionJob, GetTranscriptionJob
- Textract: AnalyzeDocument
- Polly: SynthesizeSpeech
- Bedrock: InvokeAgent, Retrieve
- S3: GetObject, PutObject (scoped to specific buckets)
- DynamoDB: Query, PutItem, UpdateItem
- CloudWatch: PutLogEvents

**Bedrock Agent Role**:
- OpenSearch: Search, Query
- S3: GetObject (knowledge base bucket)
- Lambda: InvokeFunction (action groups)

---

## 8. Scalability & Performance

### 8.1 Scaling Strategy

**Lambda**:
- Concurrent executions: 1000 (initial), auto-scale to 10,000
- Provisioned concurrency: 10 for critical functions
- Memory: 1024MB (Transcribe), 2048MB (Bedrock), 512MB (API handlers)
- Timeout: 5 minutes (document generation), 30 seconds (API)

**DynamoDB**:
- On-demand capacity mode (auto-scaling)
- Point-in-time recovery enabled
- Global tables for multi-region (future)

**OpenSearch Serverless**:
- OCU: 2-10 auto-scaling
- Index: 100K BNS law chunks (estimated 500MB)

**S3**:
- Intelligent-Tiering for cost optimization
- Lifecycle policy: Delete audio after 30 days, archive documents after 1 year

### 8.2 Performance Targets

| Operation | Target Latency | SLA |
|-----------|---------------|-----|
| Voice transcription (1 min audio) | < 5 seconds | 95th percentile |
| OCR processing (1 image) | < 10 seconds | 95th percentile |
| Bedrock Agent response | < 15 seconds | 90th percentile |
| PDF generation | < 8 seconds | 95th percentile |
| API response (non-processing) | < 500ms | 99th percentile |
| End-to-end case completion | < 2 minutes | 90th percentile |

### 8.3 Cost Optimization

**Estimated Monthly Cost (1000 active users)**:
- Lambda: $50 (5M invocations)
- Bedrock: $300 (Claude 3.5 Sonnet usage)
- Transcribe: $100 (10K minutes)
- Textract: $80 (5K pages)
- S3: $20 (100GB storage + transfer)
- DynamoDB: $25 (on-demand)
- OpenSearch: $150 (2 OCU)
- **Total: ~$725/month** (~₹0.72 per user)

**Cost Reduction Strategies**:
- Cache frequent BNS queries in ElastiCache
- Use Bedrock batch inference for non-urgent cases
- Compress audio files before storage
- Implement S3 lifecycle policies
- Use Lambda SnapStart for faster cold starts

---

## 9. Monitoring & Observability

### 9.1 CloudWatch Metrics

**Custom Metrics**:
- `GrievanceSubmissions` (by type, language)
- `TranscriptionAccuracy` (confidence scores)
- `OCRSuccessRate`
- `BedrockAgentLatency`
- `DocumentGenerationTime`
- `UserSatisfactionScore`
- `CostPerCase`

**Alarms**:
- Lambda error rate > 5%
- API Gateway 5xx errors > 1%
- Bedrock throttling errors
- S3 upload failures
- DynamoDB read/write throttling

### 9.2 Logging Strategy

**Structured Logging Format**:
```json
{
  "timestamp": "ISO 8601",
  "level": "INFO | WARN | ERROR",
  "service": "transcribe-handler",
  "case_id": "uuid",
  "user_id": "hashed",
  "operation": "transcribe_audio",
  "duration_ms": 4523,
  "status": "success",
  "metadata": {}
}
```

**Log Retention**:
- CloudWatch Logs: 30 days
- S3 archive: 1 year (compliance)
- PII redaction: Automatic via Lambda

### 9.3 Distributed Tracing

**AWS X-Ray**:
- Trace all Lambda invocations
- Track Bedrock API calls
- Monitor S3 upload/download times
- Identify bottlenecks in data flow

---

## 10. Disaster Recovery & Backup

**RTO (Recovery Time Objective)**: 4 hours  
**RPO (Recovery Point Objective)**: 1 hour

**Backup Strategy**:
- DynamoDB: Point-in-time recovery (35 days)
- S3: Versioning enabled, cross-region replication (future)
- OpenSearch: Daily snapshots to S3
- Lambda: Code stored in CodeCommit/GitHub

**Failure Scenarios**:
- Lambda failure: Automatic retry (3 attempts)
- Bedrock throttling: Exponential backoff + queue
- S3 unavailability: Fallback to secondary region
- DynamoDB failure: Read from backup table

---

## 11. Deployment Architecture

### 11.1 Environment Strategy

**Development**:
- Single region (ap-south-1)
- Reduced Lambda memory/timeout
- Bedrock on-demand pricing
- No WAF/Shield

**Staging**:
- Mirror production configuration
- Synthetic load testing
- Blue/green deployments

**Production**:
- Multi-AZ deployment
- WAF + Shield Standard
- Reserved capacity for Lambda
- CloudFront for S3 content delivery

### 11.2 CI/CD Pipeline

```
GitHub Push → CodePipeline Trigger
    ↓
CodeBuild: Run Tests
    ↓
CDK Synth: Generate CloudFormation
    ↓
Deploy to Staging
    ↓
Integration Tests
    ↓
Manual Approval
    ↓
Deploy to Production (Blue/Green)
    ↓
CloudWatch Alarms Monitoring
    ↓
Auto-Rollback if errors > threshold
```

---

## 12. Future Enhancements

### Phase 2 (3-6 months)
- Multi-region deployment (Mumbai + Hyderabad)
- Real-time case status tracking via WebSocket
- Integration with eCourts API
- Support for 15+ Indian languages
- Mobile app offline mode

### Phase 3 (6-12 months)
- Video consultation with legal aid lawyers
- AI-powered legal research chatbot
- Blockchain-based document verification
- Integration with government portals (e-Filing)
- Community legal literacy modules

---

**Document Version**: 1.0  
**Last Updated**: February 7, 2026  
**Author**: Cloud Architecture Team  
**Review Status**: Draft
