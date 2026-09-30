import os
import sys
from typing import Dict, Any, List

IGNORED_DIRS = {
    ".git", "__pycache__", ".venv", "venv", "env", ".env",
    "build", "dist", ".idea", ".vscode", "node_modules", ".pytest_cache"
}

ASSET_EXTENSIONS = {
    ".png", ".jpg", ".jpeg", ".gif", ".bmp", ".ico", ".svg", ".webp",
    ".json", ".yaml", ".yml", ".toml", ".csv", ".txt", ".xml",
    ".db", ".sqlite", ".sqlite3", ".html", ".css", ".js",
    ".mp3", ".wav", ".ogg", ".mp4", ".avi", ".ttf", ".otf", ".woff", ".woff2",
    ".qss", ".ui"
}

CONFIG_FILENAMES = {
    "requirements.txt", "pyproject.toml", "setup.py", "setup.cfg", "Pipfile", "environment.yml"
}


class ProjectScanner:
    """Scans a Python project folder for files, assets, configs, and Python version."""

    def __init__(self, project_path: str):
        self.project_path = os.path.abspath(project_path)

    def scan(self) -> Dict[str, Any]:
        if not os.path.exists(self.project_path) or not os.path.isdir(self.project_path):
            raise ValueError(f"Invalid directory path: {self.project_path}")

        python_files: List[str] = []
        asset_files: List[str] = []
        config_files: List[str] = []
        total_files = 0

        for root, dirs, files in os.walk(self.project_path):
            # Exclude ignored directories in-place
            dirs[:] = [d for d in dirs if d not in IGNORED_DIRS and not d.startswith(".")]

            for file in files:
                total_files += 1
                full_path = os.path.join(root, file)
                rel_path = os.path.relpath(full_path, self.project_path)
                ext = os.path.splitext(file)[1].lower()

                if file in CONFIG_FILENAMES:
                    config_files.append(rel_path)

                if ext == ".py":
                    python_files.append(rel_path)
                elif ext in ASSET_EXTENSIONS and file not in CONFIG_FILENAMES:
                    asset_files.append(rel_path)

        python_version = f"{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}"

        return {
            "project_path": self.project_path,
            "project_name": os.path.basename(self.project_path) or "PythonProject",
            "python_version": python_version,
            "python_files": sorted(python_files),
            "python_files_count": len(python_files),
            "asset_files": sorted(asset_files),
            "asset_files_count": len(asset_files),
            "config_files": sorted(config_files),
            "config_files_count": len(config_files),
            "total_files_count": total_files,
        }
