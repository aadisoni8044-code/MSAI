from PySide6.QtWidgets import (
    QFrame, QLabel, QHBoxLayout, QVBoxLayout, QPushButton,
    QTextEdit, QProgressBar, QApplication
)
from PySide6.QtCore import Qt, Signal, QSize
from PySide6.QtGui import QFont, QColor


class HackerCard(QFrame):
    """Container frame with thin dark border and dark charcoal background."""
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setObjectName("HackerCard")


class StatCard(QFrame):
    """Statistics card widget showing a metric value and title label."""
    def __init__(self, title: str, value: str = "0", parent=None):
        super().__init__(parent)
        self.setObjectName("StatCard")
        layout = QVBoxLayout(self)
        layout.setContentsMargins(16, 16, 16, 16)
        layout.setSpacing(6)

        self.val_label = QLabel(value, self)
        self.val_label.setObjectName("StatValue")

        self.title_label = QLabel(title.upper(), self)
        self.title_label.setObjectName("StatLabel")

        layout.addWidget(self.val_label)
        layout.addWidget(self.title_label)

    def set_value(self, value: str):
        self.val_label.setText(str(value))


class TerminalLogPanel(QFrame):
    """
    Dedicated, scrollable terminal log panel contained strictly inside its own container.
    Features top bar with title, Clear button, and Copy button.
    """
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setObjectName("HackerCard")
        self.setMinimumHeight(200)

        main_layout = QVBoxLayout(self)
        main_layout.setContentsMargins(12, 12, 12, 12)
        main_layout.setSpacing(8)

        # Header bar
        header_layout = QHBoxLayout()
        header_layout.setContentsMargins(0, 0, 0, 0)

        title = QLabel("> BUILD LOG", self)
        title.setStyleSheet("font-family: 'Consolas', 'Courier New', monospace; font-weight: bold; color: #00FF66; font-size: 13px;")

        self.clear_btn = QPushButton("Clear", self)
        self.clear_btn.setObjectName("SecondaryBtn")
        self.clear_btn.setFixedHeight(28)
        self.clear_btn.setCursor(Qt.PointingHandCursor)
        self.clear_btn.clicked.connect(self.clear_logs)

        self.copy_btn = QPushButton("Copy", self)
        self.copy_btn.setObjectName("SecondaryBtn")
        self.copy_btn.setFixedHeight(28)
        self.copy_btn.setCursor(Qt.PointingHandCursor)
        self.copy_btn.clicked.connect(self.copy_logs)

        header_layout.addWidget(title)
        header_layout.addStretch()
        header_layout.addWidget(self.clear_btn)
        header_layout.addWidget(self.copy_btn)

        # Terminal text edit
        self.text_edit = QTextEdit(self)
        self.text_edit.setObjectName("TerminalText")
        self.text_edit.setReadOnly(True)

        main_layout.addLayout(header_layout)
        main_layout.addWidget(self.text_edit)

    def append_log(self, text: str):
        self.text_edit.append(text)
        # Auto scroll to bottom
        scrollbar = self.text_edit.verticalScrollBar()
        scrollbar.setValue(scrollbar.maximum())

    def clear_logs(self):
        self.text_edit.clear()

    def copy_logs(self):
        QApplication.clipboard().setText(self.text_edit.toPlainText())

    def get_logs(self) -> str:
        return self.text_edit.toPlainText()


class PipelineStepWidget(QWidget := QFrame):
    """
    Pipeline step indicator widget showing step index (e.g. 01 SCANNING)
    and status symbol (✓ Complete, ● Running, ○ Waiting, ✕ Failed).
    """
    def __init__(self, step_num: str, step_name: str, parent=None):
        super().__init__(parent)
        self.setObjectName("HackerCard")
        self.setFixedHeight(56)

        layout = QHBoxLayout(self)
        layout.setContentsMargins(14, 10, 14, 10)

        self.num_label = QLabel(step_num, self)
        self.num_label.setStyleSheet("font-family: 'Consolas', monospace; font-weight: bold; color: #8A92A6; font-size: 14px;")

        self.name_label = QLabel(step_name.upper(), self)
        self.name_label.setStyleSheet("font-weight: bold; color: #FFFFFF; font-size: 13px; letter-spacing: 0.5px;")

        self.status_label = QLabel("○ Waiting", self)
        self.status_label.setStyleSheet("font-family: 'Consolas', monospace; color: #8A92A6; font-size: 12px;")

        layout.addWidget(self.num_label)
        layout.addWidget(self.name_label)
        layout.addStretch()
        layout.addWidget(self.status_label)

    def set_status(self, status: str):
        # status: "waiting", "running", "completed", "failed"
        if status == "completed":
            self.status_label.setText("✓ Complete")
            self.status_label.setStyleSheet("font-family: 'Consolas', monospace; color: #00FF66; font-weight: bold; font-size: 12px;")
            self.setStyleSheet("QFrame#HackerCard { border: 1px solid #00FF66; background-color: #0D2018; }")
        elif status == "running":
            self.status_label.setText("● Running")
            self.status_label.setStyleSheet("font-family: 'Consolas', monospace; color: #FFB703; font-weight: bold; font-size: 12px;")
            self.setStyleSheet("QFrame#HackerCard { border: 1px solid #FFB703; background-color: #201A0D; }")
        elif status == "failed":
            self.status_label.setText("✕ Failed")
            self.status_label.setStyleSheet("font-family: 'Consolas', monospace; color: #FF4D4D; font-weight: bold; font-size: 12px;")
            self.setStyleSheet("QFrame#HackerCard { border: 1px solid #FF4D4D; background-color: #280D0D; }")
        else:
            self.status_label.setText("○ Waiting")
            self.status_label.setStyleSheet("font-family: 'Consolas', monospace; color: #8A92A6; font-size: 12px;")
            self.setStyleSheet("QFrame#HackerCard { border: 1px solid #1E2638; background-color: #12151C; }")


class CustomProgressBar(QProgressBar):
    """Futuristic neon green progress bar."""
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setFixedHeight(12)
        self.setTextVisible(False)
        self.setStyleSheet("""
            QProgressBar {
                background-color: #090A0D;
                border: 1px solid #1E2638;
                border-radius: 6px;
            }
            QProgressBar::chunk {
                background-color: #00FF66;
                border-radius: 5px;
            }
        """)
