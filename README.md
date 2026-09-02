# MSAI Studio — Python Code Editor IDE

**MSAI Studio** is a complete desktop code editor application inspired by Visual Studio Code, designed specifically for **Python development**.

---

## Key Features

- **Professional Dark-Mode UI**: VS Code-inspired Activity Bar, Explorer, Tab System, Integrated Terminal, and Status Bar.
- **Python Execution System**: Run Python files asynchronously with real-time output streaming, stop/restart execution, and custom arguments.
- **Python Code Editor**:
  - Python syntax highlighting
  - Line numbers & current line highlight
  - Bracket matching & auto-closing brackets
  - In-editor Find & Replace
  - Multi-tab document management
- **Project Explorer**: Full directory file tree with open folder, file/folder creation, rename, delete, and refresh actions.
- **Global Search**: Project-wide search and replace supporting regular expressions, case sensitivity, and whole word matching.
- **Source Control (Git)**: Git branch status, changed file indicators, staging/unstaging, and commit capabilities.
- **Run & Debug Interface**: Breakpoints management, call stack monitoring, and local variable inspection.
- **Integrated Terminal & Output Panel**: Expandable/collapsible bottom panel with Problems, Output, Debug Console, and Integrated Terminal.
- **Python Interpreter Management**: Automatic detection and switching of system Python executables with active interpreter status bar indicator.
- **MSAI AI Assistant**: Integrated AI panel to explain, fix, refactor, document, or generate Python code.
- **Extensions & Custom Settings**: Configurable theme (MSAI Dark / MSAI Light), font size, tab size, line numbers, word wrap, and extension tools view.

---

## Project Architecture

The project is structured into modular Python source files:

```text
MSAI-Studio/
├── main.py                    # Application main entry point
├── app.py                     # QApplication runner
├── config.py                  # JSON configuration manager
├── constants.py               # App defaults and constants
├── state.py                   # App state signals and event bus
│
├── core/
│   ├── file_manager.py        # File CRUD operations
│   ├── project_manager.py     # Active folder and workspace state
│   ├── workspace.py           # Open files tracker
│   ├── python_runner.py       # Async Python execution engine
│   ├── process_manager.py     # Subprocess runner using QProcess
│   ├── interpreter_manager.py # Python interpreter detection
│   └── search_engine.py       # Global search & replace engine
│
├── ui/
│   ├── main_window.py         # Main UI layout assembly
│   ├── title_bar.py           # Custom title bar & menu bar
│   ├── activity_bar.py        # Vertical activity sidebar switcher
│   ├── explorer.py            # File system tree explorer
│   ├── editor.py              # Python code editor with syntax highlighter
│   ├── tabs.py                # Tab management system
│   ├── terminal_panel.py      # Bottom panel (Terminal, Output, Problems, Debug)
│   ├── status_bar.py          # Bottom status bar & interpreter picker
│   ├── command_palette.py     # Command palette (Ctrl+Shift+P) & Quick Open
│   ├── search_view.py         # Global search sidebar view
│   ├── git_view.py            # Source control sidebar view
│   ├── debug_view.py          # Run & debug sidebar view
│   ├── extensions_view.py     # Python extensions view
│   ├── settings_view.py       # Application settings view
│   └── ai_view.py             # MSAI AI assistant sidebar view
│
├── git/
│   ├── git_manager.py         # Git repository status & actions
│   └── git_commands.py        # Git CLI wrapper
│
├── debug/
│   └── debugger.py            # Breakpoints & frame variable inspection
│
├── ai/
│   ├── ai_assistant.py        # AI code operations engine
│   └── ai_provider.py         # Gemini REST API provider integration
│
├── resources/
│   └── themes.py              # Theme definitions & QSS stylesheets
│
└── tests/
    └── test_app.py            # Unit and integration test suite
```

---

## Installation & Running

### Prerequisites

- Python 3.10+
- PyQt6

### Run Application

```bash
# Install dependencies
pip install -r requirements.txt

# Launch MSAI Studio
python main.py
```

---

## Keyboard Shortcuts

| Shortcut | Description |
| :--- | :--- |
| `Ctrl + N` | New File |
| `Ctrl + O` | Open File |
| `Ctrl + S` | Save File |
| `Ctrl + Shift + S` | Save File As |
| `Ctrl + W` | Close Active Tab |
| `Ctrl + F` | Find in Active Editor |
| `Ctrl + Shift + P` | Command Palette |
| `Ctrl + P` | Quick Open File |
| `F5` | Start Debugging / Run File |
| `Ctrl + F5` | Run Without Debugging |
| `Ctrl + \`` | Toggle Integrated Terminal |
| `Ctrl + B` | Toggle Sidebar |

---

## Packaging as Standalone Desktop Executable

To package **MSAI Studio** into a standalone executable for Windows, Linux, or macOS:

1. Install PyInstaller:

```bash
pip install pyinstaller
```

2. Build executable:

```bash
pyinstaller --noconfirm --onedir --windowed --name "MSAI Studio" main.py
```

The output build will be available inside the `dist/MSAI Studio/` directory.
