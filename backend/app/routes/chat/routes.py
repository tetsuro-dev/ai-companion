from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
import logging


# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


router = APIRouter()


class ChatRequest(BaseModel):
    message: str
    user_id: str


class ChatResponse(BaseModel):
    response: str
    status: str


@router.post("/chat", response_model=ChatResponse)
async def chat_endpoint(request: ChatRequest):
    try:
        logger.info(f"Received chat request from user {request.user_id}")
        from ...services.chat_service import ChatService
        chat_service = ChatService()
        generated_response = await chat_service.generate_response(
            message=request.message, user_id=request.user_id
        )
        if not generated_response:
            raise HTTPException(
                status_code=500, detail="Failed to generate response"
            )
        response = ChatResponse(
            response=generated_response, status="success"
        )
        logger.info(f"Successfully processed chat request for user {request.user_id}")
        return response
    except Exception as e:
        error_msg = f"Internal server error: {str(e)}"
        logger.error(f"Error processing chat request: {error_msg}")
        raise HTTPException(status_code=500, detail=error_msg)
