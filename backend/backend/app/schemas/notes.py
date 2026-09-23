from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict


class DailyNoteCreate(BaseModel):
    patient_id: Optional[str] = None
    mood: str = "Calm & Happy"
    mood_emoji: Optional[str] = "😊"
    sleep_quality: Optional[str] = None
    appetite: Optional[str] = None
    behavioral_notes: Optional[str] = None
    clinical_observations: Optional[str] = None
    note_date: Optional[str] = None


class DailyNoteResponse(BaseModel):
    id: str
    patient_id: str
    caregiver_id: Optional[str] = None
    author_name: str
    mood: str
    mood_emoji: str
    sleep_quality: Optional[str] = None
    appetite: Optional[str] = None
    behavioral_notes: Optional[str] = None
    clinical_observations: Optional[str] = None
    note_date: Optional[str] = None
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)
