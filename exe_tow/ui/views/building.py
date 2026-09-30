from PySide6.QtWidgets import (
    QWidget, QVBoxLayout, QHBoxLayout, QLabel, QFrame, QProgressBar
)
from PySide6.QtCore import Qt
from PySide6.QtGui import QFont
from exe_tow.ui.components import TerminalPanel, CheckItem

class BuildingView(QWidget):
    BUILD_STEPS = [
        "Step 1 — Scanning project",
        "Step 2 — Detecting main file",
        "Step 3 — Collecting dependencies",
        "Step 4 — Packaging project",
        "Step 5 — Creating EXE",
        "Step 6 — Finalizing build"
    ]

    def __init__(self, parent=None):
        super().__init__(parent)

        layout = QVBoxLayout(self)
        layout.setContentsMargins(28, 28, 28, 28)
        layout.setSpacing(20)

        # Title Card
        title_box = QFrame()
        title_box.setStyleSheet("""
            QFrame {
                background-color: #12141C;
                border: 1px solid #202433;
                border-radius: 10px;
                padding: 16px;
            }
        """)
        tb_layout = QVBoxLayout(title_box)
        tb_layout.setSpacing(8)

        self.lbl_headline = QLabel("Building your application…")
        self.lbl_headline.setFont(QFont("Segoe UI", 16, QFont.Bold))
        self.lbl_headline.setStyleSheet("color: #FFFFFF;")

        self.lbl_step_status = QLabel("Initializing build engine...")
        self.lbl_step_status.setFont(QFont("Segoe UI", 10, QFont.Medium))
        self.lbl_step_status.setStyleSheet("color: #3B82F6;")

        # Animated Progress Bar
        self.progress_bar = QProgressBar()
        self.progress_bar.setRange(0, 100)
        self.progress_bar.setValue(0)
        self.progress_bar.setFixedHeight(12)

        tb_layout.addWidget(self.lbl_headline)
        tb_layout.addWidget(self.lbl_step_status)
        tb_layout.addWidget(self.progress_bar)

        layout.addWidget(title_box)

        # Steps Panel
        steps_card = QFrame()
        steps_card.setStyleSheet("""
            QFrame {
                background-color: #12141C;
                border: 1px solid #202433;
                border-radius: 10px;
                padding: 16px;
            }
        """)
        s_layout = QVBoxLayout(steps_card)
        s_layout.setSpacing(8)

        s_hdr = QLabel("BUILD PIPELINE STEPS")
        s_hdr.setFont(QFont("Segoe UI", 9, QFont.Bold))
        s_hdr.setStyleSheet("color: #64748B; letter-spacing: 0.5px;")
        s_layout.addWidget(s_hdr)

        self.step_widgets = []
        for step in self.BUILD_STEPS:
            item = CheckItem(step, is_active=False)
            s_layout.addWidget(item)
            self.step_widgets.append(item)

        layout.addWidget(steps_card)

        # Terminal / Log Panel
        self.terminal = TerminalPanel()
        layout.addWidget(self.terminal, stretch=1)

    def update_progress(self, percent: int, step_msg: str):
        self.progress_bar.setValue(percent)
        self.lbl_step_status.setText(step_msg)

        # Activate items based on progress percentage
        # 10% -> Step 1, 25% -> Step 2, 45% -> Step 3, 65% -> Step 4, 85% -> Step 5, 100% -> Step 6
        step_thresholds = [10, 25, 45, 65, 85, 100]
        for idx, thresh in enumerate(step_thresholds):
            if percent >= thresh:
                self.step_widgets[idx].set_active(True)

    def append_log(self, text: str):
        self.terminal.append_log(text)

    def reset(self):
        self.progress_bar.setValue(0)
        self.lbl_step_status.setText("Initializing build engine...")
        for item in self.step_widgets:
            item.set_active(False)
        self.terminal.clear_logs()
