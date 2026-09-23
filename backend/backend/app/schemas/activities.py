from datetime import datetime
from typing import Optional, Dict, Any, List
from pydantic import BaseModel, ConfigDict


class ActivityResponse(BaseModel):
    id: str
    type: str
    title: str
    category: str
    difficulty: str
    estimated_minutes: str
    icon: str
    color: str
    description: Optional[str] = None
    instructions: Optional[str] = None
    config_data: Optional[Dict[str, Any]] = None

    model_config = ConfigDict(from_attributes=True)


class ActivityResultCreate(BaseModel):
    activity_id: str
    score: int
    accuracy: Optional[float] = 1.0
    duration_seconds: Optional[int] = 120
    difficulty: Optional[str] = "Gentle"
    completed_at: Optional[datetime] = None
    feedback: Optional[str] = None
    raw_data: Optional[Dict[str, Any]] = None


class ActivityResultResponse(BaseModel):
    id: str
    patient_id: str
    activity_id: str
    activity_title: Optional[str] = None
    category: Optional[str] = None
    score: int
    accuracy: float
    duration_seconds: int
    difficulty: str
    completed_at: datetime
    feedback: Optional[str] = None
    raw_data: Optional[Dict[str, Any]] = None
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)
