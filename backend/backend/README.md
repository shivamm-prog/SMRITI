# MindSetu Backend — Cognitive Gaming & Memory Platform (NER)

Production-structured, modular FastAPI backend for **MindSetu** — an AI-Based Cognitive Gaming and Memory Assistance Platform for Elderly Dementia Patients in the North Eastern Region (NER) of India (SIH 2026).

---

## 1. Technologies Used

- **Python 3.11+ / 3.13**
- **FastAPI**: Modern, high-performance web framework
- **Uvicorn**: Lightning-fast ASGI production server
- **Pydantic v2 & Pydantic Settings**: Strict data validation & environment configuration
- **SQLAlchemy 2.0**: Relational ORM supporting PostgreSQL (Supabase) and local SQLite fallback
- **PostgreSQL through Supabase**: Cloud database integration
- **PyJWT & Bcrypt**: Secure token issuance & salted password hashing
- **Python-dotenv**: Configurable environment variable management
- **CORS Middleware**: Safe cross-origin resource sharing for the React frontend
- **Pytest & HTTPX**: Automated end-to-end API test suite

---

## 2. Architecture & Directory Layout

```
backend/
├── app/
│   ├── main.py                     # Application entry point, CORS, lifespan, /health
│   ├── core/
│   │   ├── config.py               # Pydantic Settings (.env, JWT secrets, CORS)
│   │   ├── security.py             # bcrypt hashing, JWT access token issuance
│   │   ├── database.py             # SQLAlchemy engine & session management
│   │   └── seed.py                 # Initial seed data for 8 NER states & demo users
│   ├── models/
│   │   ├── user.py                 # User model (PATIENT, CAREGIVER, DOCTOR)
│   │   ├── patient.py              # Patient profile, region, language, preferences
│   │   ├── caregiver.py            # Caregiver profile & patient associations
│   │   ├── doctor.py               # Doctor profile & patient assignments
│   │   ├── activity.py             # 6 cognitive activities definitions
│   │   ├── activity_result.py      # Result scores, accuracy, duration
│   │   ├── memory.py               # Family memories, photos, voice notes
│   │   ├── reminder.py             # Medicine, meal, hydration reminders
│   │   ├── daily_note.py           # Caregiver observation logs (mood, sleep, appetite)
│   │   ├── cultural_content.py     # 8 NER states regional folklore & traditions
│   │   └── sync.py                 # SyncQueueItem & ClientSyncState for 2-day alert
│   ├── schemas/
│   │   ├── common.py               # Standard ApiResponse envelope: {success, data, message}
│   │   ├── auth.py                 # Register, Login, TokenResponse
│   │   ├── users.py                # User responses
│   │   ├── patients.py             # Patient profile & dashboard schemas
│   │   ├── caregivers.py           # Caregiver profile & connected patients
│   │   ├── doctors.py              # Doctor profile, reports & clinical insights
│   │   ├── activities.py           # Activity detail & result submission
│   │   ├── memories.py             # Memory CRUD schemas
│   │   ├── reminders.py            # Reminder CRUD & verification schemas
│   │   ├── notes.py                # Caregiver daily notes
│   │   ├── progress.py             # Progress summary & non-diagnostic trends
│   │   └── sync.py                 # Push, pull, and sync status schemas
│   ├── api/
│   │   ├── deps.py                 # JWT decoding, get_current_user, require_role
│   │   └── v1/
│   │       ├── router.py           # API v1 aggregator
│   │       └── endpoints/
│   │           ├── auth.py         # /register, /login, /me
│   │           ├── patients.py     # /patients/me, /dashboard
│   │           ├── caregivers.py   # /caregivers/me, /patients
│   │           ├── doctors.py      # /doctors/patients, /insights, /reports
│   │           ├── activities.py   # /activities, /results
│   │           ├── memories.py     # CRUD /memories
│   │           ├── reminders.py    # CRUD /reminders
│   │           ├── progress.py     # /progress/summary, /trends
│   │           ├── notes.py        # /notes
│   │           ├── cultural.py     # /cultural (8 NER states)
│   │           └── sync.py         # /sync/push, /sync/pull, /sync/status
│   ├── services/
│   │   ├── auth_service.py
│   │   ├── patient_service.py
│   │   ├── activity_service.py
│   │   ├── memory_service.py
│   │   ├── reminder_service.py
│   │   ├── progress_service.py
│   │   ├── cultural_service.py
│   │   └── sync_service.py
│   └── utils/
│       └── helpers.py              # NER metadata, greetings, 2-day sync detector
├── tests/
│   ├── __init__.py
│   └── test_api.py                 # 20-point automated end-to-end test suite
├── .env.example
├── .env
├── requirements.txt
└── README.md
```

---

## 3. Database Schema (Supabase PostgreSQL Compatible)

