"""NV Studio File Explorer Sidebar Component with full file operations, context menus, and drag-and-drop support"""
import os
import shutil
from pathlib import Path
from typing import Optional
from PyQt6.QtCore import QDir, QModelIndex, Qt, pyqtSignal
from PyQt6.QtGui import QAction, QCursor, QFileSystemModel, QIcon, QKeySequence
from PyQt6.QtWidgets import (
    QAbstractItemView, QFileDialog, QHeaderView, QInputDialog, QLabel,
    QMenu, QMessageBox, QTreeView, QVBoxLayout, QWidget
)

from nvstudio.core.workspace import workspace_manager


class FileExplorerTree(QTreeView):
    """QTreeView subclass for workspace file management supporting context menus and drag-drop."""
    file_double_clicked = pyqtSignal(str)

    def __init__(self, parent=None):
        super().__init__(parent)
        self.setHeaderHidden(True)
        self.setAnimated(True)
        self.setIndentation(16)
        self.setSortingEnabled(True)
        self.sortByColumn(0, Qt.SortOrder.AscendingOrder)
        self.setContextMenuPolicy(Qt.ContextMenuPolicy.CustomContextMenu)
        self.customContextMenuRequested.connect(self._show_context_menu)
        self.doubleClicked.connect(self._on_double_click)

        # Drag & drop
        self.setDragEnabled(True)
        self.setAcceptDrops(True)
        self.setDropIndicatorShown(True)
        self.setDragDropMode(QAbstractItemView.DragDropMode.InternalMove)

        # Clipboard buffer for cut/copy/paste
        self.clipboard_path: Optional[str] = None
        self.clipboard_mode: Optional[str] = None  # 'cut' or 'copy'

    def set_model(self, model: QFileSystemModel) -> None:
        self.setModel(model)
        # Hide Size, Type, Date Modified columns
        for col in range(1, model.columnCount()):
            self.setColumnHidden(col, True)

    def _on_double_click(self, index: QModelIndex) -> None:
        model: QFileSystemModel = self.model()
        if not model:
            return
        file_path = model.filePath(index)
        if os.path.isfile(file_path):
            self.file_double_clicked.emit(file_path)

    def _get_selected_path(self) -> Optional[str]:
        indexes = self.selectedIndexes()
        if not indexes:
            return None
        model: QFileSystemModel = self.model()
        return model.filePath(indexes[0])

    def _get_target_directory(self) -> str:
        selected = self._get_selected_path()
        if selected:
            if os.path.isdir(selected):
                return selected
            else:
                return os.path.dirname(selected)
        root = workspace_manager.get_root_path()
        return root if root else os.path.expanduser("~")

    def _show_context_menu(self, position) -> None:
        menu = QMenu(self)

        selected_path = self._get_selected_path()
        target_dir = self._get_target_directory()

        action_new_file = QAction("New File", self)
        action_new_file.triggered.connect(lambda: self.create_new_file(target_dir))
        menu.addAction(action_new_file)

        action_new_folder = QAction("New Folder", self)
        action_new_folder.triggered.connect(lambda: self.create_new_folder(target_dir))
        menu.addAction(action_new_folder)

        menu.addSeparator()

        if selected_path:
            action_cut = QAction("Cut", self)
            action_cut.triggered.connect(lambda: self._set_clipboard(selected_path, "cut"))
            menu.addAction(action_cut)

            action_copy = QAction("Copy", self)
            action_copy.triggered.connect(lambda: self._set_clipboard(selected_path, "copy"))
            menu.addAction(action_copy)

        action_paste = QAction("Paste", self)
        action_paste.setEnabled(bool(self.clipboard_path and os.path.exists(self.clipboard_path)))
        action_paste.triggered.connect(lambda: self._paste_item(target_dir))
        menu.addAction(action_paste)

        menu.addSeparator()

        if selected_path:
            action_rename = QAction("Rename...", self)
            action_rename.triggered.connect(lambda: self.rename_item(selected_path))
            menu.addAction(action_rename)

            action_delete = QAction("Delete", self)
            action_delete.triggered.connect(lambda: self.delete_item(selected_path))
            menu.addAction(action_delete)

        menu.exec(self.viewport().mapToGlobal(position))

    def _set_clipboard(self, path: str, mode: str) -> None:
        self.clipboard_path = path
        self.clipboard_mode = mode

    def _paste_item(self, target_dir: str) -> None:
        if not self.clipboard_path or not os.path.exists(self.clipboard_path):
            return

        if self.clipboard_mode == "copy":
            ok, msg = workspace_manager.copy_item(self.clipboard_path, target_dir)
        elif self.clipboard_mode == "cut":
            ok, msg = workspace_manager.move_item(self.clipboard_path, target_dir)
            self.clipboard_path = None
            self.clipboard_mode = None
        else:
            return

        if not ok:
            QMessageBox.warning(self, "Paste Failed", msg)

    def create_new_file(self, parent_dir: str) -> None:
        file_name, ok = QInputDialog.getText(self, "New File", "Enter file name:")
        if ok and file_name.strip():
            success, msg_or_path = workspace_manager.create_file(parent_dir, file_name.strip())
            if success:
                self.file_double_clicked.emit(msg_or_path)
            else:
                QMessageBox.warning(self, "Create File Failed", msg_or_path)

    def create_new_folder(self, parent_dir: str) -> None:
        folder_name, ok = QInputDialog.getText(self, "New Folder", "Enter folder name:")
        if ok and folder_name.strip():
            success, msg_or_path = workspace_manager.create_folder(parent_dir, folder_name.strip())
            if not success:
                QMessageBox.warning(self, "Create Folder Failed", msg_or_path)

    def rename_item(self, old_path: str) -> None:
        old_name = Path(old_path).name
        new_name, ok = QInputDialog.getText(self, "Rename", "Enter new name:", text=old_name)
        if ok and new_name.strip() and new_name.strip() != old_name:
            success, msg = workspace_manager.rename_item(old_path, new_name.strip())
            if not success:
                QMessageBox.warning(self, "Rename Failed", msg)

    def delete_item(self, target_path: str) -> None:
        name = Path(target_path).name
        reply = QMessageBox.question(
            self,
            "Confirm Delete",
            f"Are you sure you want to delete '{name}'?",
            QMessageBox.StandardButton.Yes | QMessageBox.StandardButton.No,
            QMessageBox.StandardButton.No
        )
        if reply == QMessageBox.StandardButton.Yes:
            success, msg = workspace_manager.delete_item(target_path)
            if not success:
                QMessageBox.warning(self, "Delete Failed", msg)


