"""NV Studio Debug Interactive REPL Console Panel"""
import sys
import io
import traceback
from PyQt6.QtCore import Qt
from PyQt6.QtGui import QTextCursor
from PyQt6.QtWidgets import QHBoxLayout, QLineEdit, QPlainTextEdit, QPushButton, QVBoxLayout, QWidget


class DebugConsolePanel(QWidget):
    """Interactive Python REPL Debug Console."""

    def __init__(self, parent=None):
        super().__init__(parent)

        layout = QVBoxLayout(self)
        layout.setContentsMargins(4, 4, 4, 4)
        layout.setSpacing(4)

        self.output = QPlainTextEdit()
        self.output.setReadOnly(True)
        self.output.setStyleSheet("""
            QPlainTextEdit {
                background-color: #0d1117;
                color: #e6edf3;
                font-family: 'Consolas', 'Courier New', monospace;
                font-size: 12px;
                border: none;
            }
        """)
        layout.addWidget(self.output)

        input_row = QHBoxLayout()
        self.input_field = QLineEdit()
        self.input_field.setPlaceholderText("Evaluate Python expression or statement (e.g. 2 + 2, import sys; sys.version)...")
        self.input_field.returnPressed.connect(self.eval_code)

        input_row.addWidget(self.input_field)
        layout.addLayout(input_row)

        self.locals_dict = {}
        self.append_output("NV Studio Debug Console REPL. Ready.")

    def append_output(self, text: str) -> None:
        self.output.moveCursor(QTextCursor.MoveOperation.End)
        self.output.insertPlainText(text + "\n")
        self.output.moveCursor(QTextCursor.MoveOperation.End)

    def eval_code(self) -> None:
        code_str = self.input_field.text().strip()
        if not code_str:
            return

        self.input_field.clear()
        self.append_output(f">>> {code_str}")

        buffer = io.StringIO()
        old_stdout = sys.stdout
        sys.stdout = buffer

        try:
            try:
                res = eval(code_str, globals(), self.locals_dict)
                sys.stdout = old_stdout
                if res is not None:
                    self.append_output(repr(res))
            except SyntaxError:
                exec(code_str, globals(), self.locals_dict)
                sys.stdout = old_stdout
                out = buffer.getvalue()
                if out:
                    self.append_output(out.rstrip())
        except Exception as e:
            sys.stdout = old_stdout
            self.append_output(traceback.format_exc().rstrip())
