import os
from PySide6.QtWidgets import QWidget, QHBoxLayout, QLabel, QPushButton, QFrame
from PySide6.QtCore import Qt, QPoint
from PySide6.QtGui import QPixmap, QIcon

class TitleBar(QFrame):
    """Custom dark title bar with branding, status LED, and native window control buttons."""

    def __init__(self, parent=None, logo_path: str = "assets/logo.png"):
        super().__init__(parent)
        self.parent_window = parent
        self.drag_position = QPoint()
        self.is_dragging = False

        self.setFixedHeight(42)
        self.setStyleSheet("""
            TitleBar {
                background-color: #0B0D12;
                border-bottom: 1px solid #1A1E28;
            }
            QLabel {
                background: transparent;
            }
            QPushButton.windowControlBtn {
                background: transparent;
                border: none;
                color: #8A8F9E;
                font-size: 14px;
                font-weight: bold;
                border-radius: 4px;
                padding: 4px 10px;
            }
            QPushButton.windowControlBtn:hover {
                background-color: #1A1E28;
                color: #FFFFFF;
            }
            QPushButton.closeBtn:hover {
                background-color: #E53E3E;
                color: #FFFFFF;
            }
        """)

        layout = QHBoxLayout(self)
        layout.setContentsMargins(12, 0, 8, 0)
        layout.setSpacing(10)

        # Logo image
        self.logo_label = QLabel()
        if os.path.exists(logo_path):
            pixmap = QPixmap(logo_path)
            if not pixmap.isNull():
                self.logo_label.setPixmap(pixmap.scaled(28, 20, Qt.KeepAspectRatio, Qt.SmoothTransformation))
        layout.addWidget(self.logo_label)

        # Application Title
        title_label = QLabel("EXE/TOW")
        title_label.setStyleSheet("color: #FFFFFF; font-weight: 800; font-size: 14px; letter-spacing: 1px;")
        layout.addWidget(title_label)

        # Status Badge
        status_dot = QLabel("●")
        status_dot.setStyleSheet("color: #00FF66; font-size: 10px; margin-left: 10px;")
        layout.addWidget(status_dot)

        status_text = QLabel("READY")
        status_text.setStyleSheet("""
            color: #00FF66;
            font-size: 10px;
            font-weight: 800;
            background-color: #0B2B1B;
            border: 1px solid #00FF66;
            border-radius: 3px;
            padding: 2px 6px;
        """)
        layout.addWidget(status_text)

        layout.addStretch()

        # Window Control Buttons
        min_btn = QPushButton("─")
        min_btn.setProperty("class", "windowControlBtn")
        min_btn.setToolTip("Minimize")
        min_btn.clicked.connect(self.minimize_window)
        layout.addWidget(min_btn)

        self.max_btn = QPushButton("□")
        self.max_btn.setProperty("class", "windowControlBtn")
        self.max_btn.setToolTip("Maximize / Restore")
        self.max_btn.clicked.connect(self.toggle_maximize)
        layout.addWidget(self.max_btn)

        close_btn = QPushButton("✕")
        close_btn.setStyleSheet("""
            QPushButton {
                background: transparent;
                border: none;
                color: #8A8F9E;
                font-size: 14px;
                font-weight: bold;
                border-radius: 4px;
                padding: 4px 12px;
            }
            QPushButton:hover {
                background-color: #E53E3E;
                color: #FFFFFF;
            }
        """)
        close_btn.setToolTip("Close")
        close_btn.clicked.connect(self.close_window)
        layout.addWidget(close_btn)

    def minimize_window(self):
        if self.parent_window:
            self.parent_window.showMinimized()

    def toggle_maximize(self):
        if self.parent_window:
            if self.parent_window.isMaximized():
                self.parent_window.showNormal()
                self.max_btn.setText("□")
            else:
                self.parent_window.showMaximized()
                self.max_btn.setText("❐")

    def close_window(self):
        if self.parent_window:
            self.parent_window.close()

    def mousePressEvent(self, event):
        if event.button() == Qt.LeftButton and self.parent_window:
            self.is_dragging = True
            self.drag_position = event.globalPosition().toPoint() - self.parent_window.frameGeometry().topLeft()
            event.accept()

    def mouseMoveEvent(self, event):
        if self.is_dragging and self.parent_window and event.buttons() == Qt.LeftButton:
            self.parent_window.move(event.globalPosition().toPoint() - self.drag_position)
            event.accept()

    def mouseReleaseEvent(self, event):
        self.is_dragging = False
