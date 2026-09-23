from typing import Optional, Dict, Any
from pydantic import BaseModel, Field


class VoiceChatRequest(BaseModel):
    query: str = Field(..., min_length=1, description="Patient transcribed or typed query")
    language: Optional[str] = Field("en", description="Patient selected language code (e.g., en, as, hi, ne)")
    region: Optional[str] = Field(None, description="Patient selected region (e.g., assam, sikkim)")
    context: Optional[Dict[str, Any]] = Field(default_factory=dict, description="Current screen or app context")


class VoiceChatResponse(BaseModel):
    transcript: str = Field(..., description="The query recognized or processed")
    response: str = Field(..., description="Short elderly-friendly answer in patient language")
    language: str = Field("en", description="Language of the response")
    intent: Optional[str] = Field(None, description="Recognized whitelisted action intent")
    success: bool = Field(True, description="Whether the request succeeded")


class VoiceTranscriptionResponse(BaseModel):
    transcript: str = Field(..., description="Transcribed text from speech")
    detected_language: Optional[str] = Field(None, description="Detected or provided language code")
    success: bool = Field(True, description="Whether the transcription succeeded")
