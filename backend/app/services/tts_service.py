import logging
from typing import Optional
import aiohttp
from app.core.config import get_settings

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class TTSService:

    def __init__(self):
        self.settings = get_settings()
        self.api_key = self.settings.ZONOS_API_KEY
        self.base_url = "https://api.zonos.ai/v1"

    async def synthesize_speech(
        self, text: str, voice_id: str = "default", language: str = "ja-JP"
    ) -> Optional[bytes]:
        """Convert text to speech using Zonos API.

        Args:
            text (str): The text to convert to speech
            voice_id (str): The voice ID to use
            language (str): The language code

        Returns:
            Optional[bytes]: The audio data or None if an error occurs

        Raises:
            Exception: If there's an error in speech synthesis
        """
        try:
            logger.info("Synthesizing speech for text: %.50s...", text)
            headers = {
                "Authorization": f"Bearer {self.api_key}",
                "Content-Type": "application/json"
            }
            async with aiohttp.ClientSession() as session:
                async with session.post(
                    f"{self.base_url}/synthesize",
                    headers=headers,
                    json={"text": text, "voice_id": voice_id, "language": language}
                ) as response:
                    if response.status != 200:
                        error_text = await response.text()
                        logger.error("TTS API error: %s", error_text)
                        raise ValueError(f"TTS API error: {error_text}")
                    audio_data = await response.read()
                    logger.info("Successfully synthesized speech")
                    return audio_data
        except Exception as e:
            error_msg = f"Failed to synthesize speech: {str(e)}"
            logger.error(error_msg)
            raise ValueError(error_msg) from e
