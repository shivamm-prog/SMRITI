from typing import Optional
from fastapi import APIRouter, Depends, status, HTTPException
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.schemas.common import ApiResponse
from app.schemas.sync import SyncPushRequest, SyncPushResponse, SyncPullResponse, SyncStatusResponse
from app.services.sync_service import SyncService
from app.api.deps import get_current_user
from app.models.user import User, UserRole

router = APIRouter()


def _resolve_patient_id(current_user: User, requested_id: Optional[str]) -> str:
    if requested_id:
        return requested_id
    if current_user.role == UserRole.PATIENT and current_user.patient_profile:
        return current_user.patient_profile.id
    elif current_user.role == UserRole.CAREGIVER and current_user.caregiver_profile:
        return current_user.caregiver_profile.assigned_patient_id
    raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="No patient context available for sync.")


@router.post(
    "/push",
    response_model=ApiResponse[SyncPushResponse],
    summary="Push offline created/updated/deleted records to server",
)
def sync_push(
    request: SyncPushRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    pid = _resolve_patient_id(current_user, request.patient_id)
    result = SyncService.process_push(db, request, pid)
    return ApiResponse(success=True, data=result, message=f"Synchronized {result.synced_count} items successfully.")


@router.get(
    "/pull",
    response_model=ApiResponse[SyncPullResponse],
    summary="Pull latest cloud state for offline storage",
)
def sync_pull(
    patient_id: Optional[str] = None,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    pid = _resolve_patient_id(current_user, patient_id)
    result = SyncService.process_pull(db, pid)
    return ApiResponse(success=True, data=result, message="Pulled latest records from server.")


@router.get(
    "/status",
    response_model=ApiResponse[SyncStatusResponse],
    summary="Check patient sync health and 2-day sync overdue alert status",
)
def sync_status(
    patient_id: Optional[str] = None,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    pid = _resolve_patient_id(current_user, patient_id)
    result = SyncService.get_sync_status(db, pid)
    return ApiResponse(success=True, data=result, message="Sync status evaluated.")
