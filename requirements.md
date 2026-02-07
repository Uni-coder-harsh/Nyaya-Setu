# Nyaya-Setu: Requirements Document

## 1. Introduction & Vision

**Nyaya-Setu** (Bridge to Justice) is an AI-powered paralegal agent designed to democratize access to legal services for rural and underserved communities in India. The platform enables illiterate and semi-literate users to file formal legal grievances using voice input in local dialects and image scanning of handwritten documents, eliminating traditional barriers to justice.

### Vision Statement
To empower every Indian citizen, regardless of literacy level or geographic location, with the ability to understand their legal rights and seek justice through accessible, AI-driven legal assistance aligned with India's new Bharatiya Nyaya Sanhita (BNS) framework.

### Key Differentiators
- Voice-first interface supporting Hindi and regional languages
- OCR capabilities for handwritten legal documents
- BNS-compliant legal drafting and guidance
- WhatsApp-based delivery for maximum accessibility
- Designed specifically for low-literacy users in rural contexts

---

## 2. Problem Statement

### 2.1 Access to Justice Gap
- **Geographic Barriers**: 65% of India's population lives in rural areas with limited access to legal professionals
- **Cost Barriers**: Legal consultation fees are prohibitive for low-income households (₹500-2000 per consultation)
- **Awareness Gap**: Lack of knowledge about legal rights, procedures, and available remedies
- **Time Constraints**: Rural citizens cannot afford multiple trips to district courts or legal aid centers

### 2.2 Language & Literacy Barriers
- **Low Literacy Rates**: ~25% of rural population is illiterate; many more are functionally illiterate
- **Language Complexity**: Legal documents use complex English/Hindi terminology inaccessible to common citizens
- **Regional Language Gap**: Legal services rarely available in local dialects (Bhojpuri, Marathi, Tamil, Telugu, etc.)
- **Documentation Challenges**: Inability to read/write formal legal applications

### 2.3 New BNS Legal Framework
- **Bharatiya Nyaya Sanhita (2023)**: Replaced IPC with updated criminal law provisions
- **Bharatiya Nagarik Suraksha Sanhita**: New criminal procedure code
- **Bharatiya Sakshya Adhiniyam**: New evidence law
- **Awareness Gap**: Citizens and even some practitioners unfamiliar with new provisions, section mappings, and procedures
- **Need for Updated Tools**: Existing legal tech solutions reference outdated IPC/CrPC frameworks

---

## 3. User Personas

### Persona 1: Ramesh - Rural Farmer
- **Age**: 45 years
- **Location**: Village in Uttar Pradesh
- **Education**: 5th grade, semi-literate in Hindi
- **Language**: Speaks Bhojpuri, understands basic Hindi
- **Technology**: Owns basic smartphone, uses WhatsApp for family communication
- **Legal Need**: Wants to file complaint against moneylender for harassment
- **Pain Points**: Cannot read legal forms, doesn't know which sections apply, afraid of going to police station alone
- **Goals**: File formal complaint, understand his rights, get documentation for legal aid

### Persona 2: Lakshmi - Domestic Violence Survivor
- **Age**: 32 years
- **Location**: Rural Karnataka
- **Education**: Illiterate
- **Language**: Speaks only Kannada
- **Technology**: Borrows family member's phone
- **Legal Need**: Wants protection order against abusive husband
- **Pain Points**: Cannot travel to district court, doesn't know about legal protections, fears social stigma
- **Goals**: Understand her rights, file application from home, receive guidance in her language

### Persona 3: Arjun - Daily Wage Laborer
- **Age**: 28 years
- **Location**: Rural Bihar
- **Education**: 8th grade
- **Language**: Hindi and Maithili
- **Technology**: Smartphone user, comfortable with voice messages
- **Legal Need**: File FIR for theft of motorcycle
- **Pain Points**: Has handwritten witness statements but cannot type them, doesn't know FIR format, police station is 15km away
- **Goals**: Submit proper FIR with all details, get copy for insurance claim

### Persona 4: Savitri - Elderly Widow
- **Age**: 68 years
- **Location**: Rural Rajasthan
- **Education**: Illiterate
- **Language**: Marwari dialect
- **Technology**: Uses WhatsApp with help from grandchildren
- **Legal Need**: Property dispute with relatives over deceased husband's land
- **Pain Points**: Has old handwritten property documents, cannot read legal notices received, no money for lawyer
- **Goals**: Understand legal notices, draft response, know her inheritance rights

---

## 4. Functional Requirements

### 4.1 Voice Input & Processing

#### FR-1.1: Multi-Language Voice Recognition
- **Priority**: P0 (Critical)
- Support voice input in Hindi and minimum 5 regional languages (Bhojpuri, Marathi, Tamil, Telugu, Kannada, Bengali)
- Accuracy target: >85% for Hindi, >80% for regional languages
- Handle rural accents and dialect variations
- Support continuous speech input (up to 5 minutes per recording)

