from typing import List
from fastapi import APIRouter, Depends, status, HTTPException
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.schemas.common import ApiResponse
from app.schemas.memories import MemoryCreate, MemoryUpdate, MemoryResponse
from app.services.memory_service import MemoryService
from app.api.deps import get_current_user
from app.models.user import User, UserRole

router = APIRouter()


def _resolve_patient_id(current_user: User) -> str:
    if current_user.role == UserRole.PATIENT and current_user.patient_profile:
        return current_user.patient_profile.id
    elif current_user.role == UserRole.CAREGIVER and current_user.caregiver_profile:
        return current_user.caregiver_profile.assigned_patient_id
    raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="No patient context available.")


@router.get(
    "",
    response_model=ApiResponse[List[MemoryResponse]],
    summary="List all memories in patient's memory journal",
)
def list_memories(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    patient_id = _resolve_patient_id(current_user)
    memories = MemoryService.list_memories(db, patient_id)
    return ApiResponse(success=True, data=memories, message="Memories retrieved.")


@router.post(
    "",
    response_model=ApiResponse[MemoryResponse],
    status_code=status.HTTP_201_CREATED,
    summary="Add a new family memory with photo and voice note metadata",
)
def create_memory(
    request: MemoryCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    patient_id = _resolve_patient_id(current_user)
    memory = MemoryService.create_memory(db, patient_id, request)
    return ApiResponse(success=True, data=memory, message="Memory created.")


@router.get(
    "/{memory_id}",
    response_model=ApiResponse[MemoryResponse],
    summary="Get single memory entry",
)
def get_memory(
    memory_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    patient_id = _resolve_patient_id(current_user)
    memory = MemoryService.get_memory(db, memory_id, patient_id)
    return ApiResponse(success=True, data=memory, message="Memory retrieved.")


@router.put(
    "/{memory_id}",
    response_model=ApiResponse[MemoryResponse],
    summary="Update an existing memory entry",
)
def update_memory(
    memory_id: str,
    request: MemoryUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    patient_id = _resolve_patient_id(current_user)
    updated = MemoryService.update_memory(db, memory_id, patient_id, request)
    return ApiResponse(success=True, data=updated, message="Memory updated.")


@router.delete(
    "/{memory_id}",
    response_model=ApiResponse[bool],
    summary="Delete a memory entry",
)
def delete_memory(
    memory_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    patient_id = _resolve_patient_id(current_user)
    MemoryService.delete_memory(db, memory_id, patient_id)
    return ApiResponse(success=True, data=True, message="Memory deleted.")
