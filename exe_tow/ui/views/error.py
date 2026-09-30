from PySide6.QtWidgets import (
    QWidget, QVBoxLayout, QHBoxLayout, QLabel, QPushButton, QFrame, QPlainTextEdit
)
from PySide6.QtCore import Qt, Signal
from PySide6.QtGui import QFont, QCursor

class ErrorView(QWidget):
    try_again_requested = Signal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self.error_data = {}

        layout = QVBoxLayout(self)
        layout.setContentsMargins(28, 28, 28, 28)
        layout.setSpacing(20)

        # Failure Banner
        banner = QFrame()
        banner.setStyleSheet("""
            QFrame {
                background-color: #211214;
                border: 1px solid #4D1A1F;
                border-radius: 12px;
                padding: 24px;
            }
        """)
        b_layout = QVBoxLayout(banner)
        b_layout.setSpacing(10)

        lbl_hdr = QLabel("Build failed")
        lbl_hdr.setFont(QFont("Segoe UI", 20, QFont.Bold))
        lbl_hdr.setStyleSheet("color: #EF4444;")

        self.lbl_explanation = QLabel("An error occurred during project packaging.")
        self.lbl_explanation.setFont(QFont("Segoe UI", 11))
        self.lbl_explanation.setStyleSheet("color: #FCA5A5;")
        self.lbl_explanation.setWordWrap(True)

        b_layout.addWidget(lbl_hdr)
        b_layout.addWidget(self.lbl_explanation)

        layout.addWidget(banner)

        # Technical Logs Panel (Collapsible / Expandable)
        logs_card = QFrame()
        logs_card.setStyleSheet("""
            QFrame {
                background-color: #12141C;
                border: 1px solid #202433;
                border-radius: 10px;
                padding: 16px;
            }
        """)
        l_layout = QVBoxLayout(logs_card)
        l_layout.setSpacing(10)

        l_hdr = QLabel("TECHNICAL LOGS & EXCEPTION DETAILS")
        l_hdr.setFont(QFont("Segoe UI", 9, QFont.Bold))
        l_hdr.setStyleSheet("color: #64748B; letter-spacing: 0.5px;")

        self.txt_tech_logs = QPlainTextEdit()
        self.txt_tech_logs.setReadOnly(True)
        self.txt_tech_logs.setFont(QFont("Consolas", 9))
        self.txt_tech_logs.setStyleSheet("""
            QPlainTextEdit {
                background-color: #07080B;
                color: #F87171;
                border: 1px solid #1B1E2B;
                border-radius: 6px;
                padding: 10px;
            }
        """)

        l_layout.addWidget(l_hdr)
        l_layout.addWidget(self.txt_tech_logs)

        layout.addWidget(logs_card, stretch=1)

        # Action Buttons Row
        actions_layout = QHBoxLayout()
        actions_layout.setSpacing(14)

        btn_try_again = QPushButton("🔄 Try Again")
        btn_try_again.setFixedHeight(44)
        btn_try_again.setFont(QFont("Segoe UI", 10, QFont.Bold))
        btn_try_again.setCursor(QCursor(Qt.PointingHandCursor))
        btn_try_again.setStyleSheet("""
            QPushButton {
                background-color: #2563EB;
                color: #FFFFFF;
                border: none;
                border-radius: 8px;
                padding: 0 24px;
            }
            QPushButton:hover {
                background-color: #1D4ED8;
            }
        """)
        btn_try_again.clicked.connect(self.try_again_requested.emit)

        self.btn_toggle_details = QPushButton("🔍 View Details")
        self.btn_toggle_details.setFixedHeight(44)
        self.btn_toggle_details.setFont(QFont("Segoe UI", 10, QFont.Medium))
        self.btn_toggle_details.setCursor(QCursor(Qt.PointingHandCursor))
        self.btn_toggle_details.setStyleSheet("""
            QPushButton {
                background-color: #1E2333;
                color: #FFFFFF;
                border: 1px solid #2B3147;
                border-radius: 8px;
                padding: 0 20px;
            }
            QPushButton:hover {
                background-color: #262C40;
                border-color: #3B82F6;
            }
        """)
        self.btn_toggle_details.clicked.connect(self.toggle_details)

        actions_layout.addWidget(btn_try_again)
        actions_layout.addWidget(self.btn_toggle_details)
        actions_layout.addStretch()

        layout.addLayout(actions_layout)

    def set_error(self, error_data: dict):
        self.error_data = error_data
        self.lbl_explanation.setText(error_data.get("error_message", "An unexpected error occurred."))
        self.txt_tech_logs.setPlainText(error_data.get("technical_details", ""))

    def toggle_details(self):
        visible = self.txt_tech_logs.isVisible()
        self.txt_tech_logs.setVisible(not visible)
        self.btn_toggle_details.setText("Hide Details" if not visible else "🔍 View Details")
