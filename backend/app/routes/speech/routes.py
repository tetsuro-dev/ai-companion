from fastapi import APIRouter, WebSocket, WebSocketDisconnect
import azure.cognitiveservices.speech as speechsdk
from ...services.speech_service import SpeechService
from ...core.config import get_settings

router = APIRouter()
speech_service = SpeechService()

@router.websocket("/synthesize")
async def synthesize_speech(websocket: WebSocket):
    await websocket.accept()
    try:
        while True:
            data = await websocket.receive_json()
            if text := data.get("text"):
                audio_data = await speech_service.text_to_speech(text)
                await websocket.send_bytes(audio_data)
    except WebSocketDisconnect:
        pass

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
