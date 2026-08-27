# PyCodeStudio

**PyCodeStudio** is a lightweight, cross-platform desktop code editor and IDE built in **Python 3.11+**, **PyQt6**, **QScintilla**, and **Pygments**. It provides a VS Code–inspired user interface and feature set for lightweight daily coding, student learning, and multi-language development.

---

## Features

- **Welcome Screen**: Recent files and folders, quick actions ("New File", "Open Folder"), theme quick-switch.
- **File Explorer Sidebar**: Directory tree view with right-click context menu (create file/folder, rename, delete, duplicate, reveal in OS file manager).
- **Tabbed Multi-File Editor**: Unsaved change indicators (`*`), tab context actions (close, close others, close all).
- **Syntax Highlighting**: Built-in QScintilla lexers and Pygments fallback for Python, JavaScript, HTML, CSS, JSON, Markdown, C++, Java, Bash, XML, YAML, and SQL.
- **IDE Features**: Line numbers, code folding, auto-indentation, bracket matching, current line highlighting, word wrap toggle.
- **Find & Replace Panel**: In-file search with case sensitivity, regex toggle, and replace-all.
- **Global Project Search**: Project-wide text search across files with line jumping (Ctrl+Shift+F).
- **Integrated Terminal**: Embedded OS shell (`cmd`/`PowerShell` on Windows, `bash`/`zsh` on macOS/Linux) running inside `QProcess`.
- **Command Palette**: Searchable quick launcher (`Ctrl+Shift+P`) for all app actions.
- **Code Execution**: Run active Python or detected source file (`F5`) with output directly in the embedded terminal.
- **Split View**: Side-by-side split editor view.
- **Minimap & Status Bar**: Mini code preview and line/col, encoding, language, indent indicator.
- **Themes**: VS Code Dark+ and Light+ theme stylesheets.
- **Settings Dialog**: Custom font family, font size, tab size, auto-save timer, and word wrap options saved to local JSON config.
- **Plugin Architecture**: Place custom plugin scripts in `/plugins` to extend app capabilities.

---

## File & Directory Structure

```text
/pycodestudio
  ├── main.py                        # App entry point & splash screen launcher
  ├── requirements.txt               # Package dependencies
  ├── README.md                      # Documentation & build instructions
  ├── setup_build.spec               # PyInstaller build specification
  ├── config/
  │   ├── settings.json              # Default user settings
  │   └── keybindings.json           # Default keyboard shortcuts
  ├── app/
  │   ├── __init__.py
  │   ├── main_window.py             # Main QMainWindow assembly & menu bar
  │   ├── welcome_screen.py          # Start page widget
  │   ├── command_palette.py         # Ctrl+Shift+P dialog
  │   ├── status_bar.py              # Status bar
  │   ├── settings_dialog.py         # Preferences dialog
  │   └── splash_screen.py           # Startup splash screen
  ├── editor/
  │   ├── __init__.py
  │   ├── editor_widget.py           # QScintilla code editor component
  │   ├── tab_manager.py             # Multi-tab tab bar manager
  │   ├── syntax_highlighter.py      # QScintilla & Pygments lexer mapping
  │   ├── find_replace.py            # In-file find and replace panel
  │   ├── minimap.py                 # Minimap overview preview widget
  │   └── split_view.py              # Dual side-by-side split editor
  ├── explorer/
  │   ├── __init__.py
  │   ├── file_tree.py               # Sidebar directory tree widget
  │   ├── file_operations.py         # File system mutation helpers
  │   └── context_menu.py            # Right-click context menu
  ├── terminal/
  │   ├── __init__.py
  │   ├── terminal_widget.py         # QProcess embedded terminal
  │   └── run_manager.py             # Language execution runner
  ├── search/
  │   ├── __init__.py
  │   └── global_search.py           # Cross-file search panel
  ├── themes/
  │   ├── __init__.py
  │   ├── dark_theme.py              # Dark+ QSS theme
  │   ├── light_theme.py             # Light+ QSS theme
  │   └── theme_manager.py           # Theme switching manager
  ├── utils/
  │   ├── __init__.py
  │   ├── config_manager.py          # Settings JSON persistence
  │   ├── file_utils.py              # File I/O & OS manager reveal
  │   ├── icon_loader.py             # Procedural SVG vector icons
  │   └── logger.py                  # Logging configuration
  ├── plugins/
  │   └── __init__.py                # Plugin loading architecture
  ├── assets/
  │   ├── icons/                     # SVG/PNG icon assets
  │   ├── fonts/                     # Custom TTF/OTF monospace fonts
  │   └── app_icon.png
  └── tests/
      ├── __init__.py
      ├── test_editor.py             # Editor unit tests
      └── test_file_operations.py    # File system unit tests
```

---

## How to Run in Development Mode

### 1. Prerequisites
Ensure you have **Python 3.11+** installed on your operating system.

### 2. Install Dependencies
```bash
pip install -r requirements.txt
```

### 3. Run Application
```bash
python main.py
```

---

## Packaging into Standalone Executables

### 1. Windows Standalone Executable (`.exe`)
To package PyCodeStudio as a standalone executable on Windows using PyInstaller:

```cmd
pip install pyinstaller
pyinstaller setup_build.spec
```
The compiled output folder containing `PyCodeStudio.exe` will be generated under `dist/PyCodeStudio/`.

---

### 2. macOS Application Bundle (`.app`)

#### Using py2app:
Create a `setup.py` file:
```python
from setuptools import setup

APP = ['main.py']
DATA_FILES = ['config', 'assets', 'plugins']
OPTIONS = {
    'argv_emulation': False,
    'iconfile': 'assets/app_icon.png',
    'includes': ['PyQt6', 'PyQt6.Qsci', 'Pygments'],
}

setup(
    app=APP,
    data_files=DATA_FILES,
    options={'py2app': OPTIONS},
    setup_requires=['py2app'],
)
```
Run build command on macOS:
```bash
pip install py2app
python setup.py py2app
```
The standalone bundle `PyCodeStudio.app` will be created in the `dist/` directory.

---

### 3. Linux Standalone Binary / AppImage

#### Step A: Build Linux binary using PyInstaller
```bash
pip install pyinstaller
pyinstaller setup_build.spec
```

#### Step B: Package into an AppImage
1. Install `appimagetool` from [AppImage GitHub Releases](https://github.com/AppImage/AppImageKit/releases).
2. Create an `AppDir` folder structure:
   ```bash
   mkdir -p PyCodeStudio.AppDir/usr/bin
   cp -r dist/PyCodeStudio/* PyCodeStudio.AppDir/usr/bin/
   ```
3. Add a `PyCodeStudio.desktop` entry inside `PyCodeStudio.AppDir/`:
   ```ini
   [Desktop Entry]
   Name=PyCodeStudio
   Exec=PyCodeStudio
   Icon=app_icon
   Type=Application
   Categories=Development;IDE;
   ```
4. Copy `assets/app_icon.png` to `PyCodeStudio.AppDir/app_icon.png`.
5. Run `appimagetool`:
   ```bash
   appimagetool PyCodeStudio.AppDir PyCodeStudio-x86_64.AppImage
   ```

---

## Running Unit Tests

Run automated test suite using `pytest`:
```bash
pytest
```
