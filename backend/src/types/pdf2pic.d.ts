declare module 'pdf2pic' {
    export interface ConvertOptions {
        density?: number;
        format?: string;
        saveFilename?: string;
        savePath?: string;
        width?: number;
        height?: number;
    }

    export interface ConvertResult {
        path?: string;
    }

    export function fromPath(path: string, options?: ConvertOptions): (page: number) => Promise<ConvertResult>;
}
