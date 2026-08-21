import { CONFIG } from './config.js';
import { storage } from './storage.js';

/**
 * Google Gemini API Service Layer
 */
export class GeminiApiService {
    constructor() {
        this.currentAbortController = null;
    }

    /**
     * Get active API Key from settings or fallback configuration
     */
    getApiKey() {
        const savedKey = storage.getSetting('api_key');
        if (savedKey && savedKey.trim() !== '') {
            return savedKey.trim();
        }
        return CONFIG.GEMINI_API_KEY;
    }

    /**
     * Format conversation messages into Google Gemini API contents payload format
     */
    formatContents(messages) {
        return messages.map(msg => {
            const role = msg.role === 'assistant' ? 'model' : 'user';
            const parts = [];

            // Add attachments if present (multimodal inline_data)
            if (msg.attachments && msg.attachments.length > 0) {
                msg.attachments.forEach(att => {
                    if (att.data && att.mimeType) {
                        parts.push({
                            inline_data: {
                                mime_type: att.mimeType,
                                data: att.data
                            }
                        });
                    }
                });
            }

            // Add text prompt
            if (msg.content) {
                parts.push({ text: msg.content });
            }

            return { role, parts };
        });
    }

    /**
     * Send messages to Gemini API with SSE streaming support
     */
    async sendMessageStream(messages, options = {}) {
        const apiKey = this.getApiKey();

        if (!apiKey || apiKey === 'YOUR_GOOGLE_GEMINI_API_KEY') {
            throw new Error('API Key is missing. Please configure your Google Gemini API key in Settings or config.js.');
        }

        const model = options.model || storage.getSetting('model', CONFIG.DEFAULT_MODEL);
        const temperature = options.temperature !== undefined ? options.temperature : CONFIG.TEMPERATURE;

        // Base Google Gemini Endpoint for SSE Streaming
        const endpoint = `https://generativelanguage.googleapis.com/v1beta/models/${model}:streamGenerateContent?alt=sse&key=${apiKey}`;

        const contents = this.formatContents(messages);

        const requestBody = {
            contents: contents,
            generationConfig: {
                temperature: temperature
            }
        };

        this.currentAbortController = new AbortController();

        try {
            const response = await fetch(endpoint, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(requestBody),
                signal: this.currentAbortController.signal
            });

            if (!response.ok) {
                const errorData = await response.json().catch(() => ({}));
                const status = response.status;

                if (status === 400 || status === 403) {
                    throw new Error(errorData.error?.message || 'Invalid API Key or unauthorized request. Please check your Gemini API key.');
                } else if (status === 429) {
                    throw new Error('Rate limit exceeded or quota exhausted. Please try again in a few moments.');
                } else {
                    throw new Error(errorData.error?.message || `Server error (${status}). Please try again later.`);
                }
            }

            // Return reader for stream processing in UI
            const reader = response.body.getReader();
            const decoder = new TextDecoder('utf-8');

            return {
                async *[Symbol.asyncIterator]() {
                    let buffer = '';

                    while (true) {
                        const { done, value } = await reader.read();
                        if (done) break;

                        buffer += decoder.decode(value, { stream: true });
                        const lines = buffer.split('\n');
                        buffer = lines.pop() || ''; // keep incomplete last line in buffer

                        for (const line of lines) {
                            const trimmed = line.trim();
                            if (trimmed.startsWith('data: ')) {
                                const jsonStr = trimmed.substring(6);
                                if (jsonStr === '[DONE]') continue;
                                try {
                                    const parsed = JSON.parse(jsonStr);
                                    const textChunk = parsed.candidates?.[0]?.content?.parts?.[0]?.text;
                                    if (textChunk) {
                                        yield textChunk;
                                    }
                                } catch (e) {
                                    // Skip invalid JSON chunks
                                }
                            }
                        }
                    }
                }
            };
        } catch (error) {
            if (error.name === 'AbortError') {
                throw new Error('Request cancelled by user.');
            }
            throw error;
        } finally {
            this.currentAbortController = null;
        }
    }

    /**
     * Stop active API request generation
     */
    stopGeneration() {
        if (this.currentAbortController) {
            this.currentAbortController.abort();
            this.currentAbortController = null;
        }
    }
}

export const apiService = new GeminiApiService();
