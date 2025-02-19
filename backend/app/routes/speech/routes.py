import logging
from typing import Optional

from fastapi import APIRouter, WebSocket, WebSocketDisconnect
import azure.cognitiveservices.speech as speechsdk

from app.services.speech_service import SpeechService
from app.websockets.manager import ConnectionManager
from app.websockets.errors import WebSocketError, WebSocketErrorCode


# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

router = APIRouter(prefix="/speech")
speech_service = SpeechService()
manager = ConnectionManager()


@router.websocket("/synthesize")
async def synthesize_speech(websocket: WebSocket):
    client_id = str(id(websocket))
    logger.info("New WebSocket connection for synthesis. Client ID: %s", client_id)
    
    if not await manager.connect(client_id, websocket):
        error = WebSocketError.rate_limit()
        await websocket.send_json({"error": error.to_dict()})
        return
        
    try:
        while True:
            try:
                data = await websocket.receive_json()
                if text := data.get("text"):
                    logger.info("Synthesizing speech for client %s. Text: %.50s...", client_id, text)
                    try:
                        audio_data = await speech_service.text_to_speech(text)
                        await websocket.send_bytes(audio_data)
                        await manager.send_heartbeat(client_id)
                        logger.info("Successfully sent synthesized audio to client %s", client_id)
                    except ValueError as e:
                        error = WebSocketError.server_error({"details": str(e)})
                        await websocket.send_json({"error": error.to_dict()})
                else:
                    error = WebSocketError.invalid_message()
                    await websocket.send_json({"error": error.to_dict()})
            except WebSocketError as e:
                await websocket.send_json({"error": e.to_dict()})
    except WebSocketDisconnect:
        logger.info("WebSocket disconnected for synthesis. Client ID: %s", client_id)
    except Exception as e:
        logger.error("Error in synthesis WebSocket for client %s: %s", client_id, str(e))
        error = WebSocketError.server_error({"details": str(e)})
        try:
            await websocket.send_json({"error": error.to_dict()})
        except WebSocketDisconnect:
            pass
    finally:
        await manager.disconnect(client_id)


@router.websocket("/recognize")
async def recognize_speech(websocket: WebSocket):
    client_id = str(id(websocket))
    logger.info("New WebSocket connection for recognition. Client ID: %s", client_id)
    
    if not await manager.connect(client_id, websocket):
        error = WebSocketError.rate_limit()
        await websocket.send_json({"error": error.to_dict()})
        return
        
    try:
        while True:
            try:
                audio_data = await websocket.receive_bytes()
                logger.info("Audio data from client %s. Size: %d bytes", client_id, len(audio_data))
                try:
                    result = await speech_service.recognize_speech(audio_data)
                    response = {
                        "text": result.text if result.text else "",
                        "is_final": result.reason == speechsdk.ResultReason.RecognizedSpeech
                    }
                    await websocket.send_json(response)
                    await manager.send_heartbeat(client_id)
                    logger.info("Successfully sent recognition result to client %s", client_id)
                except ValueError as e:
                    error = WebSocketError.server_error({"details": str(e)})
                    await websocket.send_json({"error": error.to_dict()})
            except WebSocketError as e:
                await websocket.send_json({"error": e.to_dict()})
    except WebSocketDisconnect:
        logger.info("WebSocket disconnected for recognition. Client ID: %s", client_id)
    except Exception as e:
        logger.error("Error in recognition WebSocket for client %s: %s", client_id, str(e))
        error = WebSocketError.server_error({"details": str(e)})
        try:
            await websocket.send_json({"error": error.to_dict()})
        except WebSocketDisconnect:
            pass
    finally:
        await manager.disconnect(client_id)
