import time
import json
import asyncio
import httpx
from typing import AsyncGenerator
from app.core.config import (
    OLLAMA_URL,
    MODEL_NAME,
    EMBEDDING_MODEL,
    OLLAMA_EMBEDDINGS_URL,
    REQUEST_TIMEOUT,
    OLLAMA_KEEP_ALIVE,
    OLLAMA_GENERATE_URL,
)
from app.core.prompts import SYSTEM_PROMPT, RAG_SYSTEM_PROMPT
from app.core.logger import logger

# Global client to reuse connections (Connection Pooling)
_client: httpx.AsyncClient | None = None

def get_client() -> httpx.AsyncClient:
    global _client
    if _client is None or _client.is_closed:
        _client = httpx.AsyncClient(timeout=httpx.Timeout(REQUEST_TIMEOUT))
    return _client

async def close_client():
    global _client
    if _client:
        await _client.aclose()
        _client = None


async def preload_models():
    """
    Preload the AI model into memory by sending an empty request
    so the user doesn't have to wait during the first interaction.
    """
    logger.info(f"[{MODEL_NAME}] Preloading model...")
    payload = {
        "model": MODEL_NAME,
        "prompt": "",
        "keep_alive": OLLAMA_KEEP_ALIVE
    }
    try:
        client = get_client()
        response = await client.post(OLLAMA_GENERATE_URL, json=payload)
        response.raise_for_status()
        logger.info(f"[{MODEL_NAME}] Model preloaded successfully.")
    except Exception as e:
        logger.error(f"[{MODEL_NAME}] Failed to preload model: {e}")


async def ask_llama(user_message: str, history: list[dict] = [], stream: bool = False) -> str | AsyncGenerator:
    messages = [{"role": "system", "content": SYSTEM_PROMPT}]
    
    # Add history messages if any
    for msg in history:
        # Validate role (ollama expects 'user', 'assistant', 'system')
        if msg.get("role") in ["user", "assistant", "system"]:
            messages.append(msg)
            
    messages.append({"role": "user", "content": user_message})

    payload = {
        "model": MODEL_NAME,
        "keep_alive": OLLAMA_KEEP_ALIVE,
        "messages": messages,
        "stream": stream,
        "options": {
            "num_ctx": 8192,
            "temperature": 0.3
        }
    }

    logger.info(f"[GENERAL_CHAT] REQUEST: {user_message}")
    logger.info("LLAMA isteği gönderildi.")

    start_time = time.time()
    
    if stream:
        async def generate():
            client = get_client()
            async with client.stream("POST", OLLAMA_URL, json=payload) as response:
                response.raise_for_status()
                async for line in response.aiter_lines():
                    if line:
                        data = json.loads(line)
                        if "message" in data and "content" in data["message"]:
                            yield data["message"]["content"]
        return generate()
    else:
        client = get_client()
        response = await client.post(OLLAMA_URL, json=payload)
        response.raise_for_status()
            
        end_time = time.time()
        elapsed_ms = (end_time - start_time) * 1000

        data = response.json()
        response_content = data["message"]["content"]
        logger.info(f"[GENERAL_CHAT] RESPONSE ({elapsed_ms:.2f}ms): {response_content}")
        return response_content


async def get_embeddings(texts: list[str]) -> list[list[float]]:
    if not OLLAMA_EMBEDDINGS_URL:
        raise ValueError("OLLAMA_EMBEDDINGS_URL is not configured")

    embeddings: list[list[float]] = []
    
    client = get_client()
    for text in texts:
        payload = {
            "model": EMBEDDING_MODEL,
            "keep_alive": OLLAMA_KEEP_ALIVE,
            "prompt": text,
        }

        last_exc: Exception | None = None
        for attempt in range(1, 4):
            try:
                response = await client.post(
                    OLLAMA_EMBEDDINGS_URL,
                    json=payload
                )
                response.raise_for_status()
                data = response.json()
                embeddings.append(data["embedding"])
                last_exc = None
                break
            except httpx.HTTPError as exc:
                last_exc = exc
                detail = ""
                if hasattr(exc, "response") and exc.response is not None:
                    detail = f" | {exc.response.status_code} {exc.response.text}"
                logger.warning(
                    "Embedding request failed (attempt %s)%s", attempt, detail
                )
                if attempt < 3:
                    await asyncio.sleep(0.5 * attempt)

        if last_exc is not None:
            detail = ""
            if hasattr(last_exc, "response") and last_exc.response is not None:
                detail = f" | {last_exc.response.status_code} {last_exc.response.text}"
            logger.exception("Embedding request failed%s", detail)
            raise RuntimeError(f"Embedding request failed{detail}") from last_exc

    return embeddings


async def ask_document(question: str, context: str, history: list[dict] = [], stream: bool = False) -> str | AsyncGenerator:
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
        "keep_alive": OLLAMA_KEEP_ALIVE,
        "messages": messages,
        "stream": stream,
        "options": {
            "num_ctx": 4096,
            "temperature": 0.3
        }
    }

    logger.info(f"[DOCUMENT_CHAT] REQUEST: {question}")
    logger.info("LLAMA isteği gönderildi.")

    start_time = time.time()
    
    if stream:
        async def generate():
            client = get_client()
            async with client.stream("POST", OLLAMA_URL, json=payload) as response:
                response.raise_for_status()
                async for line in response.aiter_lines():
                    if line:
                        data = json.loads(line)
                        if "message" in data and "content" in data["message"]:
                            yield data["message"]["content"]
        return generate()
    else:
        client = get_client()
        response = await client.post(OLLAMA_URL, json=payload)
        response.raise_for_status()

        end_time = time.time()
        elapsed_ms = (end_time - start_time) * 1000

        data = response.json()
        response_content = data["message"]["content"]
        logger.info(f"[DOCUMENT_CHAT] RESPONSE ({elapsed_ms:.2f}ms): {response_content}")
        return response_content
