from fastapi import APIRouter, HTTPException
from app.core.logger import logger
from app.models.chat_models import (
    EmbeddingRequest,
    EmbeddingResponse,
    RagAnswerRequest,
    RagAnswerResponse,
    QuizGenerateRequest,
    QuizGenerateResponse,
    FlashcardGenerateRequest,
    FlashcardGenerateResponse,
)
from app.services.llm_service import (
    get_embeddings,
    ask_document,
    generate_quiz,
    generate_flashcards,
)

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


@router.post("/answer", response_model=RagAnswerResponse)
def answer(req: RagAnswerRequest):
    try:
        logger.info("RAG cevap isteği alındı")
        result = ask_document(req.question, req.context, req.history)
        return RagAnswerResponse(answer=result)
    except Exception as e:
        logger.exception("RAG answer error")
        raise HTTPException(status_code=500, detail=f"RAG answer error: {e}")


@router.post("/quiz")
def quiz_endpoint(req: QuizGenerateRequest):
    try:
        logger.info(f"Quiz üretimi istendi (count: {req.count}, diff: {req.difficulty})")
        result_json = generate_quiz(req.context, req.count, req.difficulty, req.instructions)
        import json
        import re
        
        match = re.search(r'(\{.*\}|\[.*\])', result_json, re.DOTALL)
        if match:
            result_json = match.group(0)
            
        parsed = json.loads(result_json)
        
        questions = parsed.get("questions", []) if isinstance(parsed, dict) else parsed if isinstance(parsed, list) else []
        if isinstance(parsed, dict) and "quiz" in parsed:
            questions = parsed["quiz"]
            
        for q in questions:
            ans = str(q.get("answer", "")).strip()
            options = q.get("options", [])
            valid_letters = ["A", "B", "C", "D"]
            
            if ans not in valid_letters and options:
                for i, opt in enumerate(options):
                    if i < 4 and (ans.lower() == str(opt).lower() or str(opt).lower().startswith(ans.lower()) or ans.lower().startswith(str(opt).lower())):
                        q["answer"] = valid_letters[i]
                        break
                        
        return {"questions": questions}
    except Exception as e:
        logger.exception("Quiz generation error")
        raise HTTPException(status_code=500, detail=f"Quiz error: {e}")


@router.post("/flashcards")
def flashcards_endpoint(req: FlashcardGenerateRequest):
    try:
        logger.info(f"Flash kart üretimi istendi (count: {req.count}, diff: {req.difficulty})")
        result_json = generate_flashcards(req.context, req.count, req.difficulty, req.instructions)
        import json
        import re
        
        match = re.search(r'(\{.*\}|\[.*\])', result_json, re.DOTALL)
        if match:
            result_json = match.group(0)
            
        parsed = json.loads(result_json)
        
        cards = parsed.get("cards", []) if isinstance(parsed, dict) else parsed if isinstance(parsed, list) else []
        if isinstance(parsed, dict) and "flashcards" in parsed:
            cards = parsed["flashcards"]
            
        return {"cards": cards}
    except Exception as e:
        logger.exception("Flashcard generation error")
        raise HTTPException(status_code=500, detail=f"Flashcard error: {e}")
