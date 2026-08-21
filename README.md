# MSAI — Advanced Intelligent Web Assistant

MSAI is a complete, modern, responsive AI web application built with **HTML5**, **CSS3**, **Vanilla JavaScript**, and the **Google Gemini API**.

---

## ✨ Features

- **⚡ Fast Streaming Responses**: Real-time response streaming using Server-Sent Events (SSE) with abort/stop generation support.
- **💬 Full Conversation Management**:
  - Auto-generated intelligent titles for conversations
  - Pinned chats, group by date (Today, Yesterday, 7 days, 30 days, Older)
  - Rename, export as Markdown, and delete chats
  - Full-text search engine with keyword highlighting (`Ctrl + K`)
- **🎨 Premium UI & Design**:
  - Dark Mode (default) & Light Mode with seamless CSS variable tokens
  - Collapsible sidebar with compact icon mode
  - Mobile responsive drawer with backdrop blur
  - Matches modern AI assistant layouts (centered brand typography, suggestion pills, quick model switcher)
- **📝 Rich Markdown & Code Blocks**:
  - Code syntax highlighting with language header
  - One-click copy code with animated feedback
  - Formatted tables, blockquotes, ordered/unordered lists, inline code
- **🎤 Speech & Voice Integration**:
  - Speech-to-Text (microphone dictation directly into prompt input)
  - Text-to-Speech (read AI responses aloud with adjustable speech rate)
- **📎 Multimodal File & Image Support**:
  - Drag-and-drop file upload
  - Clipboard image paste
  - File picker with image thumbnail previews
- **💾 Hybrid Persistence**:
  - IndexedDB for large conversation histories
  - LocalStorage fallback and user settings storage
  - Full JSON backup export and import
- **⌨️ Keyboard Shortcuts**:
  - `Enter` to send, `Shift+Enter` for newline
  - `Ctrl + K` or `Cmd + K`: Search conversations
  - `Ctrl + Shift + O`: New chat
  - `Ctrl + B`: Toggle sidebar collapse
  - `Ctrl + ,`: Open settings
  - `Ctrl + /`: Keyboard shortcuts cheat sheet
  - `Esc`: Close modals/drawers

---

## 🔒 API Key & Security Notice

### ⚠️ Frontend Security vs Backend Proxy
> **Important Security Practice**: In modern web development, placing a raw AI API key directly in client-side frontend JavaScript (`window` or public files) exposes your API key to anyone inspecting browser network traffic or source files.
>
> **MSAI Architecture**:
> To follow best security practices, MSAI implements a secure Node.js/Express backend server (`server.ts`) that holds the `GEMINI_API_KEY` securely in server environment variables and communicates with Google Gemini using the `@google/genai` SDK.
>
> For personal testing or client-side overrides, MSAI also supports custom API keys in the Settings modal stored purely in your browser's private local storage.

---

## 🛠️ Project Structure

```
├── .env.example            # Environment variables template
├── index.html              # Clean semantic HTML5 application structure
├── server.ts               # Express backend proxy for Gemini streaming API
├── package.json            # Node dependencies and scripts
├── metadata.json           # Application metadata & permissions
│
├── css/
│   ├── variables.css       # Design tokens (Colors, Typography, Dark/Light modes)
│   ├── reset.css           # Modern CSS reset & scrollbars
│   ├── layout.css          # App layout structure & header
│   ├── sidebar.css         # Collapsible sidebar, chat lists & actions
│   ├── chat.css            # Message rows, bubbles, avatars & feedback
│   ├── composer.css        # Input box, mode pills, voice & send buttons
│   ├── code.css            # Markdown styling, tables & code blocks
│   ├── modal.css           # Settings, search, and shortcuts modal dialogs
│   ├── toast.css           # Notification toasts
│   ├── animations.css      # Keyframes and transitions
│   ├── responsive.css      # Mobile breakpoints and drawer
│   ├── accessibility.css   # Focus states and reduced motion
│   └── style.css           # Main CSS aggregator
│
└── js/
    ├── config.js           # Configuration and model definitions
    ├── api.js              # API communication layer (SSE Streaming)
    ├── storage.js          # IndexedDB & LocalStorage manager
    ├── conversations.js    # Conversation lifecycle manager
    ├── renderer.js         # DOM message and welcome screen renderer
    ├── composer.js         # Auto-expanding composer & event handlers
    ├── sidebar.js          # Sidebar history list & dropdowns
    ├── settings.js         # Settings modal controller
    ├── ui.js               # Search modal, shortcuts & tabs
    ├── chat.js             # Chat orchestrator (send, regenerate, edit)
    ├── markdown.js         # Markdown parser & syntax highlighter
    ├── sanitizer.js        # HTML sanitization against XSS
    ├── theme.js            # Dark / Light theme manager
    ├── voice.js            # Web Speech STT & TTS
    ├── attachments.js      # File & image upload handler
    ├── search.js           # Full-text search engine
    ├── shortcuts.js        # Keyboard shortcuts handler
    ├── toast.js            # Toast notification system
    ├── utils.js            # General utilities (ID, dates, tokens)
    └── app.js              # Application entry point
```

---

## 🚀 Running Locally

1. Install dependencies:
   ```bash
   npm install
   ```

2. Start the development server:
   ```bash
   npm run dev
   ```

3. Build for production:
   ```bash
   npm run build
   ```

4. Start production server:
   ```bash
   npm start
   ```

---

## 📄 License
MIT License
