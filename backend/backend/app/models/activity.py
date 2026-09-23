from datetime import datetime, timezone
from sqlalchemy import Column, String, DateTime, JSON, Text
from sqlalchemy.orm import relationship
from app.core.database import Base


class Activity(Base):
    __tablename__ = "activities"

    id = Column(String(50), primary_key=True)  # e.g. 'act-memory-recall'
    type = Column(String(100), nullable=False)
    title = Column(String(255), nullable=False)
    category = Column(String(100), nullable=False)
    difficulty = Column(String(100), default="Gentle & Calming")
    estimated_minutes = Column(String(50), default="3–5 mins")
    icon = Column(String(50), default="Brain")
    color = Column(String(50), default="#2563EB")
    description = Column(Text, nullable=True)
    instructions = Column(Text, nullable=True)
    config_data = Column(JSON, nullable=True, default=dict)

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
    results = relationship("ActivityResult", back_populates="activity", cascade="all, delete-orphan")
