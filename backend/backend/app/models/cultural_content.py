import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, DateTime, JSON, Text
from app.core.database import Base


def generate_uuid() -> str:
    return str(uuid.uuid4())


class CulturalContent(Base):
    __tablename__ = "cultural_content"

    id = Column(String(36), primary_key=True, default=generate_uuid)
    region = Column(String(100), nullable=False, index=True)
    language = Column(String(100), nullable=False, default="English", index=True)
    category = Column(String(100), nullable=False, index=True)
    title = Column(String(255), nullable=False)
    content = Column(Text, nullable=False)
    media_url = Column(Text, nullable=True)
    difficulty = Column(String(50), default="Gentle")
    tags = Column(JSON, nullable=True, default=list)
    cultural_metadata = Column(JSON, nullable=True, default=dict)

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
