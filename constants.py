"""
MSAI Studio - Constants and Configurations
"""
import os
import sys

APP_NAME = "MSAI Studio"
APP_VERSION = "1.0.0"
APP_ORGANIZATION = "MSAI"

DEFAULT_SETTINGS = {
    "theme": "MSAI Dark",
    "font_family": "Consolas, 'Fira Code', 'Courier New', monospace",
    "font_size": 13,
    "tab_size": 4,
    "insert_spaces": True,
    "word_wrap": False,
    "auto_save": "off",  # off, afterDelay, onFocusChange
    "auto_save_delay": 1000,
    "minimap": True,
    "line_numbers": True,
    "cursor_style": "line",
    "terminal_font_size": 12,
    "python_interpreter": sys.executable,
    "recent_files": [],
    "recent_projects": [],
    "ai_provider": "gemini",
    "ai_api_key": "",
    "ai_model": "gemini-1.5-pro",
}

# Supported file extensions and icons mapping
FILE_ICON_MAP = {
    ".py": "🐍",
    ".json": "📋",
    ".md": "📝",
    ".txt": "📄",
    ".html": "🌐",
    ".css": "🎨",
    ".js": "📜",
    ".sh": "🐚",
    ".yml": "⚙️",
    ".yaml": "⚙️",
    ".gitignore": "👁️",
    "requirements.txt": "📦",
    "README.md": "📖",
}

DEFAULT_UNTITLED_NAME = "Untitled.py"
