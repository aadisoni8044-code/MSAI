"""
Welcome start page widget for PyCodeStudio.
"""

from pathlib import Path
from typing import List

from PyQt6.QtCore import Qt, pyqtSignal
from PyQt6.QtWidgets import (
    QHBoxLayout,
    QLabel,
    QListWidget,
    QListWidgetItem,
    QPushButton,
    QVBoxLayout,
    QWidget,
)

from utils.icon_loader import IconLoader


class WelcomeScreen(QWidget):
    """VS Code inspired welcome start page with quick start buttons and recent files/folders."""

    open_file_requested = pyqtSignal()
    open_folder_requested = pyqtSignal()
    new_file_requested = pyqtSignal()
    recent_file_clicked = pyqtSignal(Path)
    recent_folder_clicked = pyqtSignal(Path)
    toggle_theme_requested = pyqtSignal()

    def __init__(self, recent_files: List[str] = None, recent_folders: List[str] = None, parent=None):
        super().__init__(parent)
        self.recent_files = recent_files or []
        self.recent_folders = recent_folders or []

        self._init_ui()

    def _init_ui(self) -> None:
        """Constructs welcome screen layout."""
        layout = QHBoxLayout(self)
        layout.setContentsMargins(40, 40, 40, 40)
        layout.setSpacing(40)

        # Left Column: Quick Actions & Branding
        left_col = QVBoxLayout()
        left_col.setSpacing(16)

        title = QLabel("PyCodeStudio")
        title.setStyleSheet("font-size: 32px; font-weight: bold; color: #ffffff;")

        subtitle = QLabel("Editing evolved. Lightweight, fast, cross-platform.")
        subtitle.setStyleSheet("font-size: 14px; color: #888888;")

        left_col.addWidget(title)
        left_col.addWidget(subtitle)
        left_col.addSpacing(20)

        start_heading = QLabel("Start")
        start_heading.setStyleSheet("font-size: 16px; font-weight: bold; color: #cccccc;")
        left_col.addWidget(start_heading)

        btn_new = QPushButton(" New File")
        btn_new.setIcon(IconLoader.get_icon("file"))
        btn_new.setStyleSheet("text-align: left; padding: 10px 14px; font-size: 13px;")
        btn_new.clicked.connect(self.new_file_requested.emit)

        btn_open_file = QPushButton(" Open File...")
        btn_open_file.setIcon(IconLoader.get_icon("file"))
        btn_open_file.setStyleSheet("text-align: left; padding: 10px 14px; font-size: 13px;")
        btn_open_file.clicked.connect(self.open_file_requested.emit)

        btn_open_folder = QPushButton(" Open Folder...")
        btn_open_folder.setIcon(IconLoader.get_icon("folder"))
        btn_open_folder.setStyleSheet("text-align: left; padding: 10px 14px; font-size: 13px;")
        btn_open_folder.clicked.connect(self.open_folder_requested.emit)

        btn_theme = QPushButton(" Quick Switch Theme")
        btn_theme.setIcon(IconLoader.get_icon("settings"))
        btn_theme.setStyleSheet("text-align: left; padding: 10px 14px; font-size: 13px;")
        btn_theme.clicked.connect(self.toggle_theme_requested.emit)

        left_col.addWidget(btn_new)
        left_col.addWidget(btn_open_file)
        left_col.addWidget(btn_open_folder)
        left_col.addWidget(btn_theme)
        left_col.addStretch()

        # Right Column: Recent Files & Folders
        right_col = QVBoxLayout()
        right_col.setSpacing(12)

        recent_heading = QLabel("Recent")
        recent_heading.setStyleSheet("font-size: 16px; font-weight: bold; color: #cccccc;")
        right_col.addWidget(recent_heading)

        self.recent_list = QListWidget()
        self.recent_list.setStyleSheet("""
            QListWidget {
                background-color: #252526;
                border: 1px solid #3c3c3c;
                border-radius: 4px;
                padding: 6px;
            }
            QListWidget::item {
                padding: 8px;
                border-bottom: 1px solid #2d2d2d;
            }
            QListWidget::item:hover {
                background-color: #2a2d2e;
            }
        """)
        self.recent_list.itemClicked.connect(self._on_recent_item_clicked)
        right_col.addWidget(self.recent_list)

        self.populate_recents(self.recent_files, self.recent_folders)

        layout.addLayout(left_col, 1)
        layout.addLayout(right_col, 1)

    def populate_recents(self, files: List[str], folders: List[str]) -> None:
        """Populates list widget with recent items."""
        self.recent_files = files
        self.recent_folders = folders
        self.recent_list.clear()

        for f_path in folders:
            p = Path(f_path)
            item = QListWidgetItem(f"📁 {p.name}  —  {p.parent}")
            item.setData(Qt.ItemDataRole.UserRole, ("folder", p))
            self.recent_list.addItem(item)

        for f_path in files:
            p = Path(f_path)
            item = QListWidgetItem(f"📄 {p.name}  —  {p.parent}")
            item.setData(Qt.ItemDataRole.UserRole, ("file", p))
            self.recent_list.addItem(item)

        if self.recent_list.count() == 0:
            item = QListWidgetItem("No recent items")
            item.setFlags(item.flags() & ~Qt.ItemFlag.ItemIsEnabled)
            self.recent_list.addItem(item)

    def _on_recent_item_clicked(self, item: QListWidgetItem) -> None:
        """Handles click on recent list item."""
        data = item.data(Qt.ItemDataRole.UserRole)
        if data:
            item_type, path = data
            if item_type == "file":
                self.recent_file_clicked.emit(path)
            elif item_type == "folder":
                self.recent_folder_clicked.emit(path)
