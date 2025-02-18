import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def test_chat_endpoint():
    """Test the chat endpoint with a simple message"""
    response = client.post(
        "/api/chat",
        json={"message": "こんにちは", "user_id": "test_user"}
    )
    assert response.status_code == 200
    data = response.json()
    assert "response" in data
    assert "status" in data
    assert data["status"] == "success"


def test_tts_endpoint():
    """Test the text-to-speech endpoint"""
    response = client.post(
        "/api/synthesize",
        json={
            "text": "こんにちは",
            "voice_id": "default",
            "language": "ja-JP"
        }
    )
    assert response.status_code == 200
    data = response.json()
    assert "audio_url" in data
    assert "status" in data
    assert data["status"] == "success"


@pytest.mark.asyncio
async def test_speech_websocket():
    """Test the speech recognition WebSocket endpoint"""
    with client.websocket_connect("/api/speech/recognize") as websocket:
        # Send dummy audio data
        websocket.send_bytes(b"dummy_audio_data")
        data = websocket.receive_json()
        assert "text" in data
        assert "is_final" in data


def test_full_pipeline():
    """Test the complete pipeline: Speech → Chat → TTS"""
    # 1. Speech recognition (WebSocket)
    with client.websocket_connect("/api/speech/recognize") as websocket:
        websocket.send_bytes(b"dummy_audio_data")
        speech_result = websocket.receive_json()
        assert "text" in speech_result

    # 2. Chat processing
    chat_response = client.post(
        "/api/chat",
        json={"message": speech_result["text"], "user_id": "test_user"}
    )
    assert chat_response.status_code == 200
    chat_data = chat_response.json()
    
    # 3. Text-to-speech
    tts_response = client.post(
        "/api/synthesize",
        json={"text": chat_data["response"], "voice_id": "default", "language": "ja-JP"}
    )
    assert tts_response.status_code == 200
    tts_data = tts_response.json()
    assert "audio_url" in tts_data
