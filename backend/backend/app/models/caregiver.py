import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, DateTime, ForeignKey
from sqlalchemy.orm import relationship as orm_relationship
from app.core.database import Base


def generate_uuid() -> str:
    return str(uuid.uuid4())


class Caregiver(Base):
    __tablename__ = "caregivers"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    user_id = Column(String(36), ForeignKey("users.id", ondelete="CASCADE"), unique=True, nullable=False)

    name = Column(String(255), nullable=False)
    phone = Column(String(50), nullable=True)
    relationship = Column(String(100), nullable=True, default="Family Caregiver")

    # Assigned / Connected Patient
    assigned_patient_id = Column(String(36), nullable=True)

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
    user = orm_relationship("User", back_populates="caregiver_profile")
    patients = orm_relationship("Patient", back_populates="caregiver", foreign_keys="Patient.primary_caregiver_id")
    daily_notes = orm_relationship("DailyNote", back_populates="caregiver", cascade="all, delete-orphan")
