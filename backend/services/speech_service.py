import azure.cognitiveservices.speech as speechsdk
from ..core.config import get_settings

settings = get_settings()

class SpeechService:
    def __init__(self):
        self.speech_config = speechsdk.SpeechConfig(
            subscription=settings.azure_speech_key,
            region="japaneast"  # Configure as needed
        )
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
