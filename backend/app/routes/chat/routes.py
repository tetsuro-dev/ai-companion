import logging

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel


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


from app.services.chat_service import ChatService


@router.post("/chat", response_model=ChatResponse)
async def chat_endpoint(request: ChatRequest):
    try:
        logger.info("Received chat request from user %s", request.user_id)
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
        logger.info("Successfully processed chat request for user %s", request.user_id)
        return response
    except Exception as e:
        error_msg = "Internal server error: %s"
        logger.error("Error processing chat request: %s", str(e))
        raise HTTPException(status_code=500, detail=error_msg % str(e)) from e
