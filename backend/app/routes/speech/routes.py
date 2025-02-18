import logging

from fastapi import APIRouter, WebSocket, WebSocketDisconnect
import azure.cognitiveservices.speech as speechsdk

from ...services.speech_service import SpeechService


# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

router = APIRouter(prefix="/speech")
speech_service = SpeechService()


@router.websocket("/synthesize")
async def synthesize_speech(websocket: WebSocket):
    client_id = id(websocket)
    logger.info("New WebSocket connection for synthesis. Client ID: %s", client_id)
    await websocket.accept()
    try:
        while True:
            data = await websocket.receive_json()
            if text := data.get("text"):
                logger.info("Synthesizing speech for client %s. Text: %.50s...", client_id, text)
                try:
                    audio_data = await speech_service.text_to_speech(text)
                    await websocket.send_bytes(audio_data)
                    logger.info("Successfully sent synthesized audio to client %s", client_id)
                except Exception as e:
                    msg = f"Error synthesizing speech for client {client_id}: {str(e)}"
                    logger.error(msg)
                    await websocket.send_json({"error": "Speech synthesis failed"})
            else:
                msg = f"Invalid data from client {client_id}: missing 'text' field"
                logger.warning(msg)
                await websocket.send_json({"error": "Missing 'text' field in request"})
    except WebSocketDisconnect:
        logger.info("WebSocket disconnected for synthesis. Client ID: %s", client_id)
    except Exception as e:
        logger.error("Error in synthesis WebSocket for client %s: %s", client_id, str(e))
        try:
            await websocket.send_json({"error": "Internal server error"})
        except Exception:
            pass


@router.websocket("/recognize")
async def recognize_speech(websocket: WebSocket):
    client_id = id(websocket)
    logger.info("New WebSocket connection for recognition. Client ID: %s", client_id)
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
                logger.info("Successfully sent recognition result to client %s", client_id)
            except Exception as e:
                logger.error("Error recognizing speech for client %s: %s", client_id, str(e))
                await websocket.send_json({"error": "Speech recognition failed"})
    except WebSocketDisconnect:
        logger.info("WebSocket disconnected for recognition. Client ID: %s", client_id)
    except Exception as e:
        logger.error("Error in recognition WebSocket for client %s: %s", client_id, str(e))
        try:
            await websocket.send_json({"error": "Internal server error"})
        except Exception:
            pass
