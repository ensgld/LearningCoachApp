import requests
from app.core.config import OLLAMA_URL, MODEL_NAME, REQUEST_TIMEOUT
from app.core.prompts import SYSTEM_PROMPT
from app.core.logger import logger

def ask_llama(user_message: str) -> str:
    payload = {
        "model": MODEL_NAME,
        "messages": [
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user", "content": user_message}
        ],
        "stream": False
    }

    logger.info("LLAMA isteği gönderildi")

    response = requests.post(
        OLLAMA_URL,
        json=payload,
        timeout=REQUEST_TIMEOUT
    )
    response.raise_for_status()

    data = response.json()
    return data["message"]["content"]
