"""
NV Studio Configuration and Persistence Manager
Handles loading and saving app settings, theme preferences, consent flags, and workspace session state.
"""

import json
import os
from pathlib import Path
from typing import Any, Dict, List, Optional

CONFIG_DIR = Path.home() / ".nvstudio"
SETTINGS_FILE = CONFIG_DIR / "settings.json"
STATE_FILE = CONFIG_DIR / "workspace_state.json"

DEFAULT_SETTINGS = {
    "theme": None,  # None means first launch, asks user
    "storage_permission_granted": False,  # Permission consent on first launch
    "auto_save": True,
    "preview_device": "laptop",  # "mobile", "ipad", "laptop"
    "restore_workspace": True,
    "editor_font_size": 13,
    "editor_tab_size": 2,
    "editor_line_numbers": True,
    "editor_word_wrap": False,
    "last_workspace_path": None,
}

DEFAULT_WORKSPACE_STATE = {
    "project_path": None,
    "open_files": [],
    "active_file": None,
    "preview_device": "laptop",
}


class ConfigManager:
    """Manages global settings and workspace session state persistence."""

    def __init__(self):
        CONFIG_DIR.mkdir(parents=True, exist_ok=True)
        self.settings: Dict[str, Any] = self.load_settings()
        self.workspace_state: Dict[str, Any] = self.load_workspace_state()

    def load_settings(self) -> Dict[str, Any]:
        """Loads user settings from ~/.nvstudio/settings.json."""
        if SETTINGS_FILE.exists():
            try:
                with open(SETTINGS_FILE, "r", encoding="utf-8") as f:
                    data = json.load(f)
                    settings = DEFAULT_SETTINGS.copy()
                    settings.update(data)
                    return settings
            except Exception as e:
                print(f"[ConfigManager] Error loading settings: {e}")
        return DEFAULT_SETTINGS.copy()

    def save_settings(self) -> None:
        """Saves current settings to disk."""
        try:
            CONFIG_DIR.mkdir(parents=True, exist_ok=True)
            with open(SETTINGS_FILE, "w", encoding="utf-8") as f:
                json.dump(self.settings, f, indent=2)
        except Exception as e:
            print(f"[ConfigManager] Error saving settings: {e}")

    def get(self, key: str, default: Any = None) -> Any:
        return self.settings.get(key, default)

    def set(self, key: str, value: Any) -> None:
        self.settings[key] = value
        self.save_settings()

    def load_workspace_state(self) -> Dict[str, Any]:
        """Loads active workspace state (open files, active tab, device)."""
        if STATE_FILE.exists():
            try:
                with open(STATE_FILE, "r", encoding="utf-8") as f:
                    data = json.load(f)
                    state = DEFAULT_WORKSPACE_STATE.copy()
                    state.update(data)
                    return state
            except Exception as e:
                print(f"[ConfigManager] Error loading workspace state: {e}")
        return DEFAULT_WORKSPACE_STATE.copy()

    def save_workspace_state(
        self,
        project_path: Optional[str] = None,
        open_files: Optional[List[str]] = None,
        active_file: Optional[str] = None,
        preview_device: Optional[str] = None,
    ) -> None:
        """Saves current workspace state for auto-restore on next launch."""
        try:
            CONFIG_DIR.mkdir(parents=True, exist_ok=True)
            if project_path is not None:
                self.workspace_state["project_path"] = str(project_path)
                self.settings["last_workspace_path"] = str(project_path)
            if open_files is not None:
                self.workspace_state["open_files"] = open_files
            if active_file is not None:
                self.workspace_state["active_file"] = active_file
            if preview_device is not None:
                self.workspace_state["preview_device"] = preview_device
                self.settings["preview_device"] = preview_device

            with open(STATE_FILE, "w", encoding="utf-8") as f:
                json.dump(self.workspace_state, f, indent=2)
            self.save_settings()
        except Exception as e:
            print(f"[ConfigManager] Error saving workspace state: {e}")


# Singleton instance
config = ConfigManager()
