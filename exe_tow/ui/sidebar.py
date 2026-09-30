import os
from PySide6.QtWidgets import QWidget, QVBoxLayout, QHBoxLayout, QLabel, QPushButton, QFrame, QButtonGroup
from PySide6.QtCore import Qt, Signal, QSize
from PySide6.QtGui import QPixmap

NAV_ITEMS = [
    ("dashboard", "⌂", "Dashboard"),
    ("build", "▣", "Build EXE"),
    ("projects", "◈", "Projects"),
    ("history", "▤", "Build History"),
    ("settings", "⚙", "Settings"),
    ("about", "ⓘ", "About")
]

class NavButton(QPushButton):
    """Custom sidebar button with active indicator bar and green highlight styling."""

    def __init__(self, key: str, icon_str: str, text: str, parent=None):
        super().__init__(parent)
        self.key = key
        self.setCheckable(True)
        self.setFixedHeight(44)
        self.setCursor(Qt.PointingHandCursor)

        layout = QHBoxLayout(self)
        layout.setContentsMargins(0, 0, 16, 0)
        layout.setSpacing(12)

        # Left indicator bar
        self.indicator = QFrame()
        self.indicator.setFixedWidth(4)
        self.indicator.setFixedHeight(24)
        self.indicator.setStyleSheet("background-color: transparent; border-radius: 2px;")
        layout.addWidget(self.indicator)

        # Icon label
        self.icon_label = QLabel(icon_str)
        self.icon_label.setFixedWidth(24)
        self.icon_label.setAlignment(Qt.AlignCenter)
        self.icon_label.setStyleSheet("font-size: 16px; color: #8A8F9E; background: transparent;")
        layout.addWidget(self.icon_label)

        # Text label
        self.text_label = QLabel(text)
        self.text_label.setStyleSheet("font-size: 13px; font-weight: 600; color: #8A8F9E; background: transparent;")
        layout.addWidget(self.text_label)

        layout.addStretch()
        self.update_style(False)

    def update_style(self, checked: bool):
        if checked:
            self.setStyleSheet("""
                NavButton {
                    background-color: #11291B;
                    border: none;
                    border-radius: 6px;
                }
            """)
            self.indicator.setStyleSheet("background-color: #00FF66; border-radius: 2px;")
            self.icon_label.setStyleSheet("font-size: 16px; color: #00FF66; background: transparent;")
            self.text_label.setStyleSheet("font-size: 13px; font-weight: 700; color: #FFFFFF; background: transparent;")
        else:
            self.setStyleSheet("""
                NavButton {
                    background-color: transparent;
                    border: none;
                    border-radius: 6px;
                }
                NavButton:hover {
                    background-color: #161922;
                }
            """)
            self.indicator.setStyleSheet("background-color: transparent; border-radius: 2px;")
            self.icon_label.setStyleSheet("font-size: 16px; color: #8A8F9E; background: transparent;")
            self.text_label.setStyleSheet("font-size: 13px; font-weight: 600; color: #8A8F9E; background: transparent;")

class Sidebar(QFrame):
    """Compact vertical navigation sidebar with logo header, navigation items, and system status."""

    page_changed = Signal(str)

    def __init__(self, parent=None, logo_path: str = "assets/logo.png"):
        super().__init__(parent)
        self.setFixedWidth(220)
        self.setStyleSheet("""
            Sidebar {
                background-color: #0E1015;
                border-right: 1px solid #1A1E28;
            }
        """)

        layout = QVBoxLayout(self)
        layout.setContentsMargins(12, 16, 12, 16)
        layout.setSpacing(8)

        # Top Logo Branding
        brand_layout = QHBoxLayout()
        brand_layout.setContentsMargins(8, 4, 8, 12)
        brand_layout.setSpacing(10)

        if os.path.exists(logo_path):
            logo_img = QLabel()
            pixmap = QPixmap(logo_path)
            if not pixmap.isNull():
                logo_img.setPixmap(pixmap.scaled(32, 24, Qt.KeepAspectRatio, Qt.SmoothTransformation))
            brand_layout.addWidget(logo_img)

        brand_title = QLabel("exe/tow")
        brand_title.setStyleSheet("font-size: 18px; font-weight: 900; color: #FFFFFF; letter-spacing: 0.5px;")
        brand_layout.addWidget(brand_title)
        brand_layout.addStretch()

        layout.addLayout(brand_layout)

        # Divider line
        divider = QFrame()
        divider.setFrameShape(QFrame.HLine)
        divider.setStyleSheet("color: #1A1E28; background-color: #1A1E28; border: none; height: 1px;")
        layout.addWidget(divider)
        layout.addSpacing(8)

        # Navigation Buttons Group
        self.button_group = QButtonGroup(self)
        self.button_group.setExclusive(True)
        self.nav_buttons = {}

        for key, icon, text in NAV_ITEMS:
            btn = NavButton(key, icon, text)
            btn.toggled.connect(lambda checked, b=btn: b.update_style(checked))
            btn.clicked.connect(lambda _, k=key: self.on_nav_clicked(k))
            self.button_group.addButton(btn)
            self.nav_buttons[key] = btn
            layout.addWidget(btn)

        layout.addStretch()

        # Bottom System Status Panel
        status_box = QFrame()
        status_box.setStyleSheet("""
            QFrame {
                background-color: #12151D;
                border: 1px solid #1C202C;
                border-radius: 8px;
                padding: 10px;
            }
        """)
        status_layout = QVBoxLayout(status_box)
        status_layout.setContentsMargins(10, 10, 10, 10)
        status_layout.setSpacing(6)

        status_header = QLabel("SYSTEM STATUS")
        status_header.setStyleSheet("font-size: 10px; font-weight: 800; color: #8A8F9E; letter-spacing: 1px;")
        status_layout.addWidget(status_header)

        # Python Status
        py_status = QHBoxLayout()
        py_status.setSpacing(6)
        py_dot = QLabel("●")
        py_dot.setStyleSheet("color: #00FF66; font-size: 9px;")
        py_lbl = QLabel("Python")
        py_lbl.setStyleSheet("font-size: 11px; color: #A0A5B5; font-weight: 600;")
        py_val = QLabel("CONNECTED")
        py_val.setStyleSheet("font-size: 10px; color: #00FF66; font-weight: 700;")
        py_status.addWidget(py_dot)
        py_status.addWidget(py_lbl)
        py_status.addStretch()
        py_status.addWidget(py_val)
        status_layout.addLayout(py_status)

        # Build Engine Status
        eng_status = QHBoxLayout()
        eng_status.setSpacing(6)
        eng_dot = QLabel("●")
        eng_dot.setStyleSheet("color: #00FF66; font-size: 9px;")
        eng_lbl = QLabel("Build Engine")
        eng_lbl.setStyleSheet("font-size: 11px; color: #A0A5B5; font-weight: 600;")
        eng_val = QLabel("READY")
        eng_val.setStyleSheet("font-size: 10px; color: #00FF66; font-weight: 700;")
        eng_status.addWidget(eng_dot)
        eng_status.addWidget(eng_lbl)
        eng_status.addStretch()
        eng_status.addWidget(eng_val)
        status_layout.addLayout(eng_status)

        layout.addWidget(status_box)

        # Default select Dashboard
        self.set_active("dashboard")

    def on_nav_clicked(self, key: str):
        self.page_changed.emit(key)

    def set_active(self, key: str):
        if key in self.nav_buttons:
            self.nav_buttons[key].setChecked(True)
