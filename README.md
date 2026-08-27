# MSAI — Modern AI Assistant Web Application

MSAI is a modern, responsive AI chat web application built with HTML5, CSS3, TypeScript, React, Express, and Google Gemini API integration.

![MSAI Application](public/msai-preview.png)

## Features

- ** Sleek Dark AI Interface**: Clean dark design system with custom branding, responsive sidebar, navigation options, and status badges.
- ** High-Performance AI Backend Proxy**: Express server proxying requests to Google Gemini 2.5 API with streaming SSE support so `GOOGLE_API_KEY` is kept safe and never exposed to the frontend.
- ** Comprehensive Chat Interactions**:
  - Create, search, rename, and delete conversations.
  - Rich Markdown rendering (headings, bold, lists, blockquotes, tables).
  - Code blocks with syntax highlighting (`highlight.js`) and one-click code copy buttons.
  - Message action bar: Copy message, Edit user prompt with auto-resubmit, Delete message, and Regenerate AI response.
  - File attachments support (images, documents).
  - Voice/Microphone dictation input UI.
- ** Fully Responsive & Mobile Friendly**:
  - Desktop two-column layout with collapsible sidebar.
  - Mobile drawer menu with touch-friendly controls.
  - Keyboard handling (Enter to send, Shift + Enter for new line).
- ** Preferences & Storage**:
  - Browser `localStorage` persistence for conversation history, active models, theme, and settings.
  - Comprehensive Settings Modal (General, Chat, AI Engine, About).

---

## 🏗️ Architecture & Project Structure

```text
MSAI/
├── public/
├── src/
│   ├── api/
│   │   ├── api.ts              # Error handling & formatting
│   │   └── googleApi.ts        # Health check & Gemini SSE streaming client
│   ├── components/
│   │   ├── ChatWindow.tsx      # Main message scroll area & empty prompt suggestions
│   │   ├── Header.tsx          # Top bar with model selector & server status
│   │   ├── LoadingMessage.tsx  # Typing indicator animation
│   │   ├── Message.tsx         # Markdown & code block rendering with actions
│   │   ├── MessageInput.tsx    # Textarea, file attachment & voice controls
│   │   ├── Settings.tsx       # Multi-tab settings modal
│   │   └── Sidebar.tsx         # Navigation sidebar & conversation list search
│   ├── data/
│   │   └── config.json         # Models & prompt suggestions config
│   ├── services/
│   │   ├── chatService.ts      # Conversation helpers
│   │   └── storageService.ts   # LocalStorage persistence manager
│   ├── styles/
│   │   ├── components.css      # Component-specific styles
│   │   ├── global.css          # Design system & dark theme variables
│   │   └── responsive.css      # Mobile drawer & responsive breakpoints
│   ├── types/
│   │   └── chat.ts             # TypeScript interface definitions
│   ├── App.tsx                 # Main application state container
│   ├── main.tsx                # Entry point
│   └── vite-env.d.ts           # CSS module declarations
├── .env.example                # Environment template
├── index.html                  # HTML5 entry
├── package.json                # Dependencies & scripts
├── server.js                   # Node.js / Express backend proxy
├── tsconfig.json               # TypeScript configuration
├── vite.config.ts              # Vite configuration with API proxying
└── README.md
```

---

## 🚀 Quick Start & Setup

### 1. Prerequisites
- Node.js (v18 or higher)
- npm (v9 or higher)

### 2. Environment Setup
1. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```
2. Open `.env` and add your Google Gemini API key:
   ```env
   PORT=3001
   GOOGLE_API_KEY=your_actual_gemini_api_key_here
   ```

### 3. Install Dependencies
```bash
npm install
```

### 4. Running the Development Server
Run the backend server and frontend development server simultaneously:

**Backend Server:**
```bash
npm run server
```

**Frontend App:**
```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) in your browser.

---

## 🧪 Testing & Verification

- **Type Check:** `npx tsc --noEmit`
- **Production Build:** `npm run build`
- **Server Health Check:** `curl http://localhost:3001/api/health`

---

## 🛡️ Security

- The frontend application **never** receives or handles the raw Google API secret.
- All requests are securely routed through the Express backend proxy in `server.js`.
- Sensitive `.env` files are ignored by git in `.gitignore`.

---

## 📜 License

ISC © MSAI
