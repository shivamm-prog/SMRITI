from typing import Optional
from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.models.user import User, UserRole
from app.models.patient import Patient
from app.models.caregiver import Caregiver
from app.models.doctor import Doctor
from app.schemas.auth import RegisterRequest, LoginRequest, TokenResponse
from app.core.security import get_password_hash, verify_password, create_access_token


class AuthService:
    @staticmethod
    def register(db: Session, request: RegisterRequest) -> TokenResponse:
        # Check if email already exists
        existing_user = db.query(User).filter(User.email == request.email).first()
        if existing_user:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="A user with this email already exists.",
            )

        # Create user
        user = User(
            email=request.email,
            hashed_password=get_password_hash(request.password),
            full_name=request.full_name,
            role=request.role,
        )
        db.add(user)
        db.flush()

        patient_id = None
        caregiver_id = None
        doctor_id = None

        patient_code = None

        # Create role-specific profile
        if request.role == UserRole.PATIENT:
            reg_code = (request.region or "ASSAM").upper()[:5]
            count = db.query(Patient).count() + 1
            patient_code = f"MS-{reg_code}-{str(count).zfill(3)}"

            patient = Patient(
                user_id=user.id,
                patient_code=patient_code,
                name=request.full_name,
                age=request.age,
                dob=request.dob,
                gender=request.gender,
                region=request.region or "assam",
                preferred_language=request.preferred_language or "Assamese",
                cultural_preferences=request.cultural_preferences or {},
                emergency_contact_name=request.emergency_contact_name,
                emergency_contact_phone=request.emergency_contact_phone,
                emergency_contact_relation=request.emergency_contact_relation,
            )
            db.add(patient)
            db.flush()
            patient_id = patient_code

        elif request.role == UserRole.CAREGIVER:
            caregiver = Caregiver(
                user_id=user.id,
                name=request.full_name,
                phone=request.phone,
                relationship=request.relationship or "Family Caregiver",
                assigned_patient_id=request.assigned_patient_id,
            )
            db.add(caregiver)
            db.flush()
            caregiver_id = caregiver.id

        elif request.role == UserRole.DOCTOR:
            doctor = Doctor(
                user_id=user.id,
                name=request.full_name,
                qualification=request.qualification or "MD, Geriatric Medicine",
                hospital=request.hospital or "Guwahati Senior Health Institute",
                license_number=request.license_number or "NMC-NER-1001",
            )
            db.add(doctor)
            db.flush()
            doctor_id = doctor.id

        db.commit()
        db.refresh(user)

        # Generate JWT token
        access_token = create_access_token(subject=user.id, role=user.role.value)

        return TokenResponse(
            access_token=access_token,
            token_type="bearer",
            user_id=user.id,
            email=user.email,
            full_name=user.full_name,
            role=user.role,
            patient_id=patient_id,
            patient_code=patient_code,
            caregiver_id=caregiver_id,
            doctor_id=doctor_id,
        )

    @staticmethod
    def login(db: Session, request: LoginRequest) -> TokenResponse:
        user = db.query(User).filter(User.email == request.email).first()
        if not user or not verify_password(request.password, user.hashed_password):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Incorrect email or password.",
            )

        if not user.is_active:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="User account is inactive.",
            )

        patient_id = None
        patient_code = None
        if user.patient_profile:
            patient_code = user.patient_profile.patient_code or f"MS-ASSAM-{user.patient_profile.id[:4].upper()}"
            patient_id = patient_code

        caregiver_id = user.caregiver_profile.id if user.caregiver_profile else None
        doctor_id = user.doctor_profile.id if user.doctor_profile else None

        access_token = create_access_token(subject=user.id, role=user.role.value)

        return TokenResponse(
            access_token=access_token,
            token_type="bearer",
            user_id=user.id,
            email=user.email,
            full_name=user.full_name,
            role=user.role,
            patient_id=patient_id,
            patient_code=patient_code,
            caregiver_id=caregiver_id,
            doctor_id=doctor_id,
        )
