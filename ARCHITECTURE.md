# Kora Architecture

## Overview

Kora follows a modular, extensible, layered architecture designed for local desktop execution on Windows.

```text
kora/
│
├── main.py                    # Application Entry Point
│
├── app/                       # Core Logic Modules
│   ├── ui/                    # Tkinter Desktop GUI (MainWindow, TerminalView, Dialogs)
│   ├── project_scanner/       # Project Scanner & AST Import Inspector
│   ├── build_engine/          # Strategy Selection & Fallback Orchestration Engine
│   ├── command_runner/        # Safe Subprocess Command Runner
│   ├── error_analyzer/        # Error Classification & Fix Suggestion Engine
│   ├── dependency_manager/    # Pip Package Manager
│   ├── environment_manager/   # Python Interpreter & Venv Resolver
│   ├── output_detector/       # EXE Verification & Launch Tester
│   ├── permission_manager/    # Safety Permission Enforcement
│   ├── logger/                # Multi-channel File & Console Logger
│   └── configuration/         # Config Persistence Manager
│
├── builders/                  # Builder Plugin Architecture
│   ├── base_builder.py        # Abstract Base Builder Interface
│   ├── pyinstaller_builder.py # PyInstaller Plugin
│   ├── nuitka_builder.py      # Nuitka Plugin
│   └── cx_freeze_builder.py   # cx_Freeze Plugin
│
├── models/                    # Data Transfer Objects
│   ├── project_info.py
│   ├── build_result.py
│   ├── build_strategy.py
│   ├── command_result.py
│   └── settings.py
│
├── database/                  # SQLite History Persistence
│   └── build_history.py
│
├── tests/                     # Automated Test Suites
├── requirements.txt
├── build_kora.py              # Self-Build Script
└── README.md
```

## Strategy Decision Flow

```text
Select Project Folder
       │
       ▼
Project Scanner (AST + Assets + Configs)
       │
       ▼
User Permission Review & Confirmation
       │
       ▼
Check Build History (Known Successful Strategy)
       │
       ▼
Execute Selected Builder Command (Command Runner)
       │
       ├────────────────────────┐
   [SUCCESS]                 [FAILURE]
       │                        │
       ▼                        ▼
Verify Output EXE         Error Analyzer
       │                        │
  (Valid EXE?)           (Safe Fix Available?)
   ├── YES ──► DONE       ├── YES ──► Apply Fix & Retry
   └── NO                 └── NO  ──► Try Fallback Builder
```
