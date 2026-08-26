const express = require('express');
const cors = require('cors');
const path = require('path');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json({ limit: '10mb' }));
app.use(express.static(__dirname));

// Health check endpoint
app.get('/api/health', (req, res) => {
  const hasEnvApiKey = Boolean(process.env.GEMINI_API_KEY && process.env.GEMINI_API_KEY.trim() !== '');
  res.json({
    status: 'online',
    appName: 'MS AI',
    serverApiKeyConfigured: hasEnvApiKey,
    timestamp: new Date().toISOString()
  });
});

// Proxy route for Gemini API chat completion
app.post('/api/chat', async (req, res) => {
  try {
    const { contents, systemInstruction, model = 'gemini-2.5-flash', userApiKey } = req.body;

    const apiKey = (userApiKey && userApiKey.trim() !== '') ? userApiKey : process.env.GEMINI_API_KEY;

    if (!apiKey) {
      return res.status(401).json({
        error: {
          message: 'No API key provided. Please set GEMINI_API_KEY on the server or enter your API Key in Settings.',
          code: 'MISSING_API_KEY'
        }
      });
    }

    // Google Gemini REST API v1beta endpoint
    // Using default model or requested model
    const selectedModel = model || 'gemini-2.5-flash';
    const googleUrl = `https://generativelanguage.googleapis.com/v1beta/models/${selectedModel}:generateContent?key=${apiKey}`;

    const requestBody = {
      contents: contents || []
    };

    if (systemInstruction) {
      requestBody.systemInstruction = {
        parts: [{ text: systemInstruction }]
      };
    }

    const response = await fetch(googleUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(requestBody)
    });

    const data = await response.json();

    if (!response.ok) {
      const errorMsg = data.error?.message || `Google API returned status ${response.status}`;
      return res.status(response.status).json({
        error: {
          message: errorMsg,
          code: data.error?.status || 'API_ERROR',
          details: data.error
        }
      });
    }

    return res.json(data);
  } catch (err) {
    console.error('Proxy Server Error:', err);
    return res.status(500).json({
      error: {
        message: err.message || 'Internal Server Proxy Error',
        code: 'INTERNAL_SERVER_ERROR'
      }
    });
  }
});

// Proxy route for model listing
app.get('/api/models', async (req, res) => {
  try {
    const userApiKey = req.headers['x-api-key'];
    const apiKey = (userApiKey && userApiKey.trim() !== '') ? userApiKey : process.env.GEMINI_API_KEY;

    if (!apiKey) {
      return res.status(401).json({
        error: { message: 'API key missing', code: 'MISSING_API_KEY' }
      });
    }

    const response = await fetch(`https://generativelanguage.googleapis.com/v1beta/models?key=${apiKey}`);
    const data = await response.json();

    if (!response.ok) {
      return res.status(response.status).json(data);
    }

    res.json(data);
  } catch (err) {
    res.status(500).json({ error: { message: err.message } });
  }
});

// Fallback to index.html for SPA routing
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'index.html'));
});

app.listen(PORT, () => {
  console.log(`MS AI Server running on http://localhost:${PORT}`);
});
