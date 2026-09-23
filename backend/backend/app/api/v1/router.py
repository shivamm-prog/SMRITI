from fastapi import APIRouter
from app.api.v1.endpoints import (
    auth,
    patients,
    caregivers,
    doctors,
    activities,
    memories,
    reminders,
    notes,
    progress,
    cultural,
    sync,
    voice,
)

api_router = APIRouter()

api_router.include_router(auth.router, prefix="/auth", tags=["Authentication"])
api_router.include_router(patients.router, prefix="/patients", tags=["Patients"])
api_router.include_router(caregivers.router, prefix="/caregivers", tags=["Caregivers"])
api_router.include_router(doctors.router, prefix="/doctors", tags=["Doctors"])
api_router.include_router(activities.router, prefix="/activities", tags=["Cognitive Activities"])
api_router.include_router(memories.router, prefix="/memories", tags=["Memory Journal"])
api_router.include_router(reminders.router, prefix="/reminders", tags=["Reminders"])
api_router.include_router(notes.router, prefix="/notes", tags=["Caregiver Daily Notes"])
api_router.include_router(progress.router, prefix="/progress", tags=["Progress & Analytics"])
api_router.include_router(cultural.router, prefix="/cultural", tags=["Cultural Content (NER)"])
api_router.include_router(sync.router, prefix="/sync", tags=["Offline-First Sync"])
api_router.include_router(voice.router, prefix="/voice", tags=["Voice Companion"])
