"""Environment Manager module for detecting and managing Python build environments."""

import os
import sys
import subprocess
from typing import Optional, List
from app.logger import logger


class EnvironmentManager:
    """Detects virtual environments and resolves executable python interpreters."""

    def __init__(self, project_path: str, custom_python: Optional[str] = None):
        self.project_path = os.path.abspath(project_path)
        self.custom_python = custom_python

    def get_python_interpreter(self) -> str:
        """Resolves the best Python executable for running builds."""
        if self.custom_python and os.path.exists(self.custom_python):
            return self.custom_python

        # Check for virtualenv in project path
        venv_python = self._find_venv_python()
        if venv_python:
            logger.info(f"Using virtual environment Python: {venv_python}")
            return venv_python

        # Fallback to current running Python interpreter
        logger.info(f"Using current system Python: {sys.executable}")
        return sys.executable

    def _find_venv_python(self) -> Optional[str]:
        venv_dirs = ["venv", ".venv", "env", ".env", "virtualenv"]
        for venv_dir in venv_dirs:
            candidate_dir = os.path.join(self.project_path, venv_dir)
            if os.path.isdir(candidate_dir):
                # Check Windows path
                win_exe = os.path.join(candidate_dir, "Scripts", "python.exe")
                if os.path.isfile(win_exe):
                    return win_exe

                # Check POSIX path
                posix_exe = os.path.join(candidate_dir, "bin", "python")
                if os.path.isfile(posix_exe):
                    return posix_exe

        return None