class FileExplorerPanel(QWidget):
    """File Explorer Sidebar Panel containing tree view and project control actions."""
    file_selected = pyqtSignal(str)

    def __init__(self, parent=None):
        super().__init__(parent)
        self.setObjectName("FileExplorerPanel")

        layout = QVBoxLayout(self)
        layout.setContentsMargins(0, 0, 0, 0)
        layout.setSpacing(0)

        # Header Label
        self.header_label = QLabel("EXPLORER")
        self.header_label.setObjectName("SidebarHeader")
        layout.addWidget(self.header_label)

        # File system model
        self.fs_model = QFileSystemModel()
        self.fs_model.setReadOnly(False)
        self.fs_model.setFilter(QDir.Filter.AllEntries | QDir.Filter.NoDotAndDotDot | QDir.Filter.Hidden)

        # Tree view
        self.tree = FileExplorerTree()
        self.tree.set_model(self.fs_model)
        self.tree.file_double_clicked.connect(self.file_selected.emit)

        layout.addWidget(self.tree)

        # Connect workspace manager signal
        workspace_manager.folder_changed.connect(self.open_folder)

    def open_folder(self, folder_path: str) -> None:
        if os.path.exists(folder_path) and os.path.isdir(folder_path):
            self.fs_model.setRootPath(folder_path)
            self.tree.setRootIndex(self.fs_model.index(folder_path))
            self.header_label.setText(f"EXPLORER: {Path(folder_path).name.upper()}")
