/**
 * MSAI - Application Configuration
 *
 * Central configuration file for MSAI.
 * For client-side standalone execution, users can enter their Google Gemini API key
 * here or via the in-app Settings modal. When deployed with the built-in server proxy,
 * requests automatically use the server environment variable GEMINI_API_KEY.
 */

export const CONFIG = {
  APP_NAME: "MSAI",
  VERSION: "1.0.0",
  AUTHOR: "MSAI Intelligent Systems",

  // Direct Google Gemini API Key (Optional if backend proxy is used)
  GEMINI_API_KEY: "",

  // Default AI Model to use
  DEFAULT_MODEL: "gemini-3.7-flash",

  // Available Gemini Models for selection
  MODELS: [
    {
      id: "gemini-3.7-flash",
      name: "Gemini 3.7 Flash",
      badge: "Flagship",
      description: "Recommended flagship model with hybrid reasoning & multimodal capabilities",
      multimodal: true,
      contextLimit: "1M tokens",
      category: "Flash",
    },
    {
      id: "gemini-3.1-pro-preview",
      name: "Gemini 3.1 Pro",
      badge: "Deep Reasoning",
      description: "Advanced STEM reasoning, code generation, and complex architecture analysis",
      multimodal: true,
      contextLimit: "2M tokens",
      category: "Pro",
    },
    {
      id: "gemini-3.1-flash-lite",
      name: "Gemini 3.1 Flash Lite",
      badge: "Lightweight",
      description: "Ultra-fast lightweight model built for responsive real-time generation",
      multimodal: true,
      contextLimit: "1M tokens",
      category: "Lite",
    },
  ],

  // System Prompt / Persona
  DEFAULT_SYSTEM_PROMPT: `You are MSAI, a helpful, highly capable, and empathetic AI assistant.
Always format your answers in clean, readable Markdown with syntax-highlighted code blocks, tables, lists, and bold emphasis where suitable.
Provide insightful, structured, and technically accurate responses.`,

  // Generation Defaults
  DEFAULT_TEMPERATURE: 0.7,
  DEFAULT_STREAMING: true,
  MAX_HISTORY_MESSAGES: 30,

  // Storage Keys
  STORAGE_KEYS: {
    CONVERSATIONS: "msai_conversations_v1",
    ACTIVE_CHAT_ID: "msai_active_chat_id",
    SETTINGS: "msai_settings_v1",
    CUSTOM_API_KEY: "msai_custom_api_key",
    CUSTOM_PROMPTS: "msai_custom_prompts",
    PINNED_CHATS: "msai_pinned_chats",
  },

  // Limits
  MAX_FILE_SIZE_MB: 20,
  ALLOWED_IMAGE_TYPES: ["image/jpeg", "image/png", "image/webp", "image/gif"],
  ALLOWED_DOC_TYPES: ["text/plain", "text/markdown", "text/csv", "application/json", "application/pdf"],
};
