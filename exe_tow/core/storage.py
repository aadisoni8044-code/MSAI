import json
import os
import sys
from datetime import datetime
from typing import Dict, List, Any, Optional

class StorageManager:
    """Manages application settings, projects list, and build history."""

    def __init__(self, storage_dir: Optional[str] = None):
        if storage_dir is None:
            # Fallback to local data dir or user home
            home_dir = os.path.expanduser("~")
            app_dir = os.path.join(home_dir, ".exe_tow")
            try:
                os.makedirs(app_dir, exist_ok=True)
                self.storage_path = os.path.join(app_dir, "data.json")
            except Exception:
                os.makedirs("data", exist_ok=True)
                self.storage_path = os.path.join("data", "data.json")
        else:
            os.makedirs(storage_dir, exist_ok=True)
            self.storage_path = os.path.join(storage_dir, "data.json")

        self.settings: Dict[str, Any] = self._default_settings()
        self.projects: List[Dict[str, Any]] = []
        self.history: List[Dict[str, Any]] = []
        self.load()

    def _default_settings(self) -> Dict[str, Any]:
        return {
            "python_interpreter": sys.executable,
            "python_auto_detect": True,
            "build_engine": "PyInstaller (Automatic)",
            "default_output_dir": os.path.abspath("dist"),
            "one_file": True,
            "auto_dependencies": True,
            "include_assets": True,
            "windowed_mode": True,  # True for Windowed, False for Console
            "theme": "Dark Hacker",
            "terminal_font": "JetBrains Mono / Consolas",
            "animations_enabled": True
        }

    def load(self) -> None:
        """Loads settings, projects, and history from json file."""
        if os.path.exists(self.storage_path):
            try:
                with open(self.storage_path, "r", encoding="utf-8") as f:
                    data = json.load(f)
                    defaults = self._default_settings()
                    defaults.update(data.get("settings", {}))
                    self.settings = defaults
                    self.projects = data.get("projects", [])
                    self.history = data.get("history", [])
                return
            except Exception as e:
                print(f"[StorageManager] Error loading data: {e}")

        # Load sample/default projects and history if first launch
        self._seed_initial_data()
        self.save()

    def _seed_initial_data(self) -> None:
        """Seeds initial default projects and build history for first run."""
        now = datetime.now().strftime("%Y-%m-%d %H:%M")
        self.projects = [
            {
                "name": "MyPythonApp",
                "path": os.path.abspath("sample_project"),
                "entry_file": "main.py",
                "last_build": "2 MIN AGO",
                "status": "BUILT",
                "files_count": 27,
                "dep_count": 8,
                "asset_count": 14
            },
            {
                "name": "MY GAME",
                "path": os.path.abspath("my_game"),
                "entry_file": "main.py",
                "last_build": "1 DAY AGO",
                "status": "BUILT",
                "files_count": 42,
                "dep_count": 12,
                "asset_count": 35
            }
        ]
        self.history = [
            {
                "date": now,
                "project": "MyPythonApp",
                "entry_file": "main.py",
                "result": "SUCCESS",
                "time": "18.4s",
                "size": "42.8 MB",
                "output_path": os.path.abspath("dist/MyPythonApp.exe"),
                "logs": [
                    "> exe/tow build started",
                    "> scanning project...",
                    "> entry file: main.py",
                    "> collecting dependencies...",
                    "> packaging application...",
                    "> creating executable...",
                    "> finalizing...",
                    "> build successful: MyPythonApp.exe (42.8 MB)"
                ]
            },
            {
                "date": "2026-09-28 10:15",
                "project": "MY GAME",
                "entry_file": "main.py",
                "result": "SUCCESS",
                "time": "24.1s",
                "size": "68.2 MB",
                "output_path": os.path.abspath("dist/MyGame.exe"),
                "logs": [
                    "> exe/tow build started",
                    "> scanning project...",
                    "> packaging assets...",
                    "> build successful: MyGame.exe"
                ]
            },
            {
                "date": "2026-09-27 16:40",
                "project": "CLI Utility",
                "entry_file": "cli.py",
                "result": "FAILED",
                "time": "5.2s",
                "size": "0 MB",
                "output_path": "",
                "logs": [
                    "> exe/tow build started",
                    "> scanning project...",
                    "> ERROR: Missing dependency 'requests'",
                    "> build failed: unresolved import"
                ]
            }
        ]

    def save(self) -> None:
        """Saves current state to JSON file."""
        try:
            data = {
                "settings": self.settings,
                "projects": self.projects,
                "history": self.history
            }
            with open(self.storage_path, "w", encoding="utf-8") as f:
                json.dump(data, f, indent=2)
        except Exception as e:
            print(f"[StorageManager] Error saving data: {e}")

    def update_settings(self, new_settings: Dict[str, Any]) -> None:
        """Updates and saves settings."""
        self.settings.update(new_settings)
        self.save()

    def add_project(self, project_data: Dict[str, Any]) -> None:
        """Adds or updates a project in history/projects list."""
        path = project_data.get("path", "")
        # Remove existing if path matches
        self.projects = [p for p in self.projects if p.get("path") != path]
        self.projects.insert(0, project_data)
        self.save()

    def add_history_record(self, record: Dict[str, Any]) -> None:
        """Adds a build history record to top of list."""
        self.history.insert(0, record)
        self.save()

    def get_stats(self) -> Dict[str, Any]:
        """Calculates dashboard stats."""
        total_projects = len(self.projects)
        successful_builds = sum(1 for h in self.history if h.get("result") == "SUCCESS")
        failed_builds = sum(1 for h in self.history if h.get("result") == "FAILED")

        last_build_str = "NEVER"
        if self.history:
            last_build_str = self.history[0].get("date", "RECENTLY")

        return {
            "projects_count": total_projects,
            "success_count": successful_builds,
            "failed_count": failed_builds,
            "last_build": last_build_str
        }
