from PySide6.QtWidgets import (
    QWidget, QVBoxLayout, QHBoxLayout, QLabel, QPushButton, QPlainTextEdit, QFileDialog, QApplication
)
from PySide6.QtCore import Qt, QTimer
from exe_tow.ui.theme import Theme

class TerminalWidget(QWidget):
    def __init__(self, parent=None):
        super().__init__(parent)

        layout = QVBoxLayout(self)
        layout.setContentsMargins(0, 0, 0, 0)
        layout.setSpacing(8)

        # Terminal Header Bar
        header = QHBoxLayout()
        title = QLabel("> EXE/TOW LIVE TERMINAL")
        title.setStyleSheet(f"font-weight: bold; color: {Theme.ACCENT_PRIMARY}; font-family: monospace;")
        header.addWidget(title)

        header.addStretch()

        self.btn_copy = QPushButton("Copy")
        self.btn_copy.setFixedHeight(28)
        self.btn_copy.clicked.connect(self.copy_terminal)
        header.addWidget(self.btn_copy)

        self.btn_save = QPushButton("Save Log")
        self.btn_save.setFixedHeight(28)
        self.btn_save.clicked.connect(self.save_terminal_log)
        header.addWidget(self.btn_save)

        self.btn_clear = QPushButton("Clear")
        self.btn_clear.setFixedHeight(28)
        self.btn_clear.clicked.connect(self.clear_terminal)
        header.addWidget(self.btn_clear)

        layout.addLayout(header)

        # PlainTextEdit Output
        self.text_area = QPlainTextEdit()
        self.text_area.setReadOnly(True)
        self.text_area.setPlaceholderText("Live build outputs, logs, and process execution commands will appear here...")
        layout.addWidget(self.text_area)

    def append_log(self, text: str):
        self.text_area.appendPlainText(text.rstrip())
        # Auto scroll to bottom
        sb = self.text_area.verticalScrollBar()
        sb.setValue(sb.maximum())

    def clear_terminal(self):
        self.text_area.clear()

    def copy_terminal(self):
        QApplication.clipboard().setText(self.text_area.toPlainText())

    def save_terminal_log(self):
        filename, _ = QFileDialog.getSaveFileName(self, "Save Terminal Log", "build_terminal.log", "Log Files (*.log);;All Files (*)")
        if filename:
            try:
                with open(filename, "w", encoding="utf-8") as f:
                    f.write(self.text_area.toPlainText())
            except Exception:
                pass