#### FR-1.2: Voice-to-Text Conversion
- Convert voice input to structured text format
- Preserve context and intent from spoken narrative
- Handle code-switching between Hindi and regional languages
- Provide playback option for user verification

#### FR-1.3: Interactive Voice Dialogue
- Ask clarifying questions via voice prompts
- Guide users through information gathering (who, what, when, where)
- Confirm understanding before proceeding to document generation
- Support voice-based navigation through the application

### 4.2 Image Processing & OCR

#### FR-2.1: Document Image Capture
- Accept images via WhatsApp, camera upload, or gallery selection
- Support multiple image formats (JPEG, PNG, PDF)
- Handle poor lighting, skewed angles, and low-resolution images
- Allow multiple document uploads per case (up to 10 images)

#### FR-2.2: Handwritten Text Recognition
- OCR for handwritten documents in Hindi and English
- Extract text from common legal documents (complaints, notices, affidavits, property papers)
- Handle mixed handwritten and printed text
- Accuracy target: >75% for clear handwriting

#### FR-2.3: Document Classification
- Automatically identify document type (FIR, complaint, notice, agreement, etc.)
- Extract key entities (names, dates, locations, amounts)
- Flag missing critical information
- Provide structured summary of extracted content

### 4.3 AI Legal Drafting & BNS Compliance

#### FR-3.1: BNS Knowledge Base
- Comprehensive database of Bharatiya Nyaya Sanhita provisions
- Mapping from old IPC sections to new BNS sections
- Include Bharatiya Nagarik Suraksha Sanhita (procedure) and Bharatiya Sakshya Adhiniyam (evidence)
- Regular updates for amendments and judicial interpretations

#### FR-3.2: Legal Issue Identification
- Analyze user's narrative to identify applicable legal issues
- Suggest relevant BNS sections and provisions
- Explain legal concepts in simple language (5th-grade reading level)
- Provide examples and precedents in user's language

#### FR-3.3: Automated Document Drafting
- Generate formal legal documents based on user input:
  - FIR/Police Complaints
  - Civil Complaints
  - Legal Notices
  - Affidavits
  - RTI Applications
  - Consumer Complaints
- Include all mandatory fields and proper legal formatting
- Cite relevant BNS sections with explanations
- Generate in both English and user's preferred language

#### FR-3.4: Legal Guidance & Next Steps
- Provide step-by-step guidance on filing procedures
- Identify appropriate forum (police station, court, consumer forum, etc.)
- List required supporting documents
- Explain expected timelines and processes
- Suggest free legal aid options where applicable

### 4.4 WhatsApp Integration

#### FR-4.1: WhatsApp Bot Interface
- Deploy on WhatsApp Business API for maximum reach
- Support text, voice note, and image inputs
- Conversational interface with menu-driven options
- Session management for multi-turn conversations

#### FR-4.2: Document Delivery
- Send generated legal documents as PDF via WhatsApp
- Provide both English and regional language versions
- Include voice summary of key points
- Enable easy forwarding to legal aid centers or authorities

#### FR-4.3: Status Tracking
- Allow users to save and retrieve past cases
- Send reminders for important deadlines
- Provide updates on case filing procedures
- Enable follow-up questions on existing cases

#### FR-4.4: Offline Support
- Queue messages when user is offline
- Provide downloadable content for offline reference
- SMS fallback for critical notifications

### 4.5 User Experience & Accessibility

#### FR-5.1: Simplified Interface
- Icon-based navigation for illiterate users
- Voice-guided onboarding and tutorials
- Minimal text, maximum audio/visual cues
- Large buttons and high-contrast design

#### FR-5.2: Verification & Confirmation
- Read back generated documents in user's language
- Allow edits via voice commands
- Require explicit confirmation before finalizing
- Provide sample documents for reference

#### FR-5.3: Help & Support
- 24/7 automated FAQ system
- Escalation to human legal aid volunteers for complex cases
- Video tutorials in regional languages
- Community support groups

---

## 5. Non-Functional Requirements

### 5.1 Performance & Latency

#### NFR-1.1: Response Time
- Voice-to-text conversion: <5 seconds for 1-minute audio
- OCR processing: <10 seconds per image
- Legal document generation: <15 seconds
- WhatsApp message delivery: <3 seconds
- End-to-end case processing: <2 minutes

#### NFR-1.2: Availability
- System uptime: 99.5% (allowing for maintenance windows)
- Graceful degradation during high load
- Queue management for peak usage times

#### NFR-1.3: Scalability
- Support 10,000 concurrent users in Phase 1
- Scale to 100,000+ users within 6 months
- Handle 50,000 voice/image processing requests per day
- Auto-scaling infrastructure for demand spikes

