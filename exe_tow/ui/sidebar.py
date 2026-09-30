from PySide6.QtWidgets import (
    QWidget, QVBoxLayout, QPushButton, QLabel, QFrame, QSizePolicy
)
from PySide6.QtCore import Qt, Signal
from PySide6.QtGui import QFont, QCursor

class Sidebar(QFrame):
    navigation_changed = Signal(str)  # View route name

    NAV_ITEMS = [
        ("Dashboard", "dashboard", "⚡"),
        ("Build EXE", "build_exe", "📦"),
        ("Projects", "projects", "📁"),
        ("Build History", "history", "📜"),
        ("Settings", "settings", "⚙️"),
        ("About", "about", "ℹ️"),
    ]

    def __init__(self, parent=None):
        super().__init__(parent)
        self.setFixedWidth(230)
        self.setStyleSheet("""
            Sidebar {
                background-color: #0D0F15;
                border-right: 1px solid #1B1E2B;
            }
        """)

        layout = QVBoxLayout(self)
        layout.setContentsMargins(12, 20, 12, 20)
        layout.setSpacing(6)

        # Category Header
        header = QLabel("NAVIGATION")
        header.setFont(QFont("Segoe UI", 9, QFont.Bold))
        header.setStyleSheet("color: #475569; padding-left: 12px; margin-bottom: 8px; letter-spacing: 1px;")
        layout.addWidget(header)

        self.buttons = {}
        for title, key, icon in self.NAV_ITEMS:
            btn = QPushButton(f"  {icon}   {title}")
            btn.setFont(QFont("Segoe UI", 10, QFont.Medium))
            btn.setCursor(QCursor(Qt.PointingHandCursor))
            btn.setCheckable(True)
            btn.setFixedHeight(40)
            btn.setStyleSheet("""
                QPushButton {
                    text-align: left;
                    padding-left: 14px;
                    background-color: transparent;
                    border: 1px solid transparent;
                    border-radius: 8px;
                    color: #94A3B8;
                }
                QPushButton:hover {
                    background-color: #161924;
                    color: #F8FAFC;
                }
                QPushButton:checked {
                    background-color: #1E293B;
                    border: 1px solid #3B82F6;
                    color: #3B82F6;
                    font-weight: bold;
                }
            """)
            btn.clicked.connect(lambda checked=False, k=key: self.select_nav(k))
            layout.addWidget(btn)
            self.buttons[key] = btn

        layout.addStretch()

        # Bottom info badge
        bottom_box = QFrame()
        bottom_box.setStyleSheet("""
            QFrame {
                background-color: #121520;
                border: 1px solid #1E2232;
                border-radius: 8px;
                padding: 10px;
            }
        """)
        bbox_layout = QVBoxLayout(bottom_box)
        bbox_layout.setContentsMargins(8, 8, 8, 8)
        bbox_layout.setSpacing(4)

        lbl_engine = QLabel("Engine: PyInstaller")
        lbl_engine.setFont(QFont("Segoe UI", 8, QFont.Bold))
        lbl_engine.setStyleSheet("color: #94A3B8;")

        lbl_ver = QLabel("exe/tow v1.0.0 Pro")
        lbl_ver.setFont(QFont("Segoe UI", 8))
        lbl_ver.setStyleSheet("color: #64748B;")

        bbox_layout.addWidget(lbl_engine)
        bbox_layout.addWidget(lbl_ver)

        layout.addWidget(bottom_box)

        # Set default active item
        self.select_nav("dashboard")

    def select_nav(self, route_key: str):
        for key, btn in self.buttons.items():
            btn.setChecked(key == route_key)
        self.navigation_changed.emit(route_key)
