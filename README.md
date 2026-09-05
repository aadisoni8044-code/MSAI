# Nv Translate

**Nv Translate** is a clean, modern, and accessible translation web application built with Vanilla HTML5, CSS3, and JavaScript (ES Modules). Inspired by the usability and workflow of top translator applications, Nv Translate provides a seamless translation experience across desktop, tablet, and mobile devices.

---

## Key Features

- **Original Modern UI**: Custom responsive layout, dark/light theme switching with local persistence, clean typography, rounded card containers, and mobile touch-friendly controls.
- **Language Selection**: Supports 35+ global and regional languages (including English, Hindi, Urdu, Bengali, Marathi, Gujarati, Punjabi, Tamil, Telugu, Kannada, Malayalam, Odia, Nepali, Sanskrit, Arabic, French, German, Spanish, Portuguese, Italian, Russian, Chinese, Japanese, Korean, Turkish, etc.) plus **Auto Detect**.
- **Searchable Language Modal**: Includes instant filter search, recently used quick-select options, and alphabetical listings.
- **Flexible API Architecture (`api.js`)**: Isolated translation logic supporting:
  - **MyMemory Translation API** (Default free public endpoint, with optional email configuration for higher rate limits).
  - **LibreTranslate API** (Configurable custom self-hosted or public server endpoint + optional API key).
  - **Demo Mode** (Instant offline fallback/demo translation mode).
- **Copy & Translate Workflow**: 1-click text copying for source and target texts, plus browser clipboard paste button.
- **Voice Integration (`voice.js`)**:
  - **Speech-to-Text (Voice Input)** using the browser's Web Speech Recognition API.
  - **Text-to-Speech (Listen)** using the browser's Web Speech Synthesis API.
  - Graceful fallback notifications when speech features are unsupported by the browser.
- **History & Favorites (`history.js`)**:
  - Automatically saves recent translations to `localStorage`.
  - Save items to **Favorites** with 1-tap star toggling.
  - Reload, copy, or delete individual history/favorite items, or clear history completely.
- **Accessibility & Responsive Mobile UX**:
  - Fully responsive, mobile-first design with safe-area paddings and zero horizontal overflow.
  - Keyboard navigation (Ctrl/Cmd + Enter to translate, Esc to close modals).
  - ARIA attributes, high contrast colors, and visible focus states.

---

## File Structure

```text
Nv Translate/
├── index.html        # Main HTML5 document & semantic UI structure
├── style.css         # Modern CSS3 design system with CSS variables (Light/Dark themes)
├── app.js            # Main application controller, state management, & event orchestration
├── api.js            # API layer for MyMemory, LibreTranslate, and Demo fallback mode
├── voice.js          # Speech Synthesis (TTS) & Speech Recognition (STT) abstraction
├── history.js        # LocalStorage persistence for translation history and favorites
├── languages.json    # Language dataset (35+ languages + Auto Detect)
└── README.md         # Project documentation
```

---

## Running Locally

Because the project uses standard ES Modules (`import`/`export`), it should be served over an HTTP/HTTPS local server (e.g. Node `http-server`, Python `http.server`, Live Server, or Vite).

### Option 1: Python HTTP Server
```bash
python3 -m http.server 8000
```
Then open `http://localhost:8000` in your web browser.

### Option 2: Node.js / npx
```bash
npx http-server -p 8000
```
Then open `http://localhost:8000` in your web browser.

---

## API Configuration

1. Click the **Settings** icon in the header.
2. Select your preferred provider:
   - **MyMemory Translation API** (Default): Free to use out of the box. Enter your email in Settings to increase your daily limit up to 10,000 words/day.
   - **LibreTranslate API**: Enter your custom LibreTranslate server endpoint URL (and optional API key).
   - **Demo Mode**: Offline fallback mode for offline testing without network API calls.
3. Click **Save Configuration**. Your configuration is saved locally in `localStorage`.

---

## License

Created for **Nv Translate**. All rights reserved.