### 5.2 Data Privacy & Security

#### NFR-2.1: Data Protection
- End-to-end encryption for all communications
- Compliance with IT Act 2000 and Digital Personal Data Protection Act 2023
- No storage of voice recordings beyond processing (delete after 24 hours)
- Anonymization of user data for analytics
- Secure storage of generated documents (encrypted at rest)

#### NFR-2.2: User Consent & Control
- Explicit consent for data collection and processing
- Right to delete all personal data
- Transparent privacy policy in regional languages
- No sharing of data with third parties without consent

#### NFR-2.3: Authentication & Authorization
- Phone number-based authentication via OTP
- Session timeout after 30 minutes of inactivity
- Secure API endpoints with rate limiting
- Role-based access for admin and support staff

### 5.3 Reliability & Accuracy

#### NFR-3.1: AI Model Accuracy
- Legal section identification: >90% accuracy
- Voice transcription: >85% accuracy (Hindi), >80% (regional)
- OCR accuracy: >75% for handwritten text
- Regular model retraining with user feedback

#### NFR-3.2: Legal Compliance
- All generated documents reviewed against BNS provisions
- Disclaimer that AI assistance is not legal advice
- Recommendation to consult qualified lawyer for complex cases
- Audit trail for all generated documents

#### NFR-3.3: Error Handling
- Graceful error messages in user's language
- Fallback to human support for system failures
- Retry mechanisms for network issues
- Data recovery for interrupted sessions

### 5.4 Localization & Accessibility

#### NFR-4.1: Language Support
- Phase 1: Hindi + 5 regional languages
- Phase 2: Expand to 15+ Indian languages
- Culturally appropriate examples and terminology
- Local legal procedure variations by state

#### NFR-4.2: Accessibility Standards
- WCAG 2.1 Level AA compliance
- Screen reader compatibility
- Voice-only navigation option
- Support for users with visual/hearing impairments

### 5.5 Cost Efficiency

#### NFR-5.1: Operational Costs
- Target: <₹5 per case processing cost
- Optimize AI model inference costs
- Use cost-effective cloud infrastructure
- Leverage open-source tools where possible

#### NFR-5.2: User Costs
- Free for basic legal document generation
- Minimal data usage (<5MB per case)
- Works on 2G/3G networks
- No premium features that exclude poor users

### 5.6 Monitoring & Analytics

#### NFR-6.1: System Monitoring
- Real-time performance dashboards
- Error tracking and alerting
- API usage and rate limiting monitoring
- Infrastructure health checks

#### NFR-6.2: Usage Analytics
- Track user journeys and drop-off points
- Measure document generation success rates
- Analyze common legal issues by region
- A/B testing for UX improvements

#### NFR-6.3: Impact Measurement
- Number of legal documents generated
- User satisfaction scores
- Cases successfully filed
- Cost savings vs. traditional legal services

---

## 6. Technical Constraints & Assumptions

### Constraints
- Must work on low-end Android smartphones (2GB RAM)
- Limited to WhatsApp platform for MVP (no standalone app)
- Dependent on third-party APIs for voice/OCR (cost implications)
- BNS legal database requires manual curation and updates

### Assumptions
- Target users have access to smartphones with WhatsApp
- Basic mobile internet connectivity available (even if intermittent)
- Users willing to share personal legal information via digital platform
- Legal aid organizations willing to partner for human escalation
- Government/courts will accept AI-generated documents (with human review)

---

## 7. Success Metrics

### Primary KPIs
- **Adoption**: 5,000+ active users within 3 months of launch
- **Engagement**: 60%+ users complete document generation
- **Accuracy**: 85%+ user satisfaction with generated documents
- **Impact**: 500+ legal documents successfully filed using the platform

### Secondary KPIs
- Average time to generate document: <5 minutes
- User retention: 40%+ monthly active users
- Language coverage: 80%+ users served in their preferred language
- Cost per user: <₹10 per month

---

## 8. Out of Scope (for MVP)

- Legal case tracking after filing
- Direct integration with court e-filing systems
- Video consultation with lawyers
- Payment processing for legal fees
- Civil law drafting (focus on criminal/consumer complaints for MVP)
- iOS app or web interface
- Real-time translation during court proceedings

---

## 9. Future Enhancements

- Integration with eCourts portal for case status tracking
- AI-powered legal research and case law search
- Multilingual legal chatbot for general queries
- Partnership with legal aid clinics for pro bono representation
- Expansion to civil matters (property, family law, contracts)
- Voice-based legal literacy modules
- Community forums for peer support

---

**Document Version**: 1.0  
**Last Updated**: February 7, 2026  
**Owner**: Product Management Team  
**Stakeholders**: Engineering, Legal Advisory, UX Design, Rural Outreach
