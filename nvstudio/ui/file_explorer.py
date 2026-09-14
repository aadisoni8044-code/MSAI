import os
import shutil
from pathlib import Path
from PyQt6.QtWidgets import (
    QWidget, QVBoxLayout, QHBoxLayout, QTreeView,
    QPushButton, QLabel, QInputDialog, QMessageBox, QMenu, QFileDialog
)
from PyQt6.QtGui import QFileSystemModel
from PyQt6.QtCore import Qt, pyqtSignal, QDir


class FileExplorerPanel(QWidget):
    """File Explorer panel displaying project tree view with file operations."""

    file_selected = pyqtSignal(str)
    file_renamed = pyqtSignal(str, str)
    file_deleted = pyqtSignal(str)
    project_changed = pyqtSignal(str)

    def __init__(self, project_dir=None, parent=None):
        super().__init__(parent)
        self.project_dir = Path(project_dir) if project_dir else Path.home()

        layout = QVBoxLayout(self)
        layout.setContentsMargins(8, 8, 8, 8)
        layout.setSpacing(6)

        # Header bar
        header_layout = QHBoxLayout()
        header_label = QLabel("PROJECT EXPLORER")
        header_label.setStyleSheet("font-weight: bold; color: #94a3b8; font-size: 11px; letter-spacing: 0.5px;")
        header_layout.addWidget(header_label)
        header_layout.addStretch()

        self.btn_new_file = QPushButton("+ File")
        self.btn_new_file.setToolTip("New File")
        self.btn_new_file.clicked.connect(self.create_new_file)

        self.btn_new_folder = QPushButton("+ Folder")
        self.btn_new_folder.setToolTip("New Folder")
        self.btn_new_folder.clicked.connect(self.create_new_folder)

        self.btn_open_folder = QPushButton("Open...")
        self.btn_open_folder.setToolTip("Open Project Folder")
        self.btn_open_folder.clicked.connect(self.open_project_folder)

        header_layout.addWidget(self.btn_new_file)
        header_layout.addWidget(self.btn_new_folder)
        header_layout.addWidget(self.btn_open_folder)

        layout.addLayout(header_layout)

        # File System Model & Tree View
        self.model = QFileSystemModel()
        self.model.setReadOnly(False)

        self.tree = QTreeView()
        self.tree.setModel(self.model)
        self.tree.setAnimated(True)
        self.tree.setIndentation(16)
        self.tree.setSortingEnabled(True)

        # Hide size, type, date modified columns
        self.tree.setColumnHidden(1, True)
        self.tree.setColumnHidden(2, True)
        self.tree.setColumnHidden(3, True)
        self.tree.header().hide()

        self.tree.doubleClicked.connect(self._on_item_double_clicked)
        self.tree.setContextMenuPolicy(Qt.ContextMenuPolicy.CustomContextMenu)
        self.tree.customContextMenuRequested.connect(self._show_context_menu)

        layout.addWidget(self.tree)

        self.set_project_dir(self.project_dir)

    def set_project_dir(self, path):
        self.project_dir = Path(path)
        self.project_dir.mkdir(parents=True, exist_ok=True)
        root_path = str(self.project_dir)
        self.model.setRootPath(root_path)
        self.tree.setRootIndex(self.model.index(root_path))
        self.project_changed.emit(root_path)

    def _on_item_double_clicked(self, index):
        filepath = self.model.filePath(index)
        if os.path.isfile(filepath):
            self.file_selected.emit(filepath)

    def _show_context_menu(self, position):
        index = self.tree.indexAt(position)
        menu = QMenu(self)

        new_file_act = menu.addAction("New File")
        new_folder_act = menu.addAction("New Folder")
        menu.addSeparator()

        if index.isValid():
            rename_act = menu.addAction("Rename")
            delete_act = menu.addAction("Delete")
        else:
            rename_act = None
            delete_act = None

        action = menu.exec(self.tree.viewport().mapToGlobal(position))
        if action == new_file_act:
            self.create_new_file(index)
        elif action == new_folder_act:
            self.create_new_folder(index)
        elif rename_act and action == rename_act:
            self.rename_item(index)
        elif delete_act and action == delete_act:
            self.delete_item(index)

    def create_new_file(self, target_index=None):
        target_dir = self._get_target_dir(target_index)
        filename, ok = QInputDialog.getText(self, "New File", "Enter file name:")
        if ok and filename.strip():
            filepath = target_dir / filename.strip()
            if filepath.exists():
                QMessageBox.warning(self, "File Exists", f"A file or folder with name '{filename}' already exists.")
                return
            try:
                filepath.touch()
                self.file_selected.emit(str(filepath))
            except Exception as e:
                QMessageBox.critical(self, "Error", f"Failed to create file: {e}")

    def create_new_folder(self, target_index=None):
        target_dir = self._get_target_dir(target_index)
        foldername, ok = QInputDialog.getText(self, "New Folder", "Enter folder name:")
        if ok and foldername.strip():
            dirpath = target_dir / foldername.strip()
            if dirpath.exists():
                QMessageBox.warning(self, "Folder Exists", f"A folder with name '{foldername}' already exists.")
                return
            try:
                dirpath.mkdir(parents=True, exist_ok=True)
            except Exception as e:
                QMessageBox.critical(self, "Error", f"Failed to create folder: {e}")

    def rename_item(self, index):
        if not index.isValid():
            return
        old_path = Path(self.model.filePath(index))
        new_name, ok = QInputDialog.getText(self, "Rename", f"Rename '{old_path.name}' to:", text=old_path.name)
        if ok and new_name.strip() and new_name.strip() != old_path.name:
            new_path = old_path.parent / new_name.strip()
            try:
                old_path.rename(new_path)
                self.file_renamed.emit(str(old_path), str(new_path))
            except Exception as e:
                QMessageBox.critical(self, "Error", f"Failed to rename: {e}")

    def delete_item(self, index):
        if not index.isValid():
            return
        filepath = Path(self.model.filePath(index))
        reply = QMessageBox.question(
            self, "Delete Confirmation",
            f"Are you sure you want to delete '{filepath.name}'?",
            QMessageBox.StandardButton.Yes | QMessageBox.StandardButton.No
        )
        if reply == QMessageBox.StandardButton.Yes:
            try:
                if filepath.is_dir():
                    shutil.rmtree(filepath)
                else:
                    filepath.unlink()
                self.file_deleted.emit(str(filepath))
            except Exception as e:
                QMessageBox.critical(self, "Error", f"Failed to delete: {e}")

    def open_project_folder(self):
        folder = QFileDialog.getExistingDirectory(self, "Open Project Folder", str(self.project_dir))
        if folder:
            self.set_project_dir(folder)

    def _get_target_dir(self, index=None):
        if index and index.isValid():
            path = Path(self.model.filePath(index))
            if path.is_dir():
                return path
            return path.parent
        return self.project_dir
