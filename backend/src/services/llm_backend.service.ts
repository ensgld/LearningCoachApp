import fetch from 'node-fetch';
import { config } from '../config/env';

interface EmbeddingResponse {
    embeddings: number[][];
}

interface RagAnswerResponse {
    answer: string;
}

interface ChatResponse {
    answer: string;
}

export async function embedTexts(texts: string[]): Promise<number[][]> {
    let lastError: Error | null = null;
    for (let attempt = 1; attempt <= 3; attempt += 1) {
        try {
            const response = await fetch(`${config.LLM_BACKEND_URL}/rag/embeddings`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ texts }),
            });
            if (!response.ok) {
                const body = await response.text();
                throw new Error(`Embedding error: ${response.status} ${body}`);
            }
            const data = (await response.json()) as EmbeddingResponse;
            return data.embeddings;
        } catch (error) {
            lastError = error instanceof Error ? error : new Error('Embedding request failed');
            if (attempt < 3) {
                await new Promise((resolve) => setTimeout(resolve, 500 * attempt));
            }
        }
    }
    throw lastError!;
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
