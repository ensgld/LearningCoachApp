import time
from fastapi import APIRouter, HTTPException
from app.models.chat_models import ChatRequest, ChatResponse
from app.services.llm_service import ask_llama
from app.core.logger import logger

router = APIRouter(prefix="/chat", tags=["Chat"])

@router.post("", response_model=ChatResponse)
def chat(req: ChatRequest):
    start_time = time.time()
    try:
        # Determine chat type based on message content
        chat_type = "COACH_TIP" if "Merhaba Koç, benim \"Learning Coach\" asistanımsın" in req.message else "GENERAL_CHAT"
        
        logger.info(f"[{chat_type}] REQUEST: {req.message[:50]}...")
        
        answer = ask_llama(req.message, req.history)
        
        duration_ms = (time.time() - start_time) * 1000
        logger.info(f"[{chat_type}] RESPONSE ({duration_ms:.2f}ms): {answer[:50]}...")
        
        # Explicitly log specifically for the test requirement
        logger.info(f"TEST_LOG | {chat_type} | {duration_ms:.2f}ms | Q: {req.message[:100]}... | A: {answer[:100]}...")
        
        return ChatResponse(answer=answer)
    except Exception as e:
        logger.error(f"Chat error: {str(e)}")
        raise HTTPException(status_code=500, detail="LLM error")
