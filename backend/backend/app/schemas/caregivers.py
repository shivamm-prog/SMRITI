from datetime import datetime
from typing import Optional, List, Dict, Any
from pydantic import BaseModel, ConfigDict
from app.schemas.patients import PatientProfileResponse


class CaregiverProfileResponse(BaseModel):
    id: str
    user_id: str
    name: str
    phone: Optional[str] = None
    relationship: Optional[str] = "Family Caregiver"
    assigned_patient_id: Optional[str] = None
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)


class ConnectedPatientSummary(BaseModel):
    patient: PatientProfileResponse
    pending_reminders_count: int
    activities_completed_today: int
    latest_note: Optional[Dict[str, Any]] = None
