from typing import Dict, Any, List
from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.models.patient import Patient
from app.models.reminder import Reminder
from app.models.activity import Activity
from app.models.activity_result import ActivityResult
from app.models.memory import Memory
from app.schemas.patients import PatientUpdateRequest, PatientProfileResponse, EmergencyContactSchema
from app.utils.helpers import get_time_greeting


class PatientService:
    @staticmethod
    def get_patient_profile(db: Session, user_id: str) -> PatientProfileResponse:
        patient = db.query(Patient).filter(Patient.user_id == user_id).first()
        if not patient:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Patient profile not found for this user.",
            )

        emergency = None
        if patient.emergency_contact_name or patient.emergency_contact_phone:
            emergency = EmergencyContactSchema(
                name=patient.emergency_contact_name,
                phone=patient.emergency_contact_phone,
                relation=patient.emergency_contact_relation,
            )

        display_code = patient.patient_code or f"MS-ASSAM-{patient.id[:4].upper()}"
        return PatientProfileResponse(
            id=patient.id,
            patient_id=display_code,
            patient_code=display_code,
            user_id=patient.user_id,
            name=patient.name,
            age=patient.age,
            dob=patient.dob,
            gender=patient.gender,
            region=patient.region,
            preferred_language=patient.preferred_language,
            cultural_preferences=patient.cultural_preferences or {},
            cognitive_stage=patient.cognitive_stage or "Mild Memory Support",
            emergency_contact=emergency,
            primary_caregiver_id=patient.primary_caregiver_id,
            primary_doctor_id=patient.primary_doctor_id,
            last_synced_at=patient.last_synced_at,
            sync_attention_required=patient.sync_attention_required,
            created_at=patient.created_at,
            updated_at=patient.updated_at,
        )

    @staticmethod
    def update_patient_profile(db: Session, user_id: str, request: PatientUpdateRequest) -> PatientProfileResponse:
        patient = db.query(Patient).filter(Patient.user_id == user_id).first()
        if not patient:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Patient profile not found.")

        if request.name is not None:
            patient.name = request.name
        if request.age is not None:
            patient.age = request.age
        if request.dob is not None:
            patient.dob = request.dob
        if request.gender is not None:
            patient.gender = request.gender
        if request.region is not None:
            patient.region = request.region
        if request.preferred_language is not None:
            patient.preferred_language = request.preferred_language
        if request.cultural_preferences is not None:
            patient.cultural_preferences = request.cultural_preferences
        if request.emergency_contact_name is not None:
            patient.emergency_contact_name = request.emergency_contact_name
        if request.emergency_contact_phone is not None:
            patient.emergency_contact_phone = request.emergency_contact_phone
        if request.emergency_contact_relation is not None:
            patient.emergency_contact_relation = request.emergency_contact_relation

        db.commit()
        db.refresh(patient)
        return PatientService.get_patient_profile(db, user_id)

    @staticmethod
    def get_dashboard_data(db: Session, user_id: str) -> Dict[str, Any]:
        patient_profile = PatientService.get_patient_profile(db, user_id)
        patient_id = patient_profile.id

        # 1. Today's reminders
        reminders = (
            db.query(Reminder)
            .filter(Reminder.patient_id == patient_id)
            .order_by(Reminder.completed.asc(), Reminder.created_at.asc())
            .limit(5)
            .all()
        )
        reminders_list = [
            {
                "id": r.id,
                "title": r.title,
                "category": r.category,
                "time": r.time_str,
                "completed": r.completed,
                "instructions": r.instructions,
            }
            for r in reminders
        ]

        # 2. Recommended activities
        activities = db.query(Activity).limit(3).all()
        activities_list = [
            {
                "id": a.id,
                "title": a.title,
                "category": a.category,
                "estimated_minutes": a.estimated_minutes,
                "icon": a.icon,
                "color": a.color,
                "description": a.description,
            }
            for a in activities
        ]

        # 3. Recent activity results
        recent_results = (
            db.query(ActivityResult)
            .filter(ActivityResult.patient_id == patient_id)
            .order_by(ActivityResult.completed_at.desc())
            .limit(3)
            .all()
        )
        results_list = [
            {
                "id": res.id,
                "activity_id": res.activity_id,
                "score": res.score,
                "feedback": res.feedback,
                "completed_at": res.completed_at.isoformat() if res.completed_at else None,
            }
            for res in recent_results
        ]

        # 4. Recent memories
        recent_memories = (
            db.query(Memory)
            .filter(Memory.patient_id == patient_id)
            .order_by(Memory.created_at.desc())
            .limit(2)
            .all()
        )
        memories_list = [
            {
                "id": m.id,
                "title": m.title,
                "date": m.memory_date,
                "location": m.place,
                "photo_url": m.photo_url,
            }
            for m in recent_memories
        ]

        # 5. Basic progress summary
        total_activities = db.query(ActivityResult).filter(ActivityResult.patient_id == patient_id).count()

        return {
            "patient": patient_profile,
            "greeting": f"{get_time_greeting()}, {patient_profile.name}",
            "todays_reminders": reminders_list,
            "recent_activities": activities_list,
            "recent_results": results_list,
            "recent_memories": memories_list,
            "progress_summary": {
                "total_completed": total_activities,
                "consistency_streak": 5,
                "trend_label": "Consistent & Gentle",
            },
        }
