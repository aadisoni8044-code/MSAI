from PySide6.QtWidgets import QFrame, QVBoxLayout, QLabel
from PySide6.QtCore import Qt

class MetricCard(QFrame):
    """Metric statistics display card for Dashboard."""

    def __init__(self, title: str, value: str, accent_color: str = "#00FF66", parent=None):
        super().__init__(parent)
        self.setFixedHeight(85)
        self.setStyleSheet(f"""
            MetricCard {{
                background-color: #12141A;
                border: 1px solid #1E222D;
                border-radius: 8px;
            }}
            MetricCard:hover {{
                border-color: {accent_color};
                background-color: #151820;
            }}
        """)

        layout = QVBoxLayout(self)
        layout.setContentsMargins(16, 12, 16, 12)
        layout.setSpacing(4)

        title_lbl = QLabel(title.upper())
        title_lbl.setStyleSheet("font-size: 11px; font-weight: 800; color: #8A8F9E; letter-spacing: 1px;")
        layout.addWidget(title_lbl)

        self.value_lbl = QLabel(value)
        self.value_lbl.setStyleSheet(f"font-size: 22px; font-weight: 900; color: {accent_color};")
        layout.addWidget(self.value_lbl)

    def set_value(self, value: str):
        self.value_lbl.setText(value)
