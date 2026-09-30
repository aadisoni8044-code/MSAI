from PySide6.QtWidgets import (
    QWidget, QVBoxLayout, QHBoxLayout, QLabel, QPushButton, QFrame
)
from PySide6.QtCore import Qt, Signal
from exe_tow.ui.components.custom_widgets import StatCard, HackerCard
from exe_tow.core.history import HistoryManager


class DashboardView(QWidget):
    """Futuristic Dashboard view showing overview metrics and quick action buttons."""

    # Signal to navigate to Build EXE or Open Project
    create_exe_requested = Signal()
    open_project_requested = Signal()

    def __init__(self, history_manager: HistoryManager, parent=None):
        super().__init__(parent)
        self.history_manager = history_manager

        main_layout = QVBoxLayout(self)
        main_layout.setContentsMargins(32, 32, 32, 32)
        main_layout.setSpacing(24)

        # Header Hero Section
        hero_layout = QVBoxLayout()
        hero_layout.setSpacing(8)

        heading = QLabel("Build Python into EXE.", self)
        heading.setStyleSheet("font-size: 28px; font-weight: bold; color: #FFFFFF; letter-spacing: 0.5px;")

        subtitle = QLabel("Package your Python project into a Windows executable.", self)
        subtitle.setStyleSheet("font-size: 14px; color: #8A92A6;")

        hero_layout.addWidget(heading)
        hero_layout.addWidget(subtitle)

        main_layout.addLayout(hero_layout)

        # Quick Actions Row
        action_layout = QHBoxLayout()
        action_layout.setSpacing(16)

        self.create_btn = QPushButton("[ + CREATE EXE ]", self)
        self.create_btn.setObjectName("NeonPrimaryBtn")
        self.create_btn.setCursor(Qt.PointingHandCursor)
        self.create_btn.setMinimumHeight(44)
        self.create_btn.clicked.connect(self.create_exe_requested.emit)

        self.open_btn = QPushButton("[ OPEN PROJECT ]", self)
        self.open_btn.setObjectName("SecondaryBtn")
        self.open_btn.setCursor(Qt.PointingHandCursor)
        self.open_btn.setMinimumHeight(44)
        self.open_btn.clicked.connect(self.open_project_requested.emit)

        action_layout.addWidget(self.create_btn)
        action_layout.addWidget(self.open_btn)
        action_layout.addStretch()

        main_layout.addLayout(action_layout)

        # Statistics Cards Row
        stats_layout = QHBoxLayout()
        stats_layout.setSpacing(16)

        self.projects_card = StatCard("PROJECTS", "0", self)
        self.builds_card = StatCard("BUILDS", "0", self)
        self.success_card = StatCard("SUCCESS", "0", self)
        self.failed_card = StatCard("FAILED", "0", self)

        stats_layout.addWidget(self.projects_card)
        stats_layout.addWidget(self.builds_card)
        stats_layout.addWidget(self.success_card)
        stats_layout.addWidget(self.failed_card)

        main_layout.addLayout(stats_layout)

        # Quick Overview Hacker Card
        info_card = HackerCard(self)
        info_layout = QVBoxLayout(info_card)
        info_layout.setContentsMargins(20, 20, 20, 20)
        info_layout.setSpacing(12)

        info_title = QLabel("> SYSTEM CAPABILITIES & LOGS", self)
        info_title.setStyleSheet("font-family: 'Consolas', monospace; font-weight: bold; color: #00FF66; font-size: 13px;")

        info_desc = QLabel(
            "• Automated Python dependency resolution and entry point scanner.\n"
            "• Contained terminal output panel with live line-by-line build streaming.\n"
            "• Clean 6-step build pipeline for standard and single-file executable packaging.\n"
            "• Built-in project persistence and execution history tracking.",
            self
        )
        info_desc.setStyleSheet("font-family: 'Consolas', monospace; color: #8A92A6; font-size: 12px; line-height: 1.6;")

        info_layout.addWidget(info_title)
        info_layout.addWidget(info_desc)

        main_layout.addWidget(info_card)
        main_layout.addStretch()

        self.refresh_stats()

    def refresh_stats(self):
        stats = self.history_manager.get_statistics()
        self.projects_card.set_value(str(stats["projects_count"]))
        self.builds_card.set_value(str(stats["builds_count"]))
        self.success_card.set_value(str(stats["success_count"]))
        self.failed_card.set_value(str(stats["failed_count"]))
