"""
File and path operation utilities.
"""

import os
import platform
import subprocess
from pathlib import Path
from typing import Optional, Tuple

from PyQt6.QtCore import QUrl
from PyQt6.QtGui import QDesktopServices

from utils.logger import logger


def read_file_content(path: Path) -> Tuple[Optional[str], str]:
    """Reads content from a text file with encoding auto-detection fallback."""
    encodings = ["utf-8", "utf-8-sig", "latin1", "cp1252"]
    for enc in encodings:
        try:
            with open(path, "r", encoding=enc) as f:
                return f.read(), enc
        except (UnicodeDecodeError, PermissionError):
            continue
        except Exception as e:
            logger.error(f"Failed to read file {path}: {e}")
            return None, "utf-8"
    return None, "utf-8"


def write_file_content(path: Path, content: str, encoding: str = "utf-8") -> bool:
    """Writes content to a file using specified encoding."""
    try:
        path.parent.mkdir(parents=True, exist_ok=True)
        with open(path, "w", encoding=encoding) as f:
            f.write(content)
        return True
    except Exception as e:
        logger.error(f"Failed to write file {path}: {e}")
        return False


def reveal_in_file_manager(path: Path) -> None:
    """Opens system native file manager with selected file/folder revealed."""
    system_name = platform.system()
    path_str = str(path.resolve())

    try:
        if system_name == "Windows":
            if path.is_file():
                subprocess.run(["explorer", "/select,", path_str])
            else:
                subprocess.run(["explorer", path_str])
        elif system_name == "Darwin":  # macOS
            if path.is_file():
                subprocess.run(["open", "-R", path_str])
            else:
                subprocess.run(["open", path_str])
        else:  # Linux / Unix
            target = path.parent if path.is_file() else path
            QDesktopServices.openUrl(QUrl.fromLocalFile(str(target)))
    except Exception as e:
        logger.error(f"Error revealing path in file manager: {e}")


def get_language_from_filename(filename: str) -> str:
    """Detects programming language from file extension."""
    ext = Path(filename).suffix.lower()
    mapping = {
        ".py": "python",
        ".js": "javascript",
        ".jsx": "javascript",
        ".ts": "typescript",
        ".tsx": "typescript",
        ".html": "html",
        ".htm": "html",
        ".css": "css",
        ".json": "json",
        ".md": "markdown",
        ".cpp": "cpp",
        ".cxx": "cpp",
        ".cc": "cpp",
        ".c": "cpp",
        ".h": "cpp",
        ".hpp": "cpp",
        ".java": "java",
        ".sh": "bash",
        ".bash": "bash",
        ".xml": "xml",
        ".yaml": "yaml",
        ".yml": "yaml",
        ".sql": "sql"
    }
    return mapping.get(ext, "text")
