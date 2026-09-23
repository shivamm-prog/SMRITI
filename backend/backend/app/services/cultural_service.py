from typing import List, Optional, Dict, Any
from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.models.cultural_content import CulturalContent
from app.utils.helpers import NER_REGIONS_DATA, ALL_SUPPORTED_LANGUAGES


class CulturalService:
    @staticmethod
    def list_content(
        db: Session,
        region: Optional[str] = None,
        language: Optional[str] = None,
        category: Optional[str] = None,
    ) -> List[Dict[str, Any]]:
        query = db.query(CulturalContent)
        if region:
            query = query.filter(CulturalContent.region == region.lower())
        if language:
            query = query.filter(CulturalContent.language == language)
        if category:
            query = query.filter(CulturalContent.category == category.lower())

        items = query.all()
        return [
            {
                "id": i.id,
                "region": i.region,
                "language": i.language,
                "category": i.category,
                "title": i.title,
                "content": i.content,
                "media_url": i.media_url,
                "difficulty": i.difficulty,
                "tags": i.tags,
                "cultural_metadata": i.cultural_metadata,
            }
            for i in items
        ]

    @staticmethod
    def get_content_by_id(db: Session, content_id: str) -> Dict[str, Any]:
        item = db.query(CulturalContent).filter(CulturalContent.id == content_id).first()
        if not item:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Cultural item not found.")
        return {
            "id": item.id,
            "region": item.region,
            "language": item.language,
            "category": item.category,
            "title": item.title,
            "content": item.content,
            "media_url": item.media_url,
            "difficulty": item.difficulty,
            "tags": item.tags,
            "cultural_metadata": item.cultural_metadata,
        }

    @staticmethod
    def get_ner_regions() -> Dict[str, Any]:
        return {
            "states": NER_REGIONS_DATA,
            "all_languages": ALL_SUPPORTED_LANGUAGES,
        }
