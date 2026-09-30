import os
from PySide6.QtWidgets import (
    QWidget, QHBoxLayout, QLabel, QPushButton, QFrame, QSizePolicy
)
from PySide6.QtCore import Qt, Signal, QPoint
from PySide6.QtGui import QPixmap, QIcon, QFont, QCursor

class TitleBar(QFrame):
    minimize_requested = Signal()
    maximize_requested = Signal()
    close_requested = Signal()

    def __init__(self, parent=None, logo_path: str = ""):
        super().__init__(parent)
        self.parent_window = parent
        self.drag_position = QPoint()
        self.setFixedHeight(46)
        self.setStyleSheet("""
            TitleBar {
                background-color: #090A0D;
                border-bottom: 1px solid #1E2230;
            }
            QPushButton.title-btn {
                background-color: transparent;
                border: none;
                color: #94A3B8;
                font-size: 14px;
                font-weight: bold;
                width: 38px;
                height: 28px;
                border-radius: 4px;
            }
            QPushButton.title-btn:hover {
                background-color: #1E2230;
                color: #FFFFFF;
            }
            QPushButton.title-btn-close:hover {
                background-color: #EF4444;
                color: #FFFFFF;
            }
        """)

        layout = QHBoxLayout(self)
        layout.setContentsMargins(16, 0, 12, 0)
        layout.setSpacing(12)

        # Brand / Logo
        if logo_path and os.path.exists(logo_path):
            self.logo_label = QLabel()
            pixmap = QPixmap(logo_path)
            # Maintain aspect ratio, max height 22px
            self.logo_label.setPixmap(pixmap.scaledToHeight(22, Qt.SmoothTransformation))
            layout.addWidget(self.logo_label)
        else:
            self.title_logo_fallback = QLabel("exe/tow")
            self.title_logo_fallback.setFont(QFont("Segoe UI", 13, QFont.Bold))
            self.title_logo_fallback.setStyleSheet("color: #FFFFFF;")
            layout.addWidget(self.title_logo_fallback)

        # Separator dot
        sep = QLabel("•")
        sep.setStyleSheet("color: #33394B; font-size: 14px;")
        layout.addWidget(sep)

        # Application Title
        self.title_label = QLabel("exe/tow Builder")
        self.title_label.setFont(QFont("Segoe UI", 11, QFont.Medium))
        self.title_label.setStyleSheet("color: #94A3B8;")
        layout.addWidget(self.title_label)

        # Small Status Indicator
        self.status_badge = QFrame()
        self.status_badge.setFixedHeight(22)
        self.status_badge.setStyleSheet("""
            QFrame {
                background-color: #121E19;
                border: 1px solid #1A3D2E;
                border-radius: 11px;
                padding-left: 8px;
                padding-right: 10px;
            }
        """)
        status_layout = QHBoxLayout(self.status_badge)
        status_layout.setContentsMargins(8, 0, 8, 0)
        status_layout.setSpacing(6)

        self.status_dot = QLabel("●")
        self.status_dot.setStyleSheet("color: #10B981; font-size: 9px;")
        self.status_text = QLabel("Ready")
        self.status_text.setFont(QFont("Segoe UI", 10, QFont.Medium))
        self.status_text.setStyleSheet("color: #34D399;")

        status_layout.addWidget(self.status_dot)
        status_layout.addWidget(self.status_text)

        layout.addWidget(self.status_badge)
        layout.addStretch()

        # Window Control Buttons
        btn_min = QPushButton("─")
        btn_min.setObjectName("btn_min")
        btn_min.setToolTip("Minimize")
        btn_min.setCursor(QCursor(Qt.PointingHandCursor))
        btn_min.setProperty("class", "title-btn")
        btn_min.setStyleSheet("background-color: transparent; border: none; color: #94A3B8; font-size: 12px;")
        btn_min.clicked.connect(self.minimize_requested.emit)

        btn_max = QPushButton("☐")
        btn_max.setObjectName("btn_max")
        btn_max.setToolTip("Maximize / Restore")
        btn_max.setCursor(QCursor(Qt.PointingHandCursor))
        btn_max.setStyleSheet("background-color: transparent; border: none; color: #94A3B8; font-size: 12px;")
        btn_max.clicked.connect(self.maximize_requested.emit)

        btn_close = QPushButton("✕")
        btn_close.setObjectName("btn_close")
        btn_close.setToolTip("Close")
        btn_close.setCursor(QCursor(Qt.PointingHandCursor))
        btn_close.setStyleSheet("""
            QPushButton { background-color: transparent; border: none; color: #94A3B8; font-size: 13px; font-weight: bold; width: 32px; height: 28px; border-radius: 4px; }
            QPushButton:hover { background-color: #EF4444; color: #FFFFFF; }
        """)
        btn_close.clicked.connect(self.close_requested.emit)

        layout.addWidget(btn_min)
        layout.addWidget(btn_max)
        layout.addWidget(btn_close)

    def set_status(self, text: str, state: str = "ready"):
        self.status_text.setText(text)
        if state == "building":
            self.status_badge.setStyleSheet("QFrame { background-color: #1C1912; border: 1px solid #4D3813; border-radius: 11px; }")
            self.status_dot.setStyleSheet("color: #F59E0B; font-size: 9px;")
            self.status_text.setStyleSheet("color: #FBBF24;")
        elif state == "error":
            self.status_badge.setStyleSheet("QFrame { background-color: #211214; border: 1px solid #4D1A1F; border-radius: 11px; }")
            self.status_dot.setStyleSheet("color: #EF4444; font-size: 9px;")
            self.status_text.setStyleSheet("color: #F87171;")
        else:
            self.status_badge.setStyleSheet("QFrame { background-color: #121E19; border: 1px solid #1A3D2E; border-radius: 11px; }")
            self.status_dot.setStyleSheet("color: #10B981; font-size: 9px;")
            self.status_text.setStyleSheet("color: #34D399;")

    def mousePressEvent(self, event):
        if event.button() == Qt.LeftButton:
            self.drag_position = event.globalPosition().toPoint() - self.parent_window.frameGeometry().topLeft()
            event.accept()

    def mouseMoveEvent(self, event):
        if event.buttons() == Qt.LeftButton and self.parent_window and not self.parent_window.isMaximized():
            self.parent_window.move(event.globalPosition().toPoint() - self.drag_position)
            event.accept()
