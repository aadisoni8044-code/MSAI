import express from "express";
import path from "path";
import { createServer as createViteServer } from "vite";
import { GoogleGenAI } from "@google/genai";
import dotenv from "dotenv";

dotenv.config();

const app = express();
const PORT = 3000;

app.use(express.json({ limit: "50mb" }));
app.use(express.urlencoded({ extended: true, limit: "50mb" }));

// Helper to get initialized GoogleGenAI client
function getGeminiClient(customApiKey?: string) {
  const key = customApiKey || process.env.GEMINI_API_KEY;
  if (!key) {
    throw new Error("GEMINI_API_KEY is not configured in the server environment or request.");
  }
  return new GoogleGenAI({
    apiKey: key,
    httpOptions: {
      headers: {
        "User-Agent": "aistudio-build",
      },
    },
  });
}

// Map any legacy or deprecated model IDs to modern supported models
function normalizeModel(modelName?: string): string {
  if (!modelName) return "gemini-3.7-flash";
  const m = modelName.trim().toLowerCase();

  if (m === "gemini-2.5-pro" || m === "gemini-2.0-pro" || m === "gemini-1.5-pro" || (m.includes("pro") && !m.includes("3.1-pro"))) {
    return "gemini-3.1-pro-preview";
  }
  if (m === "gemini-2.5-flash-lite" || m === "gemini-2.0-flash-lite" || (m.includes("lite") && !m.includes("3.1-flash-lite"))) {
    return "gemini-3.1-flash-lite";
  }
  if (m === "gemini-2.5-flash" || m === "gemini-2.0-flash" || m === "gemini-1.5-flash" || m === "gemini-pro") {
    return "gemini-3.7-flash";
  }
  return modelName;
}

// Helper to extract clean human-readable error messages from GenAI errors
function extractErrorMessage(err: any): string {
  if (!err) return "An unexpected error occurred. Please try again.";
  let msg = err.message || String(err);

  // Try parsing nested JSON string error messages
  try {
    if (typeof msg === "string" && msg.includes("{")) {
      const jsonStart = msg.indexOf("{");
      const jsonEnd = msg.lastIndexOf("}");
      if (jsonStart !== -1 && jsonEnd !== -1 && jsonEnd > jsonStart) {
        const parsed = JSON.parse(msg.slice(jsonStart, jsonEnd + 1));
        if (parsed.error?.message) {
          msg = parsed.error.message;
        }
      }
    }
  } catch {
    // Not a JSON string
  }

  const lower = String(msg).toLowerCase();

  // 1. Invalid API Key
  if (
    lower.includes("api key not valid") ||
    lower.includes("invalid_argument") ||
    lower.includes("api_key_invalid") ||
    lower.includes("gemini_api_key") ||
    lower.includes("api key is missing") ||
    lower.includes("unauthenticated")
  ) {
    return "Your Gemini API key is invalid or missing. Please check your API configuration.";
  }

  // 2. 429 / high demand / quota / 503
  if (
    lower.includes("quota exceeded") ||
    lower.includes("resource_exhausted") ||
    lower.includes("429") ||
    lower.includes("rate-limits") ||
    lower.includes("rate limit") ||
    lower.includes("503") ||
    lower.includes("high demand") ||
    lower.includes("unavailable") ||
    lower.includes("overloaded")
  ) {
    return "MSAI is temporarily busy. Please try again in a few moments.";
  }

  // 3. Model unavailable / 404
  if (lower.includes("404") || lower.includes("not_found") || lower.includes("model is unavailable")) {
    return "The selected AI model is currently unavailable. Please choose another model.";
  }

  // 4. Request timeout
  if (lower.includes("timeout") || lower.includes("timed out") || lower.includes("deadline")) {
    return "The request timed out. Please try again.";
  }

  return "An unexpected error occurred. Please try again.";
}

// Health check endpoint
app.get("/api/health", (_req, res) => {
  res.json({
    status: "ok",
    app: "MSAI",
    hasServerKey: Boolean(process.env.GEMINI_API_KEY),
    timestamp: new Date().toISOString(),
  });
});

// Available models endpoint
app.get("/api/models", (_req, res) => {
  res.json({
    models: [
      {
        id: "gemini-3.7-flash",
        name: "Gemini 3.7 Flash",
        badge: "Recommended",
        description: "Next-gen multimodal reasoning, speed, and advanced coding intelligence",
        contextWindow: "1M tokens",
        supportsMultimodal: true,
      },
      {
        id: "gemini-3.1-pro-preview",
        name: "Gemini 3.1 Pro",
        badge: "Deep Reasoning",
        description: "Complex STEM reasoning, deep math, advanced architecture design",
        contextWindow: "2M tokens",
        supportsMultimodal: true,
      },
      {
        id: "gemini-3.1-flash-lite",
        name: "Gemini 3.1 Flash Lite",
        badge: "Lightweight",
        description: "Ultra-fast and resource-efficient for responsive chats",
        contextWindow: "1M tokens",
        supportsMultimodal: true,
      },
    ],
  });
});

