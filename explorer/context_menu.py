"""
Context menu builder for File Explorer sidebar tree view.
"""

from pathlib import Path
from typing import Callable, Optional

from PyQt6.QtWidgets import QInputDialog, QMessageBox, QMenu

from explorer.file_operations import FileOperations
from utils.file_utils import reveal_in_file_manager
from utils.logger import logger


class FileExplorerContextMenu:
    """Builds and executes right-click context menu options on tree view items."""

    @staticmethod
    def show_menu(
        parent_widget,
        global_pos,
        target_path: Optional[Path],
        root_dir: Path,
        on_file_created: Optional[Callable[[Path], None]] = None,
        on_file_deleted: Optional[Callable[[Path], None]] = None,
        on_file_renamed: Optional[Callable[[Path, Path], None]] = None
    ) -> None:
        """Constructs context menu actions and handles execution."""
        menu = QMenu(parent_widget)

        # Base target directory
        base_dir = root_dir
        if target_path:
            base_dir = target_path if target_path.is_dir() else target_path.parent

        act_new_file = menu.addAction("New File")
        act_new_folder = menu.addAction("New Folder")
        menu.addSeparator()

        act_rename = None
        act_delete = None
        act_duplicate = None
        if target_path and target_path != root_dir:
            act_rename = menu.addAction("Rename")
            act_delete = menu.addAction("Delete")
            if target_path.is_file():
                act_duplicate = menu.addAction("Duplicate")
            menu.addSeparator()

        act_reveal = menu.addAction("Reveal in File Manager")

        selected_action = menu.exec(global_pos)
        if not selected_action:
            return

        if selected_action == act_new_file:
            name, ok = QInputDialog.getText(parent_widget, "New File", "Enter file name:")
            if ok and name.strip():
                new_path = FileOperations.create_file(base_dir, name.strip())
                if new_path and on_file_created:
                    on_file_created(new_path)

        elif selected_action == act_new_folder:
            name, ok = QInputDialog.getText(parent_widget, "New Folder", "Enter folder name:")
            if ok and name.strip():
                FileOperations.create_folder(base_dir, name.strip())

        elif selected_action == act_rename and target_path:
            name, ok = QInputDialog.getText(parent_widget, "Rename Item", "New name:", text=target_path.name)
            if ok and name.strip() and name.strip() != target_path.name:
                new_path = FileOperations.rename_item(target_path, name.strip())
                if new_path and on_file_renamed:
                    on_file_renamed(target_path, new_path)

        elif selected_action == act_delete and target_path:
            reply = QMessageBox.question(
                parent_widget,
                "Delete Confirmation",
                f"Are you sure you want to delete '{target_path.name}'?",
                QMessageBox.StandardButton.Yes | QMessageBox.StandardButton.No,
                QMessageBox.StandardButton.No
            )
            if reply == QMessageBox.StandardButton.Yes:
                if FileOperations.delete_item(target_path) and on_file_deleted:
                    on_file_deleted(target_path)

        elif selected_action == act_duplicate and target_path:
            new_path = FileOperations.duplicate_file(target_path)
            if new_path and on_file_created:
                on_file_created(new_path)

        elif selected_action == act_reveal:
            target = target_path or root_dir
            reveal_in_file_manager(target)
