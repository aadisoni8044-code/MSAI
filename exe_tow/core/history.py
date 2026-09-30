import os
import json
import datetime
from typing import List, Dict, Any, Optional


class HistoryManager:
    """Manages persistence for project history and build runs in history.json."""

    def __init__(self, data_file: Optional[str] = None):
        if data_file is None:
            base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
            data_file = os.path.join(base_dir, "data", "history.json")
        self.data_file = data_file
        self._ensure_file_exists()

    def _ensure_file_exists(self) -> None:
        os.makedirs(os.path.dirname(self.data_file), exist_ok=True)
        if not os.path.exists(self.data_file):
            initial_data = {
                "projects": [],
                "builds": []
            }
            self._save_data(initial_data)

    def _load_data(self) -> Dict[str, Any]:
        try:
            with open(self.data_file, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception:
            return {"projects": [], "builds": []}

    def _save_data(self, data: Dict[str, Any]) -> None:
        try:
            with open(self.data_file, "w", encoding="utf-8") as f:
                json.dump(data, f, indent=2)
        except Exception:
            pass

    def get_statistics(self) -> Dict[str, int]:
        data = self._load_data()
        projects = data.get("projects", [])
        builds = data.get("builds", [])

        success_count = sum(1 for b in builds if b.get("status") == "SUCCESS")
        failed_count = sum(1 for b in builds if b.get("status") == "FAILED")

        return {
            "projects_count": len(projects),
            "builds_count": len(builds),
            "success_count": success_count,
            "failed_count": failed_count,
        }

    def get_projects(self) -> List[Dict[str, Any]]:
        return self._load_data().get("projects", [])

    def get_builds(self) -> List[Dict[str, Any]]:
        return self._load_data().get("builds", [])

    def add_or_update_project(self, project_path: str, name: str, main_file: str, last_status: str = "READY") -> Dict[str, Any]:
        data = self._load_data()
        projects = data.get("projects", [])

        now_str = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        updated = False

        for proj in projects:
            if os.path.abspath(proj.get("path", "")) == os.path.abspath(project_path):
                proj["name"] = name
                proj["main_file"] = main_file
                proj["last_build"] = now_str
                proj["last_status"] = last_status
                updated = True
                break

        if not updated:
            proj_entry = {
                "id": f"proj_{len(projects) + 1}_{int(datetime.datetime.now().timestamp())}",
                "name": name,
                "path": os.path.abspath(project_path),
                "main_file": main_file,
                "last_build": now_str,
                "last_status": last_status
            }
            projects.insert(0, proj_entry)

        data["projects"] = projects
        self._save_data(data)
        return projects[0]

    def record_build(self, project_name: str, project_path: str, exe_name: str, exe_path: str, status: str, size_mb: float, duration_sec: float, error_message: str = "") -> Dict[str, Any]:
        data = self._load_data()
        builds = data.get("builds", [])

        build_entry = {
            "id": f"build_{len(builds) + 1}_{int(datetime.datetime.now().timestamp())}",
            "project_name": project_name,
            "project_path": os.path.abspath(project_path),
            "exe_name": exe_name,
            "exe_path": os.path.abspath(exe_path) if exe_path else "",
            "date": datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            "status": status,  # "SUCCESS" or "FAILED"
            "size_mb": round(size_mb, 1),
            "duration_sec": round(duration_sec, 1),
            "error_message": error_message
        }

        builds.insert(0, build_entry)
        data["builds"] = builds
        self._save_data(data)

        # Also update last_status on the project entry
        self.add_or_update_project(project_path, project_name, "", last_status=status)

        return build_entry
