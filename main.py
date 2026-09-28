import sys
from PySide6.QtWidgets import QApplication
from exe_tow.ui.theme import Theme
from exe_tow.ui.app_window import MainWindow

def main():
    app = QApplication(sys.argv)
    app.setApplicationName("EXE/TOW")
    app.setStyle("Fusion")
    app.setStyleSheet(Theme.STYLE_SHEET)

    window = MainWindow()
    window.show()

    sys.exit(app.exec())

if __name__ == "__main__":
    main()
