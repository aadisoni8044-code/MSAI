"""
exe/tow - Settings Manager
Handles loading, saving, and managing application configuration settings.
"""

import json
import os
import sys

DEFAULT_SETTINGS = {
    "python_interpreter": sys.executable,
    "default_output_folder": os.path.abspath("dist"),
    "build_engine": "PyInstaller",
    "theme": "Dark Charcoal",
    "one_file_default": True,
    "windowed_default": True,
    "console_default": False,
    "include_files_default": True,
    "include_dependencies_default": True,
    "optimize_default": True,
    "clean_default": True,
    "recent_projects": []
}

class SettingsManager:
    """Manages exe/tow application preferences and default build options."""

    def __init__(self, config_file: str = "exe_tow_settings.json"):
        self.config_file = config_file
        self.data = dict(DEFAULT_SETTINGS)
        self.load()

    def load(self) -> dict:
        """Loads configuration from file if exists, falling back to defaults."""
        if os.path.exists(self.config_file) and os.path.getsize(self.config_file) > 0:
            try:
                with open(self.config_file, "r", encoding="utf-8") as f:
                    saved = json.load(f)
                    self.data.update(saved)
            except Exception as e:
                print(f"[exe/tow settings] Warning loading {self.config_file}: {e}")
        return self.data

    def save(self) -> bool:
        """Saves configuration to file."""
        try:
            with open(self.config_file, "w", encoding="utf-8") as f:
                json.dump(self.data, f, indent=4)
            return True
        except Exception as e:
            print(f"[exe/tow settings] Error saving {self.config_file}: {e}")
            return False

    def get(self, key: str, default=None):
        return self.data.get(key, default)

    def set(self, key: str, value):
        self.data[key] = value
        self.save()

    def add_recent_project(self, project_path: str):
        """Adds a project folder to recent projects list."""
        if not project_path:
            return
        abs_path = os.path.abspath(project_path)
        recents = self.data.get("recent_projects", [])
        if abs_path in recents:
            recents.remove(abs_path)
        recents.insert(0, abs_path)
        self.data["recent_projects"] = recents[:10]  # Keep last 10
        self.save()
