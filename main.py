#!/usr/bin/env python3
"""
PyCodeStudio - Cross-Platform Code Editor App (Python)
Entry point application launcher.
"""

import sys
from pathlib import Path

from PyQt6.QtCore import QTimer, Qt
from PyQt6.QtGui import QFontDatabase, QIcon
from PyQt6.QtWidgets import QApplication

from app.main_window import MainWindow
from app.splash_screen import AppSplashScreen
from utils.logger import logger


def load_custom_fonts() -> None:
    """Registers TTF/OTF fonts located in assets/fonts directory."""
    fonts_dir = Path(__file__).parent / "assets" / "fonts"
    if fonts_dir.exists():
        for font_file in fonts_dir.glob("*.[tT][tT][fF]"):
            font_id = QFontDatabase.addApplicationFont(str(font_file))
            if font_id != -1:
                families = QFontDatabase.applicationFontFamilies(font_id)
                logger.info(f"Loaded custom font: {families}")


def main() -> None:
    """App entry point initialization routine."""
    # Enable High-DPI scaling
    QApplication.setHighDpiScaleFactorRoundingPolicy(
        Qt.HighDpiScaleFactorRoundingPolicy.PassThrough
    )

    app = QApplication(sys.argv)
    app.setApplicationName("PyCodeStudio")
    app.setOrganizationName("PyCodeStudio")
    app.setApplicationVersion("1.0.0")

    # Set Application Icon
    icon_path = Path(__file__).parent / "assets" / "app_icon.png"
    if icon_path.exists():
        app.setWindowIcon(QIcon(str(icon_path)))

    # Display Splash Screen
    splash = AppSplashScreen()
    splash.show()
    app.processEvents()

    # Load custom fonts
    load_custom_fonts()

    # Create Main Window
    main_window = MainWindow()

    # Close Splash Screen and show Main Window
    def show_main():
        splash.finish(main_window)
        main_window.show()

    QTimer.singleShot(1200, show_main)

    sys.exit(app.exec())


if __name__ == "__main__":
    main()
