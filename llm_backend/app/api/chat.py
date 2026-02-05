from fastapi import APIRouter, HTTPException
from app.models.chat_models import ChatRequest, ChatResponse
from app.services.llm_service import ask_llama
from app.core.logger import logger

router = APIRouter(prefix="/chat", tags=["Chat"])

@router.post("", response_model=ChatResponse)
def chat(req: ChatRequest):
    try:
        logger.info(f"Kullanıcı mesajı: {req.message}")
        answer = ask_llama(req.message)
        return ChatResponse(answer=answer)

    except Exception as e:
        logger.error(str(e))
        raise HTTPException(status_code=500, detail="LLM error")
