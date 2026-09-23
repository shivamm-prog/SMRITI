import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, DateTime, ForeignKey, Text
from sqlalchemy.orm import relationship
from app.core.database import Base


def generate_uuid() -> str:
    return str(uuid.uuid4())


class DailyNote(Base):
    __tablename__ = "daily_notes"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    patient_id = Column(String(36), ForeignKey("patients.id", ondelete="CASCADE"), nullable=False, index=True)
    caregiver_id = Column(String(36), ForeignKey("caregivers.id", ondelete="SET NULL"), nullable=True, index=True)

    author_name = Column(String(255), nullable=False, default="Family Caregiver")
    mood = Column(String(100), nullable=False, default="Calm & Happy")
    mood_emoji = Column(String(10), default="😊")
    sleep_quality = Column(String(255), nullable=True)
    appetite = Column(String(255), nullable=True)
    behavioral_notes = Column(Text, nullable=True)
    clinical_observations = Column(Text, nullable=True)
    note_date = Column(String(100), nullable=True)

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
    patient = relationship("Patient", back_populates="daily_notes")
    caregiver = relationship("Caregiver", back_populates="daily_notes")
