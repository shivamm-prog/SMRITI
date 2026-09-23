from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.schemas.common import ApiResponse
from app.schemas.patients import PatientProfileResponse, PatientUpdateRequest, PatientDashboardResponse
from app.services.patient_service import PatientService
from app.api.deps import require_role
from app.models.user import User, UserRole

router = APIRouter()


@router.get(
    "/me",
    response_model=ApiResponse[PatientProfileResponse],
    summary="Get patient profile for current authenticated user",
)
def get_my_profile(
    current_user: User = Depends(require_role([UserRole.PATIENT])),
    db: Session = Depends(get_db),
):
    profile = PatientService.get_patient_profile(db, current_user.id)
    return ApiResponse(success=True, data=profile, message="Patient profile retrieved.")


@router.put(
    "/me",
    response_model=ApiResponse[PatientProfileResponse],
    summary="Update patient profile (region, language, preferences, emergency contacts)",
)
def update_my_profile(
    request: PatientUpdateRequest,
    current_user: User = Depends(require_role([UserRole.PATIENT])),
    db: Session = Depends(get_db),
):
    updated = PatientService.update_patient_profile(db, current_user.id, request)
    return ApiResponse(success=True, data=updated, message="Patient profile updated.")


@router.get(
    "/me/dashboard",
    response_model=ApiResponse[PatientDashboardResponse],
    summary="Get patient dashboard (today's care, activities, memories, progress)",
)
def get_my_dashboard(
    current_user: User = Depends(require_role([UserRole.PATIENT])),
    db: Session = Depends(get_db),
):
    dashboard_data = PatientService.get_dashboard_data(db, current_user.id)
    return ApiResponse(success=True, data=dashboard_data, message="Dashboard data retrieved.")
