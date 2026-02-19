import sys
from app.services.vector_store import load_vector_store

def inspect_query(question: str):
    """
    Queries the FAISS index and prints the retrieved chunks and metadata.
    """
    print(f"\n🔍 Querying for: '{question}'\n")
    
    vector_store = load_vector_store()
    if not vector_store:
        print("❌ Error: FAISS index not found. Did you run ingestion?")
        return

    results = vector_store.similarity_search(question, k=3)
    
    if not results:
        print("⚠️ No results found.")
        return

    print(f"✅ Found {len(results)} relevant chunks:\n")
    
    for i, doc in enumerate(results, 1):
        print(f"--- Chunk {i} ---")
        print(f"📄 Source: {doc.metadata.get('source', 'Unknown')}")
        print(f"📍 Page/Indices: {doc.metadata}")
        print(f"📝 Content ({len(doc.page_content)} chars):")
        print(f"\"{doc.page_content}\"")
        print("----------------\n")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        question = " ".join(sys.argv[1:])
        inspect_query(question)
    else:
        print("Usage: python inspect_chunks.py \"Your question here\"")
