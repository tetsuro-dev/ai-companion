from fastapi import APIRouter, WebSocket, WebSocketDisconnect
import azure.cognitiveservices.speech as speechsdk
from ...services.speech_service import SpeechService
import logging


# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

router = APIRouter(prefix="/speech")
speech_service = SpeechService()


@router.websocket("/synthesize")
async def synthesize_speech(websocket: WebSocket):
    client_id = id(websocket)
    logger.info(f"New WebSocket connection for synthesis. Client ID: {client_id}")
    await websocket.accept()
    try:
        while True:
            data = await websocket.receive_json()
            if text := data.get("text"):
                msg = f"Synthesizing speech for client {client_id}. Text: {text[:50]}..."
                logger.info(msg)
                try:
                    audio_data = await speech_service.text_to_speech(text)
                    await websocket.send_bytes(audio_data)
                    logger.info(f"Successfully sent synthesized audio to client {client_id}")
                except Exception as e:
                    msg = f"Error synthesizing speech for client {client_id}: {str(e)}"
                    logger.error(msg)
                    await websocket.send_json({"error": "Speech synthesis failed"})
            else:
                logger.warning(f"Received invalid data from client {client_id}: missing 'text' field")
                await websocket.send_json({"error": "Missing 'text' field in request"})
                
    except WebSocketDisconnect:
        logger.info(f"WebSocket disconnected for synthesis. Client ID: {client_id}")
    except Exception as e:
        error_msg = f"Error in synthesis WebSocket: {str(e)}"
        logger.error(f"Client {client_id}: {error_msg}")
        try:
            await websocket.send_json({"error": error_msg})
        except Exception:
            pass


@router.websocket("/recognize")
async def recognize_speech(websocket: WebSocket):
    client_id = id(websocket)
    logger.info(f"New WebSocket connection for recognition. Client ID: {client_id}")
    await websocket.accept()
    try:
        while True:
            audio_data = await websocket.receive_bytes()
            msg = f"Received audio data from client {client_id}. Size: {len(audio_data)} bytes"
            logger.info(msg)
            try:
                result = await speech_service.recognize_speech(audio_data)
                response = {
                    "text": result.text if result.text else "",
                    "is_final": result.reason == speechsdk.ResultReason.RecognizedSpeech
                }
                await websocket.send_json(response)
                logger.info(f"Successfully sent recognition result to client {client_id}")
            except Exception as e:
                msg = f"Error recognizing speech for client {client_id}: {str(e)}"
                logger.error(msg)
                await websocket.send_json({"error": "Speech recognition failed"})
    except WebSocketDisconnect:
        logger.info(f"WebSocket disconnected for recognition. Client ID: {client_id}")
    except Exception as e:
        error_msg = f"Error in recognition WebSocket: {str(e)}"
        logger.error(f"Client {client_id}: {error_msg}")
        try:
            await websocket.send_json({"error": error_msg})
        except Exception:
            pass
