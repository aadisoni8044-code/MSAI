"""
File I/O and Workspace Utilities for OpenMS Code Studio
"""

import os


class FileManager:
    """Utility class for managing file operations."""

    @staticmethod
    def read_text_file(filepath):
        """Reads content from a text file cleanly."""
        with open(filepath, "r", encoding="utf-8", errors="replace") as f:
            return f.read()

    @staticmethod
    def write_text_file(filepath, content):
        """Writes content to a text file cleanly."""
        with open(filepath, "w", encoding="utf-8") as f:
            f.write(content)

    @staticmethod
    def get_workspace_files(dirpath, extension=".game"):
        """Returns list of matching code files in directory."""
        results = []
        if not os.path.exists(dirpath):
            return results
        for root, dirs, files in os.walk(dirpath):
            for file in files:
                if file.endswith(extension) or file.endswith(".function"):
                    results.append(os.path.join(root, file))
        return results
