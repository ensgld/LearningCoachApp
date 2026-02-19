import time
import requests
from app.core.config import (
    OLLAMA_URL,
    MODEL_NAME,
    EMBEDDING_MODEL,
    OLLAMA_EMBEDDINGS_URL,
    REQUEST_TIMEOUT,
)
from app.core.prompts import SYSTEM_PROMPT, RAG_SYSTEM_PROMPT
from app.core.logger import logger


def ask_llama(user_message: str, history: list[dict] = []) -> str:
    messages = [{"role": "system", "content": SYSTEM_PROMPT}]
    
    # Add history messages if any
    for msg in history:
        # Validate role (ollama expects 'user', 'assistant', 'system')
        if msg.get("role") in ["user", "assistant", "system"]:
            messages.append(msg)
            
    messages.append({"role": "user", "content": user_message})

    payload = {
        "model": MODEL_NAME,
        "messages": messages,
        "stream": False,
    }

    logger.info("LLAMA isteği gönderildi")

    response = requests.post(OLLAMA_URL, json=payload, timeout=REQUEST_TIMEOUT)
    response.raise_for_status()

    data = response.json()
    return data["message"]["content"]


def get_embeddings(texts: list[str]) -> list[list[float]]:
    if not OLLAMA_EMBEDDINGS_URL:
        raise ValueError("OLLAMA_EMBEDDINGS_URL is not configured")

    embeddings: list[list[float]] = []
    for text in texts:
        payload = {
            "model": EMBEDDING_MODEL,
            "prompt": text,
        }

        last_exc: requests.RequestException | None = None
        for attempt in range(1, 4):
            try:
                response = requests.post(
                    OLLAMA_EMBEDDINGS_URL,
                    json=payload,
                    timeout=REQUEST_TIMEOUT,
                )
                response.raise_for_status()
                data = response.json()
                embeddings.append(data["embedding"])
                last_exc = None
                break
            except requests.RequestException as exc:
                last_exc = exc
                detail = ""
                if getattr(exc, "response", None) is not None:
                    detail = f" | {exc.response.status_code} {exc.response.text}"
                logger.warning(
                    "Embedding request failed (attempt %s)%s", attempt, detail
                )
                if attempt < 3:
                    time.sleep(0.5 * attempt)

        if last_exc is not None:
            detail = ""
            if getattr(last_exc, "response", None) is not None:
                detail = f" | {last_exc.response.status_code} {last_exc.response.text}"
            logger.exception("Embedding request failed%s", detail)
            raise RuntimeError(f"Embedding request failed{detail}") from last_exc

    return embeddings


def ask_document(question: str, context: str, history: list[dict] = []) -> str:
    messages = [{"role": "system", "content": RAG_SYSTEM_PROMPT}]
    
    # Add history messages if any
    for msg in history:
        if msg.get("role") in ["user", "assistant", "system"]:
            messages.append(msg)
    
    messages.append({
        "role": "user",
        "content": f"Bağlam:\n{context}\n\nSoru: {question}",
    })

    payload = {
        "model": MODEL_NAME,
        "messages": messages,
        "stream": False,
    }

    response = requests.post(
        OLLAMA_URL,
        json=payload,
        timeout=REQUEST_TIMEOUT,
    )
    response.raise_for_status()
    data = response.json()
    return data["message"]["content"]
