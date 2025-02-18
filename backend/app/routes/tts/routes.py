import logging

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

from app.services.tts_service import TTSService

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

router = APIRouter()


class TTSRequest(BaseModel):
    text: str
    voice_id: str = "default"
    language: str = "ja-JP"


class TTSResponse(BaseModel):
    audio_url: str
    status: str


@router.post("/synthesize", response_model=TTSResponse)
async def synthesize_speech(request: TTSRequest):
    try:
        logger.info("Received TTS request for text: %.50s...", request.text)
        tts_service = TTSService()
        audio_data = await tts_service.synthesize_speech(
            text=request.text,
            voice_id=request.voice_id,
            language=request.language
        )
        if not audio_data:
            raise HTTPException(
                status_code=500,
                detail="Failed to synthesize speech"
            )
        # TODO: Store audio data and generate URL
        # For now, we'll return a placeholder
        response = TTSResponse(
            audio_url="/api/audio/temp.mp3",  # This will be replaced with actual storage
            status="success"
        )
        logger.info("Successfully processed TTS request")
        return response
    except Exception as e:
        error_msg = f"Internal server error: {str(e)}"
        logger.error("Error processing TTS request: %s", str(e))
        raise HTTPException(status_code=500, detail=error_msg) from e
