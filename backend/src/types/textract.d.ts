declare module 'textract' {
    export function fromFileWithPath(
        path: string,
        callback: (error: Error | null, text?: string) => void
    ): void;
}
