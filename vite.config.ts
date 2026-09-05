import path from 'path';
import { defineConfig, Plugin } from 'vite';
import { GoogleGenAI } from '@google/genai';

const DEPRECATED_MODELS_MAP: Record<string, string> = {
  'gemini-2.0-flash': 'gemini-3.8-flash',
  'gemini-2.0-pro': 'gemini-3.1-pro-preview',
  'gemini-2.0-flash-thinking': 'gemini-3.8-flash',
  'gemini-1.5-flash': 'gemini-3.8-flash',
  'gemini-1.5-pro': 'gemini-3.8-flash',
  'gemini-pro': 'gemini-3.8-flash',
};

function resolveValidModel(rawModel?: string): string {
  if (!rawModel) return 'gemini-3.8-flash';
  const clean = rawModel.replace(/^models\//, '');
  if (DEPRECATED_MODELS_MAP[clean]) {
    return DEPRECATED_MODELS_MAP[clean];
  }
  return clean;
}

function geminiApiPlugin(): Plugin {
  return {
    name: 'gemini-api-plugin',
    configureServer(server) {
      server.middlewares.use('/api/chat', async (req, res) => {
        if (req.method !== 'POST') {
          res.statusCode = 405;
          res.end(JSON.stringify({ error: 'Method not allowed' }));
          return;
        }

        let body = '';
        req.on('data', chunk => {
          body += chunk;
        });

        req.on('end', async () => {
          try {
            const apiKey = process.env.GEMINI_API_KEY;
            if (!apiKey) {
              res.statusCode = 400;
              res.setHeader('Content-Type', 'application/json');
              res.end(JSON.stringify({
                error: 'GEMINI_API_KEY environment variable is missing on server.'
              }));
              return;
            }

            const data = JSON.parse(body || '{}');
            const { contents, systemInstruction, model = 'gemini-3.8-flash', generationConfig } = data;
            const targetModel = resolveValidModel(model);

            const ai = new GoogleGenAI({
              apiKey,
              httpOptions: {
                headers: {
                  'User-Agent': 'aistudio-build',
                }
              }
            });

            const response = await ai.models.generateContent({
              model: targetModel,
              contents: contents || [],
              config: {
                systemInstruction: systemInstruction || 'You are MSAI, a helpful, intelligent, modern, and empathetic AI assistant. Format your answers cleanly using Markdown.',
                temperature: generationConfig?.temperature ?? 0.7,
                maxOutputTokens: generationConfig?.maxOutputTokens ?? 4096,
              }
            });

            res.statusCode = 200;
            res.setHeader('Content-Type', 'application/json');
            res.end(JSON.stringify({
              text: response.text,
              candidates: response.candidates,
              usageMetadata: response.usageMetadata
            }));
          } catch (err: any) {
            console.error('Gemini API proxy error:', err);
            res.statusCode = 500;
            res.setHeader('Content-Type', 'application/json');
            res.end(JSON.stringify({
              error: err?.message || 'Error communicating with Gemini API'
            }));
          }
        });
      });
    }
  };
}

export default defineConfig({
  plugins: [geminiApiPlugin()],
  server: {
    port: 3000,
    host: '0.0.0.0',
    hmr: process.env.DISABLE_HMR !== 'true',
    watch: process.env.DISABLE_HMR === 'true' ? null : {},
  },
});
