import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, Integer, Float, DateTime, ForeignKey, JSON, Text
from sqlalchemy.orm import relationship
from app.core.database import Base


def generate_uuid() -> str:
    return str(uuid.uuid4())


class ActivityResult(Base):
    __tablename__ = "activity_results"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    patient_id = Column(String(36), ForeignKey("patients.id", ondelete="CASCADE"), nullable=False, index=True)
    activity_id = Column(String(50), ForeignKey("activities.id", ondelete="CASCADE"), nullable=False, index=True)

    score = Column(Integer, nullable=False, default=100)
    accuracy = Column(Float, nullable=False, default=1.0)
    duration_seconds = Column(Integer, nullable=False, default=120)
    difficulty = Column(String(50), default="Gentle")
    completed_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    feedback = Column(Text, nullable=True)
    raw_data = Column(JSON, nullable=True, default=dict)

    created_at = Column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        nullable=False,
    )

    # Relationships
    patient = relationship("Patient", back_populates="activity_results")
    activity = relationship("Activity", back_populates="results")
