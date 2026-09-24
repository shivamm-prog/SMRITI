# SMRITI

## About SMRITI

SMRITI is an AI-assisted, offline-first cognitive health support platform designed for elderly dementia patients, caregivers, and healthcare professionals, with a focus on the language, cultural, and connectivity requirements of the North Eastern Region (NER) of India.

## Problem Statement

**SIH26003 – AI-Based Cognitive Gaming and Memory Assistance Platform for Elderly Dementia Patients in North Eastern Region (NER)**

The platform aims to provide accessible cognitive support through personalized activities, multilingual interaction, offline functionality, caregiver monitoring, and doctor-assisted insights.

## Key Features

- Personalized cognitive activities
- Adaptive difficulty based on performance
- Memory, attention, sequencing and matching activities
- Multilingual and culturally relevant content
- Offline-first functionality
- Local data storage and synchronization
- Patient ID based caregiver/doctor linking
- Caregiver monitoring and alerts
- Doctor progress, trends and reports
- Preliminary AI-assisted, non-diagnostic insights

## Technical Architecture

```text
Flutter App
     ↓
REST API
     ↓
FastAPI Backend
     ↓
PostgreSQL / Supabase
```

## Technology Stack

### Frontend
- Flutter
- Dart

### Backend
- Python
- FastAPI
- Uvicorn
- REST API

### Database
- SQLite
- PostgreSQL / Supabase

### AI / ML
- Personalization
- Adaptive Difficulty
- AI-assisted Preliminary Insights

### Security
- JWT Authentication
- bcrypt Password Hashing
- Role-Based Access Control (RBAC)

## User Roles

### Patient
- Cognitive activities
- Progress tracking
- Memories
- Reminders

### Caregiver
- Connect with patient using Patient ID
- Monitor patient progress
- View relevant alerts and observations

### Doctor
- Access authorized patient records
- View progress and trends
- Add notes
- Generate patient reports
- View preliminary AI-assisted insights

## Offline-First Approach

SMRITI is designed to continue functioning during poor or unavailable internet connectivity.

Activity results are stored locally and added to a synchronization queue. When connectivity is restored, the queued data is synchronized with the backend.

If successful synchronization has not occurred for more than 48 hours, the system can flag the situation for caregiver attention.

## AI / ML Approach

The personalization layer considers factors such as:

- Previous activity scores
- Accuracy
- Response time
- Activity category
- Difficulty level
- Recent performance trends

The current prototype demonstrates adaptive decision logic. A trained machine learning model can be introduced as sufficient real-world data becomes available.

SMRITI does **not** diagnose dementia. AI-generated insights are preliminary and non-diagnostic, while clinical decisions remain with healthcare professionals.

## Security

The platform uses:

- JWT-based authentication
- bcrypt password hashing
- Role-Based Access Control
- Backend-side authorization
- Patient-specific access control

Patient ID is an identifier for linking users to a patient record; it is not itself an authorization credential.

## Project Status

Prototype developed for **Smart India Hackathon 2026**.

**Problem Statement:** SIH26003  
**Organization:** Ministry of Development of North Eastern Region (MDoNER)
