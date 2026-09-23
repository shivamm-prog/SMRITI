from typing import Dict, Any, List
from pydantic import BaseModel


class CategoryStat(BaseModel):
    category: str
    sessions_count: int
    average_score: float
    color: str = "#2563EB"
    icon: str = "🧠"


class DayActivityCount(BaseModel):
    day: str
    count: int
    height_percentage: str


class ProgressSummaryResponse(BaseModel):
    total_activities_completed: int
    average_score: float
    average_accuracy: float
    activity_trend_label: str  # e.g., "Steady", "Consistent"
    consistency_streak_days: int
    category_breakdown: List[CategoryStat]
    weekly_frequency: List[DayActivityCount]
    reassuring_message: str


class ProgressTrendsResponse(BaseModel):
    patient_id: str
    recent_performance: List[Dict[str, Any]]
    areas_practiced: List[CategoryStat]
    domain_consistency: Dict[str, float]
    disclaimer: str = "Supportive activity continuity tracking. Not a medical dementia diagnosis."
