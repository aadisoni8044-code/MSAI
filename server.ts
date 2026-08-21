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

// Helper to get initialized GoogleGenAI client with fallback
function getGeminiClient(customApiKey?: string) {
  const cleanCustom = customApiKey && typeof customApiKey === "string" ? customApiKey.trim() : "";
  const key = cleanCustom || process.env.GEMINI_API_KEY;
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

// Map user-friendly model aliases to official Gemini models
function normalizeModel(modelName?: string): string {
  if (!modelName) return "gemini-3.7-flash";
  const m = modelName.trim();

  if (m === "MSAI Flash" || m === "gemini-3.7-flash") return "gemini-3.7-flash";
  if (m === "MSAI Pro" || m === "gemini-3.1-pro-preview" || m === "gemini-3.1-pro") return "gemini-3.1-pro-preview";
  if (m === "MSAI Lite" || m === "gemini-3.1-flash-lite" || m === "gemini-flash-lite") return "gemini-3.1-flash-lite";
  if (m === "gemini-2.5-flash" || m === "gemini-flash-latest") return "gemini-2.5-flash";

  return m;
}

// Model fallback cascade for high demand / rate limits / unavailability
const MODEL_CASCADE = [
  "gemini-3.7-flash",
  "gemini-3.1-flash-lite",
  "gemini-2.5-flash",
  "gemini-3.5-flash",
];

// Helper to determine HTTP status and clean human-readable error messages from GenAI errors
function categorizeApiError(err: any): { status: number; message: string; originalError: string } {
  if (!err) {
    return {
      status: 500,
      message: "An unexpected error occurred. Please try again.",
      originalError: "Unknown",
    };
  }

  let msg = err.message || String(err);
  let statusCode = err.status || err.statusCode || 0;

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
        if (parsed.error?.code && typeof parsed.error.code === "number") {
          statusCode = parsed.error.code;
        }
      }
    }
  } catch {
    // Non-JSON
  }

  const lower = String(msg).toLowerCase();

  // 1. Missing API Key
  if (
    lower.includes("gemini_api_key is not configured") ||
    lower.includes("api key is missing") ||
    lower.includes("api_key_missing") ||
    lower.includes("missing api key")
  ) {
    return {
      status: 401,
      message: "MSAI API configuration is missing. Please configure GEMINI_API_KEY in your local environment.",
      originalError: msg,
    };
  }

  // 2. Invalid API Key / Auth (401)
  if (
    statusCode === 401 ||
    lower.includes("api key not valid") ||
    lower.includes("api_key_invalid") ||
    lower.includes("unauthenticated") ||
    lower.includes("invalid api key")
  ) {
    return {
      status: 401,
      message: "MSAI could not authenticate with the AI service. Please check your API configuration.",
      originalError: msg,
    };
  }

  // 3. Permission Denied / Forbidden (403)
  if (
    statusCode === 403 ||
    lower.includes("permission_denied") ||
    lower.includes("permission denied") ||
    lower.includes("forbidden")
  ) {
    return {
      status: 403,
      message: "MSAI does not have permission to use this AI service or model.",
      originalError: msg,
    };
  }

  // 4. Model Not Found / Unavailable (404)
  if (
    statusCode === 404 ||
    lower.includes("not_found") ||
    lower.includes("model not found") ||
    lower.includes("unsupported model")
  ) {
    return {
      status: 404,
      message: "The selected AI model is unavailable.",
      originalError: msg,
    };
  }

  // 5. Rate Limit / Quota Exceeded (429)
  if (
    statusCode === 429 ||
    lower.includes("429") ||
    lower.includes("resource_exhausted") ||
    lower.includes("quota exceeded") ||
    lower.includes("rate limit") ||
    lower.includes("rate-limits")
  ) {
    return {
      status: 429,
      message: "MSAI is temporarily busy. Please try again in a few moments.",
      originalError: msg,
    };
  }

  // 6. High Demand / Service Unavailable (500 / 503)
  if (
    statusCode === 500 ||
    statusCode === 503 ||
    lower.includes("503") ||
    lower.includes("unavailable") ||
    lower.includes("high demand") ||
    lower.includes("overloaded") ||
    lower.includes("spikes in demand")
  ) {
    return {
      status: 503,
      message: "MSAI is temporarily unavailable. Please try again in a few moments.",
      originalError: msg,
    };
  }

  // 7. Timeout
  if (lower.includes("timeout") || lower.includes("timed out") || lower.includes("deadline")) {
    return {
      status: 504,
      message: "The request timed out. Please try again.",
      originalError: msg,
    };
  }

  return {
    status: 500,
    message: "MSAI is temporarily unavailable. Please try again in a few moments.",
    originalError: msg,
  };
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
        name: "MSAI Flash",
        badge: "Recommended",
        description: "Next-gen multimodal reasoning, speed, and advanced coding intelligence",
        contextWindow: "1M tokens",
        supportsMultimodal: true,
      },
      {
        id: "gemini-3.1-pro-preview",
        name: "MSAI Pro",
        badge: "Reasoning",
        description: "Complex STEM reasoning, deep math, advanced architecture design",
        contextWindow: "2M tokens",
        supportsMultimodal: true,
      },
      {
        id: "gemini-3.1-flash-lite",
        name: "MSAI Lite",
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
  const reqStart = Date.now();
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

    // Build candidate model list starting with the requested model
    const candidateModels = [targetModel];
    for (const candidate of MODEL_CASCADE) {
      if (!candidateModels.includes(candidate)) {
        candidateModels.push(candidate);
      }
    }

    // Mask key for safe dev logging
    const isCustom = Boolean(customApiKey && typeof customApiKey === "string" && customApiKey.trim());
    console.log(`[MSAI API] Request started: model="${targetModel}", messages=${messages.length}, stream=${stream}, authSource=${isCustom ? "client-override" : "server-env"}`);

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

    let lastError: any = null;
    let successfulModel = "";

    if (stream) {
      let streamIterator: any = null;
      let firstChunkResult: any = null;

      // Try candidate models sequentially until one connects successfully
      for (const candidateModel of candidateModels) {
        try {
          console.log(`[MSAI API] Attempting streaming on "${candidateModel}"...`);
          const modelStream = await ai.models.generateContentStream({
            model: candidateModel,
            contents,
            config: configPayload,
          });

          streamIterator = modelStream[Symbol.asyncIterator]();
          firstChunkResult = await streamIterator.next();
          successfulModel = candidateModel;
          console.log(`[MSAI API] First chunk received from "${candidateModel}" in ${Date.now() - reqStart}ms`);
          break;
        } catch (attemptErr: any) {
          lastError = attemptErr;
          console.warn(`[MSAI API] Model "${candidateModel}" failed: ${attemptErr?.status || ""} ${attemptErr?.message?.slice(0, 100)}`);
          // If authentication or permission error, don't try other models with the same broken key
          const categorized = categorizeApiError(attemptErr);
          if (categorized.status === 401 || categorized.status === 403) {
            throw attemptErr;
          }
        }
      }

      if (!successfulModel || !streamIterator) {
        throw lastError || new Error("All AI models failed to respond.");
      }

      // Set SSE headers and stream chunks
      res.setHeader("Content-Type", "text/event-stream");
      res.setHeader("Cache-Control", "no-cache");
      res.setHeader("Connection", "keep-alive");
      res.flushHeaders?.();

      let totalChars = 0;

      // Output first chunk
      if (firstChunkResult && !firstChunkResult.done && firstChunkResult.value) {
        const text = firstChunkResult.value.text || "";
        if (text) {
          totalChars += text.length;
          res.write(`data: ${JSON.stringify({ text, model: successfulModel })}\n\n`);
        }
      }

      // Output remaining chunks
      if (!firstChunkResult || !firstChunkResult.done) {
        while (true) {
          const nextChunk = await streamIterator.next();
          if (nextChunk.done) break;
          const text = nextChunk.value?.text || "";
          if (text) {
            totalChars += text.length;
            res.write(`data: ${JSON.stringify({ text, model: successfulModel })}\n\n`);
          }
        }
      }

      console.log(`[MSAI API] Stream completed successfully with model="${successfulModel}", chars=${totalChars}, duration=${Date.now() - reqStart}ms`);
      res.write("data: [DONE]\n\n");
      return res.end();
    } else {
      let response: any = null;

      for (const candidateModel of candidateModels) {
        try {
          console.log(`[MSAI API] Attempting non-streaming on "${candidateModel}"...`);
          response = await ai.models.generateContent({
            model: candidateModel,
            contents,
            config: configPayload,
          });
          successfulModel = candidateModel;
          break;
        } catch (attemptErr: any) {
          lastError = attemptErr;
          console.warn(`[MSAI API] Non-streaming model "${candidateModel}" failed:`, attemptErr?.message?.slice(0, 100));
          const categorized = categorizeApiError(attemptErr);
          if (categorized.status === 401 || categorized.status === 403) {
            throw attemptErr;
          }
        }
      }

      if (!response) {
        throw lastError || new Error("All AI models failed to respond.");
      }

      const fullText = response.text || "";
      console.log(`[MSAI API] Non-stream completed successfully with model="${successfulModel}", chars=${fullText.length}, duration=${Date.now() - reqStart}ms`);

      return res.json({
        text: fullText,
        model: successfulModel,
      });
    }
  } catch (error: any) {
    const { status, message, originalError } = categorizeApiError(error);
    console.error(`[MSAI API] Request error (HTTP ${status}):`, originalError);

    // If headers already sent in streaming mode, output SSE error event
    if (res.headersSent) {
      res.write(`data: ${JSON.stringify({ error: { message, status } })}\n\n`);
      res.write("data: [DONE]\n\n");
      return res.end();
    }

    return res.status(status).json({
      error: {
        message,
        status,
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

    // Use flash lite for lightning-fast and reliable title generation
    const response = await ai.models.generateContent({
      model: "gemini-3.1-flash-lite",
      contents: `Generate a concise 3 to 6 word title summarizing this user request. Return ONLY the title text with no quotation marks, no preamble, and no trailing punctuation: "${prompt.slice(0, 300)}"`,
      config: {
        temperature: 0.2,
      },
    });

    const title = response.text?.trim().replace(/^["']|["']$/g, "") || prompt.slice(0, 30);
    return res.json({ title });
  } catch (_e) {
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
