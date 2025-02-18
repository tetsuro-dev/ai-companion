import azure.cognitiveservices.speech as speechsdk
from ..core.config import get_settings
import asyncio


settings = get_settings()


class SpeechService:

    def __init__(self):
        self.speech_config = speechsdk.SpeechConfig(
            subscription=settings.azure_speech_key,
            region="japaneast"
        )
        self.speech_config.speech_recognition_language = "ja-JP"
        self.speech_config.speech_synthesis_language = "ja-JP"

    async def text_to_speech(self, text: str) -> bytes:
        speech_synthesizer = speechsdk.SpeechSynthesizer(
            speech_config=self.speech_config,
            audio_config=None
        )
        result = speech_synthesizer.speak_text_async(text).get()
        if result.reason == speechsdk.ResultReason.SynthesizingAudioCompleted:
            return result.audio_data
        else:
            raise Exception(f"Speech synthesis failed: {result.reason}")

    async def recognize_speech(self, audio_data: bytes) -> speechsdk.SpeechRecognitionResult:
        # Create an audio stream from the received bytes
        stream = speechsdk.audio.PushAudioInputStream()
        stream.write(audio_data)
        # Configure audio input
        audio_config = speechsdk.audio.AudioConfig(stream=stream)
        # Create speech recognizer
        speech_recognizer = speechsdk.SpeechRecognizer(
            speech_config=self.speech_config, audio_config=audio_config
        )
        # Use async recognition
        future = speech_recognizer.recognize_once_async()
        result = await asyncio.wrap_future(future)
        return result
