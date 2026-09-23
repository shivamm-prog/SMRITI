import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, DateTime, ForeignKey, JSON, Text
from sqlalchemy.orm import relationship
from app.core.database import Base


def generate_uuid() -> str:
    return str(uuid.uuid4())


class Memory(Base):
    __tablename__ = "memories"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    patient_id = Column(String(36), ForeignKey("patients.id", ondelete="CASCADE"), nullable=False, index=True)

    title = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    people = Column(String(255), nullable=True)
    place = Column(String(255), nullable=True)
    memory_date = Column(String(100), nullable=True)
    photo_url = Column(Text, nullable=True)
    voice_note_url = Column(Text, nullable=True)
    tags = Column(JSON, nullable=True, default=list)

    # For personalized Memory Recall
    recall_question = Column(String(255), nullable=True)
    recall_answer = Column(String(255), nullable=True)
    recall_hint = Column(String(255), nullable=True)

    created_at = Column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        nullable=False,
    )
    updated_at = Column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
        nullable=False,
    )

    # Relationships
    patient = relationship("Patient", back_populates="memories")
