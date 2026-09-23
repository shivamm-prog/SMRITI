from typing import List, Optional
from datetime import datetime, timezone
from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.models.activity import Activity
from app.models.activity_result import ActivityResult
from app.schemas.activities import ActivityResponse, ActivityResultCreate, ActivityResultResponse


class ActivityService:
    @staticmethod
    def list_activities(db: Session) -> List[ActivityResponse]:
        activities = db.query(Activity).all()
        return [ActivityResponse.model_validate(a) for a in activities]

    @staticmethod
    def get_activity(db: Session, activity_id: str) -> ActivityResponse:
        activity = db.query(Activity).filter(Activity.id == activity_id).first()
        if not activity:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Activity '{activity_id}' not found.",
            )
        return ActivityResponse.model_validate(activity)

    @staticmethod
    def record_result(db: Session, patient_id: str, request: ActivityResultCreate) -> ActivityResultResponse:
        activity = db.query(Activity).filter(Activity.id == request.activity_id).first()
        if not activity:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Activity '{request.activity_id}' not found.",
            )

        completed_at = request.completed_at or datetime.now(timezone.utc)
        feedback = request.feedback or (
            "Splendid focus and memory!" if request.score >= 80 else "Warm and peaceful effort."
        )

        result = ActivityResult(
            patient_id=patient_id,
            activity_id=request.activity_id,
            score=request.score,
            accuracy=request.accuracy or 1.0,
            duration_seconds=request.duration_seconds or 120,
            difficulty=request.difficulty or "Gentle",
            completed_at=completed_at,
            feedback=feedback,
            raw_data=request.raw_data or {},
        )
        db.add(result)
        db.commit()
        db.refresh(result)

        return ActivityResultResponse(
            id=result.id,
            patient_id=result.patient_id,
            activity_id=result.activity_id,
            activity_title=activity.title,
            category=activity.category,
            score=result.score,
            accuracy=result.accuracy,
            duration_seconds=result.duration_seconds,
            difficulty=result.difficulty,
            completed_at=result.completed_at,
            feedback=result.feedback,
            raw_data=result.raw_data,
            created_at=result.created_at,
        )

    @staticmethod
    def list_patient_results(
        db: Session, patient_id: str, limit: int = 50
    ) -> List[ActivityResultResponse]:
        results = (
            db.query(ActivityResult)
            .filter(ActivityResult.patient_id == patient_id)
            .order_by(ActivityResult.completed_at.desc())
            .limit(limit)
            .all()
        )
        out = []
        for r in results:
            title = r.activity.title if r.activity else "Cognitive Activity"
            cat = r.activity.category if r.activity else "General"
            out.append(
                ActivityResultResponse(
                    id=r.id,
                    patient_id=r.patient_id,
                    activity_id=r.activity_id,
                    activity_title=title,
                    category=cat,
                    score=r.score,
                    accuracy=r.accuracy,
                    duration_seconds=r.duration_seconds,
                    difficulty=r.difficulty,
                    completed_at=r.completed_at,
                    feedback=r.feedback,
                    raw_data=r.raw_data,
                    created_at=r.created_at,
                )
            )
        return out
