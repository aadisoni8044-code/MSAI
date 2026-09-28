import os
import json
from dataclasses import dataclass, asdict
from pathlib import Path
from typing import Dict, Any

@dataclass
class Settings:
    python_path: str = ""
    default_output_folder: str = ""
    default_build_mode: str = "ONE FILE"  # "ONE FILE" or "ONE DIRECTORY"
    build_engine_preference: str = "PyInstaller"
    max_retries: int = 5
    command_timeout: int = 600  # seconds
    logging_location: str = ""
    auto_install_dependencies: bool = True
    auto_fallback: bool = True
    open_output_after_build: bool = True

    @classmethod
    def get_default_storage_path(cls) -> Path:
        base_dir = Path.home() / "EXE-TOW"
        base_dir.mkdir(parents=True, exist_ok=True)
        return base_dir / "config.json"

    def save(self, path: Path = None) -> None:
        if path is None:
            path = self.get_default_storage_path()
        path.parent.mkdir(parents=True, exist_ok=True)
        with open(path, "w", encoding="utf-8") as f:
            json.dump(asdict(self), f, indent=2)

    @classmethod
    def load(cls, path: Path = None) -> "Settings":
        if path is None:
            path = cls.get_default_storage_path()
        if not path.exists():
            s = cls()
            s.save(path)
            return s
        try:
            with open(path, "r", encoding="utf-8") as f:
                data = json.load(f)
            return cls(**data)
        except Exception:
            return cls()
