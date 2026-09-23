from typing import List
from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.schemas.common import ApiResponse
from app.schemas.activities import ActivityResponse, ActivityResultCreate, ActivityResultResponse
from app.services.activity_service import ActivityService
from app.api.deps import get_current_user, get_current_patient
from app.models.user import User, UserRole
from app.models.patient import Patient

router = APIRouter()


@router.get(
    "",
    response_model=ApiResponse[List[ActivityResponse]],
    summary="List all 6 cognitive activities available on MindSetu",
)
def list_activities(db: Session = Depends(get_db)):
    activities = ActivityService.list_activities(db)
    return ApiResponse(success=True, data=activities, message="Activities retrieved.")


@router.get(
    "/results",
    response_model=ApiResponse[List[ActivityResultResponse]],
    summary="Get recent activity results for current patient",
)
def get_activity_results(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    patient_id = None
    if current_user.role == UserRole.PATIENT:
        patient_id = current_user.patient_profile.id
    elif current_user.role == UserRole.CAREGIVER and current_user.caregiver_profile:
        patient_id = current_user.caregiver_profile.assigned_patient_id

    if not patient_id:
        patient = db.query(Patient).first()
        patient_id = patient.id if patient else ""

    results = ActivityService.list_patient_results(db, patient_id)
    return ApiResponse(success=True, data=results, message="Activity results retrieved.")


@router.get(
    "/{activity_id}",
    response_model=ApiResponse[ActivityResponse],
    summary="Get configuration and instructions for an activity",
)
def get_activity(activity_id: str, db: Session = Depends(get_db)):
    activity = ActivityService.get_activity(db, activity_id)
    return ApiResponse(success=True, data=activity, message="Activity retrieved.")


@router.post(
    "/results",
    response_model=ApiResponse[ActivityResultResponse],
    status_code=status.HTTP_201_CREATED,
    summary="Record cognitive activity session result",
)
def submit_activity_result(
    request: ActivityResultCreate,
    patient: Patient = Depends(get_current_patient),
    db: Session = Depends(get_db),
):
    result = ActivityService.record_result(db, patient.id, request)
    return ApiResponse(success=True, data=result, message="Activity result saved.")
