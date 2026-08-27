import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';

dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const PORT = process.env.PORT || 3001;

app.use(cors());
app.use(express.json({ limit: '10mb' }));

// Helper to map model names to Gemini model IDs
function mapModelId(modelInput) {
  if (!modelInput) return 'gemini-2.5-flash';
  const lower = modelInput.toLowerCase();
  if (lower.includes('pro')) {
    return 'gemini-2.5-pro';
  }
  return 'gemini-2.5-flash';
}

// Health check endpoint
app.get('/api/health', (req, res) => {
  const apiKey = process.env.GOOGLE_API_KEY;
  const hasApiKey = Boolean(apiKey && apiKey.trim() && apiKey !== 'your_google_gemini_api_key_here');

  res.json({
    status: 'online',
    appName: 'MSAI',
    hasApiKey,
    timestamp: new Date().toISOString(),
  });
});

// Chat completions proxy endpoint
app.post('/api/chat', async (req, res) => {
  try {
    const apiKey = process.env.GOOGLE_API_KEY;

    if (!apiKey || !apiKey.trim() || apiKey === 'your_google_gemini_api_key_here') {
      return res.status(401).json({
        error: {
          type: 'MISSING_API_KEY',
          message: 'Google API key is not configured on the server. Please add GOOGLE_API_KEY to your .env file.',
        },
      });
    }

    const { messages = [], model = 'MSAI Flash', systemInstruction, stream = true } = req.body;

    if (!Array.isArray(messages) || messages.length === 0) {
      return res.status(400).json({
        error: {
          type: 'INVALID_REQUEST',
          message: 'Messages array is required and must not be empty.',
        },
      });
    }

    const geminiModel = mapModelId(model);

    // Format messages for Gemini API
    // Gemini accepts contents: [{ role: 'user' | 'model', parts: [{ text: '...' }] }]
    const contents = messages.map((msg) => {
      const role = msg.role === 'assistant' ? 'model' : 'user';
      let textContent = msg.content || '';

      // Handle image or file attachments if present in message
      const parts = [{ text: textContent }];
      if (msg.attachments && Array.isArray(msg.attachments)) {
        msg.attachments.forEach((att) => {
          if (att.data && att.mimeType) {
            parts.push({
              inlineData: {
                mimeType: att.mimeType,
                data: att.data.replace(/^data:[^;]+;base64,/, ''),
              },
            });
          }
        });
      }

      return {
        role,
        parts,
      };
    });

    const requestBody = {
      contents,
    };

    if (systemInstruction) {
      requestBody.systemInstruction = {
        parts: [{ text: systemInstruction }],
      };
    }

    if (stream) {
      // Server-Sent Events / Chunked response
      const url = `https://generativelanguage.googleapis.com/v1beta/models/${geminiModel}:streamGenerateContent?alt=sse&key=${apiKey}`;

      const googleRes = await fetch(url, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(requestBody),
      });

      if (!googleRes.ok) {
        const errorText = await googleRes.text();
        let parsedError;
        try {
          parsedError = JSON.parse(errorText);
        } catch (e) {
          parsedError = { message: errorText };
        }

        const status = googleRes.status;
        let errorType = 'SERVER_ERROR';
        if (status === 400) errorType = 'INVALID_REQUEST';
        if (status === 403 || status === 401) errorType = 'INVALID_API_KEY';
        if (status === 429) errorType = 'RATE_LIMIT';

        return res.status(status).json({
          error: {
            type: errorType,
            message: parsedError.error?.message || `Google API returned status ${status}`,
          },
        });
      }

      res.setHeader('Content-Type', 'text/event-stream');
      res.setHeader('Cache-Control', 'no-cache');
      res.setHeader('Connection', 'keep-alive');

      const reader = googleRes.body.getReader();
      const decoder = new TextDecoder();

      req.on('close', () => {
        reader.cancel();
      });

      while (true) {
        const { done, value } = await reader.read();
        if (done) break;
        const chunk = decoder.decode(value, { stream: true });
        res.write(chunk);
      }

      res.end();
    } else {
      const url = `https://generativelanguage.googleapis.com/v1beta/models/${geminiModel}:generateContent?key=${apiKey}`;
      const googleRes = await fetch(url, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(requestBody),
      });

      if (!googleRes.ok) {
        const errorText = await googleRes.text();
        let parsedError;
        try {
          parsedError = JSON.parse(errorText);
        } catch (e) {
          parsedError = { message: errorText };
        }

        const status = googleRes.status;
        let errorType = 'SERVER_ERROR';
        if (status === 403 || status === 401) errorType = 'INVALID_API_KEY';
        if (status === 429) errorType = 'RATE_LIMIT';

        return res.status(status).json({
          error: {
            type: errorType,
            message: parsedError.error?.message || `Google API returned status ${status}`,
          },
        });
      }

      const data = await googleRes.json();
      const candidateText = data.candidates?.[0]?.content?.parts?.[0]?.text || '';
      res.json({ text: candidateText });
    }
  } catch (error) {
    console.error('API Proxy Error:', error);
    res.status(500).json({
      error: {
        type: 'SERVER_ERROR',
        message: error.message || 'An unexpected error occurred on the MSAI backend.',
      },
    });
  }
});

// Serve static frontend files in production if built
if (process.env.NODE_ENV === 'production') {
  app.use(express.static(path.join(__dirname, 'dist')));
  app.get('*', (req, res) => {
    res.sendFile(path.join(__dirname, 'dist', 'index.html'));
  });
}

app.listen(PORT, () => {
  console.log(`MSAI backend server running on http://localhost:${PORT}`);
});
