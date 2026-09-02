"""
MSAI Studio - Project Manager
"""
import os
from typing import List, Optional

class ProjectManager:
    """Manages active project folder and workspace file tree metadata."""

    def __init__(self):
        self.current_project_path: Optional[str] = None

    def open_project(self, project_path: str) -> bool:
        """Sets active project path if valid."""
        if os.path.isdir(project_path):
            self.current_project_path = os.path.abspath(project_path)
            return True
        return False

    def close_project(self):
        """Closes active project."""
        self.current_project_path = None

    def get_project_name(self) -> str:
        """Returns root directory name of current project."""
        if self.current_project_path:
            return os.path.basename(self.current_project_path)
        return "No Folder Opened"

    def get_all_python_files(self) -> List[str]:
        """Returns relative paths of all .py files in current project."""
        py_files = []
        if not self.current_project_path:
            return py_files

        for root, dirs, files in os.walk(self.current_project_path):
            # Ignore hidden directories like .git, __pycache__, .venv
            dirs[:] = [d for d in dirs if not d.startswith(".") and d != "__pycache__" and d != "venv"]
            for file in files:
                if file.endswith(".py"):
                    full_path = os.path.join(root, file)
                    rel_path = os.path.relpath(full_path, self.current_project_path)
                    py_files.append(rel_path)
        return py_files
