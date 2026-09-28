# Keyboard Sound ⌨🔊

Play realistic **mechanical keyboard sounds** while you type code inside **VS Code** with ultra-low latency!

Designed and developed by **Aadi Soni**, **Keyboard Sound** brings the tactile, satisfying audio response of physical mechanical switches directly into your code editor.

---

## Developer Information

- **Developer Name:** Aadi Soni
- **Extension Name:** Keyboard Sound
- **Developer GitHub:** [https://github.com/aadisoni8044-code](https://github.com/aadisoni8044-code)
- **Developer Instagram:** [https://www.instagram.com/aadisoni8044/](https://www.instagram.com/aadisoni8044/)
- **Developer LinkedIn:** [https://www.linkedin.com/in/aadi-soni-a9ba35394/?isSelfProfile=true](https://www.linkedin.com/in/aadi-soni-a9ba35394/?isSelfProfile=true)

---

## Features

- ⚡ **Ultra-Low Typing Latency:** High-performance Web Audio API engine decodes audio into RAM for instant audio response on every keypress without freezing or slowing down VS Code.
- 🎧 **Multiple Sound Packs:** Choose between **Mechanical** switches, deep **Thock**, or vintage **Typewriter** sound profiles.
- 🎹 **Special Key Sounds:** Distinct realistic sound effects for `Space`, `Enter`, `Backspace`, `Tab`, and `Delete` keys.
- 🔀 **Randomized Click Variations:** Plays subtle key variation samples (`click1`–`click4`) so typing sounds natural, authentic, and non-repetitive.
- 🎛 **Flexible Volume Control:** Custom volume adjustments from `0%` (Mute) up to `100%` (Maximum volume) with presets (`Mute`, `Low`, `Medium`, `High`, `Very High`).
- 🔊 **Status Bar Quick Toggle:** Real-time indicator (`🔊 Keyboard Sound: ON` / `🔇 Keyboard Sound: OFF`) in the bottom bar with single-click toggle.
- 🎯 **Only Play While Coding:** Configurable option to only trigger audio when an editor document is actively focused.
- 🌐 **100% Offline & Universal:** Works offline for all programming languages (`JavaScript`, `TypeScript`, `Python`, `Dart`, `C++`, `Rust`, `Go`, `Java`, `HTML`, `CSS`, etc.).

---

## Extension Commands

Access commands via Command Palette (`Ctrl+Shift+P` / `Cmd+Shift+P`):

| Command | Description |
|---|---|
| `Keyboard Sound: Enable` | Turn on typing sounds |
| `Keyboard Sound: Disable` | Turn off typing sounds |
| `Keyboard Sound: Toggle` | Quick toggle ON/OFF |
| `Keyboard Sound: Test Sound` | Play a sample keyboard audio sequence |
| `Keyboard Sound: Open Settings` | Open Extension Settings |
| `Keyboard Sound: Select Sound Pack` | Switch between `Mechanical`, `Thock`, and `Typewriter` |
| `Keyboard Sound: Set Volume` | Pick a volume level preset or enter custom % |

---

## Configuration Settings

You can customize the extension via **VS Code Settings (`Ctrl+,` / `Cmd+,`)** -> **Extensions** -> **Keyboard Sound**:

| Setting | Default | Description |
|---|---|---|
| `keyboardSound.enabled` | `true` | Enable or disable keyboard sound effects while typing. |
| `keyboardSound.volume` | `70` | Sound playback volume percentage (`0` = Mute, `100` = Max volume). |
| `keyboardSound.soundPack` | `"mechanical"` | Select sound profile (`mechanical`, `thock`, `typewriter`). |
| `keyboardSound.specialKeySounds` | `true` | Play distinct sounds for `Space`, `Enter`, `Backspace`, `Tab`, `Delete`. |
| `keyboardSound.randomizeSounds` | `true` | Randomize key click variations to sound authentic. |
| `keyboardSound.onlyWhenEditorFocused` | `true` | Only play keyboard sounds when an active editor is focused. |

---

## How the Low-Latency Audio System Works

To achieve near **0 ms latency** without blocking the VS Code main extension host UI thread, **Keyboard Sound** uses a specialized Web Audio API architecture:

1. **Pre-Decoded In-Memory Audio Buffers:** `.wav` sound files are pre-loaded and decoded directly into Web Audio `AudioBuffer` objects in memory upon activation/sound pack selection.
2. **Background Webview Engine:** Audio rendering runs in a dedicated webview provider thread, offloading audio synthesis entirely from the editor's main process.
3. **Polyphonic Buffer Source Triggering:** Every `onDidChangeTextDocument` typing event sends a lightweight event message to instantly fire an `AudioBufferSourceNode`. Multiple keys pressed rapidly overlap cleanly without cut-off or sound delays.

---

## Sound Pack Folder Structure

```text
sounds/
├── mechanical/
│   ├── click1.wav
│   ├── click2.wav
│   ├── click3.wav
│   ├── click4.wav
│   ├── space.wav
│   ├── enter.wav
│   ├── backspace.wav
│   ├── tab.wav
│   └── delete.wav
├── thock/
│   └── ...
└── typewriter/
    └── ...
```

---

## Development & Build Instructions

### Prerequisites

- Node.js (`v18+` or `v20+`)
- npm (`v9+`)

### Setup & Compilation

```bash
# Install dependencies
npm install

# Compile TypeScript files
npm run compile

# Watch mode for extension development
npm run watch
```

### Packaging into VSIX

To build the standalone `.vsix` extension package:

```bash
npm run package
```

The output package will be generated as `keyboard-sound-1.0.0.vsix`.

---

## License

[MIT](LICENSE) © **Aadi Soni**
