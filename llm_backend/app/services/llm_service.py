import time
import json
import asyncio
import httpx
import re
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
from app.core.prompts import (
    SYSTEM_PROMPT,
    RAG_SYSTEM_PROMPT,
    QUIZ_SYSTEM_PROMPT,
    FLASHCARD_SYSTEM_PROMPT,
    QUIZ_VERIFICATION_PROMPT,
    FLASHCARD_VERIFICATION_PROMPT,
    RAG_VERIFICATION_PROMPT,
)
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


def _alternate_chat_url(url: str) -> str | None:
    if "/api/chat" in url:
        return url.replace("/api/chat", "/v1/chat/completions")
    if "/v1/chat/completions" in url:
        return url.replace("/v1/chat/completions", "/api/chat")
    return None


def _extract_message_content(data: dict) -> str:
    message = data.get("message")
    if isinstance(message, dict) and "content" in message:
        return str(message["content"])

    choices = data.get("choices")
    if isinstance(choices, list) and choices:
        first = choices[0]
        if isinstance(first, dict):
            msg = first.get("message")
            if isinstance(msg, dict) and "content" in msg:
                return str(msg["content"])

    raise ValueError("Could not extract message content from LLM response")


def _extract_json_block(text: str) -> str:
    match = re.search(r"(\{.*\}|\[.*\])", text, re.DOTALL)
    return match.group(0) if match else text


def _language_priority_directive(instructions: str | None = None) -> str:
    directive = (
        "Dil Öncelik Kuralı: "
        "Eğer Özel Talimatlar içinde açık bir dil isteği varsa (ör. 'İngilizce hazırla', 'Türkçe üret') "
        "önce onu uygula. Açık dil isteği yoksa dokümanın baskın dilini kullan."
    )
    if instructions:
        return f"{directive}\n\nÖzel Talimatlar:\n{instructions}"
    return directive


def _detect_explicit_language(instructions: str | None) -> str | None:
    if not instructions:
        return None

    lowered = instructions.lower()
    if any(token in lowered for token in ["türkçe", "turkce", "turkish"]):
        return "Türkçe"
    if any(token in lowered for token in ["ingilizce", "english"]):
        return "English"
    return None


def _infer_context_language(context: str) -> str:
    lowered = context.lower()

    tr_markers = [
        " ve ",
        " için ",
        " ile ",
        " bir ",
        " bu ",
        "ö",
        "ü",
        "ğ",
        "ş",
        "ı",
        "ç",
    ]
    en_markers = [" the ", " and ", " with ", " of ", " in ", " is ", " are "]

    tr_score = sum(lowered.count(marker) for marker in tr_markers)
    en_score = sum(lowered.count(marker) for marker in en_markers)

    if en_score > tr_score:
        return "English"
    return "Türkçe"


def _resolve_output_language(context: str, instructions: str | None) -> str:
    explicit = _detect_explicit_language(instructions)
    if explicit:
        return explicit
    return _infer_context_language(context)


def _language_quality_directive(language: str) -> str:
    if language == "Türkçe":
        return (
            "Dil Kalitesi: Sadece doğal ve akıcı Türkçe kullan. "
            "Uydurma/bozuk kelime üretme. Türkçe karakterleri (ç, ğ, ı, İ, ö, ş, ü) doğru kullan."
        )
    return (
        "Language Quality: Use natural, grammatically correct English. "
        "Do not invent malformed words."
    )


