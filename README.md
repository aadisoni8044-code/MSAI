# NS Translate - Web Application & UI/UX Prompt Specification

**NS Translate** is a responsive, modern web application and visual layout prompt specification crafted for Dart Web, Flutter Web, and Web Browsers according to Google Material 3 Web Guidelines.

## Overview & Key Features

- **App Name**: NS Translate
- **Design Aesthetic**: Clean, modern, desktop-friendly layout with soft elevation shadows, rounded geometry, and Material 3 design tokens.
- **Color Palette**:
  - Primary Deep Indigo (`#4F46E5`)
  - Light Grey / Slate Background (`#F8FAFC`)
  - Dark Mode Charcoal Background (`#0F172A`)
  - Soft Indigo Output Accent (`#F0F3FF` light / `#1E1B4B` dark)

## Key Layout Sections

1. **Top Navigation Bar**:
   - Brand logo with `translate` symbol and title "NS Translate".
   - Action controls: Translation History button, Light/Dark Theme Switcher, and Settings toggle.

2. **Main Control Bar (Center Header)**:
   - Horizontally aligned language selector containing Source Language dropdown ("Detect Language", "English", "Spanish", "French", etc.), central interactive Swap button (`swap_horiz`), and Target Language dropdown ("Spanish", "German", "Hindi", "Japanese", etc.).

3. **Dual-Pane Split Layout (Web Workspace)**:
   - **Left Pane (Input Area)**: Type or paste text to translate up to 5,000 characters, clear button (`X`), voice microphone input, audio playback, and character counter.
   - **Right Pane (Output Area)**: Soft Indigo container card visually highlighting real-time output, complete with Text-to-Speech audio button, Copy to Clipboard, Star/Save translation, and Share link.

4. **Web Bottom Quick Access Bar**:
   - Floating pill navigation giving instant access to the Slide-over History Drawer, Saved Translations modal, and Document Translation dropzone (.pdf, .docx, .txt).

## Documentation
- Full Visual UI/UX Layout Prompt for Generative AI and Developers is located in [`PROMPT.md`](./PROMPT.md).
