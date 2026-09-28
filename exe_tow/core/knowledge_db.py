import json
from pathlib import Path
from typing import List, Dict, Any, Optional

class KnowledgeDatabase:
    def __init__(self, db_path: Optional[Path] = None):
        if db_path is None:
            db_path = Path.home() / "EXE-TOW" / "command_knowledge.json"
        self.db_path = db_path
        self.db_path.parent.mkdir(parents=True, exist_ok=True)
        self.records: List[Dict[str, Any]] = self._load()

    def _load(self) -> List[Dict[str, Any]]:
        if not self.db_path.exists():
            return []
        try:
            with open(self.db_path, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception:
            return []

    def _save(self):
        try:
            with open(self.db_path, "w", encoding="utf-8") as f:
                json.dump(self.records, f, indent=2)
        except Exception:
            pass

    def record_attempt(
        self,
        command: str,
        environment_info: Dict[str, Any],
        project_type: str,
        status: str,
        error_category: Optional[str] = None
    ):
        entry = {
            "command": command,
            "environment": {
                "python_version": environment_info.get("python_version"),
                "architecture": environment_info.get("architecture")
            },
            "project_type": project_type,
            "status": status,
            "error_category": error_category
        }
        self.records.append(entry)
        self._save()

    def get_preferred_command(self, project_type: str) -> Optional[str]:
        # Return recent successful command for this project_type if exists
        for rec in reversed(self.records):
            if rec.get("project_type") == project_type and rec.get("status") == "SUCCESS":
                return rec.get("command")
        return None
