# KORA — Python → EXE Automatic Build System

**Kora** is a professional Windows desktop application designed to automatically analyze Python projects, prepare controlled build environments, execute suitable Python-to-EXE build tools (PyInstaller, Nuitka, cx_Freeze), analyze errors, apply safe fixes, and retry through fallbacks until an executable is produced.

---

## 🌟 Key Features

* **Automatic Project Scanning**: Detects entry points (`main.py`, `app.py`, etc.), dependencies (`requirements.txt`, `pyproject.toml`, `setup.py`), virtual environments, imported modules, and application assets (`.png`, `.wav`, `.json`, etc.).
* **Controlled & Safe Execution**: Strict permission system and command validation layer. No dangerous system modifications, shell code injections, or registry edits.
* **Smart Fallback Engine**: Attempts primary strategy (PyInstaller), classifies failure errors (missing package, missing module, DLL error), applies safe automatic fixes with user permission, and seamlessly falls back to Nuitka or cx_Freeze.
* **Build Memory**: Stores successful build strategies per project in local SQLite database to optimize future builds.
* **EXE Verification & Testing**: Confirms executable existence, file size, extension, and provides automated non-destructive launch testing.
* **Local-First & Private**: 100% offline-ready. Code and logs remain strictly on the user's computer.

---

## 🚀 Quick Start

### Requirements
* Python 3.8+
* Tkinter (standard in standard Python installations)

### Installation
```bash
git clone https://github.com/user/kora.git
cd kora
pip install -r requirements.txt
```

### Running Kora
```bash
python main.py
```

---

## 🛠 Building Kora into Kora.exe

To build Kora itself into a standalone Windows executable:

```bash
python build_kora.py
```

The generated executable will be saved in `dist/Kora.exe`.

---

## 🧪 Running Tests

Run the full automated test suite using pytest:

```bash
PYTHONPATH=. pytest -v tests/
```

---

## 📖 Documentation

* [Architecture Overview](ARCHITECTURE.md)
* [Security & Permission Model](SECURITY.md)
* [Builder Plugin System](BUILDERS.md)
* [Contributing Guide](CONTRIBUTING.md)
