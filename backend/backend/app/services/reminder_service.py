from typing import List, Optional
from datetime import datetime, timezone
from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.models.reminder import Reminder
from app.schemas.reminders import ReminderCreate, ReminderUpdate, ReminderResponse


class ReminderService:
    @staticmethod
    def list_reminders(db: Session, patient_id: str) -> List[ReminderResponse]:
        reminders = (
            db.query(Reminder)
            .filter(Reminder.patient_id == patient_id)
            .order_by(Reminder.completed.asc(), Reminder.time_str.asc())
            .all()
        )
        return [ReminderResponse.model_validate(r) for r in reminders]

    @staticmethod
    def create_reminder(db: Session, patient_id: str, request: ReminderCreate) -> ReminderResponse:
        reminder = Reminder(
            patient_id=patient_id,
            title=request.title,
            category=request.category,
            time_str=request.time_str,
            scheduled_time=request.scheduled_time,
            instructions=request.instructions or "Follow scheduled routine gently.",
            recurring=request.recurring or "daily",
            completed=False,
            verified_by_caregiver=False,
        )
        db.add(reminder)
        db.commit()
        db.refresh(reminder)
        return ReminderResponse.model_validate(reminder)

    @staticmethod
    def update_reminder(db: Session, reminder_id: str, patient_id: Optional[str], request: ReminderUpdate) -> ReminderResponse:
        query = db.query(Reminder).filter(Reminder.id == reminder_id)
        if patient_id:
            query = query.filter(Reminder.patient_id == patient_id)

        reminder = query.first()
        if not reminder:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Reminder not found.")

        if request.title is not None:
            reminder.title = request.title
        if request.category is not None:
            reminder.category = request.category
        if request.time_str is not None:
            reminder.time_str = request.time_str
        if request.instructions is not None:
            reminder.instructions = request.instructions
        if request.completed is not None:
            reminder.completed = request.completed
            if request.completed and not reminder.completed_at:
                reminder.completed_at = datetime.now(timezone.utc)
            elif not request.completed:
                reminder.completed_at = None
        if request.verified_by_caregiver is not None:
            reminder.verified_by_caregiver = request.verified_by_caregiver

        db.commit()
        db.refresh(reminder)
        return ReminderResponse.model_validate(reminder)

    @staticmethod
    def delete_reminder(db: Session, reminder_id: str, patient_id: Optional[str]) -> bool:
        query = db.query(Reminder).filter(Reminder.id == reminder_id)
        if patient_id:
            query = query.filter(Reminder.patient_id == patient_id)

        reminder = query.first()
        if not reminder:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Reminder not found.")

        db.delete(reminder)
        db.commit()
        return True
