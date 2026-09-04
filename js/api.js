/**
 * MSAI - Centralized AI API Module (Google AI Studio / Gemini API)
 *
 * NOTE ON SECURITY:
 * Production web applications should never expose secret API keys in client-side code.
 * In production, all AI requests should be proxied through a secure backend or serverless
 * function where the secret key is securely stored in environment variables.
 *
 * For local development and demonstration with Google AI Studio:
 * 1. Replace the placeholder below with your Gemini API key from https://aistudio.google.com/
 * 2. Alternatively, enter your API key in MSAI Settings > AI Backend tab.
 */

// Centralized Google AI Studio API Key configuration placeholder
export const GOOGLE_API_KEY = "YOUR_API_KEY_HERE";

import { storage } from './storage.js';
import { events } from './events.js';

let activeAbortController = null;

/**
 * Initializes API configuration and validates availability
 */
export function initializeAPI() {
  const customKey = storage.get('msai_settings')?.apiKey;
  const isKeyConfigured = (customKey && customKey.trim().length > 10) || (GOOGLE_API_KEY !== "YOUR_API_KEY_HERE");
  events.emit('api:status', { ready: isKeyConfigured });
  return isKeyConfigured;
}

/**
 * Gets effective API key (from settings or the GOOGLE_API_KEY constant)
 */
export function getEffectiveApiKey() {
  const customKey = storage.get('msai_settings')?.apiKey;
  if (customKey && customKey.trim().length > 10) {
    return customKey.trim();
  }
  if (GOOGLE_API_KEY && GOOGLE_API_KEY !== "YOUR_API_KEY_HERE") {
    return GOOGLE_API_KEY.trim();
  }
  return null;
}

const DEPRECATED_MODELS_MAP = {
  'gemini-2.0-flash': 'gemini-3.8-flash',
  'gemini-2.0-pro': 'gemini-3.1-pro-preview',
  'gemini-2.0-flash-thinking': 'gemini-3.8-flash',
  'gemini-1.5-flash': 'gemini-3.8-flash',
  'gemini-1.5-pro': 'gemini-3.8-flash',
  'gemini-pro': 'gemini-3.8-flash',
};

export function resolveValidModel(rawModel) {
  if (!rawModel) return 'gemini-3.8-flash';
  const clean = rawModel.replace(/^models\//, '');
  return DEPRECATED_MODELS_MAP[clean] || clean;
}

/**
 * Sends messages and generates response from Gemini API
 * @param {Array} history - Array of { role: 'user'|'model', parts: [{ text }] }
 * @param {Object} options - { model, temperature, maxTokens }
 */
export async function generateResponse(history, options = {}) {
  const model = resolveValidModel(options.model || 'gemini-3.8-flash');
  const temperature = options.temperature ?? 0.7;
  const apiKey = getEffectiveApiKey();

  // Create new AbortController
  if (activeAbortController) {
    activeAbortController.abort();
  }
  activeAbortController = new AbortController();

  events.emit('api:loading', true);

  try {
    let resultText = '';

    // If client API key is provided, communicate directly with Google AI Studio API
    if (apiKey) {
      const url = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`;
      const payload = {
        contents: history,
        generationConfig: {
          temperature: temperature,
          maxOutputTokens: options.maxTokens || 4096
        }
      };

      const response = await fetch(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
        signal: activeAbortController.signal
      });

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw handleAPIError(response.status, errorData);
      }

      const data = await response.json();
      const candidate = data.candidates?.[0];
      resultText = candidate?.content?.parts?.[0]?.text || '';
    } else {
      // Fallback to local server proxy endpoint (/api/chat)
      const proxyResponse = await fetch('/api/chat', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          model,
          contents: history,
          generationConfig: { temperature }
        }),
        signal: activeAbortController.signal
      });

      if (!proxyResponse.ok) {
        const errorData = await proxyResponse.json().catch(() => ({}));
        if (proxyResponse.status === 400 && errorData.error?.includes('GEMINI_API_KEY')) {
          throw new Error('Please provide your Google AI Studio API key in js/api.js or Settings > AI.');
        }
        throw handleAPIError(proxyResponse.status, errorData);
      }

      const data = await proxyResponse.json();
      resultText = data.text || '';
    }

    if (!resultText) {
      throw new Error('Received empty response from the AI model.');
    }

    events.emit('api:loading', false);
    return { success: true, text: resultText };
  } catch (error) {
    events.emit('api:loading', false);
    if (error.name === 'AbortError') {
      return { success: false, aborted: true, error: 'Generation stopped by user.' };
    }
    return { success: false, error: error.message || 'Failed to generate AI response' };
  } finally {
    activeAbortController = null;
  }
}

/**
 * Stop currently active request
 */
export function stopGeneration() {
  if (activeAbortController) {
    activeAbortController.abort();
    activeAbortController = null;
    events.emit('api:loading', false);
  }
}

/**
 * Standardized API error categorizer
 */
export function handleAPIError(status, errorData) {
  const message = errorData?.error?.message || errorData?.message || '';
  if (status === 400) {
    return new Error(`Invalid Request or API Key: ${message}`);
  }
  if (status === 403) {
    return new Error('Access denied. Please verify your Google AI Studio API key permissions.');
  }
  if (status === 429) {
    return new Error('Rate limit exceeded. Please wait a moment before trying again.');
  }
  if (status >= 500) {
    return new Error(`Gemini API Service Error (${status}). Please try again shortly.`);
  }
  return new Error(message || `API communication failed with status ${status}`);
}

/**
 * Retry request helper
 */
export async function retryRequest(history, options = {}, retries = 2, delay = 1000) {
  for (let attempt = 0; attempt <= retries; attempt++) {
    try {
      const response = await generateResponse(history, options);
      if (response.success) return response;
      if (attempt === retries) return response;
    } catch (e) {
      if (attempt === retries) throw e;
    }
    await new Promise(resolve => setTimeout(resolve, delay * Math.pow(2, attempt)));
  }
}
