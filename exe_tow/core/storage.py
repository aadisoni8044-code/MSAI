import json
import os
from pathlib import Path
from typing import List, Dict, Any

DEFAULT_STORAGE_DIR = Path.home() / ".exe_tow"
STORAGE_FILE = DEFAULT_STORAGE_DIR / "app_data.json"

DEFAULT_DATA = {
    "settings": {
        "python_interpreter": "python",
        "default_output_folder": str(Path.home() / "exe_tow_builds"),
        "theme": "Dark",
        "one_file": True,
        "windowed": True,
        "include_assets": True,
        "auto_dependencies": True,
        "log_level": "DEBUG",
        "clean_build": True
    },
    "projects": [],
    "history": []
}

class StorageManager:
    def __init__(self, file_path: Path = STORAGE_FILE):
        self.file_path = file_path
        self.data = self.load_data()

    def load_data(self) -> Dict[str, Any]:
        if not self.file_path.exists():
            return self._save_defaults()
        try:
            with open(self.file_path, "r", encoding="utf-8") as f:
                loaded = json.load(f)
                # Ensure structure matches defaults
                for key in DEFAULT_DATA:
                    if key not in loaded:
                        loaded[key] = DEFAULT_DATA[key]
                return loaded
        except Exception:
            return self._save_defaults()

    def _save_defaults(self) -> Dict[str, Any]:
        self.file_path.parent.mkdir(parents=True, exist_ok=True)
        with open(self.file_path, "w", encoding="utf-8") as f:
            json.dump(DEFAULT_DATA, f, indent=2)
        return json.loads(json.dumps(DEFAULT_DATA))

    def save(self):
        try:
            self.file_path.parent.mkdir(parents=True, exist_ok=True)
            with open(self.file_path, "w", encoding="utf-8") as f:
                json.dump(self.data, f, indent=2)
        except Exception as e:
            print(f"Error saving app data: {e}")

    def get_settings(self) -> Dict[str, Any]:
        return self.data.get("settings", DEFAULT_DATA["settings"])

    def update_settings(self, new_settings: Dict[str, Any]):
        self.data["settings"].update(new_settings)
        self.save()

    def get_projects(self) -> List[Dict[str, Any]]:
        return self.data.get("projects", [])

    def add_or_update_project(self, project_info: Dict[str, Any]):
        folder = project_info.get("folder_path")
        if not folder:
            return
        projects = self.data.get("projects", [])
        existing_idx = -1
        for idx, p in enumerate(projects):
            if p.get("folder_path") == folder:
                existing_idx = idx
                break

        if existing_idx >= 0:
            projects[existing_idx].update(project_info)
        else:
            projects.insert(0, project_info)

        self.data["projects"] = projects
        self.save()

    def get_history(self) -> List[Dict[str, Any]]:
        return self.data.get("history", [])

    def add_history_entry(self, entry: Dict[str, Any]):
        history = self.data.get("history", [])
        history.insert(0, entry)
        self.data["history"] = history[:50] # Keep last 50 entries
        self.save()

    def get_stats(self) -> Dict[str, Any]:
        history = self.get_history()
        total_built = len(history)
        successful_builds = len([h for h in history if h.get("status") == "Success"])
        recent = history[0] if history else None

        recent_name = recent.get("project_name", "None") if recent else "None"
        recent_status = recent.get("status", "Ready") if recent else "Ready"

        return {
            "projects_built": total_built,
            "successful_builds": successful_builds,
            "recent_build": recent_name,
            "build_status": recent_status
        }
