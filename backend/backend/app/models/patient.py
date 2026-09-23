import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, Integer, Boolean, DateTime, ForeignKey, JSON, Text
from sqlalchemy.orm import relationship
from app.core.database import Base


def generate_uuid() -> str:
    return str(uuid.uuid4())


class Patient(Base):
    __tablename__ = "patients"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    user_id = Column(String(36), ForeignKey("users.id", ondelete="CASCADE"), unique=True, nullable=False)
    patient_code = Column(String(50), unique=True, index=True, nullable=True)

    name = Column(String(255), nullable=False)
    age = Column(Integer, nullable=True)
    dob = Column(String(50), nullable=True)
    gender = Column(String(50), nullable=True)
    region = Column(String(100), nullable=False, default="assam")
    preferred_language = Column(String(100), nullable=False, default="Assamese")
    cultural_preferences = Column(JSON, nullable=True, default=dict)
    cognitive_stage = Column(String(100), default="Mild Memory Support")

    # Emergency Contact
    emergency_contact_name = Column(String(255), nullable=True)
    emergency_contact_phone = Column(String(50), nullable=True)
    emergency_contact_relation = Column(String(100), nullable=True)

    # Connections
    primary_caregiver_id = Column(String(36), ForeignKey("caregivers.id", ondelete="SET NULL"), nullable=True)
    primary_doctor_id = Column(String(36), ForeignKey("doctors.id", ondelete="SET NULL"), nullable=True)

    # Offline Sync & Health Tracking
    last_synced_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    sync_attention_required = Column(Boolean, default=False)

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
    user = relationship("User", back_populates="patient_profile")
    caregiver = relationship("Caregiver", back_populates="patients", foreign_keys=[primary_caregiver_id])
    doctor = relationship("Doctor", back_populates="patients", foreign_keys=[primary_doctor_id])

    activity_results = relationship("ActivityResult", back_populates="patient", cascade="all, delete-orphan")
    memories = relationship("Memory", back_populates="patient", cascade="all, delete-orphan")
    reminders = relationship("Reminder", back_populates="patient", cascade="all, delete-orphan")
    daily_notes = relationship("DailyNote", back_populates="patient", cascade="all, delete-orphan")
    sync_items = relationship("SyncQueueItem", back_populates="patient", cascade="all, delete-orphan")
