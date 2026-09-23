from datetime import datetime
from typing import Optional, List, Dict, Any
from pydantic import BaseModel


class SyncRecordItem(BaseModel):
    entity_type: str  # 'reminders', 'memories', 'activity_results', 'notes'
    entity_id: str
    operation: str  # 'CREATE', 'UPDATE', 'DELETE'
    client_id: Optional[str] = None
    client_timestamp: Optional[datetime] = None
    payload: Dict[str, Any] = {}


class SyncPushRequest(BaseModel):
    client_id: Optional[str] = None
    patient_id: Optional[str] = None
    items: List[SyncRecordItem]


class SyncProcessedItem(BaseModel):
    entity_type: str
    entity_id: str
    status: str  # 'created', 'updated', 'deleted', 'conflict_resolved', 'ignored'
    server_id: Optional[str] = None
    message: Optional[str] = None


class SyncPushResponse(BaseModel):
    synced_count: int
    processed_items: List[SyncProcessedItem]
    synced_at: datetime


class SyncPullResponse(BaseModel):
    patient_id: str
    server_timestamp: datetime
    reminders: List[Dict[str, Any]]
    memories: List[Dict[str, Any]]
    activity_results: List[Dict[str, Any]]
    daily_notes: List[Dict[str, Any]]


class SyncStatusResponse(BaseModel):
    patient_id: str
    last_synced_at: Optional[datetime] = None
    sync_attention_required: bool
    days_since_last_sync: float
    alert_message: Optional[str] = None
    pending_queue_count: int = 0
