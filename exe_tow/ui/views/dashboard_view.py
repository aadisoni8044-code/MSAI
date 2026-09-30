from PySide6.QtWidgets import (
    QWidget, QVBoxLayout, QHBoxLayout, QLabel, QPushButton, QFrame, QFileDialog, QScrollArea
)
from PySide6.QtCore import Qt, Signal
from exe_tow.ui.components.status_card import MetricCard

class DashboardView(QWidget):
    """Main Dashboard View featuring Quick Build hero card, system stats, and recent projects."""

    select_project_clicked = Signal(str) # Emits directory path
    create_exe_clicked = Signal()

    def __init__(self, storage_manager, parent=None):
        super().__init__(parent)
        self.storage = storage_manager

        scroll = QScrollArea(self)
        scroll.setWidgetResizable(True)
        scroll.setStyleSheet("QScrollArea { border: none; background: transparent; }")

        content_widget = QWidget()
        layout = QVBoxLayout(content_widget)
        layout.setContentsMargins(24, 20, 24, 20)
        layout.setSpacing(20)

        # Header Title
        header_layout = QVBoxLayout()
        header_layout.setSpacing(2)

        title_lbl = QLabel("EXE/TOW")
        title_lbl.setProperty("class", "h1")
        title_lbl.setStyleSheet("font-size: 26px; font-weight: 900; color: #FFFFFF; letter-spacing: 1px;")

        sub_title_lbl = QLabel("PYTHON → WINDOWS EXE")
        sub_title_lbl.setStyleSheet("font-size: 13px; font-weight: 800; color: #00FF66; letter-spacing: 2px;")

        desc_lbl = QLabel("Build your Python project into a Windows application.")
        desc_lbl.setStyleSheet("font-size: 13px; color: #8A8F9E; margin-top: 4px;")

        header_layout.addWidget(title_lbl)
        header_layout.addWidget(sub_title_lbl)
        header_layout.addWidget(desc_lbl)
        layout.addLayout(header_layout)

        # Quick Build Hero Card
        hero_card = QFrame()
        hero_card.setProperty("class", "heroCard")
        hero_card.setStyleSheet("""
            QFrame.heroCard {
                background: qlineargradient(x1:0, y1:0, x2:1, y2:1, stop:0 #12151F, stop:1 #0A0C12);
                border: 1px solid #1C2230;
                border-radius: 10px;
                padding: 20px;
            }
        """)
        hero_layout = QVBoxLayout(hero_card)
        hero_layout.setSpacing(14)

        hero_title = QLabel("QUICK BUILD")
        hero_title.setStyleSheet("font-size: 14px; font-weight: 800; color: #00FF66; letter-spacing: 1px;")
        hero_layout.addWidget(hero_title)

        hero_desc = QLabel("Select a Python project directory and start building a standalone executable.")
        hero_desc.setStyleSheet("font-size: 13px; color: #C5C9D6;")
        hero_layout.addWidget(hero_desc)

        # Selected project path indicator
        self.project_path_lbl = QLabel("No project folder selected.")
        self.project_path_lbl.setStyleSheet("""
            font-size: 12px;
            color: #8A8F9E;
            background-color: #080A0E;
            border: 1px dashed #232838;
            border-radius: 6px;
            padding: 8px 12px;
            font-family: Consolas, monospace;
        """)
        hero_layout.addWidget(self.project_path_lbl)

        # Hero Action Buttons
        btn_layout = QHBoxLayout()
        btn_layout.setSpacing(12)

        select_btn = QPushButton("SELECT PROJECT")
        select_btn.setStyleSheet("""
            QPushButton {
                background-color: #1A1D26;
                color: #FFFFFF;
                border: 1px solid #2B3040;
                border-radius: 6px;
                padding: 10px 20px;
                font-weight: 700;
            }
            QPushButton:hover {
                background-color: #232836;
                border-color: #00FF66;
                color: #00FF66;
            }
        """)
        select_btn.clicked.connect(self.browse_folder)
        btn_layout.addWidget(select_btn)

        self.create_btn = QPushButton("> CREATE EXE")
        self.create_btn.setProperty("class", "btnPrimary")
        self.create_btn.setStyleSheet("""
            QPushButton {
                background-color: #00FF66;
                color: #090A0D;
                border: 1px solid #00FF66;
                border-radius: 6px;
                padding: 10px 24px;
                font-weight: 800;
                font-size: 13px;
                letter-spacing: 0.5px;
            }
            QPushButton:hover {
                background-color: #33FF85;
            }
        """)
        self.create_btn.clicked.connect(lambda: self.create_exe_clicked.emit())
        btn_layout.addWidget(self.create_btn)

        btn_layout.addStretch()
        hero_layout.addLayout(btn_layout)

        layout.addWidget(hero_card)

        # System Information Metric Cards Grid
        stats_grid = QHBoxLayout()
        stats_grid.setSpacing(12)

        self.card_projects = MetricCard("PROJECTS", "000", "#FFFFFF")
        self.card_success = MetricCard("SUCCESSFUL BUILDS", "000", "#00FF66")
        self.card_failed = MetricCard("FAILED BUILDS", "000", "#FF4D4D")
        self.card_last = MetricCard("LAST BUILD", "NEVER", "#00E5FF")

        stats_grid.addWidget(self.card_projects)
        stats_grid.addWidget(self.card_success)
        stats_grid.addWidget(self.card_failed)
        stats_grid.addWidget(self.card_last)

        layout.addLayout(stats_grid)

        # Recent Projects Card
        recent_card = QFrame()
        recent_card.setProperty("class", "panelCard")
        recent_card.setStyleSheet("""
            QFrame {
                background-color: #12141A;
                border: 1px solid #1E222D;
                border-radius: 8px;
                padding: 16px;
            }
        """)
        recent_layout = QVBoxLayout(recent_card)
        recent_layout.setSpacing(10)

        recent_title = QLabel("RECENT PROJECTS")
        recent_title.setStyleSheet("font-size: 12px; font-weight: 800; color: #00FF66; letter-spacing: 1px;")
        recent_layout.addWidget(recent_title)

        self.projects_list_layout = QVBoxLayout()
        self.projects_list_layout.setSpacing(8)
        recent_layout.addLayout(self.projects_list_layout)

        layout.addWidget(recent_card)
        layout.addStretch()

        scroll.setWidget(content_widget)

        main_layout = QVBoxLayout(self)
        main_layout.setContentsMargins(0, 0, 0, 0)
        main_layout.addWidget(scroll)

        self.refresh_stats()

    def browse_folder(self):
        folder = QFileDialog.getExistingDirectory(self, "Select Python Project Directory")
        if folder:
            self.set_selected_project_path(folder)
            self.select_project_clicked.emit(folder)

    def set_selected_project_path(self, path: str):
        self.project_path_lbl.setText(f"Path: {path}")
        self.project_path_lbl.setStyleSheet("""
            font-size: 12px;
            color: #00FF66;
            background-color: #0B1C13;
            border: 1px solid #00FF66;
            border-radius: 6px;
            padding: 8px 12px;
            font-family: Consolas, monospace;
        """)

    def refresh_stats(self):
        stats = self.storage.get_stats()
        self.card_projects.set_value(f"{stats['projects_count']:03d}")
        self.card_success.set_value(f"{stats['success_count']:03d}")
        self.card_failed.set_value(f"{stats['failed_count']:03d}")
        self.card_last.set_value(str(stats['last_build']))

        # Populate recent projects
        while self.projects_list_layout.count():
            child = self.projects_list_layout.takeAt(0)
            if child.widget():
                child.widget().deleteLater()

        for proj in self.storage.projects[:3]:
            row = QFrame()
            row.setStyleSheet("""
                QFrame {
                    background-color: #0A0C10;
                    border: 1px solid #1C202C;
                    border-radius: 6px;
                    padding: 8px 12px;
                }
            """)
            r_layout = QHBoxLayout(row)
            r_layout.setContentsMargins(8, 6, 8, 6)

            p_name = QLabel(proj.get("name", "Project"))
            p_name.setStyleSheet("font-weight: 700; color: #FFFFFF; font-size: 13px;")

            p_entry = QLabel(proj.get("entry_file", "main.py"))
            p_entry.setStyleSheet("color: #8A8F9E; font-family: Consolas, monospace; font-size: 11px;")

            p_status = QLabel(f"● {proj.get('status', 'BUILT')}")
            p_status.setStyleSheet("color: #00FF66; font-weight: bold; font-size: 11px;")

            btn_build = QPushButton("BUILD")
            btn_build.setStyleSheet("""
                QPushButton {
                    background-color: #141720;
                    color: #00FF66;
                    border: 1px solid #00FF66;
                    border-radius: 4px;
                    padding: 4px 12px;
                    font-size: 10px;
                    font-weight: 800;
                }
                QPushButton:hover {
                    background-color: #00FF66;
                    color: #090A0D;
                }
            """)
            proj_path = proj.get("path", "")
            btn_build.clicked.connect(lambda _, path=proj_path: self.select_project_clicked.emit(path))

            r_layout.addWidget(p_name)
            r_layout.addWidget(p_entry)
            r_layout.addStretch()
            r_layout.addWidget(p_status)
            r_layout.addWidget(btn_build)

            self.projects_list_layout.addWidget(row)
