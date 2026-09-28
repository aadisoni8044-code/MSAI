"""
exe/tow - Custom Window Top Bar
Displays the exe/tow visual identity logo, project title, and window control buttons.
Supports window dragging and window state toggles.
"""

import os
from PySide6.QtCore import Qt, QPoint, Signal
from PySide6.QtGui import QPixmap, QIcon
from PySide6.QtWidgets import (
    QFrame, QHBoxLayout, QLabel, QPushButton, QWidget, QSizePolicy
)
from exe_tow.ui.theme import ThemeColors

class TitleBar(QFrame):
    """Custom title bar for exe/tow window."""

    def __init__(self, parent_window, logo_path: str = "assets/logo.png"):
        super().__init__()
        self.parent_window = parent_window
        self.logo_path = logo_path
        self.drag_position = QPoint()

        self.setObjectName("TopBar")
        self.setFixedHeight(48)

        layout = QHBoxLayout(self)
        layout.setContentsMargins(12, 0, 12, 0)
        layout.setSpacing(10)

        # Brand Logo Image
        self.logo_label = QLabel()
        self.logo_label.setFixedSize(90, 28)
        self.logo_label.setScaledContents(True)

        if os.path.exists(self.logo_path):
            pix = QPixmap(self.logo_path)
            self.logo_label.setPixmap(pix)
        else:
            # Fallback text badge if image not loaded
            self.logo_label.setText("exe/tow")
            self.logo_label.setStyleSheet("font-weight: 800; font-size: 16px; color: #FFFFFF;")

        layout.addWidget(self.logo_label)

        # Divider
        divider = QFrame()
        divider.setFrameShape(QFrame.VLine)
        divider.setFixedSize(1, 18)
        divider.setStyleSheet(f"background-color: {ThemeColors.BORDER_SUBTLE}; border: none;")
        layout.addWidget(divider)

        # Project / Window Title
        self.title_label = QLabel("exe/tow - Desktop Python Compiler")
        self.title_label.setStyleSheet(f"color: {ThemeColors.TEXT_SECONDARY}; font-size: 12px; font-weight: 500;")
        layout.addWidget(self.title_label)

        layout.addStretch()

        # Window Controls (Minimize, Maximize, Close)
        self.min_btn = QPushButton("─")
        self.min_btn.setObjectName("WindowControlBtn")
        self.min_btn.setFixedSize(32, 28)
        self.min_btn.clicked.connect(self._minimize_window)

        self.max_btn = QPushButton("□")
        self.max_btn.setObjectName("WindowControlBtn")
        self.max_btn.setFixedSize(32, 28)
        self.max_btn.clicked.connect(self._toggle_maximize)

        self.close_btn = QPushButton("✕")
        self.close_btn.setObjectName("WindowControlBtnClose")
        self.close_btn.setFixedSize(32, 28)
        self.close_btn.clicked.connect(self._close_window)

        layout.addWidget(self.min_btn)
        layout.addWidget(self.max_btn)
        layout.addWidget(self.close_btn)

    def set_project_title(self, name: str):
        if name:
            self.title_label.setText(f"exe/tow  •  {name}")
        else:
            self.title_label.setText("exe/tow - Desktop Python Compiler")

    def _minimize_window(self):
        if self.parent_window:
            self.parent_window.showMinimized()

    def _toggle_maximize(self):
        if self.parent_window:
            if self.parent_window.isMaximized():
                self.parent_window.showNormal()
                self.max_btn.setText("□")
            else:
                self.parent_window.showMaximized()
                self.max_btn.setText("❐")

    def _close_window(self):
        if self.parent_window:
            self.parent_window.close()

    def mousePressEvent(self, event):
        if event.button() == Qt.LeftButton:
            self.drag_position = event.globalPosition().toPoint() - self.parent_window.frameGeometry().topLeft()
            event.accept()

    def mouseMoveEvent(self, event):
        if event.buttons() == Qt.LeftButton and self.parent_window:
            self.parent_window.move(event.globalPosition().toPoint() - self.drag_position)
            event.accept()
