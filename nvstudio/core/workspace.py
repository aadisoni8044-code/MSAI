"""NV Studio Workspace and Project Manager"""
import os
import shutil
from pathlib import Path
from typing import List, Optional, Tuple
from PyQt6.QtCore import QObject, pyqtSignal


class WorkspaceManager(QObject):
    """Manages active project root folder, file tree updates, and recent workspace history."""
    folder_changed = pyqtSignal(str)  # Emits current folder path
    file_opened = pyqtSignal(str)    # Emits file path to open in editor

    def __init__(self):
        super().__init__()
        self.root_path: Optional[Path] = None

    def open_folder(self, path: str) -> bool:
        """Set active project root folder."""
        p = Path(path).resolve()
        if p.exists() and p.is_dir():
            self.root_path = p
            self.folder_changed.emit(str(p))
            return True
        return False

    def get_root_path(self) -> Optional[str]:
        return str(self.root_path) if self.root_path else None

    def create_file(self, parent_dir: str, file_name: str) -> Tuple[bool, str]:
        """Create a new file in specified parent directory."""
        try:
            target_path = Path(parent_dir) / file_name
            if target_path.exists():
                return False, f"File '{file_name}' already exists."
            target_path.touch()
            return True, str(target_path)
        except Exception as e:
            return False, str(e)

    def create_folder(self, parent_dir: str, folder_name: str) -> Tuple[bool, str]:
        """Create a new folder in specified parent directory."""
        try:
            target_path = Path(parent_dir) / folder_name
            if target_path.exists():
                return False, f"Folder '{folder_name}' already exists."
            target_path.mkdir(parents=True, exist_ok=True)
            return True, str(target_path)
        except Exception as e:
            return False, str(e)

    def rename_item(self, old_path: str, new_name: str) -> Tuple[bool, str]:
        """Rename file or directory."""
        try:
            src = Path(old_path)
            dst = src.parent / new_name
            if dst.exists():
                return False, f"Destination '{new_name}' already exists."
            src.rename(dst)
            return True, str(dst)
        except Exception as e:
            return False, str(e)

    def delete_item(self, target_path: str) -> Tuple[bool, str]:
        """Delete file or directory recursively."""
        try:
            p = Path(target_path)
            if p.is_dir():
                shutil.rmtree(p)
            elif p.is_file():
                p.unlink()
            return True, "Item deleted"
        except Exception as e:
            return False, str(e)

    def copy_item(self, src_path: str, dst_dir: str) -> Tuple[bool, str]:
        """Copy file or directory to destination directory."""
        try:
            src = Path(src_path)
            dst = Path(dst_dir) / src.name
            if src.is_dir():
                shutil.copytree(src, dst)
            else:
                shutil.copy2(src, dst)
            return True, str(dst)
        except Exception as e:
            return False, str(e)

    def move_item(self, src_path: str, dst_dir: str) -> Tuple[bool, str]:
        """Move/cut file or directory to destination directory."""
        try:
            src = Path(src_path)
            dst = Path(dst_dir) / src.name
            shutil.move(str(src), str(dst))
            return True, str(dst)
        except Exception as e:
            return False, str(e)


workspace_manager = WorkspaceManager()
