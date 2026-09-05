"""NV Studio Custom Title Bar with Window Actions and Integrated Menu Bar"""
from typing import Optional
from PyQt6.QtCore import QPoint, QSize, Qt, pyqtSignal
from PyQt6.QtGui import QAction, QIcon
from PyQt6.QtWidgets import (
    QFrame, QHBoxLayout, QLabel, QMenu, QMenuBar, QToolButton, QWidget
)


class TitleBar(QFrame):
    """Custom top title bar containing logo, window title, top menu bar, and window control buttons."""
    minimize_requested = pyqtSignal()
    maximize_requested = pyqtSignal()
    close_requested = pyqtSignal()

    def __init__(self, main_window, parent=None):
        super().__init__(parent)
        self.setObjectName("TitleBar")
        self.main_window = main_window

        layout = QHBoxLayout(self)
        layout.setContentsMargins(8, 0, 8, 0)
        layout.setSpacing(8)

        # Brand Logo / Name
        self.logo_label = QLabel("⚡ NV STUDIO")
        self.logo_label.setObjectName("TitleLogoLabel")
        layout.addWidget(self.logo_label)

        # Menu Bar
        self.menu_bar = QMenuBar(self)
        self.menu_bar.setStyleSheet("""
            QMenuBar {
                background: transparent;
                color: #c5cddb;
                border: none;
                font-size: 12px;
            }
            QMenuBar::item {
                background: transparent;
                padding: 4px 8px;
            }
            QMenuBar::item:selected {
                background-color: #1e2636;
                color: #ffffff;
                border-radius: 4px;
            }
            QMenu {
                background-color: #141923;
                color: #c5cddb;
                border: 1px solid #232d3f;
                padding: 4px;
            }
            QMenu::item {
                padding: 6px 24px 6px 12px;
            }
            QMenu::item:selected {
                background-color: #25334d;
                color: #ffffff;
            }
        """)
        layout.addWidget(self.menu_bar)

        # Title Label (Active Project / Document)
        self.title_label = QLabel("NV Studio - Workspace")
        self.title_label.setObjectName("TitleTextLabel")
        self.title_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        layout.addWidget(self.title_label, stretch=1)

        # Window Control Buttons
        self.min_btn = QToolButton(self)
        self.min_btn.setText("—")
        self.min_btn.setToolTip("Minimize")
        self.min_btn.clicked.connect(self.minimize_requested.emit)

        self.max_btn = QToolButton(self)
        self.max_btn.setText("☐")
        self.max_btn.setToolTip("Maximize / Restore")
        self.max_btn.clicked.connect(self.maximize_requested.emit)

        self.close_btn = QToolButton(self)
        self.close_btn.setObjectName("CloseButton")
        self.close_btn.setText("✕")
        self.close_btn.setToolTip("Close NV Studio")
        self.close_btn.clicked.connect(self.close_requested.emit)

        layout.addWidget(self.min_btn)
        layout.addWidget(self.max_btn)
        layout.addWidget(self.close_btn)

        self._drag_pos: Optional[QPoint] = None

    def set_title(self, text: str) -> None:
        self.title_label.setText(text)

    def mousePressEvent(self, event) -> None:
        if event.button() == Qt.MouseButton.LeftButton:
            self._drag_pos = event.globalPosition().toPoint() - self.main_window.frameGeometry().topLeft()
            event.accept()

    def mouseMoveEvent(self, event) -> None:
        if event.buttons() == Qt.MouseButton.LeftButton and self._drag_pos is not None:
            self.main_window.move(event.globalPosition().toPoint() - self._drag_pos)
            event.accept()