// Chat generation & streaming endpoint
app.post("/api/chat", async (req, res) => {
  try {
    const {
      messages = [],
      model = "gemini-3.7-flash",
      systemInstruction = "You are MSAI, a modern, highly capable, intelligent AI assistant. Provide helpful, accurate, beautifully formatted markdown answers with clear code snippets when appropriate.",
      temperature = 0.7,
      stream = true,
      customApiKey,
    } = req.body;

    if (!Array.isArray(messages) || messages.length === 0) {
      return res.status(400).json({ error: { message: "Messages array cannot be empty." } });
    }

    const ai = getGeminiClient(customApiKey);
    const targetModel = normalizeModel(model);

    // Format messages for Google GenAI SDK
    const contents = messages.map((m: any) => {
      const parts: any[] = [];

      // Multimodal attachments
      if (m.attachments && Array.isArray(m.attachments)) {
        for (const att of m.attachments) {
          if (att.data && att.mimeType) {
            const cleanBase64 = att.data.replace(/^data:[^;]+;base64,/, "");
            parts.push({
              inlineData: {
                mimeType: att.mimeType,
                data: cleanBase64,
              },
            });
          }
        }
      }

      // Text prompt
      if (m.content) {
        parts.push({ text: m.content });
      }

      return {
        role: m.role === "assistant" ? "model" : "user",
        parts,
      };
    });

    const configPayload: any = {
      temperature: Number(temperature) || 0.7,
    };

    if (systemInstruction && systemInstruction.trim()) {
      configPayload.systemInstruction = systemInstruction.trim();
    }

    let activeModel = targetModel;
    const fallbackModel = activeModel !== "gemini-3.7-flash" ? "gemini-3.7-flash" : "gemini-3.1-flash-lite";

    if (stream) {
      let streamIterator: any = null;
      let firstChunkResult: any = null;

      // 1. Try initiating stream and obtaining first chunk before committing HTTP headers
      try {
        const primaryStream = await ai.models.generateContentStream({
          model: activeModel,
          contents,
          config: configPayload,
        });
        streamIterator = primaryStream[Symbol.asyncIterator]();
        firstChunkResult = await streamIterator.next();
      } catch (firstErr: any) {
        console.warn(`Primary model ${activeModel} failed:`, firstErr?.message);
        if (activeModel !== fallbackModel) {
          activeModel = fallbackModel;
          console.log(`Falling back to ${activeModel}...`);
          try {
            const fallbackStream = await ai.models.generateContentStream({
              model: activeModel,
              contents,
              config: configPayload,
            });
            streamIterator = fallbackStream[Symbol.asyncIterator]();
            firstChunkResult = await streamIterator.next();
          } catch (secondErr: any) {
            throw secondErr;
          }
        } else {
          throw firstErr;
        }
      }

      // 2. Set headers and stream chunks
      res.setHeader("Content-Type", "text/event-stream");
      res.setHeader("Cache-Control", "no-cache");
      res.setHeader("Connection", "keep-alive");
      res.flushHeaders?.();

      // Output the first chunk if present
      if (firstChunkResult && !firstChunkResult.done && firstChunkResult.value) {
        const text = firstChunkResult.value.text || "";
        if (text) {
          res.write(`data: ${JSON.stringify({ text })}\n\n`);
        }
      }

      // Continue reading remaining chunks
      if (streamIterator && (!firstChunkResult || !firstChunkResult.done)) {
        while (true) {
          const nextChunk = await streamIterator.next();
          if (nextChunk.done) break;
          const text = nextChunk.value?.text || "";
          if (text) {
            res.write(`data: ${JSON.stringify({ text })}\n\n`);
          }
        }
      }

      res.write("data: [DONE]\n\n");
      return res.end();
    } else {
      let response;
      try {
        response = await ai.models.generateContent({
          model: activeModel,
          contents,
          config: configPayload,
        });
      } catch (err: any) {
        console.warn(`Model ${activeModel} non-streaming failed:`, err?.message);
        if (activeModel !== fallbackModel) {
          activeModel = fallbackModel;
          response = await ai.models.generateContent({
            model: activeModel,
            contents,
            config: configPayload,
          });
        } else {
          throw err;
        }
      }

      return res.json({
        text: response.text || "",
        model: activeModel,
      });
    }
  } catch (error: any) {
    console.error("Gemini API Error:", error);
    const errorMessage = extractErrorMessage(error);

    // If headers already sent in streaming mode, output SSE error
    if (res.headersSent) {
      res.write(`data: ${JSON.stringify({ error: { message: errorMessage } })}\n\n`);
      res.write("data: [DONE]\n\n");
      return res.end();
    }

    return res.status(500).json({
      error: {
        message: errorMessage,
      },
    });
  }
});

// Title generation helper endpoint
app.post("/api/generate-title", async (req, res) => {
  try {
    const { prompt, customApiKey } = req.body;
    if (!prompt) {
      return res.json({ title: "New Conversation" });
    }

    const ai = getGeminiClient(customApiKey);
    const response = await ai.models.generateContent({
      model: "gemini-3.7-flash",
      contents: `Generate a concise, 3 to 6 word title summarizing this user request. Return ONLY the title text with no quotation marks, no preamble, and no trailing punctuation: "${prompt.slice(0, 300)}"`,
      config: {
        temperature: 0.2,
      },
    });

    const title = response.text?.trim().replace(/^["']|["']$/g, "") || prompt.slice(0, 30);
    return res.json({ title });
  } catch (_e) {
    // Fallback simple title if API call fails
    const fallbackTitle = (req.body.prompt || "New Conversation").slice(0, 30).trim();
    return res.json({ title: fallbackTitle });
  }
});

async function startServer() {
  if (process.env.NODE_ENV !== "production") {
    const vite = await createViteServer({
      server: { middlewareMode: true },
      appType: "spa",
    });
    app.use(vite.middlewares);
  } else {
    const distPath = path.join(process.cwd(), "dist");
    app.use(express.static(distPath));
    app.get("*", (_req, res) => {
      res.sendFile(path.join(distPath, "index.html"));
    });
  }

  app.listen(PORT, "0.0.0.0", () => {
    console.log(`MSAI Server active on http://0.0.0.0:${PORT}`);
  });
}

startServer();
