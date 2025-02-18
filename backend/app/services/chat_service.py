import logging
from typing import Optional
import openai
from ..core.config import get_settings

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class ChatService:
    def __init__(self):
        self.settings = get_settings()
        openai.api_key = self.settings.OPENAI_API_KEY
        
    async def generate_response(self, message: str, user_id: str) -> Optional[str]:
        """
        Generate a response using GPT-4 for the given message.
        
        Args:
            message (str): The user's input message
            user_id (str): Unique identifier for the user
            
        Returns:
            Optional[str]: The generated response or None if an error occurs
            
        Raises:
            Exception: If there's an error in generating the response
        """
        try:
            logger.info(f"Generating response for user {user_id}")
            
            response = await openai.ChatCompletion.acreate(
                model="gpt-4",
                messages=[
                    {"role": "system", "content": "You are a friendly AI companion who speaks Japanese."},
                    {"role": "user", "content": message}
                ]
            )
            
            if not response.choices:
                logger.error("No response generated from GPT-4")
                return None
                
            generated_text = response.choices[0].message.content
            logger.info(f"Successfully generated response for user {user_id}")
            return generated_text
            
        except Exception as e:
            logger.error(f"Error generating chat response: {str(e)}")
            raise Exception(f"Failed to generate response: {str(e)}")
