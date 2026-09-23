from typing import List, Optional, Dict, Any
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.schemas.common import ApiResponse
from app.services.cultural_service import CulturalService

router = APIRouter()


@router.get(
    "",
    response_model=ApiResponse[List[Dict[str, Any]]],
    summary="List culturally relevant items for North Eastern states",
)
def list_cultural_content(
    region: Optional[str] = None,
    language: Optional[str] = None,
    category: Optional[str] = None,
    db: Session = Depends(get_db),
):
    items = CulturalService.list_content(db, region=region, language=language, category=category)
    return ApiResponse(success=True, data=items, message="Cultural content retrieved.")


@router.get(
    "/regions/all",
    response_model=ApiResponse[Dict[str, Any]],
    summary="Get configuration and metadata for all 8 North Eastern Region states",
)
def get_ner_regions_info():
    data = CulturalService.get_ner_regions()
    return ApiResponse(success=True, data=data, message="NER regions metadata retrieved.")


@router.get(
    "/{item_id}",
    response_model=ApiResponse[Dict[str, Any]],
    summary="Get single cultural item by ID",
)
def get_cultural_item(item_id: str, db: Session = Depends(get_db)):
    item = CulturalService.get_content_by_id(db, item_id)
    return ApiResponse(success=True, data=item, message="Cultural item retrieved.")
