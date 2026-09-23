from typing import Optional, Dict, Any, List
from pydantic import BaseModel, EmailStr, Field
from app.models.user import UserRole


class RegisterRequest(BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=6)
    full_name: str
    role: UserRole

    # Patient-specific fields (Required if role == PATIENT)
    age: Optional[int] = None
    dob: Optional[str] = None
    gender: Optional[str] = None
    region: Optional[str] = "assam"
    preferred_language: Optional[str] = "Assamese"
    cultural_preferences: Optional[Dict[str, Any]] = None

    # Emergency Contact (optional for patient)
    emergency_contact_name: Optional[str] = None
    emergency_contact_phone: Optional[str] = None
    emergency_contact_relation: Optional[str] = None

    # Caregiver-specific fields
    phone: Optional[str] = None
    relationship: Optional[str] = "Family Caregiver"
    assigned_patient_id: Optional[str] = None

    # Doctor-specific fields
    qualification: Optional[str] = None
    hospital: Optional[str] = None
    license_number: Optional[str] = None


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user_id: str
    email: str
    full_name: str
    role: UserRole
    patient_id: Optional[str] = None
    patient_code: Optional[str] = None
    caregiver_id: Optional[str] = None
    doctor_id: Optional[str] = None


class TokenPayload(BaseModel):
    sub: str
    role: str
    exp: Optional[int] = None
