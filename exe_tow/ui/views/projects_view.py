import os
from PySide6.QtWidgets import (
    QWidget, QVBoxLayout, QHBoxLayout, QLabel, QPushButton, QScrollArea, QFrame
)
from PySide6.QtCore import Qt, Signal

from exe_tow.ui.components.custom_widgets import HackerCard
from exe_tow.core.history import HistoryManager


class ProjectsView(QWidget):
    """
    Displays list of previously opened/scanned Python projects.
    Each card shows:
    - Project Name & Path
    - Main File
    - Last Build Date & Status
    - [ OPEN ] and [ BUILD ] buttons
    If no projects exist, displays "No projects yet." and [ CREATE EXE ] button.
    """

    open_project_requested = Signal(str) # project_path
    build_project_requested = Signal(str) # project_path

    def __init__(self, history_manager: HistoryManager, parent=None):
        super().__init__(parent)
        self.history_manager = history_manager

        main_layout = QVBoxLayout(self)
        main_layout.setContentsMargins(32, 24, 32, 24)
        main_layout.setSpacing(16)

        # Header
        header_box = QVBoxLayout()
        header_box.setSpacing(4)

        heading = QLabel("PROJECTS", self)
        heading.setStyleSheet("font-size: 24px; font-weight: bold; color: #FFFFFF;")

        subtitle = QLabel("Manage and launch builds for your saved Python projects.", self)
        subtitle.setStyleSheet("font-size: 13px; color: #8A92A6;")

        header_box.addWidget(heading)
        header_box.addWidget(subtitle)

        main_layout.addLayout(header_box)

        # Scroll Area for Project Cards
        self.scroll_area = QScrollArea(self)
        self.scroll_area.setWidgetResizable(True)
        self.scroll_area.setFrameShape(QFrame.NoFrame)
        self.scroll_area.setStyleSheet("background-color: transparent;")

        self.cards_container = QWidget(self)
        self.cards_layout = QVBoxLayout(self.cards_container)
        self.cards_layout.setContentsMargins(0, 0, 0, 0)
        self.cards_layout.setSpacing(12)

        self.scroll_area.setWidget(self.cards_container)
        main_layout.addWidget(self.scroll_area, stretch=1)

        self.refresh_projects()

    def refresh_projects(self):
        # Clear existing card widgets
        while self.cards_layout.count():
            child = self.cards_layout.takeAt(0)
            if child.widget():
                child.widget().deleteLater()

        projects = self.history_manager.get_projects()

        if not projects:
            empty_card = HackerCard(self)
            empty_layout = QVBoxLayout(empty_card)
            empty_layout.setContentsMargins(32, 32, 32, 32)
            empty_layout.setSpacing(16)
            empty_layout.setAlignment(Qt.AlignCenter)

            empty_title = QLabel("No projects yet.", self)
            empty_title.setStyleSheet("font-size: 18px; font-weight: bold; color: #8A92A6;")
            empty_title.setAlignment(Qt.AlignCenter)

            create_btn = QPushButton("[ CREATE EXE ]", self)
            create_btn.setObjectName("NeonPrimaryBtn")
            create_btn.setCursor(Qt.PointingHandCursor)
            create_btn.setFixedWidth(160)
            create_btn.clicked.connect(lambda: self.build_project_requested.emit(""))

            empty_layout.addWidget(empty_title)
            empty_layout.addWidget(create_btn)

            self.cards_layout.addWidget(empty_card)
            self.cards_layout.addStretch()
            return

        for proj in projects:
            card = HackerCard(self)
            card_layout = QHBoxLayout(card)
            card_layout.setContentsMargins(20, 16, 20, 16)
            card_layout.setSpacing(16)

            # Left Info Box
            info_box = QVBoxLayout()
            info_box.setSpacing(4)

            proj_name = QLabel(proj.get("name", "PythonProject"), self)
            proj_name.setStyleSheet("font-size: 16px; font-weight: bold; color: #FFFFFF;")

            proj_path = QLabel(proj.get("path", ""), self)
            proj_path.setStyleSheet("font-family: 'Consolas', monospace; color: #8A92A6; font-size: 12px;")

            details_lbl = QLabel(
                f"Entry: {proj.get('main_file', 'main.py')}   |   Last Build: {proj.get('last_build', 'N/A')}   |   Status: {proj.get('last_status', 'READY')}",
                self
            )
            details_lbl.setStyleSheet("font-size: 11px; color: #00FF66;")

            info_box.addWidget(proj_name)
            info_box.addWidget(proj_path)
            info_box.addWidget(details_lbl)

            # Right Buttons Box
            btn_box = QHBoxLayout()
            btn_box.setSpacing(10)

            p_path = proj.get("path", "")

            open_btn = QPushButton("OPEN", self)
            open_btn.setObjectName("SecondaryBtn")
            open_btn.setCursor(Qt.PointingHandCursor)
            open_btn.setFixedHeight(34)
            open_btn.clicked.connect(lambda checked=False, path=p_path: self.open_project_requested.emit(path))

            build_btn = QPushButton("BUILD", self)
            build_btn.setObjectName("NeonPrimaryBtn")
            build_btn.setCursor(Qt.PointingHandCursor)
            build_btn.setFixedHeight(34)
            build_btn.clicked.connect(lambda checked=False, path=p_path: self.build_project_requested.emit(path))

            btn_box.addWidget(open_btn)
            btn_box.addWidget(build_btn)

            card_layout.addLayout(info_box, stretch=1)
            card_layout.addLayout(btn_box)

            self.cards_layout.addWidget(card)

        self.cards_layout.addStretch()
