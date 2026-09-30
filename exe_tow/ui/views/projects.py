from PySide6.QtWidgets import (
    QWidget, QVBoxLayout, QHBoxLayout, QLabel, QPushButton, QFrame,
    QGridLayout, QScrollArea, QTableWidget, QTableWidgetItem, QHeaderView
)
from PySide6.QtCore import Qt, Signal
from PySide6.QtGui import QFont, QCursor

class ProjectsView(QWidget):
    open_project_requested = Signal(str)
    build_project_requested = Signal(str)

    def __init__(self, storage_mgr, parent=None):
        super().__init__(parent)
        self.storage_mgr = storage_mgr

        layout = QVBoxLayout(self)
        layout.setContentsMargins(28, 28, 28, 28)
        layout.setSpacing(20)

        # Title Row
        title_row = QHBoxLayout()
        lbl_title = QLabel("Projects")
        lbl_title.setFont(QFont("Segoe UI", 18, QFont.Bold))
        lbl_title.setStyleSheet("color: #FFFFFF;")

        btn_refresh = QPushButton("🔄 Refresh")
        btn_refresh.setCursor(QCursor(Qt.PointingHandCursor))
        btn_refresh.setStyleSheet("""
            QPushButton {
                background-color: #12141C;
                color: #94A3B8;
                border: 1px solid #202433;
                border-radius: 6px;
                padding: 6px 14px;
            }
            QPushButton:hover {
                color: #FFFFFF;
                border-color: #3B82F6;
            }
        """)
        btn_refresh.clicked.connect(self.refresh_projects)

        title_row.addWidget(lbl_title)
        title_row.addStretch()
        title_row.addWidget(btn_refresh)

        layout.addLayout(title_row)

        # Scroll Area for Project Cards Grid
        scroll = QScrollArea()
        scroll.setWidgetResizable(True)
        scroll.setStyleSheet("QScrollArea { border: none; background: transparent; }")

        self.grid_container = QWidget()
        self.grid_layout = QGridLayout(self.grid_container)
        self.grid_layout.setSpacing(16)

        scroll.setWidget(self.grid_container)
        layout.addWidget(scroll)

        self.refresh_projects()

    def refresh_projects(self):
        # Clear grid
        for i in reversed(range(self.grid_layout.count())):
            widget = self.grid_layout.itemAt(i).widget()
            if widget:
                widget.setParent(None)

        projects = self.storage_mgr.get_projects()

        if not projects:
            lbl_empty = QLabel("No previously opened projects.\nSelect 'Build EXE' to process your first Python project.")
            lbl_empty.setFont(QFont("Segoe UI", 11))
            lbl_empty.setStyleSheet("color: #64748B; padding: 40px;")
            lbl_empty.setAlignment(Qt.AlignCenter)
            self.grid_layout.addWidget(lbl_empty, 0, 0)
            return

        row, col = 0, 0
        for p in projects:
            card = self._create_project_card(p)
            self.grid_layout.addWidget(card, row, col)
            col += 1
            if col > 1: # 2 cards per row
                col = 0
                row += 1

    def _create_project_card(self, proj_data: dict) -> QFrame:
        card = QFrame()
        card.setFixedHeight(180)
        card.setStyleSheet("""
            QFrame {
                background-color: #12141C;
                border: 1px solid #202433;
                border-radius: 10px;
                padding: 16px;
            }
            QFrame:hover {
                border: 1px solid #3B82F6;
                background-color: #151824;
            }
        """)
        c_layout = QVBoxLayout(card)
        c_layout.setSpacing(8)

        # Header Row: Project Name & Status Badge
        top_row = QHBoxLayout()
        name = proj_data.get("project_name", "Python Project")
        lbl_name = QLabel(name)
        lbl_name.setFont(QFont("Segoe UI", 12, QFont.Bold))
        lbl_name.setStyleSheet("color: #FFFFFF;")

        status = proj_data.get("status", "Ready")
        lbl_status = QLabel(f"● {status}")
        lbl_status.setFont(QFont("Segoe UI", 9, QFont.Bold))
        if status == "Success":
            lbl_status.setStyleSheet("color: #10B981;")
        elif status == "Failed":
            lbl_status.setStyleSheet("color: #EF4444;")
        else:
            lbl_status.setStyleSheet("color: #94A3B8;")

        top_row.addWidget(lbl_name)
        top_row.addStretch()
        top_row.addWidget(lbl_status)

        # Main File
        main_file = proj_data.get("main_file", "main.py")
        lbl_main = QLabel(f"Entry: {main_file}")
        lbl_main.setFont(QFont("Segoe UI", 9))
        lbl_main.setStyleSheet("color: #94A3B8;")

        # Folder path
        folder = proj_data.get("folder_path", "")
        lbl_folder = QLabel(folder)
        lbl_folder.setFont(QFont("Segoe UI", 8))
        lbl_folder.setStyleSheet("color: #64748B;")

        # Buttons
        btn_row = QHBoxLayout()
        btn_row.setSpacing(10)

        folder_path = proj_data.get("folder_path", "")

        btn_open = QPushButton("Open")
        btn_open.setFixedHeight(32)
        btn_open.setFont(QFont("Segoe UI", 9, QFont.Medium))
        btn_open.setCursor(QCursor(Qt.PointingHandCursor))
        btn_open.setStyleSheet("""
            QPushButton {
                background-color: #1A1D29;
                color: #CBD5E1;
                border: 1px solid #282E40;
                border-radius: 6px;
                padding: 0 14px;
            }
            QPushButton:hover {
                color: #FFFFFF;
                border-color: #3B82F6;
            }
        """)
        btn_open.clicked.connect(lambda checked=False, f=folder_path: self.open_project_requested.emit(f))

        btn_build = QPushButton("Build")
        btn_build.setFixedHeight(32)
        btn_build.setFont(QFont("Segoe UI", 9, QFont.Bold))
        btn_build.setCursor(QCursor(Qt.PointingHandCursor))
        btn_build.setStyleSheet("""
            QPushButton {
                background-color: #2563EB;
                color: #FFFFFF;
                border: none;
                border-radius: 6px;
                padding: 0 16px;
            }
            QPushButton:hover {
                background-color: #1D4ED8;
            }
        """)
        btn_build.clicked.connect(lambda checked=False, f=folder_path: self.build_project_requested.emit(f))

        btn_row.addWidget(btn_open)
        btn_row.addWidget(btn_build)
        btn_row.addStretch()

        c_layout.addLayout(top_row)
        c_layout.addWidget(lbl_main)
        c_layout.addWidget(lbl_folder)
        c_layout.addStretch()
        c_layout.addLayout(btn_row)

        return card


