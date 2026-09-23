"""Pydantic Schemas package for MindSetu."""
from app.schemas.common import ApiResponse, ErrorResponse
from app.schemas.auth import RegisterRequest, LoginRequest, TokenResponse, TokenPayload
from app.schemas.users import UserResponse, UserUpdate
from app.schemas.patients import PatientProfileResponse, PatientUpdateRequest, PatientDashboardResponse
from app.schemas.caregivers import CaregiverProfileResponse, ConnectedPatientSummary
from app.schemas.doctors import DoctorProfileResponse, PatientReportResponse, ClinicalInsightResponse
from app.schemas.activities import ActivityResponse, ActivityResultCreate, ActivityResultResponse
from app.schemas.memories import MemoryCreate, MemoryUpdate, MemoryResponse
from app.schemas.reminders import ReminderCreate, ReminderUpdate, ReminderResponse
from app.schemas.notes import DailyNoteCreate, DailyNoteResponse
from app.schemas.progress import ProgressSummaryResponse, ProgressTrendsResponse
from app.schemas.sync import (
    SyncPushRequest,
    SyncPushResponse,
    SyncPullResponse,
    SyncStatusResponse,
    SyncRecordItem,
)

__all__ = [
    "ApiResponse",
    "ErrorResponse",
    "RegisterRequest",
    "LoginRequest",
    "TokenResponse",
    "TokenPayload",
    "UserResponse",
    "UserUpdate",
    "PatientProfileResponse",
    "PatientUpdateRequest",
    "PatientDashboardResponse",
    "CaregiverProfileResponse",
    "ConnectedPatientSummary",
    "DoctorProfileResponse",
    "PatientReportResponse",
    "ClinicalInsightResponse",
    "ActivityResponse",
    "ActivityResultCreate",
    "ActivityResultResponse",
    "MemoryCreate",
    "MemoryUpdate",
    "MemoryResponse",
    "ReminderCreate",
    "ReminderUpdate",
    "ReminderResponse",
    "DailyNoteCreate",
    "DailyNoteResponse",
    "ProgressSummaryResponse",
    "ProgressTrendsResponse",
    "SyncPushRequest",
    "SyncPushResponse",
    "SyncPullResponse",
    "SyncStatusResponse",
    "SyncRecordItem",
]
