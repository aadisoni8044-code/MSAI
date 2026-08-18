import { GoogleGenAI } from "@google/genai";
import { ChatMessage } from "./firebase-service";

export interface ModeConfig {
  id: string;
  name: string;
  description: string;
  icon: string;
  temperature: number;
  systemInstruction: string;
  welcomeMessage: string;
}

export class GeminiService {
  private apiKeyKey = "ms_ai_gemini_api_key";
  private defaultModel = "gemini-2.0-flash";

  public getApiKey(): string {
    return localStorage.getItem(this.apiKeyKey) || "";
  }

  public setApiKey(apiKey: string): void {
    localStorage.setItem(this.apiKeyKey, apiKey.trim());
  }

  public async generateResponse(
    messages: ChatMessage[],
    mode: ModeConfig,
    onChunk?: (chunkText: string) => void
  ): Promise<string> {
    const apiKey = this.getApiKey();

    if (!apiKey) {
      // Helpful fallback response if API key hasn't been set yet
      const mockReply = `⚠️ **Gemini API Key Required**\n\nTo communicate live with Google Gemini API, please configure your Gemini API Key in **Settings** (gear icon bottom left or top right).\n\n*System Mode Active*: **${mode.name}**\n\n*Prompt received*: "${messages[messages.length - 1]?.content || ''}"`;
      if (onChunk) onChunk(mockReply);
      return mockReply;
    }

    try {
      const ai = new GoogleGenAI({ apiKey });

      // Build conversation contents for Gemini API SDK
      const contents = messages
        .filter(m => m.role === 'user' || m.role === 'model')
        .map(m => ({
          role: m.role,
          parts: [{ text: m.content }]
        }));

      const responseStream = await ai.models.generateContentStream({
        model: this.defaultModel,
        contents: contents,
        config: {
          systemInstruction: mode.systemInstruction,
          temperature: mode.temperature,
        }
      });

      let fullText = "";
      for await (const chunk of responseStream) {
        const text = chunk.text || "";
        fullText += text;
        if (onChunk) {
          onChunk(fullText);
        }
      }

      return fullText;
    } catch (error: any) {
      console.error("Error calling Gemini API:", error);
      const errMessage = `❌ **Error from Gemini API**: ${error?.message || error || "Unknown error occurred."}\n\nPlease check your API key in settings or network connection.`;
      if (onChunk) onChunk(errMessage);
      return errMessage;
    }
  }
}

export const geminiService = new GeminiService();
