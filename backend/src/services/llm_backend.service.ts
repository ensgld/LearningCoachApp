import fetch from 'node-fetch';
import { config } from '../config/env';

interface EmbeddingResponse {
    embeddings: number[][];
}

interface OllamaEmbeddingResponse {
    embedding: number[];
}

interface RagAnswerResponse {
    answer: string;
}

interface ChatResponse {
    answer: string;
}

export async function embedTexts(texts: string[]): Promise<number[][]> {
    if (!config.OLLAMA_EMBEDDINGS_URL) {
        throw new Error('Ollama embeddings endpoint is not configured');
    }

    const embeddings: number[][] = [];
    for (const text of texts) {
        let lastError: Error | null = null;
        for (let attempt = 1; attempt <= 3; attempt += 1) {
            try {
                const response = await fetch(config.OLLAMA_EMBEDDINGS_URL, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ model: config.EMBEDDING_MODEL, prompt: text }),
                });
                if (!response.ok) {
                    const body = await response.text();
                    throw new Error(`Ollama embedding error: ${response.status} ${body}`);
                }
                const data = (await response.json()) as OllamaEmbeddingResponse;
                embeddings.push(data.embedding);
                lastError = null;
                break;
            } catch (error) {
                lastError = error instanceof Error ? error : new Error('Ollama embedding failed');
                if (attempt < 3) {
                    await new Promise((resolve) => setTimeout(resolve, 500 * attempt));
                }
            }
        }
        if (lastError) {
            throw lastError;
        }
    }

    return embeddings;
}

export async function answerWithContext(question: string, context: string): Promise<string> {
    const response = await fetch(`${config.LLM_BACKEND_URL}/rag/answer`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ question, context }),
    });

    if (!response.ok) {
        const body = await response.text();
        throw new Error(`LLM answer error: ${response.status} ${body}`);
    }

    const data = (await response.json()) as RagAnswerResponse;
    return data.answer;
}

export async function askCoach(message: string): Promise<string> {
    const response = await fetch(`${config.LLM_BACKEND_URL}/chat`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ message }),
    });

    if (!response.ok) {
        const body = await response.text();
        throw new Error(`LLM chat error: ${response.status} ${body}`);
    }

    const data = (await response.json()) as ChatResponse;
    return data.answer;
}
