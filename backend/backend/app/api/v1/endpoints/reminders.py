from typing import List, Optional
from fastapi import APIRouter, Depends, status, HTTPException
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.schemas.common import ApiResponse
from app.schemas.reminders import ReminderCreate, ReminderUpdate, ReminderResponse
from app.services.reminder_service import ReminderService
from app.api.deps import get_current_user
from app.models.user import User, UserRole

router = APIRouter()


def _resolve_patient_id(current_user: User) -> str:
    if current_user.role == UserRole.PATIENT and current_user.patient_profile:
        return current_user.patient_profile.id
    elif current_user.role == UserRole.CAREGIVER and current_user.caregiver_profile:
        return current_user.caregiver_profile.assigned_patient_id
    raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="No patient context available.")


@router.get(
    "",
    response_model=ApiResponse[List[ReminderResponse]],
    summary="List patient reminders (medicines, meals, hydration, walks)",
)
def list_reminders(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    patient_id = _resolve_patient_id(current_user)
    reminders = ReminderService.list_reminders(db, patient_id)
    return ApiResponse(success=True, data=reminders, message="Reminders retrieved.")


@router.post(
    "",
    response_model=ApiResponse[ReminderResponse],
    status_code=status.HTTP_201_CREATED,
    summary="Create a new care reminder",
)
def create_reminder(
    request: ReminderCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    patient_id = _resolve_patient_id(current_user)
    reminder = ReminderService.create_reminder(db, patient_id, request)
    return ApiResponse(success=True, data=reminder, message="Reminder created.")


@router.put(
    "/{reminder_id}",
    response_model=ApiResponse[ReminderResponse],
    summary="Update reminder status, completion, or caregiver verification",
)
def update_reminder(
    reminder_id: str,
    request: ReminderUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    patient_id = _resolve_patient_id(current_user)
    updated = ReminderService.update_reminder(db, reminder_id, patient_id, request)
    return ApiResponse(success=True, data=updated, message="Reminder updated.")


@router.delete(
    "/{reminder_id}",
    response_model=ApiResponse[bool],
    summary="Delete a scheduled reminder",
)
def delete_reminder(
    reminder_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    patient_id = _resolve_patient_id(current_user)
    ReminderService.delete_reminder(db, reminder_id, patient_id)
    return ApiResponse(success=True, data=True, message="Reminder deleted.")
