from unittest.mock import MagicMock

class MockSpeechService:
    async def text_to_speech(self, text: str) -> bytes:
        return b"mock_audio_data"
        
    async def recognize_speech(self, audio_data: bytes):
        mock_result = MagicMock()
        mock_result.text = "こんにちは"
        mock_result.reason = "RecognizedSpeech"
        return mock_result
