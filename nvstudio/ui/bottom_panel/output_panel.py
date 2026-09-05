"""NV Studio Output Log Panel"""
from PyQt6.QtWidgets import QPlainTextEdit, QVBoxLayout, QWidget
from PyQt6.QtGui import QTextCursor


class OutputPanel(QWidget):
    """Output log panel for build, execution, and system logs."""

    def __init__(self, parent=None):
        super().__init__(parent)

        layout = QVBoxLayout(self)
        layout.setContentsMargins(4, 4, 4, 4)

        self.text_edit = QPlainTextEdit()
        self.text_edit.setReadOnly(True)
        self.text_edit.setStyleSheet("""
            QPlainTextEdit {
                background-color: #0d1117;
                color: #e6edf3;
                font-family: 'Consolas', 'Courier New', monospace;
                font-size: 12px;
                border: none;
            }
        """)
        layout.addWidget(self.text_edit)

        self.append_log("NV Studio IDE Output Stream Initialized.")

    def append_log(self, msg: str) -> None:
        self.text_edit.moveCursor(QTextCursor.MoveOperation.End)
        self.text_edit.insertPlainText(msg + "\n")
        self.text_edit.moveCursor(QTextCursor.MoveOperation.End)

    def clear_log(self) -> None:
        self.text_edit.clear()
