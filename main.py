import sys
import os
from PySide6.QtWidgets import QApplication
from PySide6.QtCore import Qt

from exe_tow.ui.main_window import MainWindow

def main():
    # Enable High DPI scaling
    QApplication.setHighDpiScaleFactorRoundingPolicy(Qt.HighDpiScaleFactorRoundingPolicy.PassThrough)

    app = QApplication(sys.argv)
    app.setApplicationName("exe/tow")
    app.setOrganizationName("exe_tow")

    logo_path = os.path.join(os.path.dirname(__file__), "assets", "logo.png")

    window = MainWindow(logo_path=logo_path)
    window.show()

    sys.exit(app.exec())

if __name__ == "__main__":
    main()
