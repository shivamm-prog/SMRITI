from typing import List, Optional
from fastapi import APIRouter, Depends, status, HTTPException
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.schemas.common import ApiResponse
from app.schemas.notes import DailyNoteCreate, DailyNoteResponse
from app.api.deps import get_current_user
from app.models.user import User, UserRole
from app.models.daily_note import DailyNote
from app.models.patient import Patient

router = APIRouter()


@router.post(
    "",
    response_model=ApiResponse[DailyNoteResponse],
    status_code=status.HTTP_201_CREATED,
    summary="Log a daily observation note on mood, sleep, appetite, and behavior",
)
def create_daily_note(
    request: DailyNoteCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    patient_id = request.patient_id
    caregiver_id = None

    if current_user.role == UserRole.CAREGIVER:
        caregiver_id = current_user.caregiver_profile.id if current_user.caregiver_profile else None
        if not patient_id and current_user.caregiver_profile:
            patient_id = current_user.caregiver_profile.assigned_patient_id
    elif current_user.role == UserRole.PATIENT:
        patient_id = current_user.patient_profile.id if current_user.patient_profile else None

    if not patient_id:
        patient = db.query(Patient).first()
        patient_id = patient.id if patient else None

    if not patient_id:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Target patient ID required.")

    note = DailyNote(
        patient_id=patient_id,
        caregiver_id=caregiver_id,
        author_name=current_user.full_name,
        mood=request.mood,
        mood_emoji=request.mood_emoji or "😊",
        sleep_quality=request.sleep_quality,
        appetite=request.appetite,
        behavioral_notes=request.behavioral_notes,
        clinical_observations=request.clinical_observations,
        note_date=request.note_date or "Today",
    )
    db.add(note)
    db.commit()
    db.refresh(note)

    return ApiResponse(
        success=True,
        data=DailyNoteResponse.model_validate(note),
        message="Daily observation note recorded.",
    )


@router.get(
    "",
    response_model=ApiResponse[List[DailyNoteResponse]],
    summary="List caregiver daily observation notes",
)
def list_daily_notes(
    patient_id: Optional[str] = None,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    target_id = patient_id
    if not target_id:
        if current_user.role == UserRole.PATIENT and current_user.patient_profile:
            target_id = current_user.patient_profile.id
        elif current_user.role == UserRole.CAREGIVER and current_user.caregiver_profile:
            target_id = current_user.caregiver_profile.assigned_patient_id

    query = db.query(DailyNote)
    if target_id:
        query = query.filter(DailyNote.patient_id == target_id)

    notes = query.order_by(DailyNote.created_at.desc()).all()
    return ApiResponse(
        success=True,
        data=[DailyNoteResponse.model_validate(n) for n in notes],
        message="Daily notes retrieved.",
    )
