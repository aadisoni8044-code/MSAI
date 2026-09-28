"""
exe/tow - Project Detector
Scans Python project directories to automatically detect the main entry point file,
dependencies, virtual environments, and project assets.
"""

import os
import re
from typing import Dict, List, Optional, Tuple

COMMON_MAIN_FILES = [
    "main.py",
    "app.py",
    "run.py",
    "cli.py",
    "gui.py",
    "__main__.py",
    "index.py",
    "launcher.py",
    "start.py"
]

class ProjectDetector:
    """Scans and analyzes Python project directories for exe/tow."""

    @staticmethod
    def inspect_directory(folder_path: str) -> Dict:
        """
        Inspects a given project folder path and returns detected details:
        - main_file: path or relative name of main script
        - main_file_candidates: list of candidate python files
        - dependencies: list of requirements / packages
        - requirement_files: list of requirement files found
        - project_name: inferred name
        """
        if not folder_path or not os.path.exists(folder_path):
            return {
                "valid": False,
                "error": "Directory does not exist",
                "folder_path": folder_path,
                "project_name": os.path.basename(folder_path.rstrip("/\\")) if folder_path else "Unknown",
                "main_file": None,
                "main_file_candidates": [],
                "dependencies": [],
                "requirement_files": [],
                "has_venv": False,
            }

        folder_path = os.path.abspath(folder_path)
        project_name = os.path.basename(folder_path) or "Python Project"
        python_files = []
        req_files = []
        has_venv = False

        try:
            for root, dirs, files in os.walk(folder_path):
                # Skip common ignore directories
                dirs[:] = [d for d in dirs if d not in (".git", "__pycache__", "build", "dist", "node_modules", ".venv", "venv", "env")]
                if any(v in root.lower() for v in ("venv", ".venv", "env")):
                    has_venv = True

                for file in files:
                    rel_path = os.path.relpath(os.path.join(root, file), folder_path)
                    if file.endswith(".py"):
                        python_files.append(rel_path)
                    elif file in ("requirements.txt", "pyproject.toml", "Pipfile", "setup.py", "setup.cfg"):
                        req_files.append(rel_path)
        except Exception as e:
            return {
                "valid": False,
                "error": str(e),
                "folder_path": folder_path,
                "project_name": project_name,
                "main_file": None,
                "main_file_candidates": [],
                "dependencies": [],
                "requirement_files": [],
                "has_venv": False,
            }

        main_file = ProjectDetector.detect_main_file(folder_path, python_files)
        dependencies = ProjectDetector.parse_dependencies(folder_path, req_files)

        return {
            "valid": True,
            "error": None,
            "folder_path": folder_path,
            "project_name": project_name,
            "main_file": main_file,
            "main_file_candidates": python_files,
            "dependencies": dependencies,
            "requirement_files": req_files,
            "has_venv": has_venv,
        }

    @staticmethod
    def detect_main_file(folder_path: str, python_files: List[str]) -> Optional[str]:
        """Detects the most probable main entry point script."""
        if not python_files:
            return None

        # 1. Exact match on root level common main names
        for common in COMMON_MAIN_FILES:
            if common in python_files:
                return common

        # 2. Check for `if __name__ == "__main__":` in root py files
        root_py = [f for f in python_files if os.path.dirname(f) == ""]
        for py_file in root_py:
            full_path = os.path.join(folder_path, py_file)
            try:
                with open(full_path, "r", encoding="utf-8", errors="ignore") as f:
                    content = f.read()
                    if '__name__' in content and '__main__' in content:
                        return py_file
            except Exception:
                pass

        # 3. Fallback to first root level py file or first py file overall
        if root_py:
            return root_py[0]

        return python_files[0] if python_files else None

    @staticmethod
    def parse_dependencies(folder_path: str, req_files: List[str]) -> List[str]:
        """Parses dependency packages from requirements.txt or pyproject.toml."""
        deps = set()
        for req in req_files:
            full_path = os.path.join(folder_path, req)
            if req.endswith("requirements.txt"):
                try:
                    with open(full_path, "r", encoding="utf-8", errors="ignore") as f:
                        for line in f:
                            line = line.strip()
                            if line and not line.startswith("#"):
                                # Clean version pins like `PySide6>=6.0` -> `PySide6`
                                pkg = re.split(r"[=<>;!~]", line)[0].strip()
                                if pkg:
                                    deps.add(pkg)
                except Exception:
                    pass
            elif req.endswith("pyproject.toml"):
                try:
                    with open(full_path, "r", encoding="utf-8", errors="ignore") as f:
                        content = f.read()
                        matches = re.findall(r'["\']([a-zA-Z0-9_\-]+)(?:[=<>;!~].*)?["\']', content)
                        for m in matches:
                            if m not in ("dependencies", "build-system", "project"):
                                deps.add(m)
                except Exception:
                    pass
        return sorted(list(deps))
