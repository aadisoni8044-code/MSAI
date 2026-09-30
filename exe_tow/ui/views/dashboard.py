import os
from PySide6.QtWidgets import (
    QWidget, QVBoxLayout, QHBoxLayout, QLabel, QPushButton, QFrame, QGridLayout
)
from PySide6.QtCore import Qt, Signal
from PySide6.QtGui import QFont, QPixmap, QCursor
from exe_tow.ui.components import StatCard

class DashboardView(QWidget):
    navigate_requested = Signal(str)
    open_folder_requested = Signal()

    def __init__(self, storage_mgr, parent=None):
        super().__init__(parent)
        self.storage_mgr = storage_mgr

        layout = QVBoxLayout(self)
        layout.setContentsMargins(28, 28, 28, 28)
        layout.setSpacing(24)

        # Welcome Card Panel
        welcome_card = QFrame()
        welcome_card.setStyleSheet("""
            QFrame {
                background: qlineargradient(x1:0, y1:0, x2:1, y2:1, stop:0 #121522, stop:1 #0A0C13);
                border: 1px solid #1E2336;
                border-radius: 12px;
                padding: 24px;
            }
        """)
        w_layout = QVBoxLayout(welcome_card)
        w_layout.setContentsMargins(20, 20, 20, 20)
        w_layout.setSpacing(12)

        # Main Tagline
        lbl_headline = QLabel("Build your Python project into an EXE.")
        lbl_headline.setFont(QFont("Segoe UI", 22, QFont.Bold))
        lbl_headline.setStyleSheet("color: #FFFFFF;")

        # Short Description
        lbl_desc = QLabel("Select a project folder and let exe/tow automatically detect, package and build your application.")
        lbl_desc.setFont(QFont("Segoe UI", 11))
        lbl_desc.setStyleSheet("color: #94A3B8; max-width: 650px;")
        lbl_desc.setWordWrap(True)

        # Action Buttons Layout
        btn_layout = QHBoxLayout()
        btn_layout.setContentsMargins(0, 12, 0, 0)
        btn_layout.setSpacing(14)

        btn_primary = QPushButton("⚡ Create EXE")
        btn_primary.setFont(QFont("Segoe UI", 10, QFont.Bold))
        btn_primary.setCursor(QCursor(Qt.PointingHandCursor))
        btn_primary.setFixedHeight(42)
        btn_primary.setStyleSheet("""
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
        btn_primary.clicked.connect(lambda: self.navigate_requested.emit("build_exe"))

        btn_secondary = QPushButton("📁 Open Project")
        btn_secondary.setFont(QFont("Segoe UI", 10, QFont.Medium))
        btn_secondary.setCursor(QCursor(Qt.PointingHandCursor))
        btn_secondary.setFixedHeight(42)
        btn_secondary.setStyleSheet("""
            QPushButton {
                background-color: #1E2333;
                color: #E2E8F0;
                border: 1px solid #2B3147;
                border-radius: 8px;
                padding: 0 20px;
            }
            QPushButton:hover {
                background-color: #262C40;
                border-color: #3B82F6;
                color: #FFFFFF;
            }
        """)
        btn_secondary.clicked.connect(self.open_folder_requested.emit)

        btn_layout.addWidget(btn_primary)
        btn_layout.addWidget(btn_secondary)
        btn_layout.addStretch()

        w_layout.addWidget(lbl_headline)
        w_layout.addWidget(lbl_desc)
        w_layout.addLayout(btn_layout)

        layout.addWidget(welcome_card)

        # Statistics Section Header
        lbl_stats_hdr = QLabel("PROJECT STATISTICS")
        lbl_stats_hdr.setFont(QFont("Segoe UI", 9, QFont.Bold))
        lbl_stats_hdr.setStyleSheet("color: #64748B; letter-spacing: 0.5px;")
        layout.addWidget(lbl_stats_hdr)

        # Statistics Grid
        stats_grid = QGridLayout()
        stats_grid.setSpacing(16)

        stats = self.storage_mgr.get_stats()

        self.card1 = StatCard("Projects Built", str(stats.get("projects_built", 0)), "📦", "Total build runs")
        self.card2 = StatCard("Successful Builds", str(stats.get("successful_builds", 0)), "✓", "Executable targets generated")
        self.card3 = StatCard("Recent Build", str(stats.get("recent_build", "None")), "🕒", "Last processed project")
        self.card4 = StatCard("Build Status", str(stats.get("build_status", "Ready")), "🟢", "System engine status")

        stats_grid.addWidget(self.card1, 0, 0)
        stats_grid.addWidget(self.card2, 0, 1)
        stats_grid.addWidget(self.card3, 1, 0)
        stats_grid.addWidget(self.card4, 1, 1)

        layout.addLayout(stats_grid)
        layout.addStretch()

    def refresh_stats(self):
        stats = self.storage_mgr.get_stats()
        self.card1.set_value(str(stats.get("projects_built", 0)))
        self.card2.set_value(str(stats.get("successful_builds", 0)))
        self.card3.set_value(str(stats.get("recent_build", "None")))
        self.card4.set_value(str(stats.get("build_status", "Ready")))
