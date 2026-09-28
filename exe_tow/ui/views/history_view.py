"""
exe/tow - Build History View
Displays previous compile records with project details, timestamps, statuses, and output folder actions.
"""

import os
import subprocess
from PySide6.QtCore import Qt
from PySide6.QtWidgets import (
    QWidget, QVBoxLayout, QHBoxLayout, QLabel, QPushButton, QFrame,
    QTableWidget, QTableWidgetItem, QHeaderView, QMessageBox
)
from exe_tow.ui.theme import ThemeColors

class HistoryView(QWidget):
    """Build History table view for exe/tow."""

    def __init__(self, history_manager, parent=None):
        super().__init__(parent)
        self.history = history_manager

        layout = QVBoxLayout(self)
        layout.setContentsMargins(32, 28, 32, 28)
        layout.setSpacing(20)

        # Header Row
        header_row = QHBoxLayout()
        header_title = QLabel("Build History")
        header_title.setObjectName("TitleLabel")

        btn_clear = QPushButton("🗑 Clear History")
        btn_clear.setCursor(Qt.PointingHandCursor)
        btn_clear.clicked.connect(self._clear_history)

        header_row.addWidget(header_title)
        header_row.addStretch()
        header_row.addWidget(btn_clear)
        layout.addLayout(header_row)

        # History Table
        self.table = QTableWidget()
        self.table.setColumnCount(5)
        self.table.setHorizontalHeaderLabels([
            "Project", "Date & Time", "Build Status", "Output Path", "Actions"
        ])
        self.table.horizontalHeader().setSectionResizeMode(0, QHeaderView.ResizeToContents)
        self.table.horizontalHeader().setSectionResizeMode(1, QHeaderView.ResizeToContents)
        self.table.horizontalHeader().setSectionResizeMode(2, QHeaderView.ResizeToContents)
        self.table.horizontalHeader().setSectionResizeMode(3, QHeaderView.Stretch)
        self.table.horizontalHeader().setSectionResizeMode(4, QHeaderView.ResizeToContents)
        self.table.verticalHeader().setVisible(False)

        layout.addWidget(self.table)

        self.refresh_history()

    def refresh_history(self):
        records = self.history.get_records()
        self.table.setRowCount(0)

        for rec in records:
            row = self.table.rowCount()
            self.table.insertRow(row)

            p_name = rec.get("project_name", "Unknown")
            timestamp = rec.get("timestamp", "-")
            status = rec.get("status", "SUCCESS")
            output_path = rec.get("output_exe") or rec.get("output_folder", "-")

            item_p = QTableWidgetItem(p_name)
            item_t = QTableWidgetItem(timestamp)

            item_status = QTableWidgetItem(f"✓ {status}" if status == "SUCCESS" else f"✕ {status}")
            if status == "SUCCESS":
                item_status.setForeground(Qt.green)
            else:
                item_status.setForeground(Qt.red)

            item_out = QTableWidgetItem(output_path)

            self.table.setItem(row, 0, item_p)
            self.table.setItem(row, 1, item_t)
            self.table.setItem(row, 2, item_status)
            self.table.setItem(row, 3, item_out)

            # Action button
            out_folder = rec.get("output_folder") or os.path.dirname(output_path)
            btn_open = QPushButton("📁 Folder")
            btn_open.setCursor(Qt.PointingHandCursor)
            btn_open.clicked.connect(lambda checked=False, f=out_folder: self._open_folder(f))
            self.table.setCellWidget(row, 4, btn_open)

    def _open_folder(self, folder_path: str):
        if folder_path and os.path.exists(folder_path):
            if os.name == "nt":
                os.startfile(folder_path)
            elif os.uname().sysname == "Darwin":
                subprocess.Popen(["open", folder_path])
            else:
                subprocess.Popen(["xdg-open", folder_path])

    def _clear_history(self):
        reply = QMessageBox.question(self, "Clear History", "Are you sure you want to clear build history?",
                                     QMessageBox.Yes | QMessageBox.No)
        if reply == QMessageBox.Yes:
            self.history.clear()
            self.refresh_history()
