import os
from dotenv import load_dotenv

load_dotenv()

OLLAMA_URL = os.getenv("OLLAMA_URL")
MODEL_NAME = os.getenv("MODEL_NAME")
EMBEDDING_MODEL = os.getenv("EMBEDDING_MODEL", "nomic-embed-text")
OLLAMA_EMBEDDINGS_URL = os.getenv("OLLAMA_EMBEDDINGS_URL")
REQUEST_TIMEOUT = int(os.getenv("REQUEST_TIMEOUT", 300))
OLLAMA_KEEP_ALIVE_RAW = os.getenv("OLLAMA_KEEP_ALIVE", "-1")
try:
    OLLAMA_KEEP_ALIVE = int(OLLAMA_KEEP_ALIVE_RAW)
except ValueError:
    OLLAMA_KEEP_ALIVE = OLLAMA_KEEP_ALIVE_RAW

OLLAMA_GENERATE_URL = os.getenv("OLLAMA_GENERATE_URL", "http://localhost:11434/api/generate")

if not OLLAMA_EMBEDDINGS_URL and OLLAMA_URL:
    if OLLAMA_URL.endswith("/api/chat"):
        OLLAMA_EMBEDDINGS_URL = OLLAMA_URL.replace("/api/chat", "/api/embeddings")
    else:
        OLLAMA_EMBEDDINGS_URL = f"{OLLAMA_URL.rstrip('/')}/api/embeddings"
