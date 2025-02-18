from fastapi import APIRouter, WebSocket, WebSocketDisconnect
import azure.cognitiveservices.speech as speechsdk
from ...services.speech_service import SpeechService
from ...core.config import get_settings

router = APIRouter()
speech_service = SpeechService()

@router.websocket("/recognize")
async def recognize_speech(websocket: WebSocket):
    await websocket.accept()
    try:
        while True:
            audio_data = await websocket.receive_bytes()
            result = await speech_service.recognize_speech(audio_data)
            await websocket.send_json({
                "text": result.text if result.text else "",
                "is_final": result.reason == speechsdk.ResultReason.RecognizedSpeech
            })
    except WebSocketDisconnect:
        pass
    except Exception as e:
        await websocket.send_json({
            "error": str(e)
        })
