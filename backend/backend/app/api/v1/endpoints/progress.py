from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.schemas.common import ApiResponse
from app.schemas.progress import ProgressSummaryResponse, ProgressTrendsResponse
from app.services.progress_service import ProgressService
from app.api.deps import get_current_user
from app.models.user import User, UserRole

router = APIRouter()


def _resolve_patient_id(current_user: User, requested_id: Optional[str]) -> str:
    if requested_id and current_user.role in [UserRole.DOCTOR, UserRole.CAREGIVER]:
        return requested_id
    if current_user.role == UserRole.PATIENT and current_user.patient_profile:
        return current_user.patient_profile.id
    elif current_user.role == UserRole.CAREGIVER and current_user.caregiver_profile:
        return current_user.caregiver_profile.assigned_patient_id
    raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="No patient context available.")


@router.get(
    "",
    response_model=ApiResponse[ProgressSummaryResponse],
    summary="Get non-diagnostic cognitive progress summary",
)
def get_progress(
    patient_id: Optional[str] = None,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    pid = _resolve_patient_id(current_user, patient_id)
    summary = ProgressService.get_summary(db, pid)
    return ApiResponse(success=True, data=summary, message="Progress summary retrieved.")


@router.get(
    "/summary",
    response_model=ApiResponse[ProgressSummaryResponse],
    summary="Get non-diagnostic cognitive progress summary",
)
def get_progress_summary(
    patient_id: Optional[str] = None,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    pid = _resolve_patient_id(current_user, patient_id)
    summary = ProgressService.get_summary(db, pid)
    return ApiResponse(success=True, data=summary, message="Progress summary retrieved.")


@router.get(
    "/trends",
    response_model=ApiResponse[ProgressTrendsResponse],
    summary="Get multi-domain cognitive consistency trends",
)
def get_progress_trends(
    patient_id: Optional[str] = None,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    pid = _resolve_patient_id(current_user, patient_id)
    trends = ProgressService.get_trends(db, pid)
    return ApiResponse(success=True, data=trends, message="Progress trends retrieved.")
