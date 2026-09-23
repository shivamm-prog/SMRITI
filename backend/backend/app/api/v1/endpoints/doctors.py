from datetime import datetime, timezone
from typing import List, Dict, Any
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.schemas.common import ApiResponse
from app.schemas.doctors import DoctorProfileResponse, PatientReportResponse, ClinicalInsightResponse
from app.schemas.patients import PatientProfileResponse
from app.api.deps import require_role
from app.models.user import User, UserRole
from app.models.doctor import Doctor
from app.models.patient import Patient
from app.models.activity_result import ActivityResult
from app.models.reminder import Reminder
from app.models.daily_note import DailyNote
from app.services.patient_service import PatientService
from app.services.progress_service import ProgressService

router = APIRouter()


@router.get(
    "/me",
    response_model=ApiResponse[DoctorProfileResponse],
    summary="Get doctor profile for current user",
)
def get_my_doctor_profile(
    current_user: User = Depends(require_role([UserRole.DOCTOR])),
    db: Session = Depends(get_db),
):
    doctor = db.query(Doctor).filter(Doctor.user_id == current_user.id).first()
    if not doctor:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Doctor profile not found.")
    return ApiResponse(success=True, data=DoctorProfileResponse.model_validate(doctor), message="Doctor profile retrieved.")


@router.get(
    "/patients",
    response_model=ApiResponse[List[Dict[str, Any]]],
    summary="Get patient registry assigned to this doctor",
)
def get_assigned_patients(
    current_user: User = Depends(require_role([UserRole.DOCTOR])),
    db: Session = Depends(get_db),
):
    doctor = db.query(Doctor).filter(Doctor.user_id == current_user.id).first()
    if not doctor:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Doctor profile not found.")

    # Doctor can see all patients assigned to them, or all demo patients in system
    patients = db.query(Patient).filter((Patient.primary_doctor_id == doctor.id) | (Patient.primary_doctor_id == None)).all()

    registry = []
    for p in patients:
        profile = PatientService.get_patient_profile(db, p.user_id)
        reminders_total = db.query(Reminder).filter(Reminder.patient_id == p.id).count()
        reminders_done = db.query(Reminder).filter(Reminder.patient_id == p.id, Reminder.completed == True).count()
        adherence_pct = round((reminders_done / reminders_total * 100), 1) if reminders_total > 0 else 100.0

        registry.append({
            "patient": profile,
            "cognitive_trend": "Steady Continuity (95%)",
            "adherence_rate": f"{adherence_pct}%",
            "sync_attention_required": p.sync_attention_required,
        })

    return ApiResponse(success=True, data=registry, message="Doctor patient registry retrieved.")


from pydantic import BaseModel

class DoctorOpenPatientRequest(BaseModel):
    patient_id: str


@router.post(
    "/open_patient",
    response_model=ApiResponse[Dict[str, Any]],
    summary="Open patient by Patient ID (e.g. MS-ASSAM-001) for doctor",
)
def open_patient_by_id(
    request: DoctorOpenPatientRequest,
    current_user: User = Depends(require_role([UserRole.DOCTOR])),
    db: Session = Depends(get_db),
):
    doctor = db.query(Doctor).filter(Doctor.user_id == current_user.id).first()
    if not doctor:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Doctor profile not found.")

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

    # Link doctor to patient if not already linked
    if not patient.primary_doctor_id:
        patient.primary_doctor_id = doctor.id
        db.commit()

    profile = PatientService.get_patient_profile(db, patient.user_id)
    summary = ProgressService.get_summary(db, patient.id)
    notes = db.query(DailyNote).filter(DailyNote.patient_id == patient.id).order_by(DailyNote.created_at.desc()).limit(5).all()

    return ApiResponse(
        success=True,
        data={
            "patient": profile.model_dump(),
            "patient_id": profile.patient_id,
            "patient_code": profile.patient_code,
            "progress_summary": summary.model_dump() if hasattr(summary, "model_dump") else summary.dict(),
            "recent_notes": [
                {"id": n.id, "mood": n.mood, "sleep": n.sleep_quality, "observations": n.clinical_observations, "date": n.created_at.isoformat()}
                for n in notes
            ],
        },
        message=f"Patient {patient.name} ({profile.patient_id}) record opened.",
    )


