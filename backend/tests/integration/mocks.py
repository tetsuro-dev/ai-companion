from unittest.mock import MagicMock
import azure.cognitiveservices.speech as speechsdk


class MockSpeechService:
    async def text_to_speech(self, text: str) -> bytes:
        return b"mock_audio_data"
        
    async def recognize_speech(self, audio_data: bytes):
        mock_result = MagicMock()
        mock_result.text = "こんにちは"
        mock_result.reason = speechsdk.ResultReason.RecognizedSpeech
        return mock_result


class MockOpenAIResponse:
    def __init__(self, text: str):
        self.choices = [MagicMock(message=MagicMock(content=text))]


class MockOpenAI:
    async def ChatCompletion_acreate(self, *args, **kwargs):
        return MockOpenAIResponse("こんにちは！")
