import { Message, ApiError } from '../types/chat';
import { formatApiError } from './api';

export interface StreamCallbacks {
  onChunk: (chunkText: string) => void;
  onError: (error: ApiError) => void;
  onFinish: () => void;
}

export const googleApi = {
  // Check backend server status
  async checkHealth(): Promise<{ status: string; hasApiKey: boolean }> {
    try {
      const res = await fetch('/api/health');
      if (res.ok) {
        return await res.json();
      }
    } catch (e) {
      console.warn('Health check failed:', e);
    }
    return { status: 'offline', hasApiKey: false };
  },

  // Stream chat generation from backend
  async streamChatResponse(
    messages: Message[],
    model: string,
    systemInstruction: string,
    callbacks: StreamCallbacks,
    signal?: AbortSignal
  ): Promise<void> {
    try {
      const response = await fetch('/api/chat', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          messages,
          model,
          systemInstruction,
          stream: true,
        }),
        signal,
      });

      if (!response.ok) {
        let errJson;
        try {
          errJson = await response.json();
        } catch (e) {
          errJson = { error: { message: `Server returned HTTP ${response.status}` } };
        }
        callbacks.onError(formatApiError(errJson.error));
        return;
      }

      if (!response.body) {
        callbacks.onError({
          type: 'EMPTY_RESPONSE',
          message: 'Received empty response body from AI server.',
        });
        return;
      }

      const reader = response.body.getReader();
      const decoder = new TextDecoder('utf-8');
      let buffer = '';

      while (true) {
        const { done, value } = await reader.read();
        if (done) break;

        buffer += decoder.decode(value, { stream: true });

        // Parse SSE formatted chunks: lines starting with "data: "
        const lines = buffer.split('\n');
        buffer = lines.pop() || '';

        for (const line of lines) {
          const trimmed = line.trim();
          if (trimmed.startsWith('data: ')) {
            const dataStr = trimmed.slice(6);
            if (dataStr === '[DONE]') continue;

            try {
              const parsed = JSON.parse(dataStr);
              // Extract text candidate from Gemini SSE JSON structure
              const candidateText =
                parsed.candidates?.[0]?.content?.parts?.[0]?.text || '';
              if (candidateText) {
                callbacks.onChunk(candidateText);
              }
            } catch (err) {
              // Ignore non-JSON lines or partial chunks
            }
          }
        }
      }

      // Process any remaining buffer
      if (buffer.trim().startsWith('data: ')) {
        try {
          const parsed = JSON.parse(buffer.trim().slice(6));
          const candidateText =
            parsed.candidates?.[0]?.content?.parts?.[0]?.text || '';
          if (candidateText) {
            callbacks.onChunk(candidateText);
          }
        } catch (e) {
          // Ignore parse errors on trailing buffer
        }
      }

      callbacks.onFinish();
    } catch (err: any) {
      if (err.name === 'AbortError') {
        callbacks.onError({
          type: 'ABORTED',
          message: 'Response generation was cancelled.',
        });
      } else {
        callbacks.onError(formatApiError(err));
      }
    }
  },
};
