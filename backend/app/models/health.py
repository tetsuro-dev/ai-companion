from datetime import datetime
from typing import List, Optional

from pydantic import BaseModel


class ServiceHealth(BaseModel):
    """Model representing the health status of an individual service."""
    service: str
    status: str
    error: Optional[str] = None


class HealthResponse(BaseModel):
    """Model representing the overall health status response."""
    status: str
    services: List[ServiceHealth]
    timestamp: datetime
