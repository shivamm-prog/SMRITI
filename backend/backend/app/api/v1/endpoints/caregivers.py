from typing import List, Dict, Any
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.schemas.common import ApiResponse
from app.schemas.caregivers import CaregiverProfileResponse, ConnectedPatientSummary
from app.schemas.patients import PatientProfileResponse
from app.api.deps import require_role
from app.models.user import User, UserRole
from app.models.caregiver import Caregiver
from app.models.patient import Patient
from app.models.reminder import Reminder
from app.models.activity_result import ActivityResult
from app.models.daily_note import DailyNote
from app.services.patient_service import PatientService

router = APIRouter()


@router.get(
    "/me",
    response_model=ApiResponse[CaregiverProfileResponse],
    summary="Get caregiver profile for current user",
)
def get_my_caregiver_profile(
    current_user: User = Depends(require_role([UserRole.CAREGIVER])),
    db: Session = Depends(get_db),
):
    caregiver = db.query(Caregiver).filter(Caregiver.user_id == current_user.id).first()
    if not caregiver:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Caregiver profile not found.")
    return ApiResponse(success=True, data=CaregiverProfileResponse.model_validate(caregiver), message="Caregiver profile retrieved.")


@router.get(
    "/me/patients",
    response_model=ApiResponse[List[ConnectedPatientSummary]],
    summary="Get all connected patients authorized for this caregiver",
)
def get_connected_patients(
    current_user: User = Depends(require_role([UserRole.CAREGIVER])),
    db: Session = Depends(get_db),
):
    caregiver = db.query(Caregiver).filter(Caregiver.user_id == current_user.id).first()
    if not caregiver:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Caregiver profile not found.")

    # Find connected patients: either primary_caregiver_id matches or assigned_patient_id matches
    patients = (
        db.query(Patient)
        .filter((Patient.primary_caregiver_id == caregiver.id) | (Patient.id == caregiver.assigned_patient_id))
        .all()
    )

    summaries = []
    for p in patients:
        profile = PatientService.get_patient_profile(db, p.user_id)
        pending_reminders = db.query(Reminder).filter(Reminder.patient_id == p.id, Reminder.completed == False).count()
        today_acts = db.query(ActivityResult).filter(ActivityResult.patient_id == p.id).count()
        latest_note = db.query(DailyNote).filter(DailyNote.patient_id == p.id).order_by(DailyNote.created_at.desc()).first()

        note_dict = None
        if latest_note:
            note_dict = {
                "id": latest_note.id,
                "mood": latest_note.mood,
                "mood_emoji": latest_note.mood_emoji,
                "observations": latest_note.clinical_observations,
            }

        summaries.append(
            ConnectedPatientSummary(
                patient=profile,
                pending_reminders_count=pending_reminders,
                activities_completed_today=today_acts,
                latest_note=note_dict,
            )
        )

    return ApiResponse(success=True, data=summaries, message="Connected patients retrieved.")


from pydantic import BaseModel

class ConnectPatientRequest(BaseModel):
    patient_id: str


@router.post(
    "/connect",
    response_model=ApiResponse[Dict[str, Any]],
    summary="Connect caregiver to a patient using unique Patient ID (e.g. MS-ASSAM-001)",
)
def connect_to_patient(
    request: ConnectPatientRequest,
    current_user: User = Depends(require_role([UserRole.CAREGIVER])),
    db: Session = Depends(get_db),
):
    caregiver = db.query(Caregiver).filter(Caregiver.user_id == current_user.id).first()
    if not caregiver:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Caregiver profile not found.")

    clean_id = request.patient_id.strip()
    patient = db.query(Patient).filter(
        (Patient.patient_code == clean_id) |
        (Patient.id == clean_id) |
        (Patient.patient_code.ilike(clean_id))
    ).first()

    if not patient:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Patient with ID '{clean_id}' was not found. Please verify the Patient ID.",
        )

    # Establish link
    caregiver.assigned_patient_id = patient.id
    patient.primary_caregiver_id = caregiver.id
    db.commit()
    db.refresh(caregiver)
    db.refresh(patient)

    profile = PatientService.get_patient_profile(db, patient.user_id)
    return ApiResponse(
        success=True,
        data={
            "patient": profile.model_dump(),
            "patient_id": profile.patient_id,
            "patient_name": patient.name,
        },
        message=f"Successfully connected to {patient.name} ({profile.patient_id}).",
    )


@router.get(
    "/patients/{patient_id}",
    response_model=ApiResponse[Dict[str, Any]],
    summary="Get authorized patient details for caregiver",
)
def get_patient_details(
    patient_id: str,
    current_user: User = Depends(require_role([UserRole.CAREGIVER])),
    db: Session = Depends(get_db),
):
    caregiver = db.query(Caregiver).filter(Caregiver.user_id == current_user.id).first()
    if not caregiver:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Caregiver profile not found.")

    clean_id = patient_id.strip()
    patient = db.query(Patient).filter(
        (Patient.patient_code == clean_id) |
        (Patient.id == clean_id) |
        (Patient.patient_code.ilike(clean_id))
    ).first()

    if not patient:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Patient not found.")

    # RBAC check: Caregiver can only access connected/assigned patient
    if patient.primary_caregiver_id != caregiver.id and patient.id != caregiver.assigned_patient_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You are not authorized to view this patient's records.",
        )

    profile = PatientService.get_patient_profile(db, patient.user_id)
    reminders = db.query(Reminder).filter(Reminder.patient_id == patient.id).all()
    notes = db.query(DailyNote).filter(DailyNote.patient_id == patient.id).order_by(DailyNote.created_at.desc()).all()

    return ApiResponse(
        success=True,
        data={
            "patient": profile,
            "reminders": [
                {"id": r.id, "title": r.title, "time": r.time_str, "completed": r.completed, "verified": r.verified_by_caregiver}
                for r in reminders
            ],
            "notes": [
                {"id": n.id, "mood": n.mood, "sleep": n.sleep_quality, "observations": n.clinical_observations}
                for n in notes
            ],
        },
        message="Patient details retrieved.",
    )
