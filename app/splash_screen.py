"""
Application startup splash screen for PyCodeStudio.
"""

from PyQt6.QtCore import Qt
from PyQt6.QtGui import QColor, QFont, QPainter, QPixmap
from PyQt6.QtWidgets import QSplashScreen


class AppSplashScreen(QSplashScreen):
    """Polished startup splash screen displayed on launch."""

    def __init__(self):
        pixmap = QPixmap(420, 260)
        pixmap.fill(QColor("#1e1e1e"))

        painter = QPainter(pixmap)
        painter.setRenderHint(QPainter.RenderHint.Antialiasing)

        # Background card border
        painter.setPen(QColor("#007acc"))
        painter.setBrush(Qt.BrushStyle.NoBrush)
        painter.drawRect(0, 0, 419, 259)

        # Title
        title_font = QFont("Segoe UI", 24, QFont.Weight.Bold)
        painter.setFont(title_font)
        painter.setPen(QColor("#ffffff"))
        painter.drawText(30, 80, "PyCodeStudio")

        # Subtitle
        sub_font = QFont("Segoe UI", 12)
        painter.setFont(sub_font)
        painter.setPen(QColor("#007acc"))
        painter.drawText(30, 110, "Cross-Platform Python IDE")

        # Version & Loading text
        ver_font = QFont("Segoe UI", 10)
        painter.setFont(ver_font)
        painter.setPen(QColor("#888888"))
        painter.drawText(30, 200, "Version 1.0.0")
        painter.drawText(30, 225, "Loading modules and initializing UI...")

        painter.end()

        super().__init__(pixmap, Qt.WindowType.WindowStaysOnTopHint)