async def _call_chat(
    messages: list[dict], options: dict | None = None, force_json: bool = False
) -> str:
    chat_urls = [OLLAMA_URL]
    alternate = _alternate_chat_url(OLLAMA_URL)
    if alternate:
        chat_urls.append(alternate)

    client = get_client()
    last_exc: Exception | None = None

    for idx, url in enumerate(chat_urls):
        try:
            if "/v1/chat/completions" in url:
                payload = {
                    "model": MODEL_NAME,
                    "messages": messages,
                    "stream": False,
                }
                if options:
                    if "temperature" in options:
                        payload["temperature"] = options["temperature"]
                response = await client.post(url, json=payload)
            else:
                payload = {
                    "model": MODEL_NAME,
                    "keep_alive": OLLAMA_KEEP_ALIVE,
                    "messages": messages,
                    "stream": False,
                }
                if options:
                    payload["options"] = options
                if force_json:
                    payload["format"] = "json"
                response = await client.post(url, json=payload)

            response.raise_for_status()
            return _extract_message_content(response.json())
        except httpx.HTTPStatusError as exc:
            last_exc = exc
            if exc.response is not None and exc.response.status_code == 404:
                response_text = (exc.response.text or "").lower()
                if "model" in response_text and "not found" in response_text:
                    raise RuntimeError(
                        f"Model not found: {MODEL_NAME}. Please pull/select an available model."
                    ) from exc
                if idx < len(chat_urls) - 1:
                    logger.warning(
                        "Chat endpoint not found at %s, trying fallback endpoint...",
                        url,
                    )
                    continue
            raise
        except Exception as exc:
            last_exc = exc
            if idx < len(chat_urls) - 1:
                logger.warning(
                    "Chat request failed at %s, trying fallback endpoint...", url
                )
                continue
            raise

    if last_exc:
        raise last_exc
    raise RuntimeError("No chat endpoint available")


async def preload_models():
    """
    Preload the AI model into memory by sending an empty request
    so the user doesn't have to wait during the first interaction.
    """
    logger.info(f"[{MODEL_NAME}] Preloading model...")
    payload = {"model": MODEL_NAME, "prompt": "", "keep_alive": OLLAMA_KEEP_ALIVE}
    try:
        client = get_client()
        response = await client.post(OLLAMA_GENERATE_URL, json=payload)
        if response.status_code == 404:
            logger.warning(
                "Generate endpoint not found, trying chat endpoint for warm-up..."
            )
            await _call_chat(
                messages=[
                    {"role": "system", "content": "You are a helpful assistant."},
                    {"role": "user", "content": ""},
                ],
                options={"num_ctx": 2048, "temperature": 0.0},
            )
        else:
            response.raise_for_status()
        logger.info(f"[{MODEL_NAME}] Model preloaded successfully.")
    except Exception as e:
        logger.error(f"[{MODEL_NAME}] Failed to preload model: {e}")


async def ask_llama(
    user_message: str, history: list[dict] = [], stream: bool = False
) -> str | AsyncGenerator:
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
        "options": {"num_ctx": 8192, "temperature": 0.3},
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
        response_content = await _call_chat(
            messages=messages, options={"num_ctx": 8192, "temperature": 0.3}
        )

        end_time = time.time()
        elapsed_ms = (end_time - start_time) * 1000
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
                response = await client.post(OLLAMA_EMBEDDINGS_URL, json=payload)
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


