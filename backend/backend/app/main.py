from contextlib import asynccontextmanager
from fastapi import FastAPI, Request, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from starlette.exceptions import HTTPException as StarletteHTTPException

from app.core.config import settings
from app.core.database import init_db, SessionLocal
from app.core.seed import seed_database
from app.api.v1.router import api_router


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Initialize database tables and seed starter data
    init_db()
    db = SessionLocal()
    try:
        seed_database(db)
    finally:
        db.close()
    yield


app = FastAPI(
    title=settings.PROJECT_NAME,
    description=(
        "Production backend for MindSetu — AI-Based Cognitive Gaming and Memory Assistance "
        "Platform for Elderly Dementia Patients in the North Eastern Region (NER) of India."
    ),
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
    lifespan=lifespan,
)

# CORS Configuration (Production Flutter Web, cross-domain JWT, and local dev)
cors_origins = [str(origin).rstrip("/") for origin in settings.BACKEND_CORS_ORIGINS if origin]

app.add_middleware(
    CORSMiddleware,
    allow_origins=cors_origins,
    allow_origin_regex=settings.CORS_ORIGIN_REGEX if settings.CORS_ORIGIN_REGEX else None,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"],
    allow_headers=["*"],
    expose_headers=["Content-Disposition", "Authorization"],
)


# Consistent JSON Exception Handlers
@app.exception_handler(StarletteHTTPException)
async def http_exception_handler(request: Request, exc: StarletteHTTPException):
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "success": False,
            "data": None,
            "message": str(exc.detail),
        },
    )


@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    errors = exc.errors()
    error_msg = "; ".join([f"{'.'.join(str(l) for l in e['loc'])}: {e['msg']}" for e in errors])
    return JSONResponse(
        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
        content={
            "success": False,
            "data": errors,
            "message": f"Validation Error: {error_msg}",
        },
    )


# Health Check Endpoints
@app.get("/health", tags=["Health Check"], summary="Service and database health check")
def health_check():
    from sqlalchemy import text
    db_status = "connected"
    try:
        db = SessionLocal()
        db.execute(text("SELECT 1"))
        db.close()
    except Exception as e:
        db_status = f"error: {str(e)}"

    return {
        "status": "ok",
        "database": "connected" if "error" not in db_status else db_status,
        "environment": settings.ENVIRONMENT,
        "project": settings.PROJECT_NAME,
    }


@app.get("/", tags=["Root"], summary="Root service status")
def root():
    return {
        "project": settings.PROJECT_NAME,
        "status": "running",
        "version": "1.0.0",
        "docs": "/docs",
        "api_v1": settings.API_V1_STR,
    }


# Include API v1 Router
app.include_router(api_router, prefix=settings.API_V1_STR)
