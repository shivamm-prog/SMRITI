from typing import Generic, TypeVar, Optional, Any
from pydantic import BaseModel

T = TypeVar("T")


class ApiResponse(BaseModel, Generic[T]):
    success: bool = True
    data: Optional[T] = None
    message: str = "Request successful"


class ErrorResponse(BaseModel):
    success: bool = False
    data: Optional[Any] = None
    message: str
