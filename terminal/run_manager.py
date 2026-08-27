"""
Code execution manager for language detection and running active files.
"""

import sys
from pathlib import Path
from typing import Optional

from utils.file_utils import get_language_from_filename
from utils.logger import logger


class RunManager:
    """Detects appropriate interpreter/runner for file and executes via terminal."""

    def __init__(self, terminal_widget=None):
        self.terminal_widget = terminal_widget

    def set_terminal_widget(self, terminal_widget) -> None:
        """Binds active terminal widget."""
        self.terminal_widget = terminal_widget

    def run_file(self, file_path: Path) -> bool:
        """Runs specified code file by launching command in embedded terminal."""
        if not file_path or not file_path.exists():
            logger.error("Cannot run non-existent file.")
            return False

        if not self.terminal_widget:
            logger.error("Terminal widget not configured.")
            return False

        language = get_language_from_filename(file_path.name)
        abs_path_str = f'"{file_path.resolve()}"'

        command = self._build_run_command(language, abs_path_str)
        if command:
            logger.info(f"Executing command: {command}")
            self.terminal_widget.write_command(f"echo Running {file_path.name}...\n")
            self.terminal_widget.write_command(f"{command}\n")
            return True

        logger.warning(f"No execution command configured for language: {language}")
        return False

    def _build_run_command(self, language: str, path_str: str) -> Optional[str]:
        """Builds OS execution command based on file language."""
        python_executable = sys.executable or "python3"

        if language == "python":
            return f'"{python_executable}" {path_str}'
        elif language in ("javascript", "js"):
            return f"node {path_str}"
        elif language == "bash":
            return f"bash {path_str}"
        elif language == "cpp":
            executable_name = path_str.replace('"', '').rsplit('.', 1)[0]
            if sys.platform == "win32":
                return f'g++ {path_str} -o "{executable_name}.exe" && "{executable_name}.exe"'
            else:
                return f'g++ {path_str} -o "{executable_name}" && "{executable_name}"'
        elif language == "java":
            return f"java {path_str}"

        return None
