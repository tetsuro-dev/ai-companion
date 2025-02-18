import logging
from typing import Optional
import openai
from app.core.config import get_settings

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class ChatService:

    def __init__(self):
        self.settings = get_settings()
        openai.api_key = self.settings.OPENAI_API_KEY

    async def generate_response(self, message: str, user_id: str) -> Optional[str]:
        """Generate a response using GPT-4 for the given message.

        Args:
            message (str): The user's input message
            user_id (str): Unique identifier for the user

        Returns:
            Optional[str]: The generated response or None if an error occurs

        Raises:
            Exception: If there's an error in generating the response
        """
        try:
            logger.info("Generating response for user %s", user_id)
            messages = [
                {"role": "system", "content": "You are a friendly Japanese-speaking AI companion"},
                {"role": "user", "content": message}
            ]
            response = await openai.chat.completions.create(model="gpt-4", messages=messages)

            if not response.choices:
                logger.error("No response generated from GPT-4")
                return None

            generated_text = response.choices[0].message.content
            logger.info("Generated response for user %s", user_id)
            return generated_text

        except Exception as e:
            error_msg = "Failed to generate response: %s"
            logger.error("Error generating chat response: %s", str(e))
            raise ValueError(error_msg % str(e)) from e
