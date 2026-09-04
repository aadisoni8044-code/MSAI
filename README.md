# MSAI — Complete ChatGPT-Style AI Web Application

MSAI is a complete, production-style AI chat web application built with modern vanilla web technologies (HTML5, CSS3, ES Modules, and JSON). It is powered by Google AI Studio's Gemini models with a responsive, dark-first interface inspired by the usability and workflow of ChatGPT, while maintaining an original visual identity.

---

## Key Features

1. **AI Chat Architecture**
   - Direct integration with Google AI Studio Gemini API (`gemini-3.8-flash`, `gemini-2.5-flash`, `gemini-3.1-flash-lite`, `gemini-2.5-pro`).
   - Centralized API management in `js/api.js` with `GOOGLE_API_KEY` placeholder and custom key storage in Settings.
   - Built-in development proxy (`/api/chat`) for secure server-side execution.
   - Streaming-like typing indicator, stop generation controls, and automatic retry handling.

2. **Conversation & Message Management**
   - Full CRUD operations stored locally in `localStorage`.
   - Pin/unpin important chats to keep them at the top of the sidebar.
   - User message editing with re-generation from the edited branch.
   - Assistant actions: copy full response, copy code snippets, regenerate response, like/dislike, and share.
   - One-click conversation export (JSON / Markdown) and import (JSON with validation).

3. **Internationalization (i18n)**
   - 4 fully supported languages:
     - 🇬🇧 English (`en`)
     - 🇮🇳 Hindi (`hi`)
     - 🇧🇩 Bengali (`bn`)
     - 🇪🇸 Spanish (`es`)
   - Instant language switching without page reloads via `data/` translations.

4. **Modern UI/UX & Responsive Layout**
   - Dark theme default with instant Light and System theme toggling.
   - Responsive sidebar: collapsible on desktop, sliding drawer overlay on tablets and mobile screens.
   - Live conversation search modal (`Ctrl/Cmd + K`) with keyword highlighting and snippet preview.
   - Comprehensive Settings dialog with tabs: General, AI Backend, Chat Preferences, Data & Privacy, and About.
   - WCAG AA compliant contrast and reduced-motion accessibility support.

---

## File Structure (55 Modular Files)

```
msai/
├── index.html
├── metadata.json
├── package.json
├── vite.config.ts
├── .env.example
├── assets/
│   ├── logo.svg
│   ├── favicon.svg
│   ├── avatar-msai.svg
│   ├── avatar-user.svg
│   ├── sparkle.svg
│   ├── send.svg
│   ├── mic.svg
│   ├── attach.svg
│   ├── search.svg
│   └── settings.svg
├── css/
│   ├── variables.css
│   ├── reset.css
│   ├── global.css
│   ├── layout.css
│   ├── sidebar.css
│   ├── header.css
│   ├── chat.css
│   ├── messages.css
│   ├── composer.css
│   ├── buttons.css
│   ├── modals.css
│   ├── settings.css
│   ├── search.css
│   ├── notifications.css
│   ├── animations.css
│   └── responsive.css
├── js/
│   ├── app.js
│   ├── api.js
│   ├── chat.js
│   ├── messages.js
│   ├── conversations.js
│   ├── storage.js
│   ├── settings.js
│   ├── theme.js
│   ├── language.js
│   ├── search.js
│   ├── sidebar.js
│   ├── modal.js
│   ├── notifications.js
│   ├── markdown.js
│   ├── export.js
│   ├── import.js
│   ├── keyboard.js
│   ├── validation.js
│   ├── utils.js
│   └── events.js
└── data/
    ├── en.json
    ├── hi.json
    ├── bn.json
    ├── es.json
    ├── config.json
    ├── models.json
    ├── prompts.json
    └── defaults.json
```

---

## Configuration & API Key

### Option A: Local API Key via UI
1. Open MSAI in your browser.
2. Click the **Settings** gear icon in the sidebar or top header.
3. Select the **AI Backend** tab.
4. Enter your Google AI Studio API key and adjust temperature / model settings.
5. Click **Close** — the key is stored locally in your browser.

### Option B: Centralized in `js/api.js`
Open `js/api.js` and set:
```javascript
export const GOOGLE_API_KEY = "AIzaSy...";
```

### Option C: Server Proxy
Provide `GEMINI_API_KEY` in your environment (or `.env`), which is automatically read by the local server proxy in `vite.config.ts` (`/api/chat`).

---

## Keyboard Shortcuts

- `Enter`: Send message
- `Shift + Enter`: New line in composer
- `Ctrl + K` or `Cmd + K`: Open search modal
- `Alt + N`: Start a new chat
- `Escape`: Close active modal or dialog

---

## License
MIT License
