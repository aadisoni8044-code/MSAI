"""NV Studio Configuration Manager"""
import json
import os
from pathlib import Path
from typing import Any, Dict
from PyQt6.QtCore import QObject, pyqtSignal

DEFAULT_SETTINGS: Dict[str, Any] = {
    "theme": "NV Dark",
    "editor": {
        "font_family": "Consolas, 'Courier New', monospace",
        "font_size": 13,
        "tab_size": 4,
        "insert_spaces": True,
        "word_wrap": True,
        "line_numbers": True,
        "highlight_active_line": True,
        "auto_close_brackets": True,
        "auto_save": "off",  # off, afterDelay, onFocusChange
        "auto_save_delay": 1000,
        "show_indent_guides": True
    },
    "terminal": {
        "shell": "",  # Auto-detected if empty
        "font_family": "Consolas, 'Courier New', monospace",
        "font_size": 12,
        "cursor_style": "block"
    },
    "workspace": {
        "recent_folders": [],
        "recent_files": [],
        "restore_session": True
    },
    "window": {
        "width": 1280,
        "height": 800,
        "sidebar_visible": True,
        "bottom_panel_visible": True,
        "active_activity": "explorer"
    }
}


class ConfigManager(QObject):
    """Manages NV Studio application settings with Signal notification on updates."""
    settings_changed = pyqtSignal(str, object)  # (key_path, new_value)

    def __init__(self, config_dir: Path | None = None):
        super().__init__()
        if config_dir is None:
            config_dir = Path.home() / ".nvstudio"
        self.config_dir = Path(config_dir)
        self.config_dir.mkdir(parents=True, exist_ok=True)
        self.config_file = self.config_dir / "settings.json"
        self._settings: Dict[str, Any] = {}
        self.load()

    def load(self) -> None:
        """Load settings from JSON file or create with defaults."""
        self._settings = self._deep_copy(DEFAULT_SETTINGS)
        if self.config_file.exists():
            try:
                with open(self.config_file, "r", encoding="utf-8") as f:
                    saved = json.load(f)
                    self._merge_dicts(self._settings, saved)
            except Exception as e:
                print(f"[ConfigManager] Error loading config: {e}")
        else:
            self.save()

    def save(self) -> None:
        """Save settings to JSON file."""
        try:
            with open(self.config_file, "w", encoding="utf-8") as f:
                json.dump(self._settings, f, indent=2)
        except Exception as e:
            print(f"[ConfigManager] Error saving config: {e}")

    def get(self, key_path: str, default: Any = None) -> Any:
        """Get setting using dot notation, e.g., 'editor.font_size'."""
        keys = key_path.split(".")
        val = self._settings
        for k in keys:
            if isinstance(val, dict) and k in val:
                val = val[k]
            else:
                return default
        return val

    def set(self, key_path: str, value: Any) -> None:
        """Set setting using dot notation and emit change signal."""
        keys = key_path.split(".")
        curr = self._settings
        for k in keys[:-1]:
            if k not in curr or not isinstance(curr[k], dict):
                curr[k] = {}
            curr = curr[k]
        curr[keys[-1]] = value
        self.save()
        self.settings_changed.emit(key_path, value)

    def _merge_dicts(self, target: dict, source: dict) -> None:
        for k, v in source.items():
            if k in target and isinstance(target[k], dict) and isinstance(v, dict):
                self._merge_dicts(target[k], v)
            else:
                target[k] = v

    def _deep_copy(self, d: dict) -> dict:
        return json.loads(json.dumps(d))


# Global config instance
config_manager = ConfigManager()
