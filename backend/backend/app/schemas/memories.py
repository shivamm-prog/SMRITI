from datetime import datetime
from typing import Optional, List
from pydantic import BaseModel, ConfigDict


class MemoryCreate(BaseModel):
    title: str
    description: Optional[str] = None
    people: Optional[str] = None
    place: Optional[str] = None
    memory_date: Optional[str] = None
    photo_url: Optional[str] = None
    voice_note_url: Optional[str] = None
    tags: Optional[List[str]] = None
    recall_question: Optional[str] = None
    recall_answer: Optional[str] = None
    recall_hint: Optional[str] = None


class MemoryUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    people: Optional[str] = None
    place: Optional[str] = None
    memory_date: Optional[str] = None
    photo_url: Optional[str] = None
    voice_note_url: Optional[str] = None
    tags: Optional[List[str]] = None
    recall_question: Optional[str] = None
    recall_answer: Optional[str] = None
    recall_hint: Optional[str] = None


class MemoryResponse(BaseModel):
    id: str
    patient_id: str
    title: str
    description: Optional[str] = None
    people: Optional[str] = None
    place: Optional[str] = None
    memory_date: Optional[str] = None
    photo_url: Optional[str] = None
    voice_note_url: Optional[str] = None
    tags: Optional[List[str]] = None
    recall_question: Optional[str] = None
    recall_answer: Optional[str] = None
    recall_hint: Optional[str] = None
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)
