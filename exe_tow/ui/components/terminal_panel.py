from PySide6.QtWidgets import QWidget, QVBoxLayout, QHBoxLayout, QLabel, QPushButton, QTextEdit, QCheckBox, QApplication, QFrame
from PySide6.QtCore import Qt
from PySide6.QtGui import QTextCursor, QFont

class TerminalPanel(QFrame):
    """Live build terminal output display panel with syntax highlights and action controls."""

    def __init__(self, parent=None):
        super().__init__(parent)
        self.setObjectName("terminalPanel")
        self.setStyleSheet("""
            QFrame#terminalPanel {
                background-color: #0A0C10;
                border: 1px solid #1C202C;
                border-radius: 8px;
            }
        """)

        layout = QVBoxLayout(self)
        layout.setContentsMargins(12, 10, 12, 10)
        layout.setSpacing(8)

        # Terminal Header Bar
        header_layout = QHBoxLayout()
        header_layout.setSpacing(10)

        terminal_title = QLabel("LIVE BUILD TERMINAL")
        terminal_title.setStyleSheet("font-size: 11px; font-weight: 800; color: #00FF66; letter-spacing: 1px;")
        header_layout.addWidget(terminal_title)

        header_layout.addStretch()

        # Auto-scroll checkbox
        self.auto_scroll_cb = QCheckBox("Auto-scroll")
        self.auto_scroll_cb.setChecked(True)
        self.auto_scroll_cb.setStyleSheet("font-size: 11px; color: #8A8F9E;")
        header_layout.addWidget(self.auto_scroll_cb)

        # Clear button
        clear_btn = QPushButton("CLEAR")
        clear_btn.setStyleSheet("""
            QPushButton {
                background-color: #141720;
                color: #8A8F9E;
                border: 1px solid #232838;
                border-radius: 4px;
                padding: 4px 10px;
                font-size: 10px;
                font-weight: 700;
            }
            QPushButton:hover {
                background-color: #1F2433;
                color: #FFFFFF;
                border-color: #00FF66;
            }
        """)
        clear_btn.clicked.connect(self.clear_logs)
        header_layout.addWidget(clear_btn)

        # Copy button
        copy_btn = QPushButton("COPY")
        copy_btn.setStyleSheet("""
            QPushButton {
                background-color: #141720;
                color: #00E5FF;
                border: 1px solid #00E5FF;
                border-radius: 4px;
                padding: 4px 10px;
                font-size: 10px;
                font-weight: 700;
            }
            QPushButton:hover {
                background-color: #1A2633;
                color: #66F0FF;
            }
        """)
        copy_btn.clicked.connect(self.copy_logs)
        header_layout.addWidget(copy_btn)

        layout.addLayout(header_layout)

        # Monospace Text Box
        self.text_edit = QTextEdit()
        self.text_edit.setReadOnly(True)
        font = QFont("JetBrains Mono", 10)
        font.setStyleHint(QFont.Monospace)
        self.text_edit.setFont(font)
        self.text_edit.setStyleSheet("""
            QTextEdit {
                background-color: #060709;
                color: #00FF66;
                border: 1px solid #161922;
                border-radius: 6px;
                padding: 10px;
                line-height: 1.4;
            }
        """)
        layout.addWidget(self.text_edit)

    def append_log(self, text: str):
        """Appends log line with color highlighting."""
        cursor = self.text_edit.textCursor()
        cursor.movePosition(QTextCursor.End)

        # Color logic
        text_upper = text.upper()
        if "ERROR" in text_upper or "FAILED" in text_upper or "EXCEPTION" in text_upper:
            color = "#FF4D4D" # Red
        elif "WARNING" in text_upper:
            color = "#FFB300" # Amber
        elif "SUCCESS" in text_upper or "COMPLETE" in text_upper:
            color = "#00FF66" # Green
        elif "STEP" in text_upper or "COMMAND" in text_upper:
            color = "#00E5FF" # Cyan
        else:
            color = "#C5C9D6" # Off-white / light gray

        html_line = f"<span style='color: {color}; font-family: Consolas, monospace;'>{text}</span><br>"
        cursor.insertHtml(html_line)

        if self.auto_scroll_cb.isChecked():
            self.text_edit.moveCursor(QTextCursor.End)

    def clear_logs(self):
        self.text_edit.clear()

    def copy_logs(self):
        QApplication.clipboard().setText(self.text_edit.toPlainText())

    def get_logs_text(self) -> str:
        return self.text_edit.toPlainText()
