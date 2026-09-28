"""
exe/tow - Projects Manager View
Inspects, scans, and displays Python project folders, entry points, and dependencies.
"""

import os
from PySide6.QtCore import Qt, Signal
from PySide6.QtWidgets import (
    QWidget, QVBoxLayout, QHBoxLayout, QLabel, QPushButton, QFrame,
    QFileDialog, QTableWidget, QTableWidgetItem, QHeaderView
)
from exe_tow.ui.theme import ThemeColors
from exe_tow.core.detector import ProjectDetector

class ProjectsView(QWidget):
    """Projects workspace view for exe/tow."""

    sig_open_in_builder = Signal(str)

    def __init__(self, settings_manager, parent=None):
        super().__init__(parent)
        self.settings = settings_manager

        layout = QVBoxLayout(self)
        layout.setContentsMargins(32, 28, 32, 28)
        layout.setSpacing(20)

        # Header Row
        header_row = QHBoxLayout()
        header_title = QLabel("Projects Explorer")
        header_title.setObjectName("TitleLabel")

        btn_add = QPushButton("📁 Add Project")
        btn_add.setObjectName("PrimaryButton")
        btn_add.setCursor(Qt.PointingHandCursor)
        btn_add.clicked.connect(self._add_project)

        header_row.addWidget(header_title)
        header_row.addStretch()
        header_row.addWidget(btn_add)
        layout.addLayout(header_row)

        # Projects Table
        self.table = QTableWidget()
        self.table.setColumnCount(5)
        self.table.setHorizontalHeaderLabels([
            "Project Name", "Folder Path", "Detected Main File", "Dependencies", "Actions"
        ])
        self.table.horizontalHeader().setSectionResizeMode(0, QHeaderView.ResizeToContents)
        self.table.horizontalHeader().setSectionResizeMode(1, QHeaderView.Stretch)
        self.table.horizontalHeader().setSectionResizeMode(2, QHeaderView.ResizeToContents)
        self.table.horizontalHeader().setSectionResizeMode(3, QHeaderView.ResizeToContents)
        self.table.horizontalHeader().setSectionResizeMode(4, QHeaderView.ResizeToContents)
        self.table.verticalHeader().setVisible(False)
        self.table.setSelectionBehavior(QTableWidget.SelectRows)

        layout.addWidget(self.table)

        self.refresh_projects()

    def _add_project(self):
        folder = QFileDialog.getExistingDirectory(self, "Select Python Project Folder")
        if folder:
            self.settings.add_recent_project(folder)
            self.refresh_projects()

    def refresh_projects(self):
        recents = self.settings.get("recent_projects", [])
        self.table.setRowCount(0)

        for folder in recents:
            if not os.path.exists(folder):
                continue

            info = ProjectDetector.inspect_directory(folder)
            row = self.table.rowCount()
            self.table.insertRow(row)

            p_name = info.get("project_name", "Unknown")
            main_file = info.get("main_file") or "None"
            deps = info.get("dependencies", [])
            deps_str = f"{len(deps)} package(s)" if deps else "None"

            item_name = QTableWidgetItem(f"🐍 {p_name}")
            item_path = QTableWidgetItem(folder)
            item_main = QTableWidgetItem(main_file)
            item_deps = QTableWidgetItem(deps_str)

            item_name.setForeground(Qt.white)
            item_path.setForeground(Qt.gray)

            self.table.setItem(row, 0, item_name)
            self.table.setItem(row, 1, item_path)
            self.table.setItem(row, 2, item_main)
            self.table.setItem(row, 3, item_deps)

            btn_build = QPushButton("⚡ Build")
            btn_build.setCursor(Qt.PointingHandCursor)
            btn_build.clicked.connect(lambda checked=False, p=folder: self.sig_open_in_builder.emit(p))
            self.table.setCellWidget(row, 4, btn_build)
