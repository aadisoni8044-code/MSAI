import json
from pathlib import Path
from typing import List, Dict, Any, Optional
from exe_tow.core.models import CommandExecution, BuildRecord

class HistoryManager:
    def __init__(self, base_dir: Optional[Path] = None):
        if base_dir is None:
            base_dir = Path.home() / "EXE-TOW"
        self.base_dir = base_dir
        self.cmd_file = self.base_dir / "data" / "command_history.json"
        self.build_file = self.base_dir / "data" / "build_history.json"

        self.cmd_file.parent.mkdir(parents=True, exist_ok=True)

    def save_command_execution(self, execution: CommandExecution):
        history = self.get_command_history()
        history.append(execution.to_dict())
        try:
            with open(self.cmd_file, "w", encoding="utf-8") as f:
                json.dump(history, f, indent=2)
        except Exception:
            pass

    def get_command_history(self) -> List[Dict[str, Any]]:
        if not self.cmd_file.exists():
            return []
        try:
            with open(self.cmd_file, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception:
            return []

    def save_build_record(self, record: BuildRecord):
        history = self.get_build_history()
        history.append(record.to_dict())
        try:
            with open(self.build_file, "w", encoding="utf-8") as f:
                json.dump(history, f, indent=2)
        except Exception:
            pass

    def get_build_history(self) -> List[Dict[str, Any]]:
        if not self.build_file.exists():
            return []
        try:
            with open(self.build_file, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception:
            return []
