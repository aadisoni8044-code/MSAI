import os
import subprocess
from PySide6.QtWidgets import (
    QWidget, QVBoxLayout, QHBoxLayout, QLabel, QPushButton, QLineEdit, QFrame, QFileDialog, QScrollArea
)
from PySide6.QtCore import Qt, Signal
from exe_tow.core.scanner import ProjectScanner

class ProjectsView(QWidget):
    """Project management page with search, project cards, and quick actions."""

    select_project_for_build = Signal(str)

    def __init__(self, storage_manager, parent=None):
        super().__init__(parent)
        self.storage = storage_manager

        scroll = QScrollArea(self)
        scroll.setWidgetResizable(True)
        scroll.setStyleSheet("QScrollArea { border: none; background: transparent; }")

        content_widget = QWidget()
        layout = QVBoxLayout(content_widget)
        layout.setContentsMargins(24, 20, 24, 20)
        layout.setSpacing(18)

        # Header Title and Add Button
        header_bar = QHBoxLayout()

        title_lbl = QLabel("PROJECTS")
        title_lbl.setStyleSheet("font-size: 22px; font-weight: 800; color: #FFFFFF; letter-spacing: 1px;")

        add_btn = QPushButton("+ ADD PROJECT")
        add_btn.setStyleSheet("""
            QPushButton {
                background-color: #00FF66;
                color: #090A0D;
                border: 1px solid #00FF66;
                border-radius: 6px;
                padding: 8px 16px;
                font-weight: 800;
            }
            QPushButton:hover { background-color: #33FF85; }
        """)
        add_btn.clicked.connect(self.add_new_project)

        header_bar.addWidget(title_lbl)
        header_bar.addStretch()
        header_bar.addWidget(add_btn)

        layout.addLayout(header_bar)

        # Search bar
        self.search_txt = QLineEdit()
        self.search_txt.setPlaceholderText("Search projects by name, path or entry file...")
        self.search_txt.textChanged.connect(self.filter_projects)
        layout.addWidget(self.search_txt)

        # Projects cards list container
        self.cards_layout = QVBoxLayout()
        self.cards_layout.setSpacing(12)
        layout.addLayout(self.cards_layout)

        layout.addStretch()

        scroll.setWidget(content_widget)

        main_layout = QVBoxLayout(self)
        main_layout.setContentsMargins(0, 0, 0, 0)
        main_layout.addWidget(scroll)

        self.refresh_projects()

    def refresh_projects(self):
        query = self.search_txt.text().lower()

        while self.cards_layout.count():
            child = self.cards_layout.takeAt(0)
            if child.widget():
                child.widget().deleteLater()

        for proj in self.storage.projects:
            name = proj.get("name", "Project")
            path = proj.get("path", "")
            entry = proj.get("entry_file", "main.py")

            if query and query not in name.lower() and query not in path.lower() and query not in entry.lower():
                continue

            card = QFrame()
            card.setStyleSheet("""
                QFrame {
                    background-color: #12141A;
                    border: 1px solid #1E222D;
                    border-radius: 8px;
                    padding: 14px;
                }
                QFrame:hover {
                    border-color: #00FF66;
                }
            """)
            c_layout = QHBoxLayout(card)
            c_layout.setContentsMargins(12, 10, 12, 10)
            c_layout.setSpacing(16)

            info_layout = QVBoxLayout()
            info_layout.setSpacing(4)

            name_lbl = QLabel(name.upper())
            name_lbl.setStyleSheet("font-size: 14px; font-weight: 800; color: #FFFFFF;")

            entry_lbl = QLabel(f"Entry File: {entry}")
            entry_lbl.setStyleSheet("font-size: 11px; color: #00E5FF; font-family: Consolas, monospace;")

            path_lbl = QLabel(path)
            path_lbl.setStyleSheet("font-size: 11px; color: #8A8F9E; font-family: Consolas, monospace;")

            info_layout.addWidget(name_lbl)
            info_layout.addWidget(entry_lbl)
            info_layout.addWidget(path_lbl)

            status_layout = QVBoxLayout()
            status_layout.setSpacing(4)

            stat_lbl = QLabel(f"● {proj.get('status', 'BUILT')}")
            stat_lbl.setStyleSheet("font-size: 11px; font-weight: bold; color: #00FF66;")

            last_lbl = QLabel(f"Last build: {proj.get('last_build', 'RECENTLY')}")
            last_lbl.setStyleSheet("font-size: 10px; color: #8A8F9E;")

            status_layout.addWidget(stat_lbl)
            status_layout.addWidget(last_lbl)

            btn_layout = QHBoxLayout()
            btn_layout.setSpacing(8)

            btn_open = QPushButton("OPEN")
            btn_open.setStyleSheet("""
                QPushButton {
                    background-color: #1A1D26;
                    color: #FFFFFF;
                    border: 1px solid #2B3040;
                    border-radius: 4px;
                    padding: 6px 12px;
                    font-weight: bold;
                }
                QPushButton:hover { background-color: #232836; }
            """)
            btn_open.clicked.connect(lambda _, p=path: self.open_project_folder(p))

            btn_build = QPushButton("BUILD")
            btn_build.setStyleSheet("""
                QPushButton {
                    background-color: #00FF66;
                    color: #090A0D;
                    border: 1px solid #00FF66;
                    border-radius: 4px;
                    padding: 6px 14px;
                    font-weight: 800;
                }
                QPushButton:hover { background-color: #33FF85; }
            """)
            btn_build.clicked.connect(lambda _, p=path: self.select_project_for_build.emit(p))

            btn_layout.addWidget(btn_open)
            btn_layout.addWidget(btn_build)

            c_layout.addLayout(info_layout, stretch=3)
            c_layout.addLayout(status_layout, stretch=1)
            c_layout.addLayout(btn_layout)

            self.cards_layout.addWidget(card)

    def filter_projects(self):
        self.refresh_projects()

    def add_new_project(self):
        folder = QFileDialog.getExistingDirectory(self, "Select Python Project Directory")
        if folder:
            scanner = ProjectScanner(folder)
            res = scanner.scan()
            proj_data = {
                "name": res.get("project_name", os.path.basename(folder)),
                "path": folder,
                "entry_file": res.get("entry_file", "main.py"),
                "last_build": "NEVER",
                "status": "NOT BUILT",
                "files_count": res.get("py_files_count", 0),
                "dep_count": res.get("dep_count", 0),
                "asset_count": res.get("asset_files_count", 0)
            }
            self.storage.add_project(proj_data)
            self.refresh_projects()

    def open_project_folder(self, path: str):
        if os.path.exists(path):
            try:
                if os.name == "nt":
                    os.startfile(path)
                else:
                    subprocess.Popen(["xdg-open", path])
            except Exception as e:
                print(f"Error opening folder: {e}")
