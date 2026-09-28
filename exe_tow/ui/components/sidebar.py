from PySide6.QtWidgets import QWidget, QVBoxLayout, QPushButton, QLabel, QFrame, QHBoxLayout
from PySide6.QtCore import Qt, Signal
from exe_tow.ui.theme import Theme

class LogoBadge(QFrame):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setStyleSheet(f"""
            QFrame {{
                background-color: #000000;
                border: 1px solid {Theme.SURFACE_BORDER};
                border-radius: 12px;
                padding: 12px;
            }}
        """)
        layout = QHBoxLayout(self)
        layout.setContentsMargins(12, 10, 12, 10)
        layout.setAlignment(Qt.AlignCenter)

        label = QLabel("exe/tow")
        label.setStyleSheet("""
            QLabel {
                color: #FFFFFF;
                font-size: 22px;
                font-weight: 900;
                font-family: 'Segoe UI', sans-serif;
                letter-spacing: -0.5px;
            }
        """)
        layout.addWidget(label)

class Sidebar(QWidget):
    nav_changed = Signal(str)  # Emits target view key

    def __init__(self, parent=None):
        super().__init__(parent)
        self.setFixedWidth(240)
        self.setStyleSheet(f"""
            QWidget {{
                background-color: {Theme.SURFACE_DARK};
                border-right: 1px solid {Theme.SURFACE_BORDER};
            }}
        """)

        layout = QVBoxLayout(self)
        layout.setContentsMargins(16, 20, 16, 20)
        layout.setSpacing(12)

        # Logo Badge Header
        self.logo = LogoBadge(self)
        layout.addWidget(self.logo)

        tagline = QLabel("Python to Windows EXE")
        tagline.setObjectName("secondary")
        tagline.setAlignment(Qt.AlignCenter)
        tagline.setStyleSheet("font-size: 11px; margin-bottom: 12px;")
        layout.addWidget(tagline)

        # Navigation Buttons
        self.nav_buttons = {}
        nav_items = [
            ("dashboard", "Dashboard"),
            ("build", "Build EXE"),
            ("projects", "Projects"),
            ("cmd_history", "Command History"),
            ("build_history", "Build History"),
            ("settings", "Settings")
        ]

        for key, label in nav_items:
            btn = QPushButton(f"  {label}")
            btn.setCheckable(True)
            btn.setCursor(Qt.PointingHandCursor)
            btn.setStyleSheet(f"""
                QPushButton {{
                    background-color: transparent;
                    color: {Theme.TEXT_SECONDARY};
                    border: none;
                    border-radius: 6px;
                    padding: 10px 14px;
                    text-align: left;
                    font-size: 13px;
                    font-weight: 600;
                }}
                QPushButton:hover {{
                    background-color: {Theme.SURFACE_HOVER};
                    color: {Theme.TEXT_PRIMARY};
                }}
                QPushButton:checked {{
                    background-color: {Theme.ACCENT_PRIMARY};
                    color: #FFFFFF;
                }}
            """)
            btn.clicked.connect(lambda checked=False, k=key: self._on_nav_clicked(k))
            layout.addWidget(btn)
            self.nav_buttons[key] = btn

        layout.addStretch()

        # Footer Version Label
        ver_lbl = QLabel("EXE/TOW v1.0.0")
        ver_lbl.setObjectName("secondary")
        ver_lbl.setAlignment(Qt.AlignCenter)
        ver_lbl.setStyleSheet("font-size: 11px; opacity: 0.7;")
        layout.addWidget(ver_lbl)

        # Set default selection
        self.set_active("dashboard")

    def _on_nav_clicked(self, key: str):
        self.set_active(key)
        self.nav_changed.emit(key)

    def set_active(self, active_key: str):
        for key, btn in self.nav_buttons.items():
            btn.setChecked(key == active_key)
