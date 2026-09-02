"""
MSAI Studio - File Explorer Sidebar
"""
import os
from PyQt6.QtWidgets import (
    QWidget, QVBoxLayout, QHBoxLayout, QLabel, QTreeView,
    QPushButton, QMenu, QInputDialog, QMessageBox, QHeaderView
)
from PyQt6.QtGui import QFileSystemModel
from PyQt6.QtCore import pyqtSignal, QDir, Qt
from core.file_manager import FileManager
from constants import FILE_ICON_MAP

class ExplorerView(QWidget):
    """
    Project / File Tree Explorer sidebar with open folder, file creation,
    directory creation, rename, delete, and refresh actions.
    """
    file_selected = pyqtSignal(str)
    open_folder_requested = pyqtSignal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self.root_path = ""

        layout = QVBoxLayout(self)
        layout.setContentsMargins(4, 4, 4, 4)
        layout.setSpacing(6)

        # Header bar
        header_layout = QHBoxLayout()
        self.title_label = QLabel("EXPLORER")
        self.title_label.setStyleSheet("font-weight: bold; color: #a6adc8; font-size: 11px;")

        self.btn_new_file = QPushButton("+📄")
        self.btn_new_file.setToolTip("New File")
        self.btn_new_folder = QPushButton("+📁")
        self.btn_new_folder.setToolTip("New Folder")
        self.btn_refresh = QPushButton("🔄")
        self.btn_refresh.setToolTip("Refresh Tree")

        btn_style = "QPushButton { background: transparent; border: none; font-size: 12px; } QPushButton:hover { background: #313244; }"
        for btn in (self.btn_new_file, self.btn_new_folder, self.btn_refresh):
            btn.setStyleSheet(btn_style)
            btn.setFixedWidth(24)

        self.btn_new_file.clicked.connect(self._create_new_file)
        self.btn_new_folder.clicked.connect(self._create_new_folder)
        self.btn_refresh.clicked.connect(self.refresh)

        header_layout.addWidget(self.title_label)
        header_layout.addStretch()
        header_layout.addWidget(self.btn_new_file)
        header_layout.addWidget(self.btn_new_folder)
        header_layout.addWidget(self.btn_refresh)

        # File System Model & Tree View
        self.model = QFileSystemModel()
        self.model.setReadOnly(False)

        self.tree_view = QTreeView()
        self.tree_view.setModel(self.model)
        self.tree_view.setAnimated(True)
        self.tree_view.setIndentation(16)
        self.tree_view.setSortingEnabled(True)
        self.tree_view.header().setSectionResizeMode(0, QHeaderView.ResizeMode.Stretch)
        self.tree_view.header().hideSection(1) # Hide Size
        self.tree_view.header().hideSection(2) # Hide Type
        self.tree_view.header().hideSection(3) # Hide Date
        self.tree_view.header().hide()

        self.tree_view.doubleClicked.connect(self._on_item_double_clicked)
        self.tree_view.setContextMenuPolicy(Qt.ContextMenuPolicy.CustomContextMenu)
        self.tree_view.customContextMenuRequested.connect(self._show_context_menu)

        # Open Folder Prompt Button (if no folder open)
        self.open_folder_btn = QPushButton("Open Folder")
        self.open_folder_btn.clicked.connect(lambda: self.open_folder_requested.emit())
        self.open_folder_btn.setStyleSheet("background-color: #89b4fa; color: #11111b; font-weight: bold; padding: 8px;")

        layout.addLayout(header_layout)
        layout.addWidget(self.tree_view)
        layout.addWidget(self.open_folder_btn)

        self.open_folder_btn.hide()

    def set_project_path(self, path: str):
        """Set active project root directory."""
        if not path or not os.path.exists(path):
            self.tree_view.hide()
            self.open_folder_btn.show()
            return

        self.root_path = os.path.abspath(path)
        self.model.setRootPath(self.root_path)
        self.tree_view.setRootIndex(self.model.index(self.root_path))
        self.tree_view.show()
        self.open_folder_btn.hide()

    def refresh(self):
        """Refreshes tree model."""
        if self.root_path:
            self.model.setRootPath("")
            self.model.setRootPath(self.root_path)

    def _on_item_double_clicked(self, index):
        file_path = self.model.filePath(index)
        if os.path.isfile(file_path):
            self.file_selected.emit(file_path)

    def _get_selected_dir(self) -> str:
        indexes = self.tree_view.selectedIndexes()
        if indexes:
            path = self.model.filePath(indexes[0])
            return path if os.path.isdir(path) else os.path.dirname(path)
        return self.root_path or os.getcwd()

    def _create_new_file(self):
        target_dir = self._get_selected_dir()
        name, ok = QInputDialog.getText(self, "New File", "Enter file name:")
        if ok and name.strip():
            full_path = os.path.join(target_dir, name.strip())
            ok_res, err = FileManager.create_file(full_path)
            if ok_res:
                self.refresh()
                self.file_selected.emit(full_path)
            else:
                QMessageBox.warning(self, "Error", err)

    def _create_new_folder(self):
        target_dir = self._get_selected_dir()
        name, ok = QInputDialog.getText(self, "New Folder", "Enter folder name:")
        if ok and name.strip():
            full_path = os.path.join(target_dir, name.strip())
            ok_res, err = FileManager.create_directory(full_path)
            if ok_res:
                self.refresh()
            else:
                QMessageBox.warning(self, "Error", err)

    def _show_context_menu(self, position):
        indexes = self.tree_view.selectedIndexes()
        if not indexes:
            return

        index = indexes[0]
        path = self.model.filePath(index)

        menu = QMenu(self)
        action_new_file = menu.addAction("New File")
        action_new_folder = menu.addAction("New Folder")
        menu.addSeparator()
        action_rename = menu.addAction("Rename")
        action_delete = menu.addAction("Delete")

        action = menu.exec(self.tree_view.viewport().mapToGlobal(position))
        if action == action_new_file:
            self._create_new_file()
        elif action == action_new_folder:
            self._create_new_folder()
        elif action == action_rename:
            self._rename_item(path)
        elif action == action_delete:
            self._delete_item(path)

    def _rename_item(self, old_path: str):
        old_name = os.path.basename(old_path)
        new_name, ok = QInputDialog.getText(self, "Rename", "New name:", text=old_name)
        if ok and new_name.strip() and new_name != old_name:
            new_path = os.path.join(os.path.dirname(old_path), new_name.strip())
            ok_res, err = FileManager.rename_item(old_path, new_path)
            if ok_res:
                self.refresh()
            else:
                QMessageBox.warning(self, "Error", err)

    def _delete_item(self, path: str):
        reply = QMessageBox.question(
            self, "Confirm Delete",
            f"Are you sure you want to delete '{os.path.basename(path)}'?",
            QMessageBox.StandardButton.Yes | QMessageBox.StandardButton.No
        )
        if reply == QMessageBox.StandardButton.Yes:
            ok_res, err = FileManager.delete_item(path)
            if ok_res:
                self.refresh()
            else:
                QMessageBox.warning(self, "Error", err)
