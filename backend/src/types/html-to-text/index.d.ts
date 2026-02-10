declare module 'html-to-text' {
    export interface HtmlToTextOptions {
        wordwrap?: number | false;
    }

    export function htmlToText(html: string, options?: HtmlToTextOptions): string;
}