class HistoryView(QWidget):
    def __init__(self, storage_mgr, parent=None):
        super().__init__(parent)
        self.storage_mgr = storage_mgr

        layout = QVBoxLayout(self)
        layout.setContentsMargins(28, 28, 28, 28)
        layout.setSpacing(20)

        # Title Row
        title_row = QHBoxLayout()
        lbl_title = QLabel("Build History")
        lbl_title.setFont(QFont("Segoe UI", 18, QFont.Bold))
        lbl_title.setStyleSheet("color: #FFFFFF;")

        btn_refresh = QPushButton("🔄 Refresh")
        btn_refresh.setCursor(QCursor(Qt.PointingHandCursor))
        btn_refresh.setStyleSheet("""
            QPushButton {
                background-color: #12141C;
                color: #94A3B8;
                border: 1px solid #202433;
                border-radius: 6px;
                padding: 6px 14px;
            }
            QPushButton:hover {
                color: #FFFFFF;
                border-color: #3B82F6;
            }
        """)
        btn_refresh.clicked.connect(self.refresh_history)

        title_row.addWidget(lbl_title)
        title_row.addStretch()
        title_row.addWidget(btn_refresh)

        layout.addLayout(title_row)

        # Table Widget
        self.table = QTableWidget()
        self.table.setColumnCount(6)
        self.table.setHorizontalHeaderLabels(["Timestamp", "Project Name", "EXE Filename", "Build Time", "Size", "Status"])
        self.table.horizontalHeader().setSectionResizeMode(QHeaderView.Stretch)
        self.table.setSelectionBehavior(QTableWidget.SelectRows)
        self.table.setEditTriggers(QTableWidget.NoEditTriggers)

        layout.addWidget(self.table)

        self.refresh_history()

    def refresh_history(self):
        history = self.storage_mgr.get_history()
        self.table.setRowCount(len(history))

        for idx, entry in enumerate(history):
            item_time = QTableWidgetItem(entry.get("timestamp", ""))
            item_proj = QTableWidgetItem(entry.get("project_name", ""))
            item_exe = QTableWidgetItem(entry.get("exe_filename", ""))
            item_dur = QTableWidgetItem(entry.get("build_time", ""))
            item_size = QTableWidgetItem(entry.get("file_size", ""))

            status_str = entry.get("status", "Ready")
            item_status = QTableWidgetItem(status_str)
            if status_str == "Success":
                item_status.setForeground(Qt.green)
            elif status_str == "Failed":
                item_status.setForeground(Qt.red)

            self.table.setItem(idx, 0, item_time)
            self.table.setItem(idx, 1, item_proj)
            self.table.setItem(idx, 2, item_exe)
            self.table.setItem(idx, 3, item_dur)
            self.table.setItem(idx, 4, item_size)
            self.table.setItem(idx, 5, item_status)
