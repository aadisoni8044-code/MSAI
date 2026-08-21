# MSAI — Intelligent AI Assistant

MSAI is a complete, modern, responsive AI web application built with HTML5, CSS3, Vanilla JavaScript, and the Google Gemini API.

---

## 🌟 Key Features

- **Google Gemini API Streaming**: Real-time response streaming using Google Gemini model family (`gemini-2.5-flash` and `gemini-2.5-pro`).
- **Multimodal File & Image Input**: Upload images or text files directly into prompts.
- **Voice-to-Text Input**: Integrated Web Speech API for voice prompt input.
- **Persistent Storage**: Full conversation CRUD with IndexedDB (and LocalStorage fallback).
- **Markdown & Code Rendering**: Full Markdown parsing with syntax-highlighted code blocks, copy buttons, bold/italics, lists, blockquotes, and tables.
- **Interactive Message Controls**: Copy responses, edit/resend previous prompts, regenerate AI answers, or stop generation at any time.
- **Light & Dark Theme System**: Persistent theme toggle with smooth CSS variable transitions.
- **Search Conversations**: Live filtering across chat titles and message contents.
- **Responsive Mobile & Desktop UI**: Collapsible sidebar with drawer transformation on mobile devices.
- **Keyboard Shortcuts**: `Ctrl+K` (Search), `Ctrl+N` (New Chat), `Ctrl+B` (Toggle Sidebar), `Escape` (Close Modals), `Enter` / `Shift+Enter`.

---

## 📁 Directory Architecture

```
MSAI/
├── index.html              # Main HTML application layout
├── css/
│   ├── variables.css       # Design system tokens and CSS variables
│   ├── reset.css           # Modern CSS reset and global defaults
│   ├── layout.css          # Main grid and viewport layouts
│   ├── sidebar.css         # Collapsible sidebar & conversation items
│   ├── chat.css            # Chat message streams & welcome prompt cards
│   ├── composer.css       # Auto-expanding input area & control buttons
│   ├── settings.css        # Modal forms & toggle switches
│   ├── modal.css           # Modal backdrop & dialog cards
│   ├── toast.css           # Notification toast alerts
│   ├── code.css            # Code block headers & pre formatting
│   ├── animations.css     # Keyframes and CSS transitions
│   ├── responsive.css      # Mobile & tablet media queries
│   └── accessibility.css   # Screen-reader helpers & focus rings
├── js/
│   ├── config.js           # API key & model selection configuration
│   ├── utils.js            # DOM helpers, UUID generator, date formatting
│   ├── sanitizer.js        # XSS sanitization helper
│   ├── markdown.js         # Safe Markdown parser & code block builder
│   ├── storage.js          # IndexedDB / LocalStorage persistence
│   ├── conversations.js    # Conversation CRUD & title generation
│   ├── api.js              # Google Gemini API SSE stream client
│   ├── toast.js            # Toast notification system
│   ├── theme.js            # Dark/Light theme manager
│   ├── shortcuts.js        # Global keyboard shortcuts
│   ├── attachments.js      # File & image upload manager
│   ├── voice.js            # Web Speech API speech-to-text
│   ├── composer.js         # Textarea & message input controller
│   ├── sidebar.js          # Sidebar drawer & navigation manager
│   ├── settings.js         # Settings modal & JSON data export
│   ├── search.js           # Search filter controller
│   ├── renderer.js         # DOM message component renderer
│   ├── chat.js             # Chat orchestration controller
│   └── app.js              # Application entry point
├── assets/
│   ├── logo/
│   └── icons/
└── README.md
```

---

## 🔑 How to Configure the Google Gemini API Key

1. Open `js/config.js` in your text editor.
2. Replace `"YOUR_GOOGLE_GEMINI_API_KEY"` with your Google AI Gemini API Key:
   ```javascript
   export const CONFIG = {
       GEMINI_API_KEY: "AIzaSyYourActualKeyHere...",
       DEFAULT_MODEL: "gemini-2.5-flash",
       // ...
   };
   ```
3. Alternatively, click the **Settings** or **API Key** icon in the app header and paste your key directly into the settings dialog. It will be saved locally in your browser storage.

---

## 🔒 Security Notice Regarding Frontend API Keys

> ⚠️ **Important Security Warning:**
> Putting an API key directly into client-side JavaScript (`js/config.js` or browser storage) exposes it to any user inspecting web network traffic or browser memory.

### Production Recommendation
For a real production application, move API requests to a backend server or serverless proxy (e.g., Node.js / Express, Cloudflare Workers, Next.js API Routes):
1. Client sends user prompts to your private endpoint `/api/chat`.
2. Server validates user authentication and attaches the private `GEMINI_API_KEY` stored safely in server environment variables.
3. Server proxies the Google Gemini API request and streams the response back to MSAI frontend.

---

## 🚀 Running the Application

Because MSAI uses JavaScript ES Modules (`type="module"`), it should be served over HTTP/HTTPS rather than directly via `file://`.

### Using Node.js (npx http-server)
```bash
npx http-server . -p 8080
```
Open `http://localhost:8080` in Chrome, Edge, Firefox, or Safari.

---

## 🛠️ Browser Compatibility

Tested and compatible with modern browsers:
- Google Chrome / Chromium (v90+)
- Microsoft Edge (v90+)
- Mozilla Firefox (v88+)
- Apple Safari (v14+)
- Android Chrome / iOS Safari
