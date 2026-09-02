"""
MSAI Studio - File Manager
"""
import os
import shutil
from typing import Optional, Tuple, List

class FileManager:
    """Provides utility methods for file operations."""

    @staticmethod
    def read_file(file_path: str) -> Tuple[bool, str]:
        """Reads file content safely and returns (success, content_or_error)."""
        if not os.path.exists(file_path):
            return False, f"File not found: {file_path}"
        try:
            with open(file_path, "r", encoding="utf-8") as f:
                return True, f.read()
        except UnicodeDecodeError:
            try:
                with open(file_path, "r", encoding="latin-1") as f:
                    return True, f.read()
            except Exception as e:
                return False, f"Encoding error reading file: {e}"
        except Exception as e:
            return False, f"Error reading file: {e}"

    @staticmethod
    def write_file(file_path: str, content: str) -> Tuple[bool, str]:
        """Writes content to file safely."""
        try:
            parent_dir = os.path.dirname(file_path)
            if parent_dir and not os.path.exists(parent_dir):
                os.makedirs(parent_dir, exist_ok=True)
            with open(file_path, "w", encoding="utf-8") as f:
                f.write(content)
            return True, "File saved successfully"
        except Exception as e:
            return False, f"Error writing file: {e}"

    @staticmethod
    def create_file(file_path: str) -> Tuple[bool, str]:
        """Creates an empty file."""
        if os.path.exists(file_path):
            return False, "File already exists"
        return FileManager.write_file(file_path, "")

    @staticmethod
    def create_directory(dir_path: str) -> Tuple[bool, str]:
        """Creates a directory."""
        if os.path.exists(dir_path):
            return False, "Directory already exists"
        try:
            os.makedirs(dir_path, exist_ok=True)
            return True, "Directory created successfully"
        except Exception as e:
            return False, f"Error creating directory: {e}"

    @staticmethod
    def rename_item(old_path: str, new_path: str) -> Tuple[bool, str]:
        """Renames a file or directory."""
        if not os.path.exists(old_path):
            return False, f"Source path does not exist: {old_path}"
        if os.path.exists(new_path):
            return False, f"Destination path already exists: {new_path}"
        try:
            os.rename(old_path, new_path)
            return True, "Item renamed successfully"
        except Exception as e:
            return False, f"Error renaming item: {e}"

    @staticmethod
    def delete_item(path: str) -> Tuple[bool, str]:
        """Deletes a file or directory."""
        if not os.path.exists(path):
            return False, f"Path does not exist: {path}"
        try:
            if os.path.isdir(path):
                shutil.rmtree(path)
            else:
                os.remove(path)
            return True, "Item deleted successfully"
        except Exception as e:
            return False, f"Error deleting item: {e}"
