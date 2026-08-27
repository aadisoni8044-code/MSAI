"""
File and folder creation, deletion, renaming, and copying logic.
"""

import shutil
from pathlib import Path
from typing import Optional

from utils.logger import logger


class FileOperations:
    """Helper methods for file system mutations."""

    @staticmethod
    def create_file(parent_dir: Path, name: str) -> Optional[Path]:
        """Creates a new empty file inside parent_dir."""
        try:
            target = parent_dir / name
            target.parent.mkdir(parents=True, exist_ok=True)
            target.touch(exist_ok=False)
            return target
        except Exception as e:
            logger.error(f"Error creating file {name} in {parent_dir}: {e}")
            return None

    @staticmethod
    def create_folder(parent_dir: Path, name: str) -> Optional[Path]:
        """Creates a new folder inside parent_dir."""
        try:
            target = parent_dir / name
            target.mkdir(parents=True, exist_ok=False)
            return target
        except Exception as e:
            logger.error(f"Error creating folder {name} in {parent_dir}: {e}")
            return None

    @staticmethod
    def rename_item(target: Path, new_name: str) -> Optional[Path]:
        """Renames a file or folder."""
        try:
            destination = target.parent / new_name
            target.rename(destination)
            return destination
        except Exception as e:
            logger.error(f"Error renaming {target} to {new_name}: {e}")
            return None

    @staticmethod
    def delete_item(target: Path) -> bool:
        """Deletes a file or directory tree."""
        try:
            if target.is_dir():
                shutil.rmtree(target)
            else:
                target.unlink()
            return True
        except Exception as e:
            logger.error(f"Error deleting {target}: {e}")
            return False

    @staticmethod
    def duplicate_file(target: Path) -> Optional[Path]:
        """Duplicates a file with 'copy' appended."""
        try:
            if not target.is_file():
                return None
            stem = target.stem
            suffix = target.suffix
            copy_path = target.parent / f"{stem}_copy{suffix}"
            shutil.copy2(target, copy_path)
            return copy_path
        except Exception as e:
            logger.error(f"Error duplicating file {target}: {e}")
            return None
