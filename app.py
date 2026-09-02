"""
MSAI Studio - App Entry Initializer
"""
import sys
from PyQt6.QtWidgets import QApplication
from ui.main_window import MainWindow

def run_app():
    """Initializes QApplication and launches MSAI Studio Main Window."""
    app = QApplication(sys.argv)
    app.setApplicationName("MSAI Studio")
    app.setStyle("Fusion")

    window = MainWindow()
    window.show()

    return app.exec()
