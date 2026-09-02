"""
MSAI Studio - Interpreter Manager
"""
import os
import sys
import subprocess
from typing import List, Dict, Optional

class InterpreterManager:
    """Detects and validates Python interpreters installed on system."""

    @staticmethod
    def get_system_interpreters() -> List[Dict[str, str]]:
        """Scans common Python interpreter locations and returns details."""
        candidates = [sys.executable]

        # Common executable names
        names = ["python3", "python", "python3.12", "python3.11", "python3.10", "python3.9"]
        for name in names:
            try:
                res = shutil_which(name)
                if res and res not in candidates:
                    candidates.append(res)
            except Exception:
                pass

        # Check virtual environments if present
        for venv_path in ["venv/bin/python", ".venv/bin/python", "env/bin/python", "venv/Scripts/python.exe"]:
            full_venv = os.path.abspath(venv_path)
            if os.path.exists(full_venv) and full_venv not in candidates:
                candidates.append(full_venv)

        interpreters = []
        for path in candidates:
            info = InterpreterManager.get_interpreter_info(path)
            if info:
                interpreters.append(info)

        return interpreters

    @staticmethod
    def get_interpreter_info(path: str) -> Optional[Dict[str, str]]:
        """Queries Python binary for version string."""
        if not path or not os.path.isfile(path) or not os.access(path, os.X_OK):
            return None

        try:
            output = subprocess.check_output(
                [path, "-c", "import sys; print(f'Python {sys.version.split()[0]}')"],
                stderr=subprocess.STDOUT,
                timeout=2,
                text=True
            ).strip()
            return {
                "path": path,
                "version": output,
                "label": f"{output} ({path})"
            }
        except Exception:
            return None

def shutil_which(cmd: str) -> Optional[str]:
    import shutil
    return shutil.which(cmd)
