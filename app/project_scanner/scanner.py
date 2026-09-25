"""Project Scanner module for analyzing Python projects."""

import os
import ast
from pathlib import Path
from typing import List, Set, Optional
from models.project_info import ProjectInfo
from app.logger import logger


class ProjectScanner:
    """Scans a Python project directory to analyze structure, dependencies, entry points, and assets."""

    ENTRY_POINT_NAMES = [
        "main.py", "app.py", "run.py", "start.py", "cli.py", "__main__.py", "index.py"
    ]

    CONFIG_FILE_NAMES = [
        "requirements.txt", "pyproject.toml", "setup.py", "setup.cfg",
        "Pipfile", "Pipfile.lock", "poetry.lock", "environment.yml", "environment.yaml"
    ]

    ASSET_EXTENSIONS = {
        ".png", ".jpg", ".jpeg", ".gif", ".bmp", ".ico", ".svg",
        ".wav", ".mp3", ".ogg", ".flac",
        ".json", ".txt", ".csv", ".xml", ".yaml", ".yml",
        ".ttf", ".otf",
        ".ui", ".qml", ".db", ".sqlite", ".sqlite3"
    }

    VENV_DIR_NAMES = {"venv", ".venv", "env", ".env", "virtualenv"}

    def __init__(self, project_path: str):
        self.project_path = os.path.abspath(project_path)

    def scan(self) -> ProjectInfo:
        """Executes full scan of the project folder."""
        logger.info(f"Scanning project at: {self.project_path}")
        if not os.path.isdir(self.project_path):
            raise ValueError(f"Project directory does not exist: {self.project_path}")

        project_name = os.path.basename(self.project_path) or "PythonProject"

        python_files = self._find_python_files()
        config_files = self._find_config_files()
        venv_path = self._find_venv()
        entry_candidates = self._detect_entry_points(python_files)
        assets = self._detect_assets()

        selected_entry = entry_candidates[0] if entry_candidates else (python_files[0] if python_files else None)
        imported_modules = self._scan_imports(selected_entry) if selected_entry else []

        project_info = ProjectInfo(
            project_path=self.project_path,
            project_name=project_name,
            python_files=python_files,
            config_files=config_files,
            venv_path=venv_path,
            entry_point_candidates=entry_candidates,
            selected_entry_point=selected_entry,
            imported_modules=imported_modules,
            detected_assets=assets,
            selected_assets=assets.copy(),  # Default all assets selected
            app_name=project_name
        )

        logger.info(f"Scan complete for '{project_name}': {len(python_files)} python files, "
                    f"{len(entry_candidates)} entry point candidates, {len(assets)} asset files detected.")
        return project_info

    def _find_python_files(self) -> List[str]:
        python_files = []
        for root, dirs, files in os.walk(self.project_path):
            # Skip venvs, git, build dirs
            dirs[:] = [d for d in dirs if d not in self.VENV_DIR_NAMES and not d.startswith(".") and d not in ("dist", "build", "__pycache__", "kora_build")]
            for file in files:
                if file.endswith(".py"):
                    rel_path = os.path.relpath(os.path.join(root, file), self.project_path)
                    python_files.append(rel_path)
        return python_files

    def _find_config_files(self) -> List[str]:
        config_files = []
        for file_name in os.listdir(self.project_path):
            if file_name in self.CONFIG_FILE_NAMES:
                config_files.append(file_name)
        return config_files

    def _find_venv(self) -> Optional[str]:
        for name in self.VENV_DIR_NAMES:
            candidate = os.path.join(self.project_path, name)
            if os.path.isdir(candidate):
                return candidate
        return None

    def _detect_entry_points(self, python_files: List[str]) -> List[str]:
        candidates = []
        # Priority match by common main file names
        for file in python_files:
            file_name = os.path.basename(file)
            if file_name in self.ENTRY_POINT_NAMES:
                candidates.append(file)

        # Check for if __name__ == '__main__': in root files
        for file in python_files:
            if file not in candidates and os.path.dirname(file) == "":
                full_path = os.path.join(self.project_path, file)
                try:
                    with open(full_path, "r", encoding="utf-8", errors="ignore") as f:
                        content = f.read()
                        if "__main__" in content:
                            candidates.append(file)
                except Exception:
                    pass

        # If still no candidates, put top-level python files
        if not candidates:
            for file in python_files:
                if os.path.dirname(file) == "":
                    candidates.append(file)

        return candidates

    def _scan_imports(self, entry_file: str) -> List[str]:
        full_path = os.path.join(self.project_path, entry_file)
        if not os.path.isfile(full_path):
            return []

        imports: Set[str] = set()
        try:
            with open(full_path, "r", encoding="utf-8", errors="ignore") as f:
                tree = ast.parse(f.read(), filename=full_path)

            for node in ast.walk(tree):
                if isinstance(node, ast.Import):
                    for alias in node.names:
                        imports.add(alias.name.split('.')[0])
                elif isinstance(node, ast.ImportFrom):
                    if node.module:
                        imports.add(node.module.split('.')[0])
        except Exception as e:
            logger.warning(f"Could not parse imports from {entry_file}: {e}")

        return sorted(list(imports))

    def _detect_assets(self) -> List[str]:
        assets = []
        for root, dirs, files in os.walk(self.project_path):
            dirs[:] = [d for d in dirs if d not in self.VENV_DIR_NAMES and not d.startswith(".") and d not in ("dist", "build", "__pycache__", "kora_build")]
            for file in files:
                ext = os.path.splitext(file)[1].lower()
                if ext in self.ASSET_EXTENSIONS:
                    rel_path = os.path.relpath(os.path.join(root, file), self.project_path)
                    assets.append(rel_path)
        return assets
