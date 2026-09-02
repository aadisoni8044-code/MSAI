/**
 * MSAI API Gateway Integration
 * Centralized communication layer for Google AI Gemini API and backend proxy
 */
window.MSAI = window.MSAI || {};

window.MSAI.API = {
  activeRequest: null,

  async checkStatus() {
    const badge = document.getElementById('status-badge');
    const text = document.getElementById('status-text');

    try {
      const res = await fetch('/api/health', { method: 'GET' });
      if (res.ok) {
        window.MSAI.State.serverOnline = true;
        if (badge) badge.classList.add('online');
        if (text) text.textContent = window.MSAI.Language.get('status.serverOnline', 'Server Online');
      } else {
        throw new Error('Offline');
      }
    } catch (e) {
      window.MSAI.State.serverOnline = false;
      if (badge) badge.classList.remove('online');
      if (text) text.textContent = window.MSAI.Language.get('status.serverOffline', 'Server Offline');
    }
  },

  async sendMessage(prompt, model = 'msai-flash') {
    const customKey = window.MSAI.Storage.get('msai_api_key_v1');

    // Attempt direct backend proxy request
    try {
      const response = await fetch(window.MSAI.Config.apiEndpoint, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ prompt, model, apiKey: customKey })
      });

      if (response.ok) {
        const data = await response.json();
        return data.reply || data.text || 'No response text received.';
      }
    } catch (e) {
      console.warn('Backend endpoint unavailable, attempting direct Gemini client fallback.');
    }

    // Direct Gemini client call if user configured custom key
    if (customKey) {
      try {
        const geminiEndpoint = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${customKey}`;
        const res = await fetch(geminiEndpoint, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            contents: [{ parts: [{ text: prompt }] }]
          })
        });

        if (res.ok) {
          const data = await res.json();
          return data.candidates[0].content.parts[0].text;
        }
      } catch (err) {
        console.error('Gemini API call failed:', err);
      }
    }

    // Intelligent Offline Simulation Mode
    await new Promise(r => setTimeout(r, 1000));
    return this.generateOfflineResponse(prompt);
  },

  generateOfflineResponse(prompt) {
    const lower = prompt.toLowerCase();
    if (lower.includes('hello') || lower.includes('hi')) {
      return "Hello! I am MSAI, your advanced AI assistant developed by Nvisov. How can I assist you today?";
    }
    if (lower.includes('code') || lower.includes('python') || lower.includes('js')) {
      return "Here is a clean snippet matching your request:\n\n```javascript\n// MSAI High Performance Engine\nasync function processTask(data) {\n  console.log('Processing data with MSAI...', data);\n  return { success: true, timestamp: Date.now() };\n}\n```\n\nIs there anything specific you would like me to refactor or optimize?";
    }
    return `Thank you for your prompt: "${prompt}". MSAI is currently operating in offline demonstration mode. To unlock live real-time Google AI (Gemini) responses, please configure your API key in Settings or connect the MSAI Node.js backend proxy server.`;
  }
};
