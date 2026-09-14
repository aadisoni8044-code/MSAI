# OpenMS Desktop IDE

A modern, native Python desktop code editor and interpreter engine for the custom **OpenMS** programming language.

Built using Tkinter without web technology or external server dependencies.

---

## Features Overview

* **VS Code-Style UI/UX**: Features an Activity Bar, Primary Sidebar, Tabbed Code Editor with line numbers, Integrated Terminal Log, AI Copilot, Command Palette, and Status Bar.
* **OpenMS Interpreter Engine**: Custom tokenizer, AST expression evaluator, and indentation-based block parser supporting functions, conditionals, variables, and math operators.
* **14 Built-in Functions**: Full runtime support for 1D console logic, 2D vector primitives, composite shapes, photo assets, and pseudo-3D isometric graphics windows.
* **Live Theme Switcher**: 5 themes out of the box (VS Code Dark, Obsidian Dark, Monokai, Cyberpunk, Light Slate).
* **Command Palette**: Quick command launcher accessible via `Ctrl+Shift+P` / `Cmd+Shift+P`.
* **OpenMS AI Assistant**: Rule-based AI Copilot panel providing interactive guidance, error explanation, and function reference.

---

## OpenMS Language Reference (14 Functions)

| Category | Function | Description |
| :--- | :--- | :--- |
| **1D Execution** | `machine(*args)` | Prints output values directly to the Integrated Terminal panel. |
| | `input(prompt)` | Displays a native input prompt dialog and returns the user string. |
| | `function name(params):` | Defines a reusable block of OpenMS code. |
| | `open(path)` | Reads a file from disk into memory. |
| | `if(condition):` | Executes an indented block if the condition evaluates to truthy. |
| **2D / 3D Visuals** | `box(size, color)` | Constructs a square / cube box object with configurable dimensions and hex color. |
| | `bol(radius, color)` | Constructs a circle / sphere ball object. |
| | `size(obj, value)` | Resizes a shape object's size or radius in place. |
| | `photo(path)` | References an image photo asset. |
| | `time(seconds)` | Registers a non-blocking delay / timer. |
| | `house(width, height)`| Constructs a composite house object with walls and roof. |
| | `game(title, w, h)` | Creates a game container world holding multiple shapes. |
| | `boody_2D(obj)` | Renders any shape primitive or game world into a live 2D window viewport. |
| | `boody_3D(obj)` | Renders any shape primitive or game world into a live pseudo-3D isometric viewport. |

---

## Project Codebase Structure

```text
/app
├── openms_ide.py             # Main executable entry point script
├── main.py                   # Alternative entry point script
├── openms/                   # OpenMS core application package
│   ├── __init__.py           # Package version and metadata
│   ├── config.py             # Themes, application settings, and function reference docs
│   ├── runtime/              # OpenMS Language Execution Runtime
│   │   ├── __init__.py
│   │   ├── errors.py         # OpenMSError exception classes
│   │   ├── models.py         # OMSBox, OMSBall, OMSHouse, OMSGame, OMSPhoto, etc.
│   │   ├── builtins.py       # Implementation of all 14 built-in OpenMS functions
│   │   ├── interpreter.py    # AST evaluator, tokenizer, and block parser
│   │   └── renderer.py     # 2D Canvas and pseudo-3D isometric rendering engine
│   └── ui/                   # Tkinter GUI Components
│       ├── __init__.py
│       ├── app.py            # Main OpenMSIDE application layout orchestration
│       ├── activity_bar.py   # VS Code activity navigation bar
│       ├── sidebar.py        # Primary sidebar container (Explorer, Search, Copilot, Ref)
│       ├── file_explorer.py  # Workspace directory file tree
│       ├── editor_tab.py     # Multi-tab notebook editor container
│       ├── editor.py         # Code editor with line numbers and auto-indent
│       ├── highlighter.py    # OpenMS regex syntax highlighting engine
│       ├── terminal.py       # Integrated terminal output panel
│       ├── ai_copilot.py     # OpenMS AI Assistant chat panel
│       ├── command_palette.py# Ctrl+Shift+P Command Palette dialog
│       ├── status_bar.py     # Line/Col cursor indicator and status bar
│       └── theme_manager.py  # Dynamic theme manager & subscriber event bus
└── tests/                    # Automated Test Suite
    ├── __init__.py
    ├── test_interpreter.py   # Unit tests for runtime interpreter and 14 builtins
    └── test_ui.py            # Unit tests for UI components, themes, and highlighter
```

---

## How to Run

### Start the OpenMS Desktop IDE
```bash
python3 openms_ide.py
```

### Run in Headless / Check Mode
```bash
PYTHONPATH=. xvfb-run python3 openms_ide.py --check
```

### Run Test Suite
```bash
PYTHONPATH=. xvfb-run python3 -m pytest
```
