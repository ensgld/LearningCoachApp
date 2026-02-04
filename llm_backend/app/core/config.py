import os
from dotenv import load_dotenv

load_dotenv()

OLLAMA_URL = os.getenv("OLLAMA_URL")
MODEL_NAME = os.getenv("MODEL_NAME")
REQUEST_TIMEOUT = int(os.getenv("REQUEST_TIMEOUT", 60))
