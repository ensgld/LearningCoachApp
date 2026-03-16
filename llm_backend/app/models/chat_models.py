from pydantic import BaseModel, Field
from typing import Literal


class ChatRequest(BaseModel):
    message: str = Field(..., min_length=1)
    history: list[dict] = Field(default_factory=list)
    stream: bool = False


class ChatResponse(BaseModel):
    answer: str


class EmbeddingRequest(BaseModel):
    texts: list[str] = Field(..., min_length=1)


class EmbeddingResponse(BaseModel):
    embeddings: list[list[float]]


class RagAnswerRequest(BaseModel):
    question: str = Field(..., min_length=1)
    context: str = Field(..., min_length=1)
    history: list[dict] = Field(default_factory=list)
    stream: bool = False


class RagAnswerResponse(BaseModel):
    answer: str


# ── Quiz / Test Sorusu Üretimi ─────────────────────────────────────────────────

class QuizGenerateRequest(BaseModel):
    context: str = Field(..., min_length=1, description="Doküman bağlamı (chunk metinleri)")
    count: int = Field(default=10, ge=1, le=25, description="Üretilecek soru sayısı")
    difficulty: Literal["easy", "medium", "hard"] = Field(default="medium")
    instructions: str | None = Field(default=None, description="Opsiyonel özel talimatlar")


class QuizQuestion(BaseModel):
    question: str
    options: list[str]  # [A, B, C, D]
    answer: str          # "A" | "B" | "C" | "D"
    explanation: str


class QuizGenerateResponse(BaseModel):
    questions: list[QuizQuestion]


# ── Flash Kart Üretimi ─────────────────────────────────────────────────────────

class FlashcardGenerateRequest(BaseModel):
    context: str = Field(..., min_length=1, description="Doküman bağlamı (chunk metinleri)")
    count: int = Field(default=15, ge=1, le=25, description="Üretilecek kart sayısı")
    difficulty: Literal["easy", "medium", "hard"] = Field(default="medium")
    instructions: str | None = Field(default=None, description="Opsiyonel özel talimatlar")


class Flashcard(BaseModel):
    front: str   # ön yüz: kavram / soru
    back: str    # arka yüz: tanım / cevap


class FlashcardGenerateResponse(BaseModel):
    cards: list[Flashcard]
