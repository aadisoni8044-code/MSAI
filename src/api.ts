import { GoogleGenerativeAI } from '@google/generative-ai';

const geminiApiKey = import.meta.env.VITE_GEMINI_API_KEY || '';
const isGeminiConfigured = geminiApiKey.length > 0 && !geminiApiKey.includes('YOUR_GEMINI_API_KEY');

const genAI = isGeminiConfigured ? new GoogleGenerativeAI(geminiApiKey) : null;

export interface ChatMessage {
  id: string;
  role: 'user' | 'model';
  content: string;
  timestamp: number;
  webSearchUsed?: boolean;
}

export class GeminiApiService {
  /**
   * Stream chat response from Gemini API or fallback mock stream if key is placeholder
   */
  public async *streamChatResponse(
    messages: { role: 'user' | 'model'; content: string }[],
    prompt: string,
    webSearchEnabled: boolean = false
  ): AsyncGenerator<string, void, unknown> {
    if (isGeminiConfigured && genAI) {
      try {
        // Use gemini-1.5-flash model
        const model = genAI.getGenerativeModel({ model: 'gemini-1.5-flash' });

        let fullPrompt = prompt;
        if (webSearchEnabled) {
          fullPrompt = `[Web Search Mode Enabled: Provide factual, up-to-date, structured information.]\n\n${prompt}`;
        }

        const history = messages.map(m => ({
          role: m.role === 'user' ? 'user' : 'model',
          parts: [{ text: m.content }]
        }));

        const chat = model.startChat({
          history: history,
        });

        const resultStream = await chat.sendMessageStream(fullPrompt);

        for await (const chunk of resultStream.stream) {
          const chunkText = chunk.text();
          yield chunkText;
        }
        return;
      } catch (err: any) {
        console.warn('Gemini API call failed, falling back to smart simulated stream:', err);
        // Fall through to simulated stream with error note
        yield `*(Note: Gemini API returned an error: ${err.message || 'API key issue'}. Displaying fallback response.)*\n\n`;
      }
    }

    // Simulated streaming response for offline / demo mode
    const simulatedText = this.generateSimulatedResponse(prompt, webSearchEnabled);
    const words = simulatedText.split(' ');

    for (let i = 0; i < words.length; i++) {
      yield (i === 0 ? '' : ' ') + words[i];
      // Delay to simulate token streaming speed
      await new Promise(resolve => setTimeout(resolve, 25));
    }
  }

  private generateSimulatedResponse(prompt: string, webSearchEnabled: boolean): string {
    const lower = prompt.toLowerCase();

    if (webSearchEnabled) {
      return `🔍 **Web Search Results for:** "${prompt}"\n\n` +
             `Based on recent real-time web intelligence:\n\n` +
             `1. **Key Insights**: MS AI has analyzed live data regarding "${prompt}".\n` +
             `2. **Summary**: Current trends and developments highlight rapid progress in AI reasoning, web integration, and high-performance frontend interfaces.\n` +
             `3. **Verification**: Sources confirm that seamless AI assistance empowers users to draft content, generate code, and structure plans rapidly.`;
    }

    if (lower.includes('image') || lower.includes('picture') || lower.includes('draw')) {
      return `🖼️ **Image Generation Request Received**\n\n` +
             `I have processed your prompt: *"${prompt}"*.\n\n` +
             `*[Image Generation Stub]*: An ultra-high-definition preview image has been queued for render. (In a production environment, this connects directly to Imagen 3 / DALL-E endpoints).`;
    }

    if (lower.includes('code') || lower.includes('typescript') || lower.includes('function') || lower.includes('html')) {
      return `Here is a clean, modular solution tailored to your request:\n\n` +
             `\`\`\`typescript\n` +
             `// Solution for: ${prompt.slice(0, 40)}...\n` +
             `export function processData<T>(input: T[]): { success: boolean; data: T[] } {\n` +
             `  console.log("Processing input with MS AI engine...");\n` +
             `  return {\n` +
             `    success: true,\n` +
             `    data: input.filter(Boolean)\n` +
             `  };\n` +
             `}\n` +
             `\`\`\`\n\n` +
             `This snippet utilizes TypeScript strict typing and modular exports. Let me know if you'd like to extend or refactor this!`;
    }

    if (lower.includes('plan') || lower.includes('schedule') || lower.includes('step')) {
      return `📋 **Action Plan Created by MS AI**\n\n` +
             `Here is a structured step-by-step plan for your goal:\n\n` +
             `1. **Phase 1: Discovery & Definition**\n` +
             `   - Clarify objectives, core metrics, and timeline requirements.\n\n` +
             `2. **Phase 2: Execution & Implementation**\n` +
             `   - Build prototype modules and test edge cases early.\n\n` +
             `3. **Phase 3: Review & Optimization**\n` +
             `   - Run performance benchmarks, verify UX response, and finalize delivery.`;
    }

    return `I am **MS AI**, your advanced AI workspace assistant powered by Google Gemini.\n\n` +
           `Regarding: *"${prompt}"*\n\n` +
           `I can assist you with comprehensive analysis, creative writing, code debugging, and strategic planning. Feel free to enable the **Search** toggle below whenever you need up-to-date online information!`;
  }
}

export const geminiApi = new GeminiApiService();
