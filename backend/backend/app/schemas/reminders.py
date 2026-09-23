from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict


class ReminderCreate(BaseModel):
    title: str
    category: str = "Medicine"
    time_str: str = "08:00 AM"
    scheduled_time: Optional[datetime] = None
    instructions: Optional[str] = None
    recurring: Optional[str] = "daily"


class ReminderUpdate(BaseModel):
    title: Optional[str] = None
    category: Optional[str] = None
    time_str: Optional[str] = None
    scheduled_time: Optional[datetime] = None
    instructions: Optional[str] = None
    completed: Optional[bool] = None
    completed_at: Optional[datetime] = None
    verified_by_caregiver: Optional[bool] = None


class ReminderResponse(BaseModel):
    id: str
    patient_id: str
    title: str
    category: str
    time_str: str
    scheduled_time: Optional[datetime] = None
    instructions: Optional[str] = None
    recurring: str
    completed: bool
    completed_at: Optional[datetime] = None
    verified_by_caregiver: bool
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)