@router.get(
    "/patients/{patient_id}",
    response_model=ApiResponse[Dict[str, Any]],
    summary="Get clinical details for assigned patient",
)
def get_doctor_patient_details(
    patient_id: str,
    current_user: User = Depends(require_role([UserRole.DOCTOR])),
    db: Session = Depends(get_db),
):
    clean_id = patient_id.strip()
    patient = db.query(Patient).filter(
        (Patient.patient_code == clean_id) |
        (Patient.id == clean_id) |
        (Patient.patient_code.ilike(clean_id))
    ).first()

    if not patient:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Patient not found.")

    profile = PatientService.get_patient_profile(db, patient.user_id)
    summary = ProgressService.get_summary(db, patient.id)
    notes = db.query(DailyNote).filter(DailyNote.patient_id == patient.id).order_by(DailyNote.created_at.desc()).limit(5).all()

    return ApiResponse(
        success=True,
        data={
            "patient": profile,
            "progress_summary": summary,
            "recent_notes": [
                {"id": n.id, "mood": n.mood, "sleep": n.sleep_quality, "observations": n.clinical_observations, "date": n.created_at.isoformat()}
                for n in notes
            ],
        },
        message="Patient clinical details retrieved.",
    )


@router.get(
    "/patients/{patient_id}/progress",
    response_model=ApiResponse[Dict[str, Any]],
    summary="Get patient progress for doctor review",
)
def get_patient_progress_for_doctor(
    patient_id: str,
    current_user: User = Depends(require_role([UserRole.DOCTOR])),
    db: Session = Depends(get_db),
):
    summary = ProgressService.get_summary(db, patient_id)
    return ApiResponse(success=True, data=summary.dict(), message="Patient progress retrieved.")


@router.get(
    "/patients/{patient_id}/trends",
    response_model=ApiResponse[Dict[str, Any]],
    summary="Get multi-domain cognitive trends",
)
def get_patient_trends_for_doctor(
    patient_id: str,
    current_user: User = Depends(require_role([UserRole.DOCTOR])),
    db: Session = Depends(get_db),
):
    trends = ProgressService.get_trends(db, patient_id)
    return ApiResponse(success=True, data=trends.dict(), message="Patient trends retrieved.")


@router.get(
    "/patients/{patient_id}/notes",
    response_model=ApiResponse[List[Dict[str, Any]]],
    summary="Get caregiver daily observation notes for patient",
)
def get_patient_caregiver_notes_for_doctor(
    patient_id: str,
    current_user: User = Depends(require_role([UserRole.DOCTOR])),
    db: Session = Depends(get_db),
):
    notes = db.query(DailyNote).filter(DailyNote.patient_id == patient_id).order_by(DailyNote.created_at.desc()).all()
    return ApiResponse(
        success=True,
        data=[
            {
                "id": n.id,
                "author": n.author_name,
                "mood": n.mood,
                "mood_emoji": n.mood_emoji,
                "sleep_quality": n.sleep_quality,
                "appetite": n.appetite,
                "behavior": n.behavioral_notes,
                "observations": n.clinical_observations,
                "date": n.created_at.isoformat(),
            }
            for n in notes
        ],
        message="Caregiver notes retrieved.",
    )


