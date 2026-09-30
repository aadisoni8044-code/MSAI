import os
import subprocess
from PySide6.QtWidgets import (
    QWidget, QVBoxLayout, QHBoxLayout, QLabel, QPushButton, QLineEdit, QTableWidget, QTableWidgetItem, QHeaderView, QComboBox, QFrame, QScrollArea
)
from PySide6.QtCore import Qt
from exe_tow.ui.components.dialogs import LogViewerDialog

class HistoryView(QWidget):
    """Terminal-inspired Build History table view with search, status filter, and log view dialog."""

    def __init__(self, storage_manager, parent=None):
        super().__init__(parent)
        self.storage = storage_manager

        layout = QVBoxLayout(self)
        layout.setContentsMargins(24, 20, 24, 20)
        layout.setSpacing(16)

        # Title Header
        title_lbl = QLabel("BUILD HISTORY")
        title_lbl.setStyleSheet("font-size: 22px; font-weight: 800; color: #FFFFFF; letter-spacing: 1px;")
        layout.addWidget(title_lbl)

        # Search and Filter Toolbar
        tool_bar = QHBoxLayout()
        tool_bar.setSpacing(12)

        self.search_input = QLineEdit()
        self.search_input.setPlaceholderText("Search history by project name or entry file...")
        self.search_input.textChanged.connect(self.filter_table)
        tool_bar.addWidget(self.search_input, stretch=3)

        self.filter_combo = QComboBox()
        self.filter_combo.addItems(["All Results", "Success Only", "Failed Only"])
        self.filter_combo.currentIndexChanged.connect(self.filter_table)
        tool_bar.addWidget(self.filter_combo, stretch=1)

        layout.addLayout(tool_bar)

        # Build History Table
        self.table = QTableWidget()
        self.table.setColumnCount(7)
        self.table.setHorizontalHeaderLabels([
            "DATE", "PROJECT", "ENTRY FILE", "RESULT", "TIME", "SIZE", "ACTIONS"
        ])
        self.table.horizontalHeader().setSectionResizeMode(QHeaderView.Stretch)
        self.table.horizontalHeader().setSectionResizeMode(6, QHeaderView.ResizeToContents)
        self.table.setSelectionBehavior(QTableWidget.SelectRows)
        self.table.setEditTriggers(QTableWidget.NoEditTriggers)
        self.table.setAlternatingRowColors(True)

        layout.addWidget(self.table)

        self.refresh_table()

    def refresh_table(self):
        query = self.search_input.text().lower()
        filter_idx = self.filter_combo.currentIndex() # 0 = All, 1 = Success, 2 = Failed

        filtered_history = []
        for record in self.storage.history:
            proj = record.get("project", "")
            entry = record.get("entry_file", "")
            res = record.get("result", "")

            if query and query not in proj.lower() and query not in entry.lower():
                continue

            if filter_idx == 1 and res != "SUCCESS":
                continue
            elif filter_idx == 2 and res != "FAILED":
                continue

            filtered_history.append(record)

        self.table.setRowCount(len(filtered_history))

        for row, rec in enumerate(filtered_history):
            date_item = QTableWidgetItem(rec.get("date", ""))
            proj_item = QTableWidgetItem(rec.get("project", ""))
            entry_item = QTableWidgetItem(rec.get("entry_file", ""))

            res_str = rec.get("result", "SUCCESS")
            if res_str == "SUCCESS":
                res_item = QTableWidgetItem("✓ SUCCESS")
                res_item.setForeground(Qt.green)
            else:
                res_item = QTableWidgetItem("✕ FAILED")
                res_item.setForeground(Qt.red)

            time_item = QTableWidgetItem(rec.get("time", "18.4s"))
            size_item = QTableWidgetItem(rec.get("size", "42.8 MB"))

            self.table.setItem(row, 0, date_item)
            self.table.setItem(row, 1, proj_item)
            self.table.setItem(row, 2, entry_item)
            self.table.setItem(row, 3, res_item)
            self.table.setItem(row, 4, time_item)
            self.table.setItem(row, 5, size_item)

            # Action Buttons Cell
            btn_container = QWidget()
            btn_layout = QHBoxLayout(btn_container)
            btn_layout.setContentsMargins(4, 2, 4, 2)
            btn_layout.setSpacing(6)

            btn_open = QPushButton("Open")
            btn_open.setStyleSheet("""
                QPushButton {
                    background-color: #141720;
                    color: #00E5FF;
                    border: 1px solid #00E5FF;
                    border-radius: 4px;
                    padding: 3px 8px;
                    font-size: 10px;
                    font-weight: bold;
                }
                QPushButton:hover { background-color: #1A2633; }
            """)
            out_path = rec.get("output_path", "")
            btn_open.clicked.connect(lambda _, p=out_path: self.open_output_path(p))

            btn_log = QPushButton("Logs")
            btn_log.setStyleSheet("""
                QPushButton {
                    background-color: #141720;
                    color: #00FF66;
                    border: 1px solid #00FF66;
                    border-radius: 4px;
                    padding: 3px 8px;
                    font-size: 10px;
                    font-weight: bold;
                }
                QPushButton:hover { background-color: #122B1E; }
            """)
            logs = rec.get("logs", [])
            proj_name = rec.get("project", "Build")
            btn_log.clicked.connect(lambda _, l=logs, p=proj_name: self.view_logs(p, l))

            btn_layout.addWidget(btn_open)
            btn_layout.addWidget(btn_log)

            self.table.setCellWidget(row, 6, btn_container)

    def filter_table(self):
        self.refresh_table()

    def open_output_path(self, path: str):
        if not path:
            return
        target = path if os.path.exists(path) else os.path.dirname(path)
        if os.path.exists(target):
            try:
                if os.name == "nt":
                    os.startfile(target)
                else:
                    subprocess.Popen(["xdg-open", target])
            except Exception as e:
                print(f"Error opening output: {e}")

    def view_logs(self, project_name: str, logs: list):
        dlg = LogViewerDialog(f"Build Logs - {project_name}", logs, self)
        dlg.exec()
