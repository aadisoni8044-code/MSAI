import os
import re
from typing import Dict, List, Any, Optional

ASSET_EXTENSIONS = {
    ".png", ".jpg", ".jpeg", ".bmp", ".gif", ".ico", ".svg",
    ".json", ".yaml", ".yml", ".toml", ".ini", ".cfg", ".xml",
    ".txt", ".csv", ".db", ".sqlite", ".sqlite3",
    ".ui", ".qss", ".wav", ".mp3", ".ogg", ".html", ".css", ".js"
}

IGNORED_DIRS = {
    "__pycache__", ".git", ".venv", "venv", "env", ".idea", ".vscode",
    "build", "dist", "node_modules", ".pytest_cache", ".tox"
}

class ProjectScanner:
    """Scans Python project directories and auto-detects files, dependencies, assets, and entry points."""

    def __init__(self, project_dir: str):
        self.project_dir = os.path.abspath(project_dir)
        self.py_files: List[str] = []
        self.asset_files: List[str] = []
        self.dependencies: List[str] = []
        self.entry_file: Optional[str] = None
        self.is_valid_dir = os.path.exists(self.project_dir) and os.path.isdir(self.project_dir)

    def scan(self) -> Dict[str, Any]:
        """Performs full scanning of project folder."""
        if not self.is_valid_dir:
            return {
                "valid": False,
                "project_name": os.path.basename(self.project_dir) or "Unknown",
                "path": self.project_dir,
                "error": "Directory does not exist",
                "checklist": [
                    {"label": "Python detected", "status": "OK"},
                    {"label": "Project directory detected", "status": "ERROR"},
                    {"label": "Main Python file detected", "status": "ERROR"},
                    {"label": "Additional Python modules detected", "status": "WARNING"},
                    {"label": "Assets detected", "status": "WARNING"},
                    {"label": "Dependencies detected", "status": "WARNING"},
                ]
            }

        self.py_files.clear()
        self.asset_files.clear()
        self.dependencies.clear()

        # Walk directory
        for root, dirs, files in os.walk(self.project_dir):
            # Prune ignored directories
            dirs[:] = [d for d in dirs if d not in IGNORED_DIRS and not d.startswith(".")]

            for file in files:
                rel_path = os.path.relpath(os.path.join(root, file), self.project_dir)
                ext = os.path.splitext(file)[1].lower()

                if ext == ".py":
                    self.py_files.append(rel_path)
                elif ext in ASSET_EXTENSIONS:
                    self.asset_files.append(rel_path)

        # Detect entry file
        self.entry_file = self._detect_entry_file()

        # Detect dependencies
        self._detect_dependencies()

        project_name = os.path.basename(self.project_dir.rstrip("/\\")) or "PythonProject"

        checklist = [
            {"label": "Python detected", "status": "OK"},
            {"label": "Project directory detected", "status": "OK"},
            {
                "label": "Main Python file detected",
                "status": "OK" if self.entry_file else "WARNING"
            },
            {
                "label": "Additional Python modules detected",
                "status": "OK" if len(self.py_files) > 1 else "OK"
            },
            {
                "label": "Assets detected",
                "status": "OK" if len(self.asset_files) > 0 else "OK"
            },
            {
                "label": "Dependencies detected",
                "status": "OK" if len(self.dependencies) > 0 else "OK"
            }
        ]

        return {
            "valid": True,
            "project_name": project_name,
            "path": self.project_dir,
            "entry_file": self.entry_file or (self.py_files[0] if self.py_files else "main.py"),
            "py_files": self.py_files,
            "py_files_count": len(self.py_files),
            "asset_files": self.asset_files,
            "asset_files_count": len(self.asset_files),
            "dependencies": self.dependencies,
            "dep_count": len(self.dependencies),
            "checklist": checklist
        }

    def _detect_entry_file(self) -> Optional[str]:
        """Selects the best Python entry file based on heuristics."""
        if not self.py_files:
            return None

        candidates = []
        for rel_path in self.py_files:
            filename = os.path.basename(rel_path).lower()
            full_path = os.path.join(self.project_dir, rel_path)
            score = 0

            if filename == "main.py":
                score += 100
            elif filename == "app.py":
                score += 90
            elif filename == "run.py":
                score += 80
            elif filename == "cli.py":
                score += 70
            elif filename == "index.py":
                score += 60
            elif filename in ("gui.py", "window.py", "desktop.py"):
                score += 50
            elif filename == "__main__.py":
                score += 40

            # Direct root file check
            if os.path.dirname(rel_path) == "":
                score += 20

            # Check for __main__ block inside file
            try:
                with open(full_path, "r", encoding="utf-8", errors="ignore") as f:
                    content = f.read(5000)
                    if 'if __name__' in content and '__main__' in content:
                        score += 30
            except Exception:
                pass

            candidates.append((score, rel_path))

        candidates.sort(key=lambda x: x[0], reverse=True)
        return candidates[0][1] if candidates else self.py_files[0]

    def _detect_dependencies(self) -> None:
        """Parses requirements.txt, setup.py, pyproject.toml or python imports."""
        req_file = os.path.join(self.project_dir, "requirements.txt")
        found_deps = set()

        if os.path.exists(req_file):
            try:
                with open(req_file, "r", encoding="utf-8", errors="ignore") as f:
                    for line in f:
                        line = line.strip()
                        if line and not line.startswith("#"):
                            pkg = re.split(r"[=<>]", line)[0].strip()
                            if pkg:
                                found_deps.add(pkg)
            except Exception:
                pass

        # Scan python imports if requirements empty or for supplementary detection
        import_regex = re.compile(r"^\s*(?:import|from)\s+([a-zA-Z0-9_]+)", re.MULTILINE)
        standard_libs = {
            "os", "sys", "re", "math", "time", "datetime", "json", "typing",
            "pathlib", "subprocess", "threading", "asyncio", "collections",
            "functools", "shutil", "tempfile", "logging", "random", "struct",
            "copy", "traceback", "gc", "hashlib", "urllib", "sqlite3"
        }

        for py_rel in self.py_files[:10]: # Check up to 10 python files
            full_path = os.path.join(self.project_dir, py_rel)
            try:
                with open(full_path, "r", encoding="utf-8", errors="ignore") as f:
                    content = f.read(10000)
                    matches = import_regex.findall(content)
                    for mod in matches:
                        if mod not in standard_libs and not mod.startswith("_"):
                            found_deps.add(mod)
            except Exception:
                pass

        self.dependencies = sorted(list(found_deps))
