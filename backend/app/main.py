import asyncio
import logging
from datetime import datetime

import azure.cognitiveservices.speech as speechsdk
import openai
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .core.config import get_settings
from .models.health import ServiceHealth, HealthResponse
from .utils.health import get_cached_timestamp, is_cache_valid
from .routes.base import router as base_router
from .routes.speech import router as speech_router
from .routes.chat import router as chat_router
from .routes.tts import router as tts_router

settings = get_settings()
CACHED_HEALTH_RESULT = None

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

app = FastAPI()

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # For development only
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routes
app.include_router(base_router)
app.include_router(speech_router, prefix="/api")
app.include_router(chat_router, prefix="/api")
app.include_router(tts_router, prefix="/api")


# Add startup event handler


async def check_openai_health() -> ServiceHealth:
    """Check the health of OpenAI API."""
    try:
        await openai.chat.completions.create(
            model="gpt-4",
            messages=[{"role": "system", "content": "Health check"}],
            max_tokens=5
        )
        return ServiceHealth(service="openai", status="healthy")
    except openai.OpenAIError as e:
        logger.error("OpenAI health check failed: %s", str(e))
        return ServiceHealth(service="openai", status="unhealthy", error=str(e))


async def check_azure_speech_health() -> ServiceHealth:
    """Check the health of Azure Speech Services."""
    try:
        speech_config = speechsdk.SpeechConfig(
            subscription=settings.azure_speech_key,
            region="japaneast"
        )
        speech_synthesizer = speechsdk.SpeechSynthesizer(
            speech_config=speech_config,
            audio_config=None
        )
        result = speech_synthesizer.speak_text_async("Health check").get()
        if result.reason == speechsdk.ResultReason.SynthesizingAudioCompleted:
            return ServiceHealth(service="azure_speech", status="healthy")
        return ServiceHealth(
            service="azure_speech",
            status="unhealthy",
            error=f"Synthesis failed: {result.reason}"
        )
    except Exception as e:  # Azure SDK doesn't expose specific error types
        logger.error("Azure Speech health check failed: %s", str(e))
        return ServiceHealth(
            service="azure_speech",
            status="unhealthy",
            error=str(e)
        )


@app.get("/health", response_model=HealthResponse)
async def health_check() -> HealthResponse:
    """Check the health of all required services."""
    global CACHED_HEALTH_RESULT
    cached_time = get_cached_timestamp()
    if CACHED_HEALTH_RESULT and is_cache_valid(cached_time):
        return CACHED_HEALTH_RESULT

    results = await asyncio.gather(
        check_openai_health(),
        check_azure_speech_health(),
    )

    all_healthy = all(result.status == "healthy" for result in results)
    response = HealthResponse(
        status="healthy" if all_healthy else "unhealthy",
        services=results,
        timestamp=datetime.utcnow()
    )

    CACHED_HEALTH_RESULT = response
    return response


@app.on_event("startup")
async def startup_event() -> None:
    """Initialize the application and check service health."""
    logger.info("Application starting up...")
    global CACHED_HEALTH_RESULT
    CACHED_HEALTH_RESULT = await health_check()
