from fastapi import APIRouter
from app.routes.speech.routes import router as speech_router

router = APIRouter()

# Include speech routes
router.include_router(speech_router, tags=["speech"])


@router.get("/")
async def root():
    return {"message": "Welcome to AI Companion API"}
