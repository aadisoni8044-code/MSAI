"""NV Studio Status Bar"""
from PyQt6.QtWidgets import QLabel, QStatusBar, QWidget


class StatusBar(QStatusBar):
    """Bottom status bar displaying file metadata, encoding, cursor position, and editor state."""

    def __init__(self, parent=None):
        super().__init__(parent)

        self.file_info_lbl = QLabel("Ready")
        self.cursor_lbl = QLabel("Ln 1, Col 1")
        self.indent_lbl = QLabel("Spaces: 4")
        self.encoding_lbl = QLabel("UTF-8")
        self.filetype_lbl = QLabel("PLAIN TEXT")

        self.addWidget(self.file_info_lbl, stretch=1)
        self.addPermanentWidget(self.cursor_lbl)
        self.addPermanentWidget(self.indent_lbl)
        self.addPermanentWidget(self.encoding_lbl)
        self.addPermanentWidget(self.filetype_lbl)

    def set_cursor_position(self, line: int, col: int) -> None:
        self.cursor_lbl.setText(f"Ln {line}, Col {col}")

    def set_file_type(self, filetype: str) -> None:
        self.filetype_lbl.setText(filetype.upper())

    def set_status_message(self, msg: str) -> None:
        self.file_info_lbl.setText(msg)