The database layer connects to Supabase PostgreSQL using `DATABASE_URL` (or falls back to local SQLite when unset for immediate testing):
- `users`: ID (UUID), Email, Hashed Password, Full Name, Role (`PATIENT`, `CAREGIVER`, `DOCTOR`), Timestamps.
- `patients`: Regional cultural profile (Assam, Meghalaya, etc.), Preferred Language, Cultural Preferences, Emergency Contacts, Caregiver & Doctor Foreign Keys, `last_synced_at`, `sync_attention_required`.
- `caregivers`: Phone, Relationship, Assigned Patient ID.
- `doctors`: Qualifications, Hospital Affiliations, License Number.
- `activities`: 6 cognitive games (Memory Recall, Object Matching, Daily Routine Sequence, Gentle Nature Spotting, Musical Instrument Recognition, Familiar Words & Proverbs).
- `activity_results`: Scores, accuracy, duration, difficulty, feedback, completed_at.
- `memories`: Title, people, place, date, photos, voice notes, tags, recall quiz prompts.
- `reminders`: Title, category (Medicine, Meal, Hydration, Activity, Appointment), scheduled time, caregiver verification.
- `daily_notes`: Mood, mood emoji, sleep quality, appetite, behavioral notes, clinical observations.
- `cultural_content`: 8 NER states folklore, landmarks, foods, festivals, and music.
- `sync_queue`: Queue log for offline push mutations.
- `client_sync_states`: Tracking for the 2-day sync overdue alert.

---

## 4. API Endpoints

### Authentication (`/api/v1/auth`)
- `POST /register`: Register Patient (with NER state & language), Caregiver, or Doctor.
- `POST /login`: Authenticate and receive signed JWT access token.
- `GET /me`: Authenticated user identity.

### Patients (`/api/v1/patients`)
- `GET /me`: Current patient profile.
- `PUT /me`: Update region, language, preferences, or emergency contacts.
- `GET /me/dashboard`: Patient dashboard (today's care, recommended activities, recent memories, progress).

### Caregivers (`/api/v1/caregivers`)
- `GET /me`: Caregiver profile.
- `GET /me/patients`: Connected patients overview.
- `GET /patients/{id}`: Detailed patient overview (authorized access only).

### Doctors (`/api/v1/doctors`)
- `GET /me`: Doctor profile.
- `GET /patients`: Assigned patient registry across NER states.
- `GET /patients/{id}`: Clinical patient details.
- `GET /patients/{id}/progress`: Multi-domain progress review.
- `GET /patients/{id}/trends`: Cognitive continuity trends.
- `GET /patients/{id}/notes`: Caregiver observation notes.
- `GET /patients/{id}/insights`: Preliminary AI-assisted insights (*strictly non-diagnostic*).
- `GET /patients/{id}/reports`: Comprehensive clinical PDF/JSON summary report.

### Cognitive Activities (`/api/v1/activities`)
- `GET /`: List all 6 cognitive activities.
- `GET /{id}`: Activity details and instructions.
- `POST /results`: Submit patient activity score and metrics.
- `GET /results`: Patient activity history.

### Memory Journal (`/api/v1/memories`)
- `GET /`: List patient memory journal items.
- `POST /`: Add memory with photo, people, and recall cues.
- `GET /{id}`: Single memory details.
- `PUT /{id}`: Update memory.
- `DELETE /{id}`: Remove memory.

### Reminders (`/api/v1/reminders`)
- `GET /`: List scheduled care reminders.
- `POST /`: Create reminder.
- `PUT /{id}`: Mark completed or verify by caregiver.
- `DELETE /{id}`: Delete reminder.

### Caregiver Daily Notes (`/api/v1/notes`)
- `GET /`: List observation notes for patient.
- `POST /`: Log note on mood, sleep hours, appetite, and behavior.

### Progress & Analytics (`/api/v1/progress`)
- `GET /summary`: Average score, accuracy, consistency streak, category breakdown.
- `GET /trends`: Multi-domain trends with non-diagnostic language.

### Cultural Content (`/api/v1/cultural`)
- `GET /`: Cultural items filtered by region, language, category.
- `GET /regions/all`: Metadata configuration for all 8 NER states and 12 languages.
- `GET /{id}`: Cultural item details.

### Offline Sync & 2-Day Alert (`/api/v1/sync`)
- `POST /push`: Ingest offline batched records (CREATE, UPDATE, DELETE).
- `GET /pull`: Retrieve delta updates from cloud.
- `GET /status`: Sync health check and 2-day overdue detection alert.

### System
- `GET /health`: Service and database health check.
- `GET /docs`: Interactive Swagger UI.
- `GET /redoc`: ReDoc API documentation.

---

## 5. Quick Start Instructions

### 1. Activate Environment & Run
```bash
cd backend
.venv\Scripts\activate
uvicorn app.main:app --reload --port 8000
```

### 2. Verify Health
Open in browser or curl:
```bash
curl http://localhost:8000/health
```

### 3. Open API Documentation
- Swagger UI: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`

### 4. Run Automated Tests
```bash
cd backend
.venv\Scripts\pytest.exe tests\test_api.py -v
```
