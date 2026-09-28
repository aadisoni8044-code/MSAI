import sys
import os
import platform
import subprocess
from pathlib import Path
from typing import Optional
from exe_tow.core.models import EnvironmentInfo

class EnvironmentDetector:
    def __init__(self, custom_python_path: Optional[str] = None):
        self.custom_python_path = custom_python_path

    def detect(self) -> EnvironmentInfo:
        python_exe = self._get_python_executable()
        python_ver = self._get_python_version(python_exe)
        arch = f"{platform.architecture()[0]} ({platform.machine()})"

        pip_exe = self._get_pip_executable(python_exe)
        pip_installed = pip_exe is not None or self._check_module_available(python_exe, "pip")

        pyinstaller_installed, pyinstaller_ver = self._check_pyinstaller(python_exe)
        virtual_env = os.environ.get("VIRTUAL_ENV")

        return EnvironmentInfo(
            python_executable=python_exe,
            python_version=python_ver,
            architecture=arch,
            pip_executable=pip_exe,
            pip_installed=pip_installed,
            pyinstaller_installed=pyinstaller_installed,
            pyinstaller_version=pyinstaller_ver,
            virtual_env=virtual_env
        )

    def _get_python_executable(self) -> str:
        if self.custom_python_path and os.path.exists(self.custom_python_path):
            return self.custom_python_path
        return sys.executable

    def _get_python_version(self, python_exe: str) -> str:
        try:
            res = subprocess.run(
                [python_exe, "-c", "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}')"],
                capture_output=True,
                text=True,
                timeout=5
            )
            if res.returncode == 0:
                return res.stdout.strip()
        except Exception:
            pass
        return f"{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}"

    def _get_pip_executable(self, python_exe: str) -> Optional[str]:
        # Check adjacent pip
        py_path = Path(python_exe)
        parent_dir = py_path.parent
        possible_pips = [
            parent_dir / "pip",
            parent_dir / "pip.exe",
            parent_dir / "Scripts" / "pip.exe",
            parent_dir / "Scripts" / "pip",
        ]
        for p in possible_pips:
            if p.exists() and os.access(str(p), os.X_OK):
                return str(p)

        # Check system pip via subprocess
        try:
            res = subprocess.run(["pip", "--version"], capture_output=True, text=True, timeout=5)
            if res.returncode == 0:
                return "pip"
        except Exception:
            pass

        return None

    def _check_module_available(self, python_exe: str, module_name: str) -> bool:
        try:
            res = subprocess.run(
                [python_exe, "-m", module_name, "--version"],
                capture_output=True,
                text=True,
                timeout=5
            )
            return res.returncode == 0
        except Exception:
            return False

    def _check_pyinstaller(self, python_exe: str) -> (bool, Optional[str]):
        # Try python -m PyInstaller --version
        try:
            res = subprocess.run(
                [python_exe, "-m", "PyInstaller", "--version"],
                capture_output=True,
                text=True,
                timeout=5
            )
            if res.returncode == 0:
                return True, res.stdout.strip()
        except Exception:
            pass

        # Try pyinstaller command
        try:
            res = subprocess.run(
                ["pyinstaller", "--version"],
                capture_output=True,
                text=True,
                timeout=5
            )
            if res.returncode == 0:
                return True, res.stdout.strip()
        except Exception:
            pass

        return False, None
