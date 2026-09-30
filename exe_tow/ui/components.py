from PySide6.QtWidgets import (
    QWidget, QVBoxLayout, QHBoxLayout, QLabel, QPushButton, QFrame, QPlainTextEdit, QProgressBar
)
from PySide6.QtCore import Qt, Signal
from PySide6.QtGui import QFont, QCursor

class StatCard(QFrame):
    def __init__(self, title: str, value: str, icon: str = "📊", subtext: str = "", parent=None):
        super().__init__(parent)
        self.setFixedHeight(110)
        self.setStyleSheet("""
            StatCard {
                background-color: #12141C;
                border: 1px solid #202433;
                border-radius: 10px;
            }
            StatCard:hover {
                border: 1px solid #2A3045;
                background-color: #151822;
            }
        """)

        layout = QVBoxLayout(self)
        layout.setContentsMargins(16, 14, 16, 14)
        layout.setSpacing(6)

        # Header with title & icon
        top_layout = QHBoxLayout()
        top_layout.setContentsMargins(0, 0, 0, 0)

        lbl_title = QLabel(title)
        lbl_title.setFont(QFont("Segoe UI", 9, QFont.Bold))
        lbl_title.setStyleSheet("color: #94A3B8; text-transform: uppercase; letter-spacing: 0.5px;")

        lbl_icon = QLabel(icon)
        lbl_icon.setFont(QFont("Segoe UI", 12))

        top_layout.addWidget(lbl_title)
        top_layout.addStretch()
        top_layout.addWidget(lbl_icon)

        layout.addLayout(top_layout)

        # Value
        self.lbl_val = QLabel(value)
        self.lbl_val.setFont(QFont("Segoe UI", 18, QFont.Bold))
        self.lbl_val.setStyleSheet("color: #FFFFFF;")
        layout.addWidget(self.lbl_val)

        if subtext:
            lbl_sub = QLabel(subtext)
            lbl_sub.setFont(QFont("Segoe UI", 8))
            lbl_sub.setStyleSheet("color: #64748B;")
            layout.addWidget(lbl_sub)

    def set_value(self, val: str):
        self.lbl_val.setText(val)


class CheckItem(QFrame):
    def __init__(self, label_text: str, is_active: bool = False, parent=None):
        super().__init__(parent)
        self.setStyleSheet("""
            CheckItem {
                background-color: #161924;
                border: 1px solid #232838;
                border-radius: 6px;
            }
        """)
        layout = QHBoxLayout(self)
        layout.setContentsMargins(12, 8, 12, 8)
        layout.setSpacing(10)

        self.icon_lbl = QLabel("✓" if is_active else "○")
        self.icon_lbl.setFont(QFont("Segoe UI", 11, QFont.Bold))
        self.icon_lbl.setStyleSheet("color: #10B981;" if is_active else "color: #64748B;")

        self.text_lbl = QLabel(label_text)
        self.text_lbl.setFont(QFont("Segoe UI", 10, QFont.Medium))
        self.text_lbl.setStyleSheet("color: #F8FAFC;" if is_active else "color: #64748B;")

        layout.addWidget(self.icon_lbl)
        layout.addWidget(self.text_lbl)
        layout.addStretch()

    def set_active(self, active: bool):
        if active:
            self.icon_lbl.setText("✓")
            self.icon_lbl.setStyleSheet("color: #10B981;")
            self.text_lbl.setStyleSheet("color: #F8FAFC;")
        else:
            self.icon_lbl.setText("○")
            self.icon_lbl.setStyleSheet("color: #64748B;")
            self.text_lbl.setStyleSheet("color: #64748B;")


class TerminalPanel(QFrame):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setStyleSheet("""
            TerminalPanel {
                background-color: #0B0D12;
                border: 1px solid #1B1F2D;
                border-radius: 8px;
            }
        """)
        layout = QVBoxLayout(self)
        layout.setContentsMargins(12, 10, 12, 10)
        layout.setSpacing(8)

        # Terminal Header
        hdr_layout = QHBoxLayout()
        hdr_layout.setContentsMargins(0, 0, 0, 0)

        title = QLabel("TERMINAL / BUILD LOGS")
        title.setFont(QFont("Consolas", 9, QFont.Bold))
        title.setStyleSheet("color: #64748B; letter-spacing: 0.5px;")

        btn_clear = QPushButton("Clear")
        btn_clear.setFont(QFont("Segoe UI", 8))
        btn_clear.setCursor(QCursor(Qt.PointingHandCursor))
        btn_clear.setStyleSheet("""
            QPushButton {
                background-color: transparent;
                color: #64748B;
                border: 1px solid #1E2230;
                border-radius: 4px;
                padding: 2px 8px;
            }
            QPushButton:hover {
                color: #F8FAFC;
                background-color: #181B26;
            }
        """)
        btn_clear.clicked.connect(self.clear_logs)

        hdr_layout.addWidget(title)
        hdr_layout.addStretch()
        hdr_layout.addWidget(btn_clear)

        layout.addLayout(hdr_layout)

        # Text Console
        self.console = QPlainTextEdit()
        self.console.setReadOnly(True)
        self.console.setFont(QFont("Consolas", 9))
        self.console.setStyleSheet("""
            QPlainTextEdit {
                background-color: #07080B;
                color: #38BDF8;
                border: none;
                border-radius: 4px;
                padding: 8px;
            }
        """)
        layout.addWidget(self.console)

    def append_log(self, text: str):
        self.console.appendPlainText(text)
        # Auto scroll to bottom
        sb = self.console.verticalScrollBar()
        sb.setValue(sb.maximum())

    def clear_logs(self):
        self.console.clear()
