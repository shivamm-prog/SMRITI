from datetime import datetime
from typing import Optional, Dict, Any, List
from pydantic import BaseModel, ConfigDict


class EmergencyContactSchema(BaseModel):
    name: Optional[str] = None
    phone: Optional[str] = None
    relation: Optional[str] = None


class PatientProfileResponse(BaseModel):
    id: str
    patient_id: Optional[str] = None
    patient_code: Optional[str] = None
    user_id: str
    name: str
    age: Optional[int] = None
    dob: Optional[str] = None
    gender: Optional[str] = None
    region: str
    preferred_language: str
    cultural_preferences: Optional[Dict[str, Any]] = None
    cognitive_stage: Optional[str] = "Mild Memory Support"
    emergency_contact: Optional[EmergencyContactSchema] = None
    primary_caregiver_id: Optional[str] = None
    primary_doctor_id: Optional[str] = None
    last_synced_at: Optional[datetime] = None
    sync_attention_required: bool = False
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)


class PatientUpdateRequest(BaseModel):
    name: Optional[str] = None
    age: Optional[int] = None
    dob: Optional[str] = None
    gender: Optional[str] = None
    region: Optional[str] = None
    preferred_language: Optional[str] = None
    cultural_preferences: Optional[Dict[str, Any]] = None
    emergency_contact_name: Optional[str] = None
    emergency_contact_phone: Optional[str] = None
    emergency_contact_relation: Optional[str] = None


class PatientDashboardResponse(BaseModel):
    patient: PatientProfileResponse
    greeting: str
    todays_reminders: List[Dict[str, Any]]
    recent_activities: List[Dict[str, Any]]
    recent_results: List[Dict[str, Any]]
    recent_memories: List[Dict[str, Any]]
    progress_summary: Dict[str, Any]
