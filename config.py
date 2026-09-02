"""
MSAI Studio - Config Manager
"""
import json
import os
import sys
from pathlib import Path
from constants import DEFAULT_SETTINGS, APP_NAME

class ConfigManager:
    """Handles loading and saving application configuration settings."""

    def __init__(self, config_file: str = None):
        if config_file:
            self.config_path = Path(config_file)
        else:
            config_dir = Path.home() / f".{APP_NAME.lower().replace(' ', '_')}"
            config_dir.mkdir(parents=True, exist_ok=True)
            self.config_path = config_dir / "settings.json"

        self.settings = DEFAULT_SETTINGS.copy()
        self.load()

    def load(self):
        """Load settings from JSON file if it exists."""
        if self.config_path.exists():
            try:
                with open(self.config_path, "r", encoding="utf-8") as f:
                    data = json.load(f)
                    self.settings.update(data)
            except Exception as e:
                print(f"[ConfigManager] Error loading config: {e}")

    def save(self):
        """Save settings to JSON file."""
        try:
            self.config_path.parent.mkdir(parents=True, exist_ok=True)
            with open(self.config_path, "w", encoding="utf-8") as f:
                json.dump(self.settings, f, indent=4)
        except Exception as e:
            print(f"[ConfigManager] Error saving config: {e}")

    def get(self, key: str, default=None):
        """Get a setting value."""
        return self.settings.get(key, default)

    def set(self, key: str, value):
        """Set a setting value and save."""
        self.settings[key] = value
        self.save()

    def add_recent_project(self, path: str):
        """Add a project directory to recent projects."""
        recents = [p for p in self.settings.get("recent_projects", []) if p != path]
        recents.insert(0, path)
        self.settings["recent_projects"] = recents[:10]
        self.save()

    def add_recent_file(self, path: str):
        """Add a file to recent files list."""
        recents = [p for p in self.settings.get("recent_files", []) if p != path]
        recents.insert(0, path)
        self.settings["recent_files"] = recents[:10]
        self.save()
