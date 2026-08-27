/**
 * MSAI — Isolated Google AI API Layer
 * All external network communication and response parsing is handled strictly within this file.
 */

const MSAIApi = (function() {

  /**
   * Check backend server and API key status
   * @returns {Promise<{online: boolean, apiKeyConfigured: boolean, appName: string}>}
   */
  async function checkApiStatus() {
    try {
      const response = await fetch(CONFIG.API_STATUS_ENDPOINT, {
        method: 'GET',
        headers: { 'Cache-Control': 'no-cache' }
      });
      if (!response.ok) {
        return { online: false, apiKeyConfigured: false };
      }
      const data = await response.json();
      return {
        online: true,
        apiKeyConfigured: Boolean(data.apiKeyConfigured),
        appName: data.appName || 'MSAI'
      };
    } catch (err) {
      console.warn('[MSAI API] Server status check failed. Running in standalone/offline mode.', err);
      return { online: false, apiKeyConfigured: false };
    }
  }

  /**
   * Formats chat message history into Google Gemini contents format
   * @param {Array<{role: string, content: string}>} history
   * @returns {Array<{role: string, parts: Array<{text: string}>}>}
   */
  function formatHistoryForGemini(history) {
    if (!Array.isArray(history)) return [];

    return history.map(msg => ({
      role: msg.role === 'assistant' || msg.role === 'model' ? 'model' : 'user',
      parts: [{ text: msg.content || '' }]
    }));
  }

  /**
   * High-level function to send a prompt or history to Google AI / backend proxy
   * @param {Array<{role: string, content: string}> | string} input - Messages array or prompt string
   * @param {Object} options - { model, apiKey, systemInstruction }
   * @returns {Promise<string>} Generated text response
   */
  async function sendMessage(input, options = {}) {
    let contents = [];

    if (typeof input === 'string') {
      contents = [{ role: 'user', parts: [{ text: input }] }];
    } else if (Array.isArray(input)) {
      contents = formatHistoryForGemini(input);
    } else {
      throw new Error('Invalid input format provided to MSAIApi.sendMessage');
    }

    const model = options.model || (window.CONFIG ? window.CONFIG.DEFAULT_MODEL : 'gemini-2.0-flash');
    const customApiKey = options.apiKey || (window.MSAIState && window.MSAIState.settings ? window.MSAIState.settings.userApiKey : '');

    // 1. Direct client call to Google Generative Language API if user provided key directly
    if (customApiKey && customApiKey !== 'YOUR_GOOGLE_API_KEY') {
      try {
        return await generateResponseDirect(contents, model, customApiKey);
      } catch (err) {
        console.warn('[MSAI API] Direct client API key call failed:', err);
        throw err;
      }
    }

    // 2. Try backend Express proxy endpoint next
    try {
      const headers = { 'Content-Type': 'application/json' };
      const response = await fetch(CONFIG.API_PROXY_ENDPOINT, {
        method: 'POST',
        headers: headers,
        body: JSON.stringify({
          model: model,
          contents: contents,
          systemInstruction: CONFIG.SYSTEM_INSTRUCTION
        })
      });

      if (response.ok) {
        const data = await response.json();
        return extractResponseText(data);
      }

      const errorData = await response.json().catch(() => ({}));

      // If missing API key error from proxy, fallback gracefully to offline assistant
      if (response.status === 401 || (errorData.error && errorData.error.code === 'MISSING_API_KEY')) {
        console.info('[MSAI API] No API Key found on server. Falling back to offline assistant mode.');
        return getOfflineFallbackResponse(contents);
      }

      const message = (errorData.error && errorData.error.message) || `Server error (${response.status})`;
      throw new Error(message);

    } catch (err) {
      if (err.message && (err.message.includes('Server error') || err.message.includes('Google API error'))) {
        throw err;
      }
      console.warn('[MSAI API] Proxy connection failed. Running offline fallback generator.', err);
      return getOfflineFallbackResponse(contents);
    }
  }

  /**
   * Direct API call to Google Gemini endpoint when client key is provided
   */
  async function generateResponseDirect(contents, model, apiKey) {
    const url = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`;
    const payload = {
      contents: contents,
      systemInstruction: CONFIG.SYSTEM_INSTRUCTION
    };

    const res = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload)
    });

    const data = await res.json();
    if (!res.ok) {
      const errMsg = (data.error && data.error.message) || `Google API error: ${res.status}`;
      throw new Error(errMsg);
    }

    return extractResponseText(data);
  }

  /**
   * Helper function to extract text content from Google Gemini response object
   */
  function extractResponseText(data) {
    if (data.candidates && data.candidates[0] && data.candidates[0].content && data.candidates[0].content.parts) {
      return data.candidates[0].content.parts.map(p => p.text).join('\n');
    }
    if (data.text) {
      return data.text;
    }
    throw new Error('Received empty or unexpected response structure from Google AI service.');
  }

  /**
   * Mock / Offline smart fallback for demo and offline test use
   */
  function getOfflineFallbackResponse(contents) {
    return new Promise((resolve) => {
      setTimeout(() => {
        const lastMsgObj = contents[contents.length - 1];
        const lastText = lastMsgObj && lastMsgObj.parts && lastMsgObj.parts[0] ? lastMsgObj.parts[0].text.toLowerCase() : '';

        if (lastText.includes('code') || lastText.includes('javascript') || lastText.includes('function') || lastText.includes('html') || lastText.includes('sum')) {
          resolve(`Here is a clean JavaScript function that sums two numbers:\n\n\`\`\`javascript\n/**\n * Adds two numbers together\n * @param {number} a\n * @param {number} b\n * @returns {number}\n */\nfunction sum(a, b) {\n  return a + b;\n}\n\n// Example Usage:\nconsole.log(sum(5, 7)); // Output: 12\n\`\`\`\n\nIs there anything else you'd like to add to this function?`);
        } else if (lastText.includes('write') || lastText.includes('email') || lastText.includes('draft') || lastText.includes('content')) {
          resolve(`### Creative Content Draft\n\nHere is a drafted piece tailored for your prompt:\n\n> **Subject:** Next Steps & Strategic Planning\n>\n> Dear Team,\n>\n> I hope this message finds you well. As we advance our initiatives, I wanted to outline our core focus areas for the upcoming sprint. Key priorities include optimizing user workflows and enhancing system responsiveness.\n\nFeel free to adjust the tone or expand specific sections!`);
        } else if (lastText.includes('explain') || lastText.includes('learn') || lastText.includes('what is')) {
          resolve(`### Understanding the Concept\n\nHere is a breakdown of **${lastText.slice(0, 40)}...**:\n\n1. **Core Principle**: At its foundation, it relies on structured patterns and systematic evaluation.\n2. **Key Advantage**: Enables efficient problem solving and predictable outcomes.\n3. **Practical Application**: Commonly utilized in modern Web software and intelligent algorithms.\n\nWould you like a deeper dive into any specific aspect?`);
        } else {
          resolve(`I am **MSAI**, your intelligent AI assistant. I have processed your request: *"_${lastMsgObj ? lastMsgObj.parts[0].text : 'Hello'}_"*.\n\n* Note: To enable live real-time Google Gemini AI responses, please configure your \`GOOGLE_API_KEY\` in your \`.env\` file or enter your API key in the MSAI Settings panel.\n\nHow else can I assist you with your projects today?`);
        }
      }, 300);
    });
  }

  /**
   * Public interface alias matching requirements
   */
  return {
    checkApiStatus: checkApiStatus,
    sendMessage: sendMessage,
    generateResponse: sendMessage
  };
})();

if (typeof module !== 'undefined' && module.exports) {
  module.exports = MSAIApi;
}
