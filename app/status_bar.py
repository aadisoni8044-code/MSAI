"""
Status bar component for PyCodeStudio.
"""

from PyQt6.QtWidgets import QLabel, QStatusBar


class AppStatusBar(QStatusBar):
    """VS Code style status bar showing position, encoding, language mode, and tabs/spaces."""

    def __init__(self, parent=None):
        super().__init__(parent)

        self.lbl_position = QLabel("Ln 1, Col 1")
        self.lbl_spaces = QLabel("Spaces: 4")
        self.lbl_encoding = QLabel("UTF-8")
        self.lbl_language = QLabel("Python")

        for lbl in (self.lbl_position, self.lbl_spaces, self.lbl_encoding, self.lbl_language):
            lbl.setStyleSheet("padding: 0 8px; color: #ffffff;")

        self.addPermanentWidget(self.lbl_position)
        self.addPermanentWidget(self.lbl_spaces)
        self.addPermanentWidget(self.lbl_encoding)
        self.addPermanentWidget(self.lbl_language)

        self.showMessage("Ready")

    def update_cursor_position(self, line: int, col: int) -> None:
        """Updates line and column display."""
        self.lbl_position.setText(f"Ln {line}, Col {col}")

    def update_file_info(self, language: str = "Plain Text", encoding: str = "UTF-8", tab_size: int = 4, use_spaces: bool = True) -> None:
        """Updates file language, encoding, and tab configuration."""
        self.lbl_language.setText(language.title())
        self.lbl_encoding.setText(encoding.upper())
        indent_type = "Spaces" if use_spaces else "Tabs"
        self.lbl_spaces.setText(f"{indent_type}: {tab_size}")
