from app.models.chat_models import RagAnswerRequest, RagAnswerResponse
from app.services.llm_service import ask_document
from app.services.vector_store import load_vector_store
from app.core.logger import logger

def get_answer(req: RagAnswerRequest) -> RagAnswerResponse:
    """
    RAG pipeline: Retrieve context -> Generate Answer
    """
    question = req.question
    history = req.history
    
    # 1. Retrieve Context
    context = req.context
    sources = []
    
    if not context:
        # Query FAISS
        try:
            vector_store = load_vector_store()
            if vector_store:
                results = vector_store.similarity_search(question, k=10) # Adjust k as needed to 10 previous was 3
                if results:
                    context = "\n\n".join([doc.page_content for doc in results])
                    # Extract sources
                    sources = []
                    for doc in results:
                        sources.append({
                            "docTitle": doc.metadata.get("source", "unknown"),
                            "pageLabel": str(doc.metadata.get("chunk_index", "?")),
                            "excerpt": doc.page_content[:100] + "..."
                        })
                else:
                    logger.info("No relevant documents found")
                    context = "İlgili doküman bulunamadı."
            else:
                logger.warning("Vector store index not found")
                context = "Henüz doküman yüklenmedi."
        except Exception as e:
            logger.error(f"Failed to query vector store: {e}")
            context = "Doküman araması sırasında hata oluştu."

    # 2. Generate Answer
    answer = ask_document(question, context, history)
    
    return RagAnswerResponse(
        answer=answer,
        sources=sources
    )
