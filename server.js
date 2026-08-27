const express = require('express');
const path = require('path');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json({ limit: '10mb' }));
app.use(express.static(path.join(__dirname)));

// API Status endpoint
app.get('/api/status', (req, res) => {
  const apiKeyAvailable = Boolean(process.env.GOOGLE_API_KEY && process.env.GOOGLE_API_KEY.trim() !== '');
  res.json({
    online: true,
    apiKeyConfigured: apiKeyAvailable,
    appName: 'MSAI',
    version: '1.0.0'
  });
});

// Proxy route for Google Gemini API
app.post('/api/chat', async (req, res) => {
  const apiKey = req.headers['x-api-key'] || process.env.GOOGLE_API_KEY;

  if (!apiKey || apiKey === 'YOUR_GOOGLE_API_KEY') {
    return res.status(401).json({
      error: {
        message: 'No Google Gemini API key configured on server or in request header.',
        code: 'MISSING_API_KEY'
      }
    });
  }

  const model = req.body.model || 'gemini-2.0-flash';
  const contents = req.body.contents || [];
  const systemInstruction = req.body.systemInstruction;

  const targetUrl = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`;

  try {
    const payload = { contents };
    if (systemInstruction) {
      payload.systemInstruction = systemInstruction;
    }

    const response = await fetch(targetUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload)
    });

    const data = await response.json();

    if (!response.ok) {
      return res.status(response.status).json({
        error: data.error || { message: `Google Gemini API error (${response.status})` }
      });
    }

    res.json(data);
  } catch (err) {
    console.error('API Proxy Error:', err);
    res.status(500).json({
      error: { message: 'Internal server error proxying request to Google Gemini API.' }
    });
  }
});

app.listen(PORT, () => {
  console.log(`MSAI Server listening on port ${PORT}`);
});
