# SYLVAN WHISPERS - 2D Adventure Platformer Game

*Sylvan Whispers* is a responsive, highly polished 2D adventure platformer built strictly using Vanilla HTML5, CSS3, JavaScript ES6+, and the HTML5 Canvas API.

Inspired directly by deep teal/cyan fantasy forest art, the game features a young masked explorer traversing a giant ancient forest, avoiding hazards, fighting shadowy forest creatures, gathering bioluminescent Lumina Orbs, and cleansing the ancient Sylvan Temple.

---

## 🌲 Technical Specification

- **Engine Architecture**: Pure Vanilla HTML5 Canvas 2D Engine with modular ES modules / global namespaces.
- **Dependencies**: 0 external frameworks (NO React, NO Vue, NO TypeScript, NO Webpack, NO npm build step required).
- **Audio System**: Web Audio API procedural synthesizer for jumps, slashes, hits, coins, checkpoints, damage, and ambient forest synth music.
- **Parallax System**: 5 distinct visual layers (Deep Sky & Fog, Distant Silhouette Trees, Ancient Tree Canopy, Playable Platform Environment, Dark Foreground Plant Silhouettes).
- **Controls**: Unified Input System supporting full Desktop Keyboard controls and responsive Mobile Touch Controls overlay.

---

## 🗂 Exact 20-File Manifest

```text
.
├── 01. index.html              # Main application shell & entry view
├── 02. game.html               # Direct gameplay viewport page
├── 03. menu.html               # Animated main menu page with background particle canvas
├── css/
│   ├── 04. css/style.css       # Core design system, theme variables, reset & modals
│   ├── 05. css/menu.css        # Main menu overlay layout & button styling
│   └── 06. css/game.css        # Game viewport, HUD layout & mobile touch buttons
├── js/
│   ├── 07. js/main.js          # App initializer & DOM event binding
│   ├── 08. js/game.js          # Game loop, state machine & rendering pipeline
│   ├── 09. js/player.js        # Player physics, movement & spirit blade attack
│   ├── 10. js/enemy.js         # AI behaviors & canvas rendering for 3 enemy types
│   ├── 11. js/level.js         # Level layouts for 5 distinct forest regions
│   ├── 12. js/collision.js     # AABB collision resolution & platform snapping
│   ├── 13. js/camera.js        # Smooth camera lerp tracking & screen shake
│   ├── 14. js/particles.js     # High-performance particle engine (dust, sparks, fireflies, leaves)
│   ├── 15. js/audio.js         # Web Audio API procedural sound synthesizer
│   ├── 16. js/ui.js            # HUD status bar updates & modal announcements
│   ├── 17. js/input.js         # Unified keyboard & virtual touch control listener
│   ├── 18. js/save.js          # LocalStorage progress & checkpoint persistence
│   └── 19. js/settings.js      # User settings manager (audio volume, graphics, touch toggle)
└── 20. README.md              # Documentation & guide
```

---

## 🕹 Controls Guide

### Desktop Keyboard
- **A / D** or **Left / Right Arrow**: Move Left / Right
- **Space** or **W** or **Up Arrow**: Jump / Double Jump
- **Shift**: Run / Sprint (Consumes stamina)
- **J** or **Z**: Attack with Spirit Blade
- **E** or **X**: Interact / Read Ancient Tablets
- **ESC** or **P**: Pause Game

### Mobile Touchscreen
- **D-Pad Buttons (◀ ▶ ▼)**: Move Left, Move Right, Crouch
- **▲ Button**: Jump / Double Jump
- **⚔ Button**: Attack
- **🖐 Button**: Interact
- **⏸ Button**: Pause

---

## 🗺 Regions & Level Progression

1. **Forest Entrance**: Edge of the sylvan realm introducing jumping & collectibles.
2. **Ancient Tree Area**: Giant canopy tree branches and flying moth enemies.
3. **Dark Swamp**: Floating moss logs, murky abyss hazards, and shadow stalkers.
4. **Hidden Cave**: Gloom caverns illuminated by glowing crystals.
5. **Ancient Temple**: Sanctuary of Sylvan Light leading to the temple altar.

---

## 🚀 How to Run Locally

Open `index.html` directly in any web browser, or serve using any static HTTP server:

```bash
python3 -m http.server 8080
```

Navigate to `http://localhost:8080` in your web browser.
