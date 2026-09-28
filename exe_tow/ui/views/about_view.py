"""
exe/tow - About View
Displays exe/tow brand visual identity, developer documentation, version info,
and system runtime environment details.
"""

import os
import platform
import sys
import PySide6
from PySide6.QtCore import Qt
from PySide6.QtGui import QPixmap
from PySide6.QtWidgets import (
    QWidget, QVBoxLayout, QHBoxLayout, QLabel, QFrame
)
from exe_tow.ui.theme import ThemeColors

class AboutView(QWidget):
    """About & visual identity documentation view for exe/tow."""

    def __init__(self, logo_path: str = "assets/logo.png", parent=None):
        super().__init__(parent)
        self.logo_path = logo_path

        layout = QVBoxLayout(self)
        layout.setContentsMargins(32, 28, 32, 28)
        layout.setSpacing(24)

        # Main Card
        card = QFrame()
        card.setObjectName("GlassPanel")
        card_layout = QVBoxLayout(card)
        card_layout.setContentsMargins(32, 32, 32, 32)
        card_layout.setSpacing(16)

        # Brand Identity Logo Showcase
        logo_lbl = QLabel()
        logo_lbl.setFixedSize(140, 44)
        logo_lbl.setScaledContents(True)

        if os.path.exists(self.logo_path):
            logo_lbl.setPixmap(QPixmap(self.logo_path))
        else:
            logo_lbl.setText("exe/tow")
            logo_lbl.setStyleSheet("font-size: 24px; font-weight: 800; color: #FFFFFF;")

        card_layout.addWidget(logo_lbl)

        version_lbl = QLabel("exe/tow Commercial Developer Suite v1.0.0")
        version_lbl.setObjectName("SectionTitle")
        card_layout.addWidget(version_lbl)

        desc_lbl = QLabel(
            "exe/tow is a modern developer tool that lets users select a Python project folder, "
            "automatically detect the main Python file and project dependencies, "
            "then build/package the project into a Windows .exe application."
        )
        desc_lbl.setWordWrap(True)
        desc_lbl.setStyleSheet(f"color: {ThemeColors.TEXT_SECONDARY}; font-size: 13px; line-height: 1.5;")
        card_layout.addWidget(desc_lbl)

        card_layout.addSpacing(16)

        # Runtime Info Section
        runtime_title = QLabel("RUNTIME & ENVIRONMENT")
        runtime_title.setStyleSheet(f"color: {ThemeColors.TEXT_MUTED}; font-size: 10px; font-weight: 700; letter-spacing: 1px;")
        card_layout.addWidget(runtime_title)

        info_box = QFrame()
        info_box.setStyleSheet(f"background-color: {ThemeColors.BG_INPUT}; border-radius: 8px; padding: 16px;")
        info_layout = QVBoxLayout(info_box)
        info_layout.setSpacing(8)

        sys_info = [
            f"<b>Application Brand:</b> exe/tow",
            f"<b>Python Version:</b> {platform.python_version()} ({sys.executable})",
            f"<b>PySide6 UI Framework:</b> {PySide6.__version__}",
            f"<b>Operating System:</b> {platform.system()} {platform.release()} ({platform.architecture()[0]})",
            f"<b>Build Engine:</b> PyInstaller / Nuitka Direct Compiler"
        ]

        for item in sys_info:
            lbl = QLabel(item)
            lbl.setStyleSheet(f"color: {ThemeColors.TEXT_PRIMARY}; font-size: 12px;")
            info_layout.addWidget(lbl)

        card_layout.addWidget(info_box)

        layout.addWidget(card)
        layout.addStretch()
