"""NV Studio Application Entry Point"""
import sys
import traceback
from PyQt6.QtCore import Qt
from PyQt6.QtWidgets import QApplication, QMessageBox

from nvstudio.ui.main_window import MainWindow


def main():
    """Launch NV Studio Desktop IDE Application."""
    app = QApplication(sys.argv)
    app.setApplicationName("NV Studio")
    app.setOrganizationName("NVStudio")

    def handle_exception(exc_type, exc_value, exc_traceback):
        if issubclass(exc_type, KeyboardInterrupt):
            sys.__excepthook__(exc_type, exc_value, exc_traceback)
            return
        err_msg = "".join(traceback.format_exception(exc_type, exc_value, exc_traceback))
        print(f"[NV Studio Error Uncaught]: {err_msg}", file=sys.stderr)

    sys.excepthook = handle_exception

    window = MainWindow()
    window.show()

    sys.exit(app.exec())


if __name__ == "__main__":
    main()
