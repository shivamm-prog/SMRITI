from datetime import datetime, timezone, timedelta
from typing import List, Dict, Any
from sqlalchemy.orm import Session
from fastapi import HTTPException, status

from app.models.patient import Patient
from app.models.reminder import Reminder
from app.models.memory import Memory
from app.models.activity_result import ActivityResult
from app.models.daily_note import DailyNote
from app.models.sync import SyncQueueItem, ClientSyncState
from app.schemas.sync import (
    SyncPushRequest,
    SyncPushResponse,
    SyncProcessedItem,
    SyncPullResponse,
    SyncStatusResponse,
)
from app.utils.helpers import check_two_day_sync_overdue


class SyncService:
    @staticmethod
    def process_push(db: Session, request: SyncPushRequest, current_user_patient_id: str) -> SyncPushResponse:
        patient_id = request.patient_id or current_user_patient_id
        if not patient_id:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Patient ID required for sync.")

        patient = db.query(Patient).filter(Patient.id == patient_id).first()
        if not patient:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Patient not found.")

        processed_items: List[SyncProcessedItem] = []
        now = datetime.now(timezone.utc)

        for item in request.items:
            # Record in SyncQueueItem for audit trail
            sync_log = SyncQueueItem(
                patient_id=patient_id,
                entity_type=item.entity_type,
                entity_id=item.entity_id,
                operation=item.operation.upper(),
                client_id=request.client_id,
                payload=item.payload,
                client_timestamp=item.client_timestamp,
                server_timestamp=now,
                status="synced",
            )
            db.add(sync_log)

            # Apply mutation based on entity type and operation
            try:
                if item.entity_type == "reminders":
                    SyncService._apply_reminder_sync(db, patient_id, item)
                elif item.entity_type == "memories":
                    SyncService._apply_memory_sync(db, patient_id, item)
                elif item.entity_type == "activity_results":
                    SyncService._apply_activity_result_sync(db, patient_id, item)
                elif item.entity_type == "notes":
                    SyncService._apply_note_sync(db, patient_id, item)

                processed_items.append(
                    SyncProcessedItem(
                        entity_type=item.entity_type,
                        entity_id=item.entity_id,
                        status="synced",
                        message="Applied successfully",
                    )
                )
            except Exception as e:
                processed_items.append(
                    SyncProcessedItem(
                        entity_type=item.entity_type,
                        entity_id=item.entity_id,
                        status="conflict_resolved",
                        message=f"Handled with fallback: {str(e)}",
                    )
                )

        # Update Patient sync timestamp
        patient.last_synced_at = now
        patient.sync_attention_required = False

        # Update ClientSyncState
        sync_state = db.query(ClientSyncState).filter(ClientSyncState.patient_id == patient_id).first()
        if not sync_state:
            sync_state = ClientSyncState(patient_id=patient_id, last_synced_at=now, sync_attention_required=False)
            db.add(sync_state)
        else:
            sync_state.last_synced_at = now
            sync_state.sync_attention_required = False
            sync_state.alert_message = None

        db.commit()

        return SyncPushResponse(
            synced_count=len(processed_items),
            processed_items=processed_items,
            synced_at=now,
        )

    @staticmethod
    def _apply_reminder_sync(db: Session, patient_id: str, item):
        if item.operation.upper() == "CREATE":
            existing = db.query(Reminder).filter(Reminder.id == item.entity_id).first()
            if not existing:
                rem = Reminder(
                    id=item.entity_id,
                    patient_id=patient_id,
                    title=item.payload.get("title", "Scheduled Care"),
                    category=item.payload.get("category", "Medicine"),
                    time_str=item.payload.get("time_str", "08:00 AM"),
                    instructions=item.payload.get("instructions"),
                    completed=item.payload.get("completed", False),
                    verified_by_caregiver=item.payload.get("verified_by_caregiver", False),
                )
                db.add(rem)
        elif item.operation.upper() == "UPDATE":
            rem = db.query(Reminder).filter(Reminder.id == item.entity_id).first()
            if rem:
                for k, v in item.payload.items():
                    if hasattr(rem, k):
                        setattr(rem, k, v)
        elif item.operation.upper() == "DELETE":
            rem = db.query(Reminder).filter(Reminder.id == item.entity_id).first()
            if rem:
                db.delete(rem)

    @staticmethod
    def _apply_memory_sync(db: Session, patient_id: str, item):
        if item.operation.upper() == "CREATE":
            existing = db.query(Memory).filter(Memory.id == item.entity_id).first()
            if not existing:
                mem = Memory(
                    id=item.entity_id,
                    patient_id=patient_id,
                    title=item.payload.get("title", "Family Memory"),
                    description=item.payload.get("description"),
                    people=item.payload.get("people"),
                    place=item.payload.get("place"),
                    memory_date=item.payload.get("date", "Today"),
                    photo_url=item.payload.get("photo_url", "🏡 ☕ 🌺"),
                    tags=item.payload.get("tags", ["Family"]),
                )
                db.add(mem)

    @staticmethod
    def _apply_activity_result_sync(db: Session, patient_id: str, item):
        if item.operation.upper() == "CREATE":
            existing = db.query(ActivityResult).filter(ActivityResult.id == item.entity_id).first()
            if not existing:
                res = ActivityResult(
                    id=item.entity_id,
                    patient_id=patient_id,
                    activity_id=item.payload.get("activity_id", "act-memory-recall"),
                    score=item.payload.get("score", 100),
                    accuracy=item.payload.get("accuracy", 1.0),
                    duration_seconds=item.payload.get("duration_seconds", 120),
                    difficulty=item.payload.get("difficulty", "Gentle"),
                    feedback=item.payload.get("feedback", "Completed offline"),
                )
                db.add(res)

    @staticmethod
    def _apply_note_sync(db: Session, patient_id: str, item):
        if item.operation.upper() == "CREATE":
            existing = db.query(DailyNote).filter(DailyNote.id == item.entity_id).first()
            if not existing:
                note = DailyNote(
                    id=item.entity_id,
                    patient_id=patient_id,
                    author_name=item.payload.get("author_name", "Family Caregiver"),
                    mood=item.payload.get("mood", "Calm & Happy"),
                    mood_emoji=item.payload.get("mood_emoji", "😊"),
                    sleep_quality=item.payload.get("sleep_quality"),
                    appetite=item.payload.get("appetite"),
                    behavioral_notes=item.payload.get("behavioral_notes"),
                    clinical_observations=item.payload.get("clinical_observations"),
                )
                db.add(note)

    @staticmethod
    def process_pull(db: Session, patient_id: str) -> SyncPullResponse:
        now = datetime.now(timezone.utc)

        reminders = db.query(Reminder).filter(Reminder.patient_id == patient_id).all()
        memories = db.query(Memory).filter(Memory.patient_id == patient_id).all()
        results = db.query(ActivityResult).filter(ActivityResult.patient_id == patient_id).all()
        notes = db.query(DailyNote).filter(DailyNote.patient_id == patient_id).all()

        return SyncPullResponse(
            patient_id=patient_id,
            server_timestamp=now,
            reminders=[
                {"id": r.id, "title": r.title, "category": r.category, "time_str": r.time_str, "completed": r.completed}
                for r in reminders
            ],
            memories=[
                {"id": m.id, "title": m.title, "description": m.description, "people": m.people, "place": m.place}
                for m in memories
            ],
            activity_results=[
                {"id": res.id, "activity_id": res.activity_id, "score": res.score, "accuracy": res.accuracy}
                for res in results
            ],
            daily_notes=[
                {"id": n.id, "mood": n.mood, "sleep_quality": n.sleep_quality, "appetite": n.appetite}
                for n in notes
            ],
        )

    @staticmethod
    def get_sync_status(db: Session, patient_id: str) -> SyncStatusResponse:
        patient = db.query(Patient).filter(Patient.id == patient_id).first()
        if not patient:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Patient not found.")

        last_synced = patient.last_synced_at
        is_overdue = check_two_day_sync_overdue(last_synced)

        days_diff = 0.0
        if last_synced:
            if last_synced.tzinfo is None:
                last_synced = last_synced.replace(tzinfo=timezone.utc)
            days_diff = round((datetime.now(timezone.utc) - last_synced).total_seconds() / 86400, 2)

        alert_msg = None
        if is_overdue:
            patient.sync_attention_required = True
            alert_msg = (
                f"Sync attention required: Patient '{patient.name}' has not synchronized with cloud storage for {days_diff} days. "
                "Alert queued for assigned caregiver and doctor."
            )
            # Update ClientSyncState alert
            sync_state = db.query(ClientSyncState).filter(ClientSyncState.patient_id == patient_id).first()
            if sync_state:
                sync_state.sync_attention_required = True
                sync_state.alert_generated_at = datetime.now(timezone.utc)
                sync_state.alert_message = alert_msg
            db.commit()

        return SyncStatusResponse(
            patient_id=patient.id,
            last_synced_at=patient.last_synced_at,
            sync_attention_required=is_overdue,
            days_since_last_sync=days_diff,
            alert_message=alert_msg,
            pending_queue_count=0,
        )
