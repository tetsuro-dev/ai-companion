from fastapi import APIRouter
from .speech import router as speech_router

router = APIRouter()

# Include speech routes
router.include_router(speech_router, prefix="/speech", tags=["speech"])

@router.get("/")
async def root():
    return {"message": "Welcome to AI Companion API"}
