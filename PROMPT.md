# NS Translate - Production-Ready Visual UI/UX Layout Prompt Document

## Executive Summary
This document provides a production-ready, highly structured visual UI/UX layout prompt designed specifically for generative AI tools (Midjourney v6, DALL-E 3, SDXL) as well as Dart Web / Flutter Web / HTML5 engineers. It defines the layout architecture, component specs, Material 3 design tokens, color dynamics, and visual previews for **NS Translate**, a high-accessibility, responsive web translation app.

---

## Visual UI/UX Generation Prompt (Generative AI Prompt)

```text
A high-fidelity, ultra-clean modern Web UI/UX desktop dashboard design for a translation application named "NS Translate" built according to Google Material 3 Web guidelines.

Primary color palette: Deep Indigo (#4F46E5), Light Grey/Slate background (#F8FAFC), Dark Mode Charcoal (#0F172A), and Soft Indigo accents (#F0F3FF / #1E1B4B). Typography is crisp Plus Jakarta Sans.

Layout Architecture:
1. Top Navigation Bar: Sticky header featuring "NS Translate" brand title with a sleek globe/translate logo icon on the left, and Theme Switcher (light/dark mode toggle button), History button, and Settings gear icon on the right.
2. Main Control Bar: Centered floating pill card containing a source language dropdown ("Detect Language", "English", "Spanish", "French"), a circular hoverable language swap button with a swap_horiz icon in Deep Indigo, and a target language dropdown ("Spanish", "German", "Hindi", "Japanese").
3. Workspace Dual-Pane Split Layout:
   - Left Input Pane: Clean white card containing a large multi-line text input area with placeholder "Type or paste text to translate...", a bottom toolbar with a microphone icon for voice input, audio playback button, and character counter "0 / 5000".
   - Right Output Pane: Highlighted card in Soft Indigo tint (#F0F3FF) with subtle indigo outline border to visually separate from input. Displays real-time translation output, with a bottom toolbar featuring Text-to-Speech audio icon, Copy to Clipboard button, Star bookmark icon, and Share/Export link button.
4. Web Bottom Quick Access Toolbar: Centered floating pill bar with three interactive pill buttons: "History Drawer", "Saved Translations", and "Document Translation".

Includes both Light Mode preview (#F8FAFC background) and Dark Mode preview (#0F172A background). UI/UX perspective shows soft elevation shadows, crisp 12px-24px rounded corners, high contrast accessibility, minimalist aesthetic, 4K resolution, vector interface layout mockup, product design presentation.
```

---

## Application Specifications & Design Tokens

### App Specifications
- **App Name**: NS Translate
- **Platform Target**: Responsive Web Application (Optimized for Dart Web, Chrome, Safari, Edge, Firefox)
- **Design System**: Google Material 3 Web Guidelines
- **Design Aesthetic**: Modern desktop-friendly dashboard with split-pane layout, soft elevation shadows, rounded geometry (`border-radius: 12px` to `24px`), and AAA contrast ratios.

### Color Palette Tokens
| Token Name | Light Mode Hex | Dark Mode Hex | Usage |
| :--- | :--- | :--- | :--- |
| `--md-sys-color-primary` | `#4F46E5` (Deep Indigo) | `#818CF8` | Primary branding, buttons, active states |
| `--md-sys-color-background` | `#F8FAFC` (Light Slate) | `#0F172A` (Charcoal) | App background canvas |
| `--md-sys-color-surface` | `#FFFFFF` | `#1E293B` | Cards, top nav bar, dialogs |
| `--md-sys-color-soft-indigo` | `#F0F3FF` | `#1E1B4B` | Right Pane (Output Area) highlight card |
| `--md-sys-color-soft-indigo-border` | `#C7D2FE` | `#3730A3` | Accent border for output container |
| `--md-sys-color-on-surface` | `#0F172A` | `#F8FAFC` | Primary text content |
| `--md-sys-color-on-surface-variant` | `#64748B` | `#94A3B8` | Subtitles, placeholders, character counts |

---

## Detailed Web Screen Layout Architecture

### 1. Top Navigation Bar (`<header class="top-nav">`)
- **Left Section**:
  - `material-symbols-outlined`: `translate` (Deep Indigo icon, 28px)
  - Application Title: **NS Translate** (`font-weight: 700`, `1.25rem`)
  - Tag Badge: `Dart Web` (`12px` pill badge in Soft Indigo)
- **Right Section**:
  - History Button (`history` icon)
  - Theme Switcher (`dark_mode` / `light_mode` toggle button)
  - Settings Icon (`settings` icon)

### 2. Main Control Bar (`<section class="language-bar-container">`)
- **Horizontally Aligned Center Card**:
  - **Left Source Dropdown**: Dropdown menu containing "Detect Language" (Default), "English", "Spanish", "French", "German", "Hindi", "Japanese", "Chinese".
  - **Center Interactive Swap Button**: Circular button with `swap_horiz` icon. Rotates 180 degrees on hover and flips active source/target selections.
  - **Right Target Dropdown**: Dropdown menu containing "Spanish" (Default), "English", "French", "German", "Hindi", "Japanese", "Chinese".

