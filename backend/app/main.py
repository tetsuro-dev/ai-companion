import logging
import asyncio

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .routes.base import router as base_router
from .routes.speech import router as speech_router
from .routes.chat import router as chat_router
from .routes.tts import router as tts_router
from .websockets.middleware import WebSocketMiddleware
from .websockets.heartbeat import heartbeat_monitor
from .websockets.manager import ConnectionManager

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


# Create connection manager
manager = ConnectionManager()

# Add WebSocket middleware
app.add_middleware(WebSocketMiddleware)

# Add startup event handler
@app.on_event("startup")
async def startup_event():
    logger.info("Application starting up...")
    # Start WebSocket heartbeat monitor
    asyncio.create_task(heartbeat_monitor(manager))
    logger.info("Started WebSocket heartbeat monitor")
    # TODO: Add health checks for required services (Azure, OpenAI, Zonos)
