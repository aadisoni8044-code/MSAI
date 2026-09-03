# MSAI — Next-Gen AI Assistant Web Application

MSAI is a complete, polished, production-style AI chat web application built with HTML5, CSS3, ES6+ Vanilla JavaScript, and JSON datasets. Inspired by modern ChatGPT workflows, MSAI delivers an intuitive, fast, and feature-complete AI interface powered by Google AI Studio's Gemini API.

## Brand Identity & Attribution
- **Brand**: MSAI
- **Organization**: Nvisov

---

## Features

- **Gemini API Integration**: Centralized in `js/api.js` supporting model selection (`gemini-1.5-flash` and `gemini-1.5-pro`), customizable API key, automatic offline mock response fallback, error handling, and retry states.
- **4 Language Support**: Complete i18n system with English (`en.json`), Hindi (`hi.json`), Bengali (`bn.json`), and Spanish (`es.json`), persisted via `localStorage`.
- **Modern ChatGPT-Style UI**: Dark/Light/System theme modes, custom CSS variables, responsive mobile drawer navigation, markdown parsing for AI responses, code syntax blocks, and welcome suggestion cards.
- **Conversation Management**: Full local storage CRUD (Create, Rename, Delete, Pin/Unpin, Clear All) and real-time conversation content search.
- **Import & Export**: Backup and restore all conversations and user preferences in JSON format.

---

## How to Run Locally

1. **Start the local server**:
   ```bash
   node server.js
   ```
2. Open your browser and navigate to:
   ```
   http://localhost:3000
   ```

---

## How to Configure the Google Gemini API Key

You can configure your API key in two ways:

1. **Via UI Settings**:
   - Open MSAI in your browser.
   - Click the **Settings (⚙️)** button in the bottom-left sidebar.
   - Enter your key in **Google AI Studio API Key**.

2. **Via Code Configuration**:
   - Open `js/api.js`.
   - Update the placeholder constant:
     ```javascript
     let GOOGLE_API_KEY = "YOUR_ACTUAL_GEMINI_API_KEY";
     ```

*Note: If no API key is set, MSAI gracefully operates in offline demo mode.*

---

## How to Test Language & Theme Switching

- Open **Settings (⚙️)** in MSAI.
- Under **General**, select **Language** (English, Hindi, Bengali, Spanish) or **Theme** (Dark, Light, System).
- Updates apply instantly and persist across reloads.
