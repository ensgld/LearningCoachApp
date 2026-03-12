import time
from fastapi import APIRouter, HTTPException
from fastapi.responses import StreamingResponse
from app.models.chat_models import ChatRequest, ChatResponse
from app.services.llm_service import ask_llama
from app.core.logger import logger

router = APIRouter(prefix="/chat", tags=["Chat"])

@router.post("")
async def chat(req: ChatRequest):
    start_time = time.time()
    try:
        # Determine chat type based on message content
        chat_type = "COACH_TIP" if "Merhaba Koç, benim \"Learning Coach\" asistanımsın" in req.message else "GENERAL_CHAT"
        
        if req.stream:
            generator = await ask_llama(req.message, req.history, stream=True)
            return StreamingResponse(generator, media_type="text/plain")
        else:
            answer = await ask_llama(req.message, req.history, stream=False)
            duration_ms = (time.time() - start_time) * 1000
            return ChatResponse(answer=answer)
    except Exception as e:
        logger.error(f"Chat error: {str(e)}")
        raise HTTPException(status_code=500, detail="LLM error")
