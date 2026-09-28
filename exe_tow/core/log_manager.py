import logging
import datetime
from pathlib import Path
from typing import Optional

class LogManager:
    def __init__(self, log_dir: Optional[Path] = None):
        if log_dir is None:
            log_dir = Path.home() / "EXE-TOW" / "logs"
        self.log_dir = log_dir
        self.log_dir.mkdir(parents=True, exist_ok=True)

        self.session_file = self.log_dir / f"exe_tow_{datetime.datetime.now().strftime('%Y%m%d_%H%M%S')}.log"

    def log(self, message: str, level: str = "INFO"):
        timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        formatted = f"[{timestamp}] [{level}] {message}"
        try:
            with open(self.session_file, "a", encoding="utf-8") as f:
                f.write(formatted + "\n")
        except Exception:
            pass
        return formatted

    def get_latest_logs(self) -> str:
        if not self.session_file.exists():
            return ""
        try:
            with open(self.session_file, "r", encoding="utf-8") as f:
                return f.read()
        except Exception:
            return ""
