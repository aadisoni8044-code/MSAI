import os
import sys
from PySide6.QtWidgets import QWidget, QVBoxLayout, QHBoxLayout, QLabel, QFrame, QScrollArea
from PySide6.QtCore import Qt
from PySide6.QtGui import QPixmap

class AboutView(QWidget):
    """About View displaying software version, logo, system environment details, and backend specs."""

    def __init__(self, logo_path: str = "assets/logo.png", parent=None):
        super().__init__(parent)

        scroll = QScrollArea(self)
        scroll.setWidgetResizable(True)
        scroll.setStyleSheet("QScrollArea { border: none; background: transparent; }")

        content_widget = QWidget()
        layout = QVBoxLayout(content_widget)
        layout.setContentsMargins(24, 20, 24, 20)
        layout.setSpacing(18)

        # Main Brand Card
        brand_card = QFrame()
        brand_card.setStyleSheet("""
            QFrame {
                background: qlineargradient(x1:0, y1:0, x2:1, y2:1, stop:0 #121520, stop:1 #080A0E);
                border: 1px solid #1C2232;
                border-radius: 10px;
                padding: 24px;
            }
        """)
        b_layout = QHBoxLayout(brand_card)
        b_layout.setSpacing(20)

        if os.path.exists(logo_path):
            logo_lbl = QLabel()
            pixmap = QPixmap(logo_path)
            if not pixmap.isNull():
                logo_lbl.setPixmap(pixmap.scaled(90, 65, Qt.KeepAspectRatio, Qt.SmoothTransformation))
            b_layout.addWidget(logo_lbl)

        info_box = QVBoxLayout()
        info_box.setSpacing(4)

        title = QLabel("exe/tow")
        title.setStyleSheet("font-size: 28px; font-weight: 900; color: #FFFFFF; letter-spacing: 1px;")

        ver = QLabel("VERSION 2.4.0 (STABLE)")
        ver.setStyleSheet("font-size: 11px; font-weight: 800; color: #00FF66; letter-spacing: 2px;")

        desc = QLabel("Professional Python-to-Windows EXE Desktop Application Builder & Packaging Workstation.")
        desc.setStyleSheet("font-size: 13px; color: #A0A5B5; margin-top: 4px;")

        info_box.addWidget(title)
        info_box.addWidget(ver)
        info_box.addWidget(desc)

        b_layout.addLayout(info_box, stretch=1)
        layout.addWidget(brand_card)

        # Specifications Card Grid
        specs_card = QFrame()
        specs_card.setStyleSheet("""
            QFrame {
                background-color: #12141A;
                border: 1px solid #1E222D;
                border-radius: 8px;
                padding: 18px;
            }
        """)
        s_layout = QVBoxLayout(specs_card)
        s_layout.setSpacing(12)

        s_title = QLabel("SYSTEM & ENGINE SPECIFICATIONS")
        s_title.setStyleSheet("font-size: 12px; font-weight: 800; color: #00E5FF; letter-spacing: 1px;")
        s_layout.addWidget(s_title)

        grid = QVBoxLayout()
        grid.setSpacing(8)

        py_ver_str = f"{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}"
        self._add_spec_row("PYTHON RUNTIME", f"v{py_ver_str} ({sys.executable})", grid)
        self._add_spec_row("BUILD BACKEND", "PyInstaller 6.x / Automatic Dependency Collector", grid)
        self._add_spec_row("UI FRAMEWORK", "PySide6 (Qt for Python 6.x)", grid)
        self._add_spec_row("PLATFORM", f"{sys.platform.upper()} (64-bit Workstation Environment)", grid)
        self._add_spec_row("BRANDING", "exe/tow Dark Hacker Workstation Identity", grid)

        s_layout.addLayout(grid)
        layout.addWidget(specs_card)

        layout.addStretch()

        scroll.setWidget(content_widget)

        main_layout = QVBoxLayout(self)
        main_layout.setContentsMargins(0, 0, 0, 0)
        main_layout.addWidget(scroll)

    def _add_spec_row(self, key: str, val: str, parent_layout):
        row = QHBoxLayout()
        k_lbl = QLabel(key)
        k_lbl.setStyleSheet("font-size: 11px; font-weight: 800; color: #8A8F9E; width: 140px;")
        k_lbl.setFixedWidth(150)

        v_lbl = QLabel(val)
        v_lbl.setStyleSheet("font-size: 12px; font-weight: 700; color: #FFFFFF; font-family: Consolas, monospace;")

        row.addWidget(k_lbl)
        row.addWidget(v_lbl)
        row.addStretch()

        parent_layout.addLayout(row)