@router.get(
    "/patients/{patient_id}/insights",
    response_model=ApiResponse[List[ClinicalInsightResponse]],
    summary="Get AI-assisted preliminary cognitive insights (Non-Diagnostic)",
)
def get_patient_insights_for_doctor(
    patient_id: str,
    current_user: User = Depends(require_role([UserRole.DOCTOR])),
    db: Session = Depends(get_db),
):
    clean_id = patient_id.strip()
    patient = db.query(Patient).filter(
        (Patient.patient_code == clean_id) |
        (Patient.id == clean_id) |
        (Patient.patient_code.ilike(clean_id))
    ).first()
    if not patient:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Patient not found.")

    # Preliminary structured pattern recognition placeholders (NO live ML/Gemini)
    insights = [
        ClinicalInsightResponse(
            id=f"ins-1-{patient.id[:8]}",
            patient_id=patient.patient_code or patient.id,
            title="Consistent Procedural & Routine Sequencing",
            summary="Patient scores 95–100% on sequential daily life tasks (e.g. Making Morning Tea). Semantic connection to familiar regional items remains robust.",
            clinical_advice="Encourage continued participation in familiar daily kitchen & garden habits to preserve procedural independence.",
            severity="positive",
            badge="Consistent Routine",
            generated_at="Today, 06:00 AM",
            disclaimer="AI-assisted insight — final clinical decisions remain with the doctor.",
        ),
        ClinicalInsightResponse(
            id=f"ins-2-{patient.id[:8]}",
            patient_id=patient.patient_code or patient.id,
            title="Afternoon Attention Fluctuations Correlate with Nap Duration",
            summary="Slight increase in reaction time (avg +18s) during late afternoon activities on days when rest window is shorter than 30 minutes.",
            clinical_advice="Recommend caregiver maintains a quiet 30–45 minute afternoon rest window to sustain evening alertness.",
            severity="neutral",
            badge="Gentle Attention Note",
            generated_at="Yesterday, 07:00 PM",
            disclaimer="AI-assisted insight — final clinical decisions remain with the doctor.",
        ),
    ]

    return ApiResponse(success=True, data=insights, message="Clinical insights retrieved.")


@router.get(
    "/patients/{patient_id}/reports",
    response_model=ApiResponse[PatientReportResponse],
    summary="Generate comprehensive clinical summary report for patient",
)
def get_patient_report_for_doctor(
    patient_id: str,
    current_user: User = Depends(require_role([UserRole.DOCTOR])),
    db: Session = Depends(get_db),
):
    clean_id = patient_id.strip()
    patient = db.query(Patient).filter(
        (Patient.patient_code == clean_id) |
        (Patient.id == clean_id) |
        (Patient.patient_code.ilike(clean_id))
    ).first()
    if not patient:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Patient not found.")

    profile = PatientService.get_patient_profile(db, patient.user_id)
    results = db.query(ActivityResult).filter(ActivityResult.patient_id == patient_id).order_by(ActivityResult.completed_at.desc()).limit(10).all()
    notes = db.query(DailyNote).filter(DailyNote.patient_id == patient_id).order_by(DailyNote.created_at.desc()).limit(5).all()
    reminders = db.query(Reminder).filter(Reminder.patient_id == patient_id).all()

    completed_rems = sum(1 for r in reminders if r.completed)
    total_rems = len(reminders)
    adherence_pct = round((completed_rems / total_rems * 100), 1) if total_rems > 0 else 100.0

    report = PatientReportResponse(
        patient_summary=profile,
        activity_history=[
            {"activity_id": r.activity_id, "score": r.score, "accuracy": r.accuracy, "date": r.completed_at.isoformat()}
            for r in results
        ],
        cognitive_domain_trends={
            "Memory Recall": "96%",
            "Matching": "90%",
            "Routine Sequencing": "100%",
            "Visual Attention": "92%",
        },
        caregiver_notes=[
            {"mood": n.mood, "sleep": n.sleep_quality, "observations": n.clinical_observations, "date": n.created_at.isoformat()}
            for n in notes
        ],
        reminder_adherence={
            "total_reminders": total_rems,
            "completed": completed_rems,
            "adherence_percentage": f"{adherence_pct}%",
            "caregiver_verified_rate": "94%",
        },
        generated_at=datetime.now(timezone.utc),
    )

    return ApiResponse(success=True, data=report, message="Clinical report generated.")
