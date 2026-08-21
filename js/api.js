/**
 * MSAI - API Communication Layer (Google Gemini API & Backend Proxy)
 * Handles sending user prompts, SSE streaming, error management, and cancellation
 */

import { CONFIG } from "./config.js";
import { storage } from "./storage.js";

/**
 * Categorize error and return clean, user-friendly message
 */
export function formatApiError(err, status = 0) {
  if (!err) return "An unexpected error occurred. Please try again.";

  let msg = err.message || String(err);

  // Try extracting inner message if stringified JSON
  try {
    if (typeof msg === "string" && msg.includes("{")) {
      const start = msg.indexOf("{");
      const end = msg.lastIndexOf("}");
      if (start !== -1 && end > start) {
        const parsed = JSON.parse(msg.slice(start, end + 1));
        if (parsed?.error?.message) {
          msg = parsed.error.message;
        }
      }
    }
  } catch {
    // Non-JSON string
  }

  const lower = (msg || "").toLowerCase();

  // 1. Request timeout
  if (
    err.name === "TimeoutError" ||
    lower.includes("timeout") ||
    lower.includes("timed out") ||
    lower.includes("econnaborted") ||
    lower.includes("deadline")
  ) {
    return "The request timed out. Please try again.";
  }

  // 2. Network error
  if (
    (err.name === "TypeError" && (lower.includes("fetch") || lower.includes("network"))) ||
    lower.includes("failed to fetch") ||
    lower.includes("networkerror") ||
    lower.includes("unable to connect") ||
    lower.includes("net::err") ||
    (typeof navigator !== "undefined" && navigator.onLine === false)
  ) {
    return "Unable to connect to the AI service. Please check your internet connection and try again.";
  }

  // 3. Invalid API Key
  if (
    lower.includes("api key") ||
    lower.includes("api_key") ||
    lower.includes("gemini_api_key") ||
    lower.includes("invalid_argument") ||
    lower.includes("unauthenticated") ||
    lower.includes("permission_denied") ||
    status === 401 ||
    status === 403
  ) {
    return "Your Gemini API key is invalid or missing. Please check your API configuration.";
  }

  // 4. Rate limit / 429 / high demand / 503
  if (
    status === 429 ||
    status === 503 ||
    lower.includes("429") ||
    lower.includes("503") ||
    lower.includes("resource_exhausted") ||
    lower.includes("quota") ||
    lower.includes("rate limit") ||
    lower.includes("high demand") ||
    lower.includes("temporarily busy") ||
    lower.includes("unavailable") ||
    lower.includes("overloaded")
  ) {
    return "MSAI is temporarily busy. Please try again in a few moments.";
  }

  // 5. Model unavailable / 404
  if (
    status === 404 ||
    lower.includes("404") ||
    lower.includes("not_found") ||
    (lower.includes("model") && (lower.includes("unavailable") || lower.includes("not found") || lower.includes("unsupported")))
  ) {
    return "The selected AI model is currently unavailable. Please choose another model.";
  }

  // 6. Empty response
  if (
    lower.includes("empty response") ||
    lower.includes("no response returned") ||
    lower.trim() === "empty"
  ) {
    return "The AI service returned an empty response. Please try again.";
  }

  // 7. Unknown API error fallback
  return "An unexpected error occurred. Please try again.";
}

export class ApiService {
  constructor() {
    this.currentAbortController = null;
    this.timeoutTimer = null;
  }

  // Check if server is active and has configured key
  async checkHealth() {
    try {
      const res = await fetch("/api/health");
      if (res.ok) {
        return await res.json();
      }
    } catch {
      // Offline / Static mode
    }
    return { status: "offline", hasServerKey: false };
  }

