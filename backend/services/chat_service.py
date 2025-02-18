from typing import Dict, Any
import openai
from ..core.config import get_settings

settings = get_settings()
openai.api_key = settings.openai_api_key

async def generate_response(message: str) -> Dict[str, Any]:
    try:
        response = await openai.ChatCompletion.acreate(
            model="gpt-4",
            messages=[
                {"role": "system", "content": "You are a friendly AI companion."},
                {"role": "user", "content": message}
            ]
        )
        return {
            "message": response.choices[0].message.content,
            "status": "success"
        }
    except Exception as e:
        return {
            "message": str(e),
            "status": "error"
        }