### 3. Dual-Pane Split Layout (`<section class="workspace-split">`)
- **Left Pane (Input Area)**:
  - Header: Source tag badge ("Source Text") and clear button (`close` X icon).
  - Main Body: High-accessibility `<textarea>` with placeholder `Type or paste text to translate...` and max limit of 5,000 characters.
  - Bottom Toolbar: Voice input button (`mic`), Listen audio button (`volume_up`), and right-aligned live character counter (`0 / 5000`).
- **Right Pane (Output Area)**:
  - Distinct Highlight Container: Styled in **Soft Indigo** (`#F0F3FF` light / `#1E1B4B` dark) with border `#C7D2FE`.
  - Header: Target tag badge ("Translation Result") and live status pill ("Ready" / "Translating...").
  - Main Body: Real-time translation display area with high text contrast.
  - Bottom Toolbar: Text-to-Speech audio button (`volume_up`), Copy to Clipboard button (`content_copy`), Save/Star button (`star_border`), and Share link button (`share`).

### 4. Web Bottom Toolbar / Quick Access (`<section class="bottom-quick-bar">`)
- Centered horizontal pill toolbar containing:
  - **History Drawer Toggle**: Opens right slide-over translation history panel.
  - **Saved Translations Button**: Opens modal overlay with starred translations.
  - **Document Translation Button**: Opens document drag-and-drop file upload modal (`.pdf`, `.docx`, `.txt`).

---

## High-Fidelity UI/UX Visual Previews

### Desktop Web View Preview (1440px Width)

```text
+---------------------------------------------------------------------------------------------------+
|  (icon) NS Translate  [Dart Web]                                  (history)  (theme_toggle)  (*)  | Top Nav
+---------------------------------------------------------------------------------------------------+
|                                                                                                   |
|             +-----------------------------------------------------------------------+             |
|             | (lang) Detect Language [v]     (  <===>  )     (g_trans) Spanish [v]   |             | Control Bar
|             +-----------------------------------------------------------------------+             |
|                                                                                                   |
|     +-----------------------------------------+   +-----------------------------------------+     |
|     | SOURCE TEXT                         (X) |   | TRANSLATION RESULT              [Ready] |     |
|     |-----------------------------------------|   |-----------------------------------------|     |
|     | Welcome to NS Translate.                |   | Bienvenido a NS Translate.              |     | Dual-Pane
|     | Type or paste text to translate...      |   |                                         |     | Split Layout
|     |                                         |   | (Soft Indigo Card Background #F0F3FF)   |     |
|     |                                         |   |                                         |     |
|     |-----------------------------------------|   |-----------------------------------------|     |
|     | (mic) (speaker)                24 / 5000 |   | (speaker) (copy) (star) (share)         |     |
|     +-----------------------------------------+   +-----------------------------------------+     |
|                                                                                                   |
|                          +-------------------------------------------------+                      |
|                          | (history) History  | (bookmark) Saved | (doc) Upload|                      | Bottom Bar
|                          +-------------------------------------------------+                      |
+---------------------------------------------------------------------------------------------------+
```

### Mobile Browser View Preview (375px Width)

```text
+-----------------------------------+
| (icon) NS Translate   (h) (theme) | Top Nav
+-----------------------------------+
|                                   |
| +-------------------------------+ |
| | [Detect Language v] ( <==> )  | |
| | [Spanish           v]         | | Control Bar (Stacked)
| +-------------------------------+ |
|                                   |
| +-------------------------------+ |
| | SOURCE TEXT               (X) | |
| |-------------------------------| |
| | Welcome to NS Translate.      | | Top Pane (Input)
| |-------------------------------| |
| | (mic) (speaker)     24 / 5000 | |
| +-------------------------------+ |
|                                   |
| +-------------------------------+ |
| | TRANSLATION RESULT    [Ready] | |
| |-------------------------------| |
| | Bienvenido a NS Translate.    | | Bottom Pane (Output)
| | (Soft Indigo Container)       | |
| |-------------------------------| |
| | (speaker) (copy) (star) (share)| |
| +-------------------------------+ |
|                                   |
| +-------------------------------+ |
| |  (h) Hist  |  (b) Saved | (u) | | Quick Access Bar
| +-------------------------------+ |
+-----------------------------------+
```

---

## Mobile & Responsive Adaptive Rules
1. **Layout Re-ordering**:
   - On viewports < 900px, the Dual-Pane split layout stacks vertically (Input area on top, Output area on bottom).
   - On viewports < 600px, language selection controls optimize spacing while retaining full swap functionality.
2. **Touch Targets & Accessibility**:
   - All interactive icons enforce a minimum target size of 44x44px.
   - Text colors strictly comply with WCAG 2.1 AA standards for high readability in both light and dark themes.
