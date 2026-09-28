# EXE/TOW — Python to Windows EXE Builder

**EXE/TOW** is a professional desktop build tool built in Python with PySide6. It automatically compiles Python projects and `.py` scripts into standalone Windows `.exe` applications.

---

## Key Features

- **Automated Fallback Engine:** Intelligent retry system that executes alternative strategies and recovery steps if a build command fails.
- **Environment & Project Auto-Detection:** Automatically detects installed Python interpreters, `pip`, `PyInstaller`, `requirements.txt`, virtual environments, and entry points.
- **Command Knowledge Database:** Records successful and failed command executions across environments to continuously optimize build strategy selection.
- **Live Terminal Output:** Real-time stdout/stderr logging stream with auto-scrolling, clear, copy, and file export options.
- **Build & Command History:** View past command executions with exit codes, durations, and detailed stdout/stderr inspector dialogs.
- **Standalone Executable Creation:** Easily configure One-File (`--onefile`) or One-Directory (`--onedir`) outputs, customize output folders, and launch generated EXEs.
- **Self-Packaging:** EXE/TOW can be compiled into a standalone `EXE/TOW.exe` using `python build_exe.py`.

---

## Usage Instructions

### Running from Source
1. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
2. Launch the application:
   ```bash
   python main.py
   ```

### Building EXE/TOW as Standalone .exe
Run the automated self-packaging script:
```bash
python build_exe.py
```
The compiled binary will be located at `dist/EXE_TOW.exe`.

### Running Tests
Execute unit and integration tests:
```bash
PYTHONPATH=. pytest
```
