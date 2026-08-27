"""
Configuration manager for user settings and keybindings.
"""

import json
import os
import platform
from pathlib import Path
from typing import Any, Dict

from utils.logger import logger


class ConfigManager:
    """Manages loading, saving, and defaults for application settings and keybindings."""

    def __init__(self) -> None:
        self.config_dir = self._get_config_directory()
        self.config_dir.mkdir(parents=True, exist_ok=True)

        self.settings_file = self.config_dir / "settings.json"
        self.keybindings_file = self.config_dir / "keybindings.json"

        self.default_settings: Dict[str, Any] = {
            "theme": "dark",
            "font_family": "Consolas",
            "font_size": 13,
            "tab_size": 4,
            "use_spaces": True,
            "word_wrap": False,
            "auto_save": False,
            "auto_save_delay": 5,
            "show_minimap": True,
            "show_line_numbers": True,
            "show_folding": True,
            "highlight_current_line": True,
            "recent_files": [],
            "recent_folders": []
        }

        self.default_keybindings: Dict[str, str] = {
            "save_file": "Ctrl+S",
            "open_file": "Ctrl+O",
            "open_folder": "Ctrl+K",
            "new_file": "Ctrl+N",
            "close_tab": "Ctrl+W",
            "find": "Ctrl+F",
            "find_in_files": "Ctrl+Shift+F",
            "command_palette": "Ctrl+Shift+P",
            "quick_open": "Ctrl+P",
            "toggle_comment": "Ctrl+/",
            "run_file": "F5",
            "toggle_terminal": "Ctrl+`",
            "toggle_sidebar": "Ctrl+B"
        }

        self.settings = self.load_settings()
        self.keybindings = self.load_keybindings()

    def _get_config_directory(self) -> Path:
        """Determines OS-appropriate user configuration directory."""
        sys_name = platform.system()
        if sys_name == "Windows":
            app_data = os.environ.get("APPDATA")
            if app_data:
                return Path(app_data) / "PyCodeStudio"
            return Path.home() / "AppData" / "Roaming" / "PyCodeStudio"
        else:
            return Path.home() / ".pycodestudio"

    def load_settings(self) -> Dict[str, Any]:
        """Loads settings from file or creates defaults if missing."""
        if self.settings_file.exists():
            try:
                with open(self.settings_file, "r", encoding="utf-8") as f:
                    data = json.load(f)
                    merged = dict(self.default_settings)
                    merged.update(data)
                    return merged
            except Exception as e:
                logger.error(f"Error reading settings file: {e}")

        self.save_settings(self.default_settings)
        return dict(self.default_settings)

    def save_settings(self, settings: Dict[str, Any] = None) -> None:
        """Saves current settings dictionary to disk."""
        if settings is not None:
            self.settings = settings
        try:
            with open(self.settings_file, "w", encoding="utf-8") as f:
                json.dump(self.settings, f, indent=4)
        except Exception as e:
            logger.error(f"Error saving settings file: {e}")

    def get(self, key: str, default: Any = None) -> Any:
        """Gets a setting value by key."""
        return self.settings.get(key, default)

    def set(self, key: str, value: Any) -> None:
        """Sets a setting value and saves settings."""
        self.settings[key] = value
        self.save_settings()

    def load_keybindings(self) -> Dict[str, str]:
        """Loads keybindings from file or returns defaults."""
        if self.keybindings_file.exists():
            try:
                with open(self.keybindings_file, "r", encoding="utf-8") as f:
                    data = json.load(f)
                    merged = dict(self.default_keybindings)
                    merged.update(data)
                    return merged
            except Exception as e:
                logger.error(f"Error reading keybindings file: {e}")

        self.save_keybindings(self.default_keybindings)
        return dict(self.default_keybindings)

    def save_keybindings(self, keybindings: Dict[str, str] = None) -> None:
        """Saves keybindings dictionary to disk."""
        if keybindings is not None:
            self.keybindings = keybindings
        try:
            with open(self.keybindings_file, "w", encoding="utf-8") as f:
                json.dump(self.keybindings, f, indent=4)
        except Exception as e:
            logger.error(f"Error saving keybindings file: {e}")

    def add_recent_file(self, file_path: str) -> None:
        """Adds a file path to recent files list."""
        recent = self.settings.get("recent_files", [])
        if file_path in recent:
            recent.remove(file_path)
        recent.insert(0, file_path)
        self.settings["recent_files"] = recent[:10]
        self.save_settings()

    def add_recent_folder(self, folder_path: str) -> None:
        """Adds a folder path to recent folders list."""
        recent = self.settings.get("recent_folders", [])
        if folder_path in recent:
            recent.remove(folder_path)
        recent.insert(0, folder_path)
        self.settings["recent_folders"] = recent[:10]
        self.save_settings()
