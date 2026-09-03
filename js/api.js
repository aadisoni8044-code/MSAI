import { storage } from './storage.js';

// Central API Configuration
// NOTE: For production deployments, backend/proxy endpoint protection is recommended rather than frontend API key exposure.
let GOOGLE_API_KEY = "YOUR_API_KEY_HERE";

export const apiService = {
  getKey() {
    const savedKey = storage.get('api_key', '');
    return savedKey || GOOGLE_API_KEY;
  },

  setKey(key) {
    GOOGLE_API_KEY = key;
    storage.set('api_key', key);
  },

  async generateResponse(prompt, history = [], model = 'gemini-1.5-flash') {
    const apiKey = this.getKey();

    // Check if valid key exists, otherwise fallback to offline response mode
    if (!apiKey || apiKey === "YOUR_API_KEY_HERE") {
      return this.getMockResponse(prompt);
    }

    const endpoint = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`;

    const formattedHistory = history.map(msg => ({
      role: msg.role === 'user' ? 'user' : 'model',
      parts: [{ text: msg.content }]
    }));

    formattedHistory.push({
      role: 'user',
      parts: [{ text: prompt }]
    });

    try {
      const res = await fetch(endpoint, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ contents: formattedHistory })
      });

      if (!res.ok) {
        const errorData = await res.json().catch(() => ({}));
        throw new Error(errorData.error?.message || `API Error (${res.status})`);
      }

      const data = await res.json();
      const text = data.candidates?.[0]?.content?.parts?.[0]?.text;

      if (!text) throw new Error('Received empty response from Gemini API.');
      return text;

    } catch (err) {
      console.warn('Gemini API fetch error, using graceful fallback:', err);
      throw err;
    }
  },

  getMockResponse(prompt) {
    return new Promise(resolve => {
      setTimeout(() => {
        resolve(`[MSAI Offline / Demo Mode]\n\nThank you for trying **MSAI by Nvisov**! I received your prompt: "${prompt}".\n\nTo connect to the live Gemini AI engine, please configure your Google AI Studio API Key in **Settings -> AI Settings** or set your key in \`js/api.js\`.`);
      }, 1000);
    });
  }
};