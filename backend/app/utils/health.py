from datetime import datetime, timedelta
from functools import lru_cache

from fastapi import HTTPException


CACHE_TTL = 60  # seconds


@lru_cache(maxsize=1)
def get_cached_timestamp() -> datetime:
    """Get the cached timestamp for health check responses."""
    return datetime.utcnow()


def is_cache_valid(cached_time: datetime) -> bool:
    """Check if the cached health check result is still valid."""
    return datetime.utcnow() - cached_time < timedelta(seconds=CACHE_TTL)


def raise_health_check_error(service: str, error: str) -> None:
    """Raise a standardized HTTP exception for health check errors."""
    raise HTTPException(
        status_code=503,
        detail={
            "message": f"{service} service is unhealthy",
            "error": error
        }
    )
