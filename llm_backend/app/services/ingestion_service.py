import os
import pypdf
from langchain_text_splitters import RecursiveCharacterTextSplitter
from app.services.vector_store import (
    load_vector_store,
    create_vector_store,
    save_vector_store
)
from app.core.logger import logger

def ingest_pdf(file_path: str, source_name: str) -> dict:
    """
    Reads a PDF, chunks it, and stores it in FAISS.
    """
    logger.info(f"Starting ingestion for {source_name}")
    
    # 1. Extract Text
    text = ""
    try:
        with open(file_path, "rb") as f:
            reader = pypdf.PdfReader(f)
            for page in reader.pages:
                page_text = page.extract_text()
                if page_text:
                    text += page_text + "\n"
    except Exception as e:
        logger.error(f"Failed to read PDF: {e}")
        raise

    if not text.strip():
        raise ValueError("No text extracted from PDF")

    # 2. Chunk Text
    text_splitter = RecursiveCharacterTextSplitter(
        chunk_size=1000,
        chunk_overlap=200,
        length_function=len,
    )
    chunks = text_splitter.split_text(text)
    
    if not chunks:
        logger.warning("No chunks created")
        return {"status": "warning", "message": "No chunks created"}

    logger.info(f"Created {len(chunks)} chunks")

    # 3. Store in FAISS
    metadatas = [{"source": source_name, "chunk_index": i} for i in range(len(chunks))]

    try:
        vector_store = load_vector_store()
        
        if vector_store:
            logger.info("Adding to existing FAISS index")
            vector_store.add_texts(texts=chunks, metadatas=metadatas)
        else:
            logger.info("Creating new FAISS index")
            vector_store = create_vector_store(texts=chunks, metadatas=metadatas)
            
        save_vector_store(vector_store)
        logger.info(f"Successfully saved FAISS index")
        
    except Exception as e:
        logger.exception("Failed to update vector store")
        raise e
    
    return {
        "status": "success", 
        "chunks_count": len(chunks), 
        "backend": "faiss"
    }