  // Generate title for conversation based on the first message
  async generateTitle(prompt) {
    if (!prompt) return "New Conversation";

    const settings = storage.getSettings();
    const apiKey = settings.apiKey || CONFIG.GEMINI_API_KEY;

    try {
      const response = await fetch("/api/generate-title", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ prompt, customApiKey: apiKey }),
      });

      if (response.ok) {
        const data = await response.json();
        if (data.title) return data.title;
      }
    } catch (err) {
      console.warn("Could not fetch AI title, using fallback:", err);
    }

    // Local fallback title generation
    const cleaned = prompt.replace(/[^\w\s]/gi, "").trim();
    const words = cleaned.split(/\s+/).slice(0, 5).join(" ");
    return words ? words.charAt(0).toUpperCase() + words.slice(1) : "New Conversation";
  }

  // Stream or send chat message to Gemini
  async sendMessage({
    messages,
    model,
    systemInstruction,
    temperature,
    onChunk,
    onDone,
    onError,
  }) {
    // Abort previous generation if any
    this.abortCurrentRequest();
    this.currentAbortController = new AbortController();
    const signal = this.currentAbortController.signal;

    // Set 60s request timeout
    this.timeoutTimer = setTimeout(() => {
      if (this.currentAbortController) {
        const timeoutErr = new Error("The request timed out. Please try again.");
        timeoutErr.name = "TimeoutError";
        this.currentAbortController.abort();
        if (onError) onError(timeoutErr);
      }
    }, 60000);

    const settings = storage.getSettings();
    const selectedModel = model || settings.model || CONFIG.DEFAULT_MODEL;
    const sysPrompt = systemInstruction || settings.systemPrompt || CONFIG.DEFAULT_SYSTEM_PROMPT;
    const temp = typeof temperature === "number" ? temperature : settings.temperature || CONFIG.DEFAULT_TEMPERATURE;
    const customApiKey = settings.apiKey || CONFIG.GEMINI_API_KEY || "";

    let responseStatus = 0;

    try {
      // 1. Try server backend endpoint first (with streaming support)
      const response = await fetch("/api/chat", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          messages,
          model: selectedModel,
          systemInstruction: sysPrompt,
          temperature: temp,
          stream: true,
          customApiKey: customApiKey || undefined,
        }),
        signal,
      });

      responseStatus = response.status;

      if (!response.ok) {
        let errorData = null;
        try {
          errorData = await response.json();
        } catch {
          // not JSON
        }
        const rawMsg = errorData?.error?.message || `HTTP ${response.status}: ${response.statusText}`;
        throw new Error(rawMsg);
      }

      // Check if response is Server-Sent Events stream
      const contentType = response.headers.get("Content-Type") || "";
      if (contentType.includes("text/event-stream") && response.body) {
        const reader = response.body.getReader();
        const decoder = new TextDecoder("utf-8");
        let accumulatedText = "";
        let buffer = "";

        while (true) {
          const { value, done } = await reader.read();
          if (done) break;

          buffer += decoder.decode(value, { stream: true });
          const lines = buffer.split("\n");
          buffer = lines.pop() || ""; // Keep partial line in buffer

          for (const line of lines) {
            const trimmed = line.trim();
            if (!trimmed || !trimmed.startsWith("data:")) continue;

            const dataStr = trimmed.substring(5).trim();
            if (dataStr === "[DONE]") {
              continue;
            }

            try {
              const parsed = JSON.parse(dataStr);
              if (parsed.error) {
                throw new Error(parsed.error.message || "Streaming error from Gemini");
              }
              if (parsed.text) {
                accumulatedText += parsed.text;
                if (onChunk) onChunk(parsed.text, accumulatedText);
              }
            } catch (err) {
              if (err.message && !err.message.includes("JSON")) {
                throw err;
              }
            }
          }
        }

        if (!accumulatedText.trim()) {
          throw new Error("Empty response");
        }

        if (onDone) onDone(accumulatedText);
        return accumulatedText;
      } else {
        // Non-streaming fallback response
        const data = await response.json();
        const fullText = data.text || "";
        if (!fullText.trim()) {
          throw new Error("Empty response");
        }
        if (onChunk) onChunk(fullText, fullText);
        if (onDone) onDone(fullText);
        return fullText;
      }
    } catch (err) {
      if (err.name === "AbortError" || signal.aborted) {
        // Check if aborted due to timeout
        if (this.timeoutTimer === null) {
          // Timeout already handled
          return null;
        }
        console.log("Generation stopped by user.");
        if (onDone) onDone(null, true);
        return null;
      }

      console.error("API error details:", err);
      const friendlyMessage = formatApiError(err, responseStatus);

      if (onError) onError(new Error(friendlyMessage));
      throw new Error(friendlyMessage);
    } finally {
      if (this.timeoutTimer) {
        clearTimeout(this.timeoutTimer);
        this.timeoutTimer = null;
      }
      this.currentAbortController = null;
    }
  }

  // Abort active streaming request
  abortCurrentRequest() {
    if (this.timeoutTimer) {
      clearTimeout(this.timeoutTimer);
      this.timeoutTimer = null;
    }
    if (this.currentAbortController) {
      this.currentAbortController.abort();
      this.currentAbortController = null;
      return true;
    }
    return false;
  }

  isGenerating() {
    return Boolean(this.currentAbortController);
  }
}

export const api = new ApiService();
