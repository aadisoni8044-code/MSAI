# MSAI — Modern Production-Ready AI Web Application

**MSAI** is a complete, modern, responsive, client-side AI web application powered by the Google Gemini API. It features a sleek, dark/light themed user interface, full conversation persistence, real-time response streaming, Markdown and code syntax formatting, attachment uploads, voice input, keyboard navigation, and customizable settings.

---

## 🌟 Key Features

- **Modern Assistant Interface**: Collapsible sidebar, dark/light theme switching, and responsive design optimized for mobile, tablet, and desktop.
- **Real-Time Streaming**: Live token streaming using SSE (Server-Sent Events) via Gemini's `streamGenerateContent` REST API.
- **Rich Markdown & Code Support**: Custom-built Markdown parser supporting headings, bold/italics, blockquotes, lists, tables, inline code, and syntax-highlighted code blocks with **Copy** buttons.
- **Conversation Management**:
  - Auto-generated smart titles from prompt context.
  - Persistent storage using IndexedDB with `localStorage` fallback.
  - Search conversation titles and message contents (`Ctrl+K`).
  - Rename, delete individual chats, or clear all history with confirmation.
  - Full data Export/Import in JSON format.
- **Multimodal & Voice Input**:
  - File attachments (images, text, code) converted into Base64 inline payloads for Gemini vision/multimodal parsing.
  - Voice input powered by the Web Speech API with browser fallback handling.
- **Interactive Actions**:
  - Copy individual user/assistant messages.
  - Regenerate AI responses.
  - Stop live AI generation anytime (`AbortController`).
- **Shortcuts & Accessibility**:
  - `Enter` to send, `Shift+Enter` for new lines.
  - `Ctrl+K` (or `Cmd+K`) to jump to Search.
  - `Ctrl+N` (or `Cmd+N`) for New Chat.
  - `Esc` to close modal dialogs or mobile drawers.

---

## 📁 Project Architecture

```
MSAI/
├── index.html               # Main HTML entry point with semantic accessibility tags
├── README.md                # Documentation, configuration, and security guidelines
├── css/
│   ├── variables.css        # Design tokens & CSS custom properties (Light/Dark themes)
│   ├── reset.css            # Box-sizing reset & base scrollbars
│   ├── layout.css           # Grid architecture & top header
│   ├── sidebar.css          # Sidebar, search, recent chats & collapsible states
│   ├── chat.css             # Chat container, message bubbles, welcome suggestions
│   ├── composer.css         # Textarea, auto-expand, attachment preview bar
│   ├── modal.css            # Modals (Settings, Rename, Clear Data)
│   ├── toast.css            # Reusable popup toast notifications
│   ├── code.css             # Code block formatting, language header & copy buttons
│   ├── animations.css       # Keyframes & transitions
│   ├── responsive.css       # Mobile drawer & adaptive breakpoints
│   └── accessibility.css    # High-contrast, focus rings & reduced motion
└── js/
    ├── config.js            # Default API key and model config
    ├── api.js               # Google Gemini REST API client & streaming fetch wrapper
    ├── storage.js           # IndexedDB storage adapter with localStorage fallback
    ├── sanitizer.js         # XSS protection and HTML escaping
    ├── markdown.js          # Markdown renderer & code block decorator
    ├── conversations.js     # State store for chats, messages, and title generation
    ├── attachments.js       # File attachment, size validation & Base64 encoding
    ├── voice.js             # Web Speech API recognition wrapper
    ├── search.js            # Instant search filtering module
    ├── settings.js          # User settings state and modal form sync
    ├── theme.js             # Light/Dark theme manager
    ├── toast.js             # Toast notification service
    ├── modal.js             # Accessible modal popup controller
    ├── sidebar.js           # Sidebar drawer & item event listeners
    ├── renderer.js          # Message bubble rendering & event delegation
    ├── composer.js          # Composer auto-resize & send handlers
    ├── shortcuts.js         # Keyboard shortcut event handlers
    └── app.js               # Main bootstrap entry point
```

---

## ⚙️ Configuration & Google Gemini API Setup

### 1. Where to configure the API Key

You can configure your Google Gemini API Key in two ways:

#### Method A: Configuration File (`js/config.js`)
Edit `js/config.js` and set your key:

```javascript
export const CONFIG = {
    GEMINI_API_KEY: "AIzaSyYourActualApiKeyHere",
    MODEL: "gemini-2.5-flash",
    // ...
};
```

#### Method B: Settings UI inside MSAI
1. Open the application in your browser.
2. Click the **Settings** gear icon in the top header or bottom sidebar.
3. Paste your Google Gemini API Key into the **Google Gemini API Key** field.
4. Click **Save Settings**. (Key will be securely stored in your browser's `localStorage`).

---

## 🚀 How to Run the Application

Because MSAI uses standard ES Modules (`import`/`export`), it must be served over an HTTP web server rather than opening `file://` directly in the browser.

### Using Python
```bash
# Python 3
python3 -m http.server 8080
```
Open your browser and navigate to `http://localhost:8080`.

### Using Node.js / npx
```bash
npx serve .
```

---

## 🔒 Security Warning: Frontend API Keys

> ⚠️ **IMPORTANT SECURITY NOTICE FOR PRODUCTION:**
> Storing an API key directly in client-side JavaScript (`config.js` or `localStorage`) exposes the key to anyone who inspects the browser source or network traffic.
>
> **How to secure this for Production:**
> 1. Build a simple serverless endpoint (e.g., Node.js/Express, Vercel Functions, Cloudflare Workers).
> 2. Move your `GEMINI_API_KEY` to an environment variable on the server (`process.env.GEMINI_API_KEY`).
> 3. Update `js/api.js` to send requests to your backend endpoint (e.g., `/api/chat`), which proxies the request to `generativelanguage.googleapis.com` and streams the response back to MSAI.

---

## 🌐 Browser Requirements

MSAI is supported on all modern web browsers:
- Google Chrome (recommended)
- Mozilla Firefox
- Apple Safari
- Microsoft Edge
- Opera / Android Chrome / iOS Safari

---

## 🛠️ Version & License

- **Version**: 1.0.0
- **Build**: Pure Vanilla HTML5, CSS3, JavaScript (ES6 Modules)
