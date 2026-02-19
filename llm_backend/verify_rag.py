import sys
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

from app.services.vector_store import load_vector_store
from app.services.llm_service import ask_document

def verify_rag(question: str):
    print(f"\n🧪 Verifying RAG for: '{question}'\n")

    # 1. Load Vector Store
    vector_store = load_vector_store()
    if not vector_store:
        print("❌ Error: FAISS index not found. Please run ingestion first.")
        return

    # 2. Retrieve Context
    print("🔍 Retrieving context...")
    results = vector_store.similarity_search(question, k=3)
    
    if not results:
        print("⚠️ No relevant documents found in vector store.")
        context = ""
    else:
        print(f"✅ Found {len(results)} chunks.\n")
        context_parts = []
        for i, doc in enumerate(results, 1):
            source = doc.metadata.get("source", "unknown")
            page = doc.metadata.get("chunk_index", "?")
            content = doc.page_content
            context_parts.append(content)
            
            print(f"--- Chunk {i} ({source}, index {page}) ---")
            print(f"{content[:200]}...") # Print first 200 chars
            print("-----------------------------------")
        
        context = "\n\n".join(context_parts)

    # 3. Generate Answer
    print("\n🤖 Asking LLM...")
    if not context:
        print("⚠️ proceeding with empty context.")
        
    try:
        answer = ask_document(question, context)
        print("\n📝 LLM Answer:")
        print("===================================")
        print(answer)
        print("===================================\n")
    except Exception as e:
        print(f"❌ Error querying LLM: {e}")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        question = " ".join(sys.argv[1:])
        verify_rag(question)
    else:
        print("Usage: python verify_rag.py \"Your question here\"")
        print("Example: python verify_rag.py \"Dokümanda X hakkında ne yazıyor?\"")
