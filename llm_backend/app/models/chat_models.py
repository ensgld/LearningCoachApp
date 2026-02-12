from pydantic import BaseModel, Field


class ChatRequest(BaseModel):
    message: str = Field(..., min_length=1)


class ChatResponse(BaseModel):
    answer: str


class EmbeddingRequest(BaseModel):
    texts: list[str] = Field(..., min_length=1)


class EmbeddingResponse(BaseModel):
    embeddings: list[list[float]]


class RagAnswerRequest(BaseModel):
    question: str = Field(..., min_length=1)
    context: str = Field(..., min_length=1)


class RagAnswerResponse(BaseModel):
    answer: str
