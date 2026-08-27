"""
File Explorer sidebar tree view widget for PyCodeStudio.
"""

from pathlib import Path
from typing import Optional

from PyQt6.QtCore import QDir, Qt, pyqtSignal
from PyQt6.QtGui import QFileSystemModel
from PyQt6.QtWidgets import (
    QHBoxLayout,
    QHeaderView,
    QLabel,
    QPushButton,
    QTreeView,
    QVBoxLayout,
    QWidget,
)

from explorer.context_menu import FileExplorerContextMenu
from utils.icon_loader import IconLoader


class FileExplorerTree(QWidget):
    """File explorer sidebar widget containing tree view and quick actions."""

    file_double_clicked = pyqtSignal(Path)
    file_created = pyqtSignal(Path)
    file_deleted = pyqtSignal(Path)
    file_renamed = pyqtSignal(Path, Path)

    def __init__(self, root_path: Optional[Path] = None, parent=None):
        super().__init__(parent)
        self.root_path = root_path or Path.home()

        layout = QVBoxLayout(self)
        layout.setContentsMargins(0, 0, 0, 0)
        layout.setSpacing(0)

        # Header bar
        header = QWidget()
        header.setStyleSheet("background-color: #252526; border-bottom: 1px solid #1e1e1e;")
        h_layout = QHBoxLayout(header)
        h_layout.setContentsMargins(8, 4, 8, 4)

        title = QLabel("EXPLORER")
        title.setStyleSheet("font-weight: bold; color: #bbbbbb; font-size: 11px;")
        h_layout.addWidget(title)
        h_layout.addStretch()

        btn_new_file = QPushButton()
        btn_new_file.setIcon(IconLoader.get_icon("file"))
        btn_new_file.setToolTip("New File")
        btn_new_file.setFlat(True)
        btn_new_file.clicked.connect(self._create_new_file)

        btn_new_folder = QPushButton()
        btn_new_folder.setIcon(IconLoader.get_icon("folder"))
        btn_new_folder.setToolTip("New Folder")
        btn_new_folder.setFlat(True)
        btn_new_folder.clicked.connect(self._create_new_folder)

        h_layout.addWidget(btn_new_file)
        h_layout.addWidget(btn_new_folder)

        layout.addWidget(header)

        # File System Model
        self.model = QFileSystemModel()
        self.model.setReadOnly(False)
        self.model.setFilter(QDir.Filter.AllEntries | QDir.Filter.NoDotAndDotDot)

        # Tree View
        self.tree = QTreeView()
        self.tree.setModel(self.model)
        self.tree.setAnimated(True)
        self.tree.setIndentation(16)
        self.tree.setSortingEnabled(True)

        # Hide extra columns (Size, Type, Date)
        header_view = self.tree.header()
        header_view.hideSection(1)
        header_view.hideSection(2)
        header_view.hideSection(3)
        header_view.setSectionResizeMode(0, QHeaderView.ResizeMode.Stretch)

        self.tree.doubleClicked.connect(self._on_item_double_clicked)
        self.tree.setContextMenuPolicy(Qt.ContextMenuPolicy.CustomContextMenu)
        self.tree.customContextMenuRequested.connect(self._show_context_menu)

        layout.addWidget(self.tree)

        self.set_root_directory(self.root_path)

    def set_root_directory(self, path: Path) -> None:
        """Sets root directory displayed by File Explorer."""
        self.root_path = path.resolve()
        self.model.setRootPath(str(self.root_path))
        self.tree.setRootIndex(self.model.index(str(self.root_path)))

    def _on_item_double_clicked(self, index) -> None:
        """Emits signal when a file is double clicked in tree."""
        file_path = Path(self.model.filePath(index))
        if file_path.is_file():
            self.file_double_clicked.emit(file_path)

    def _show_context_menu(self, pos) -> None:
        """Triggers custom right-click context menu."""
        index = self.tree.indexAt(pos)
        target_path = Path(self.model.filePath(index)) if index.isValid() else self.root_path
        global_pos = self.tree.mapToGlobal(pos)

        FileExplorerContextMenu.show_menu(
            parent_widget=self,
            global_pos=global_pos,
            target_path=target_path,
            root_dir=self.root_path,
            on_file_created=self.file_created.emit,
            on_file_deleted=self.file_deleted.emit,
            on_file_renamed=self.file_renamed.emit
        )

    def _create_new_file(self) -> None:
        """Action handler for new file button in header."""
        from explorer.file_operations import FileOperations
        from PyQt6.QtWidgets import QInputDialog
        name, ok = QInputDialog.getText(self, "New File", "Enter file name:")
        if ok and name.strip():
            new_path = FileOperations.create_file(self.root_path, name.strip())
            if new_path:
                self.file_created.emit(new_path)

    def _create_new_folder(self) -> None:
        """Action handler for new folder button in header."""
        from explorer.file_operations import FileOperations
        from PyQt6.QtWidgets import QInputDialog
        name, ok = QInputDialog.getText(self, "New Folder", "Enter folder name:")
        if ok and name.strip():
            FileOperations.create_folder(self.root_path, name.strip())
