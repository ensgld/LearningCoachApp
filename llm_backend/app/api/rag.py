from fastapi import APIRouter, HTTPException
from app.core.logger import logger
from app.models.chat_models import (
    EmbeddingRequest,
    EmbeddingResponse,
    RagAnswerRequest,
    RagAnswerResponse,
)
from app.services.llm_service import get_embeddings, ask_document

from fastapi.responses import StreamingResponse

router = APIRouter(prefix="/rag", tags=["RAG"])


@router.post("/embeddings", response_model=EmbeddingResponse)
def embeddings(req: EmbeddingRequest):
    try:
        logger.info("Embedding isteği alındı")
        vectors = get_embeddings(req.texts)
        return EmbeddingResponse(embeddings=vectors)
    except Exception as e:
        logger.exception("Embedding error")
        raise HTTPException(status_code=500, detail=f"Embedding error: {e}")


@router.post("/answer")
def answer(req: RagAnswerRequest):
    try:
        logger.info("RAG cevap isteği alındı")
        if req.stream:
            generator = ask_document(req.question, req.context, req.history, stream=True)
            return StreamingResponse(generator, media_type="text/plain")
        else:
            result = ask_document(req.question, req.context, req.history, stream=False)
            return RagAnswerResponse(answer=result)
    except Exception as e:
        logger.exception("RAG answer error")
        raise HTTPException(status_code=500, detail=f"RAG answer error: {e}")
