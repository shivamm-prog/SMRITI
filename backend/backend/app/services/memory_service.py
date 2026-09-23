from typing import List
from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.models.memory import Memory
from app.schemas.memories import MemoryCreate, MemoryUpdate, MemoryResponse


class MemoryService:
    @staticmethod
    def list_memories(db: Session, patient_id: str) -> List[MemoryResponse]:
        memories = (
            db.query(Memory)
            .filter(Memory.patient_id == patient_id)
            .order_by(Memory.created_at.desc())
            .all()
        )
        return [MemoryResponse.model_validate(m) for m in memories]

    @staticmethod
    def get_memory(db: Session, memory_id: str, patient_id: str) -> MemoryResponse:
        memory = (
            db.query(Memory)
            .filter(Memory.id == memory_id, Memory.patient_id == patient_id)
            .first()
        )
        if not memory:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Memory not found.")
        return MemoryResponse.model_validate(memory)

    @staticmethod
    def create_memory(db: Session, patient_id: str, request: MemoryCreate) -> MemoryResponse:
        memory = Memory(
            patient_id=patient_id,
            title=request.title,
            description=request.description,
            people=request.people,
            place=request.place,
            memory_date=request.memory_date or "Today",
            photo_url=request.photo_url or "🏡 ☕ 🌺",
            voice_note_url=request.voice_note_url,
            tags=request.tags or ["Family"],
            recall_question=request.recall_question or f"Who was with you during '{request.title}'?",
            recall_answer=request.recall_answer or request.people or "Family",
            recall_hint=request.recall_hint or "Look at your smiling family members.",
        )
        db.add(memory)
        db.commit()
        db.refresh(memory)
        return MemoryResponse.model_validate(memory)

    @staticmethod
    def update_memory(db: Session, memory_id: str, patient_id: str, request: MemoryUpdate) -> MemoryResponse:
        memory = (
            db.query(Memory)
            .filter(Memory.id == memory_id, Memory.patient_id == patient_id)
            .first()
        )
        if not memory:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Memory not found.")

        for key, value in request.model_dump(exclude_unset=True).items():
            if value is not None:
                setattr(memory, key, value)

        db.commit()
        db.refresh(memory)
        return MemoryResponse.model_validate(memory)

    @staticmethod
    def delete_memory(db: Session, memory_id: str, patient_id: str) -> bool:
        memory = (
            db.query(Memory)
            .filter(Memory.id == memory_id, Memory.patient_id == patient_id)
            .first()
        )
        if not memory:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Memory not found.")

        db.delete(memory)
        db.commit()
        return True
