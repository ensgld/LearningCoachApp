import os
from dotenv import load_dotenv

load_dotenv()

OLLAMA_URL = os.getenv("OLLAMA_URL")
MODEL_NAME = os.getenv("MODEL_NAME")
EMBEDDING_MODEL = os.getenv("EMBEDDING_MODEL", "nomic-embed-text")
OLLAMA_EMBEDDINGS_URL = os.getenv("OLLAMA_EMBEDDINGS_URL")
REQUEST_TIMEOUT = int(os.getenv("REQUEST_TIMEOUT", 60))

if not OLLAMA_EMBEDDINGS_URL and OLLAMA_URL:
    if OLLAMA_URL.endswith("/api/chat"):
        OLLAMA_EMBEDDINGS_URL = OLLAMA_URL.replace("/api/chat", "/api/embeddings")
    else:
        OLLAMA_EMBEDDINGS_URL = f"{OLLAMA_URL.rstrip('/')}/api/embeddings"
