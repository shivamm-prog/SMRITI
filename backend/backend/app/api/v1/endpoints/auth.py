from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.schemas.common import ApiResponse
from app.schemas.auth import RegisterRequest, LoginRequest, TokenResponse
from app.schemas.users import UserResponse
from app.services.auth_service import AuthService
from app.api.deps import get_current_user
from app.models.user import User

router = APIRouter()


@router.post(
    "/register",
    response_model=ApiResponse[TokenResponse],
    status_code=status.HTTP_201_CREATED,
    summary="Register a new Patient, Caregiver, or Doctor",
)
def register(request: RegisterRequest, db: Session = Depends(get_db)):
    result = AuthService.register(db, request)
    return ApiResponse(
        success=True,
        data=result,
        message="Registration successful. Welcome to MindSetu.",
    )


@router.post(
    "/login",
    response_model=ApiResponse[TokenResponse],
    summary="Authenticate user and return JWT access token",
)
def login(request: LoginRequest, db: Session = Depends(get_db)):
    result = AuthService.login(db, request)
    return ApiResponse(
        success=True,
        data=result,
        message="Login successful.",
    )


@router.get(
    "/me",
    response_model=ApiResponse[UserResponse],
    summary="Get current authenticated user profile",
)
def get_me(current_user: User = Depends(get_current_user)):
    return ApiResponse(
        success=True,
        data=UserResponse.model_validate(current_user),
        message="User profile retrieved.",
    )
