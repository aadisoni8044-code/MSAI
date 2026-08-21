/**
 * Google Gemini API Client Module for MSAI
 * Handles REST requests, streaming text response, file attachment payloads, and error handling.
 */

import { getAppConfig } from './config.js';

export class GeminiApiClient {
    constructor() {
        this.currentAbortController = null;
    }

    /**
     * Formats internal application messages to the structure expected by Gemini API
     */
    _formatMessages(messages, attachments = []) {
        const contents = messages.map(msg => {
            const role = msg.role === 'assistant' ? 'model' : 'user';
            const parts = [{ text: msg.content }];
            return { role, parts };
        });

        // Attach files/images to the last user prompt if present
        if (attachments && attachments.length > 0 && contents.length > 0) {
            const lastMsg = contents[contents.length - 1];
            if (lastMsg.role === 'user') {
                attachments.forEach(att => {
                    if (att.base64 && att.mimeType) {
                        lastMsg.parts.push({
                            inlineData: {
                                mimeType: att.mimeType,
                                data: att.base64
                            }
                        });
                    }
                });
            }
        }

        return contents;
    }

    /**
     * Cancels any active generation request
     */
    cancelRequest() {
        if (this.currentAbortController) {
            this.currentAbortController.abort();
            this.currentAbortController = null;
        }
    }

    /**
     * Sends conversation to Gemini API with stream or single response
     * @param {Array} messages - List of message objects
     * @param {Array} attachments - Optional uploaded attachments
     * @param {Function} onChunk - Callback fired when stream chunk is received
     */
    async generateResponse(messages, attachments = [], onChunk = null) {
        const config = getAppConfig();

        if (!config.GEMINI_API_KEY || config.GEMINI_API_KEY === "YOUR_GOOGLE_GEMINI_API_KEY") {
            throw new Error("API_KEY_MISSING: Please configure a valid Google Gemini API Key in Settings.");
        }

        this.cancelRequest();
        this.currentAbortController = new AbortController();

        const formattedContents = this._formatMessages(messages, attachments);
        const modelName = config.MODEL || "gemini-2.5-flash";

        const endpoint = `${config.API_BASE_URL}/models/${modelName}:streamGenerateContent?alt=sse&key=${config.GEMINI_API_KEY}`;

        const payload = {
            contents: formattedContents,
            generationConfig: {
                temperature: config.TEMPERATURE || 0.7,
                maxOutputTokens: config.MAX_OUTPUT_TOKENS || 4096
            }
        };

        try {
            const response = await fetch(endpoint, {
                method: "POST",
                headers: {
                    "Content-Type": "application/json"
                },
                body: JSON.stringify(payload),
                signal: this.currentAbortController.signal
            });

            if (!response.ok) {
                const errorData = await response.json().catch(() => ({}));
                const message = errorData.error?.message || `HTTP ${response.status}: ${response.statusText}`;

                if (response.status === 400 && message.includes("API key")) {
                    throw new Error("INVALID_API_KEY: The provided Gemini API Key is invalid.");
                } else if (response.status === 429) {
                    throw new Error("RATE_LIMIT: API rate limit exceeded. Please wait a moment and try again.");
                } else if (response.status === 403) {
                    throw new Error("QUOTA_EXCEEDED: API key quota exceeded or restricted permissions.");
                } else {
                    throw new Error(`API_ERROR: ${message}`);
                }
            }

            // Stream response reader
            const reader = response.body.getReader();
            const decoder = new TextDecoder("utf-8");
            let accumulatedText = "";
            let buffer = "";

            while (true) {
                const { done, value } = await reader.read();
                if (done) break;

                buffer += decoder.decode(value, { stream: true });
                const lines = buffer.split("\n");
                buffer = lines.pop() || ""; // Keep incomplete line in buffer

                for (const line of lines) {
                    const trimmed = line.trim();
                    if (trimmed.startsWith("data:")) {
                        const jsonStr = trimmed.substring(5).trim();
                        if (!jsonStr || jsonStr === "[DONE]") continue;

                        try {
                            const parsed = JSON.parse(jsonStr);
                            const chunkText = parsed.candidates?.[0]?.content?.parts?.[0]?.text;
                            if (chunkText) {
                                accumulatedText += chunkText;
                                if (onChunk) {
                                    onChunk(accumulatedText, chunkText);
                                }
                            }
                        } catch (e) {
                            // Ignore malformed SSE chunks
                        }
                    }
                }
            }

            return accumulatedText;

        } catch (err) {
            if (err.name === 'AbortError') {
                throw new Error("USER_CANCELLED: Response generation was stopped.");
            }
            throw err;
        } finally {
            this.currentAbortController = null;
        }
    }
}

export const api = new GeminiApiClient();
