from datetime import datetime
from typing import Optional, List, Dict, Any
from pydantic import BaseModel, ConfigDict
from app.schemas.patients import PatientProfileResponse


class DoctorProfileResponse(BaseModel):
    id: str
    user_id: str
    name: str
    qualification: Optional[str] = None
    hospital: Optional[str] = None
    license_number: Optional[str] = None
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)


class ClinicalInsightResponse(BaseModel):
    id: str
    patient_id: str
    title: str
    summary: str
    clinical_advice: str
    severity: str = "positive"  # 'positive', 'neutral', 'attention'
    badge: str
    generated_at: str
    disclaimer: str = "AI-assisted insight — final clinical decisions remain with the doctor."


class PatientReportResponse(BaseModel):
    patient_summary: PatientProfileResponse
    activity_history: List[Dict[str, Any]]
    cognitive_domain_trends: Dict[str, Any]
    caregiver_notes: List[Dict[str, Any]]
    reminder_adherence: Dict[str, Any]
    generated_at: datetime
    disclaimer: str = "MindSetu supportive tele-monitoring report. Not a formal psychiatric diagnosis."
