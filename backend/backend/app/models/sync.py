import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, DateTime, ForeignKey, JSON, Text, Boolean
from sqlalchemy.orm import relationship
from app.core.database import Base


def generate_uuid() -> str:
    return str(uuid.uuid4())


class SyncQueueItem(Base):
    __tablename__ = "sync_queue"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    patient_id = Column(String(36), ForeignKey("patients.id", ondelete="CASCADE"), nullable=False, index=True)

    entity_type = Column(String(100), nullable=False)  # e.g., 'reminders', 'memories', 'activity_results', 'notes'
    entity_id = Column(String(100), nullable=False)
    operation = Column(String(50), nullable=False)  # 'CREATE', 'UPDATE', 'DELETE'
    client_id = Column(String(100), nullable=True)
    payload = Column(JSON, nullable=True, default=dict)

    client_timestamp = Column(DateTime(timezone=True), nullable=True)
    server_timestamp = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False)
    status = Column(String(50), default="synced", nullable=False)  # 'synced', 'conflict_resolved', 'pending'

    # Relationships
    patient = relationship("Patient", back_populates="sync_items")


class ClientSyncState(Base):
    """Tracks each patient's latest synchronization timestamp for the 2-day sync alert."""
    __tablename__ = "client_sync_states"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    patient_id = Column(String(36), ForeignKey("patients.id", ondelete="CASCADE"), unique=True, nullable=False)

    last_synced_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False)
    sync_attention_required = Column(Boolean, default=False, nullable=False)
    alert_generated_at = Column(DateTime(timezone=True), nullable=True)
    alert_message = Column(Text, nullable=True)

    updated_at = Column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
        nullable=False,
    )