async def ask_document(
    question: str,
    context: str,
    history: list[dict] = [],
    stream: bool = False,
) -> str | AsyncGenerator:
    resolved_language = _infer_context_language(context)
    messages = [{"role": "system", "content": RAG_SYSTEM_PROMPT}]

    # Add history messages if any
    for msg in history:
        if msg.get("role") in ["user", "assistant", "system"]:
            messages.append(msg)

    messages.append(
        {
            "role": "user",
            "content": (
                f"Bağlam:\n{context}\n\n"
                f"Soru: {question}\n\n"
                f"ÇIKTI DİLİ: {resolved_language}.\n"
                f"{_language_quality_directive(resolved_language)}"
            ),
        }
    )

    payload = {
        "model": MODEL_NAME,
        "keep_alive": OLLAMA_KEEP_ALIVE,
        "messages": messages,
        "stream": stream,
        "options": {"num_ctx": 4096, "temperature": 0.3},
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
        draft_response = await _call_chat(
            messages=messages, options={"num_ctx": 4096, "temperature": 0.3}
        )

        verified_response = draft_response
        try:
            verified_response = await _call_chat(
                messages=[
                    {"role": "system", "content": RAG_VERIFICATION_PROMPT},
                    {
                        "role": "user",
                        "content": (
                            f"Bağlam:\n{context}\n\n"
                            f"Soru:\n{question}\n\n"
                            f"ÇIKTI DİLİ: {resolved_language}.\n"
                            f"{_language_quality_directive(resolved_language)}\n\n"
                            f"İlk Cevap:\n{draft_response}"
                        ),
                    },
                ],
                options={"num_ctx": 4096, "temperature": 0.1},
            )
        except Exception as verify_error:
            logger.warning(
                "RAG verification failed, using draft response: %s", verify_error
            )

        end_time = time.time()
        elapsed_ms = (end_time - start_time) * 1000

        logger.info(
            f"[DOCUMENT_CHAT] RESPONSE ({elapsed_ms:.2f}ms): {verified_response}"
        )
        return verified_response


async def generate_quiz(
    context: str,
    count: int,
    difficulty: str,
    instructions: str | None = None,
) -> str:
    messages = [{"role": "system", "content": QUIZ_SYSTEM_PROMPT}]
    resolved_output_language = _resolve_output_language(context, instructions)

    req_text = f"Bağlam:\n{context}\n\nİstek: Lütfen bu bağlama göre {count} adet {difficulty} (zorluk) seviyede soru içeren bir seçenekli test hazırla."
    req_text += f"\n\n{_language_priority_directive(instructions)}"
    req_text += f"\nÇIKTI DİLİ: {resolved_output_language}."
    req_text += f"\n{_language_quality_directive(resolved_output_language)}"

    messages.append(
        {
            "role": "user",
            "content": req_text,
        }
    )

    draft_json = await _call_chat(messages=messages, force_json=True)
    draft_json = _extract_json_block(draft_json)

    try:
        verified_json = await _call_chat(
            messages=[
                {"role": "system", "content": QUIZ_VERIFICATION_PROMPT},
                {
                    "role": "user",
                    "content": (
                        f"Bağlam:\n{context}\n\n"
                        f"{_language_priority_directive(instructions)}\n\n"
                        f"ÇIKTI DİLİ: {resolved_output_language}.\n\n"
                        f"{_language_quality_directive(resolved_output_language)}\n\n"
                        f"Quiz JSON:\n{draft_json}"
                    ),
                },
            ],
            force_json=True,
            options={"num_ctx": 4096, "temperature": 0.1},
        )
        return _extract_json_block(verified_json)
    except Exception as verify_error:
        logger.warning("Quiz verification failed, using draft JSON: %s", verify_error)
        return draft_json


async def generate_flashcards(
    context: str,
    count: int,
    difficulty: str,
    instructions: str | None = None,
) -> str:
    messages = [{"role": "system", "content": FLASHCARD_SYSTEM_PROMPT}]
    resolved_output_language = _resolve_output_language(context, instructions)

    req_text = f"Bağlam:\n{context}\n\nİstek: Lütfen bu bağlama göre {count} adet {difficulty} (zorluk) seviyede flash kart hazırla."
    req_text += f"\n\n{_language_priority_directive(instructions)}"
    req_text += f"\nÇIKTI DİLİ: {resolved_output_language}."
    req_text += f"\n{_language_quality_directive(resolved_output_language)}"

    messages.append(
        {
            "role": "user",
            "content": req_text,
        }
    )

    draft_json = await _call_chat(messages=messages, force_json=True)
    draft_json = _extract_json_block(draft_json)

    try:
        verified_json = await _call_chat(
            messages=[
                {"role": "system", "content": FLASHCARD_VERIFICATION_PROMPT},
                {
                    "role": "user",
                    "content": (
                        f"Bağlam:\n{context}\n\n"
                        f"{_language_priority_directive(instructions)}\n\n"
                        f"ÇIKTI DİLİ: {resolved_output_language}.\n\n"
                        f"{_language_quality_directive(resolved_output_language)}\n\n"
                        f"Flashcards JSON:\n{draft_json}"
                    ),
                },
            ],
            force_json=True,
            options={"num_ctx": 4096, "temperature": 0.1},
        )
        return _extract_json_block(verified_json)
    except Exception as verify_error:
        logger.warning(
            "Flashcard verification failed, using draft JSON: %s", verify_error
        )
        return draft_json
