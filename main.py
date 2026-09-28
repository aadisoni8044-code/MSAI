"""
exe/tow - Python to EXE Desktop Compiler
Main entry point for launching the PySide6 Windows desktop application.
"""

import os
import sys
from PySide6.QtWidgets import QApplication
from PySide6.QtGui import QIcon, QFont

from exe_tow.core.settings import SettingsManager
from exe_tow.core.history import HistoryManager
from exe_tow.ui.main_window import MainWindow

def main():
    app = QApplication(sys.argv)
    app.setApplicationName("exe/tow")
    app.setOrganizationName("exe/tow")

    # Set default high DPI scaling attributes
    if hasattr(app, "setStyle"):
        app.setStyle("Fusion")

    logo_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "assets", "logo.png"))
    if os.path.exists(logo_path):
        app.setWindowIcon(QIcon(logo_path))

    settings_manager = SettingsManager()
    history_manager = HistoryManager()

    window = MainWindow(settings_manager, history_manager, logo_path=logo_path)
    window.show()

    sys.exit(app.exec())

if __name__ == "__main__":
    main()
