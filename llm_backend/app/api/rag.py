from fastapi import APIRouter, UploadFile, File, HTTPException
from app.services.llm_service import get_embeddings
from app.models.chat_models import EmbeddingRequest, EmbeddingResponse, RagAnswerRequest, RagAnswerResponse
from app.core.logger import logger
import shutil
import os

from app.services.ingestion_service import ingest_pdf
from app.services.rag_service import get_answer

router = APIRouter()

@router.post("/embeddings", response_model=EmbeddingResponse)
async def create_embeddings(request: EmbeddingRequest):
    embeddings = get_embeddings(request.texts)
    return EmbeddingResponse(embeddings=embeddings)

@router.post("/ingest")
async def ingest_document(file: UploadFile = File(...)):
    """
    Upload a PDF and ingest it into the vector store.
    """
    logger.info(f"Received file for ingestion: {file.filename}")
    
    # Save file temporarily
    temp_file_path = f"temp_{file.filename}"
    try:
        with open(temp_file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
            
        # Process file
        result = ingest_pdf(temp_file_path, source_name=file.filename)
        
        return result
    except Exception as e:
        logger.error(f"Ingestion failed: {e}")
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        # Clean up
        if os.path.exists(temp_file_path):
            os.remove(temp_file_path)

@router.post("/answer", response_model=RagAnswerResponse)
async def answer_question(req: RagAnswerRequest):
    """
    RAG endpoint: Retrieve relevant context and answer question.
    """
    logger.info(f"RAG Answer request: {req.question}")
    return get_answer(req)
