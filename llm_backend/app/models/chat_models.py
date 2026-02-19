from pydantic import BaseModel, Field


class ChatRequest(BaseModel):
    message: str = Field(..., min_length=1)
    history: list[dict] = Field(default_factory=list)


class ChatResponse(BaseModel):
    answer: str


class EmbeddingRequest(BaseModel):
    texts: list[str] = Field(..., min_length=1)


class EmbeddingResponse(BaseModel):
    embeddings: list[list[float]]


class RagAnswerRequest(BaseModel):
    question: str = Field(..., min_length=1)
    context: str | None = None
    history: list[dict] = Field(default_factory=list)


class RagAnswerResponse(BaseModel):
    answer: str
    sources: list[dict] | None = None
