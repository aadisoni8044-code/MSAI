from PySide6.QtWidgets import QDialog, QVBoxLayout, QHBoxLayout, QLabel, QTextEdit, QPushButton, QApplication
from PySide6.QtCore import Qt
from PySide6.QtGui import QFont

class LogViewerDialog(QDialog):
    """Modal dialog for inspecting detailed build logs."""

    def __init__(self, title: str, logs: list, parent=None):
        super().__init__(parent)
        self.setWindowTitle(f"exe/tow - {title}")
        self.resize(700, 480)
        self.setStyleSheet("""
            QDialog {
                background-color: #0A0C10;
                color: #FFFFFF;
            }
        """)

        layout = QVBoxLayout(self)
        layout.setContentsMargins(16, 16, 16, 16)
        layout.setSpacing(12)

        header = QLabel(title.upper())
        header.setStyleSheet("font-size: 16px; font-weight: 800; color: #00FF66;")
        layout.addWidget(header)

        self.text_edit = QTextEdit()
        self.text_edit.setReadOnly(True)
        font = QFont("JetBrains Mono", 10)
        font.setStyleHint(QFont.Monospace)
        self.text_edit.setFont(font)
        self.text_edit.setStyleSheet("""
            QTextEdit {
                background-color: #060709;
                color: #00FF66;
                border: 1px solid #1C202C;
                border-radius: 6px;
                padding: 10px;
            }
        """)

        log_str = "\n".join(logs) if isinstance(logs, list) else str(logs)
        self.text_edit.setPlainText(log_str)
        layout.addWidget(self.text_edit)

        btn_layout = QHBoxLayout()
        btn_layout.addStretch()

        copy_btn = QPushButton("COPY LOGS")
        copy_btn.setStyleSheet("""
            QPushButton {
                background-color: #1A1D26;
                color: #00E5FF;
                border: 1px solid #00E5FF;
                border-radius: 6px;
                padding: 8px 16px;
                font-weight: bold;
            }
            QPushButton:hover {
                background-color: #232836;
            }
        """)
        copy_btn.clicked.connect(lambda: QApplication.clipboard().setText(log_str))
        btn_layout.addWidget(copy_btn)

        close_btn = QPushButton("CLOSE")
        close_btn.setStyleSheet("""
            QPushButton {
                background-color: #00FF66;
                color: #090A0D;
                border: 1px solid #00FF66;
                border-radius: 6px;
                padding: 8px 16px;
                font-weight: bold;
            }
            QPushButton:hover {
                background-color: #33FF85;
            }
        """)
        close_btn.clicked.connect(self.accept)
        btn_layout.addWidget(close_btn)

        layout.addLayout(btn_layout)
