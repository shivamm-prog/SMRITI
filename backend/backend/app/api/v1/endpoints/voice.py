from typing import Optional
from fastapi import APIRouter, Depends, UploadFile, File, Form, HTTPException, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.api.deps import get_current_user
from app.models.user import User, UserRole
from app.models.patient import Patient
from app.schemas.common import ApiResponse
from app.schemas.voice import VoiceChatRequest, VoiceChatResponse, VoiceTranscriptionResponse
from app.services.voice_service import VoiceService

router = APIRouter()


def _resolve_patient(current_user: User, db: Session) -> Optional[Patient]:
    if current_user.role == UserRole.PATIENT and current_user.patient_profile:
        return current_user.patient_profile
    elif current_user.role == UserRole.CAREGIVER and current_user.caregiver_profile:
        assigned_id = current_user.caregiver_profile.assigned_patient_id
        if assigned_id:
            return db.query(Patient).filter(Patient.id == assigned_id).first()
    return None


@router.post(
    "/chat",
    response_model=ApiResponse[VoiceChatResponse],
    summary="Query MindSetu Voice Companion with Groq and elderly care context",
)
async def voice_chat(
    request: VoiceChatRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    Process elderly voice/text query through Groq LLM with safety filters,
    multilingual region adaptation, minimal patient context, and local fallback.
    """
    patient = _resolve_patient(current_user, db)
    result = await VoiceService.chat(db, request, patient)
    return ApiResponse(
        success=result.success,
        data=result,
        message="Voice response generated successfully.",
    )


@router.post(
    "/transcribe",
    response_model=ApiResponse[VoiceTranscriptionResponse],
    summary="Transcribe elderly speech audio using Groq Whisper",
)
async def voice_transcribe(
    file: UploadFile = File(...),
    language: Optional[str] = Form(None),
    current_user: User = Depends(get_current_user),
):
    """
    Transcribe audio upload (wav/m4a/mp3/webm) using Groq whisper-large-v3-turbo.
    """
    try:
        audio_bytes = await file.read()
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Could not read audio file: {str(e)}",
        )

    if not audio_bytes or len(audio_bytes) == 0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Uploaded audio file is empty.",
        )

    try:
        result = await VoiceService.transcribe(
            audio_bytes=audio_bytes,
            filename=file.filename or "audio.wav",
            content_type=file.content_type or "audio/wav",
            language=language,
        )
    except ValueError as ve:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(ve),
        )

    return ApiResponse(
        success=result.success,
        data=result,
        message="Audio transcribed." if result.success else "Transcription unavailable; fallback to local.",
    )
