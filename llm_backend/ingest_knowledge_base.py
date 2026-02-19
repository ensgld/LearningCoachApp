import os
import sys
from app.services.ingestion_service import ingest_pdf
from app.core.logger import logger

def main():
    pdf_path = os.path.join(os.getcwd(), "mydoc.pdf")
    
    if not os.path.exists(pdf_path):
        logger.error(f"File not found: {pdf_path}")
        sys.exit(1)
        
    try:
        logger.info(f"Ingesting {pdf_path} into FAISS vector store...")
        result = ingest_pdf(pdf_path, source_name="mydoc.pdf")
        
        if result.get("status") == "success":
            logger.info("✅ Ingestion successful!")
            logger.info(f"Chunks created: {result.get('chunks_count')}")
            logger.info(f"Backend: {result.get('backend')}")
        else:
            logger.error(f"❌ Ingestion failed: {result}")
            sys.exit(1)
            
    except Exception as e:
        logger.exception(f"❌ Error during ingestion: {e}")
        sys.exit(1)

if __name__ == "__main__":
    # Ensure logs directory exists if logger depends on it
    if not os.path.exists("logs"):
        os.makedirs("logs")
        
    main()
