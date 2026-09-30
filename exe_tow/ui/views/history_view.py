from PySide6.QtWidgets import (
    QWidget, QVBoxLayout, QLabel, QTableWidget, QTableWidgetItem, QHeaderView
)
from PySide6.QtCore import Qt
from exe_tow.core.history import HistoryManager


class HistoryView(QWidget):
    """
    Build History view displaying a table of all past builds.
    Columns: Project | EXE | Date | Status | Size
    """

    def __init__(self, history_manager: HistoryManager, parent=None):
        super().__init__(parent)
        self.history_manager = history_manager

        main_layout = QVBoxLayout(self)
        main_layout.setContentsMargins(32, 24, 32, 24)
        main_layout.setSpacing(16)

        # Header
        header_box = QVBoxLayout()
        header_box.setSpacing(4)

        heading = QLabel("BUILD HISTORY", self)
        heading.setStyleSheet("font-size: 24px; font-weight: bold; color: #FFFFFF;")

        subtitle = QLabel("Track and inspect past executable builds and generated output logs.", self)
        subtitle.setStyleSheet("font-size: 13px; color: #8A92A6;")

        header_box.addWidget(heading)
        header_box.addWidget(subtitle)

        main_layout.addLayout(header_box)

        # Build History Table
        self.table = QTableWidget(self)
        self.table.setColumnCount(5)
        self.table.setHorizontalHeaderLabels(["Project", "EXE Name", "Date", "Status", "Size"])
        self.table.horizontalHeader().setSectionResizeMode(QHeaderView.Stretch)
        self.table.verticalHeader().setVisible(False)
        self.table.setSelectionBehavior(QTableWidget.SelectRows)
        self.table.setEditTriggers(QTableWidget.NoEditTriggers)

        main_layout.addWidget(self.table, stretch=1)

        self.refresh_history()

    def refresh_history(self):
        builds = self.history_manager.get_builds()
        self.table.setRowCount(len(builds))

        for row_idx, build in enumerate(builds):
            proj_item = QTableWidgetItem(build.get("project_name", "N/A"))
            exe_item = QTableWidgetItem(build.get("exe_name", "N/A"))
            date_item = QTableWidgetItem(build.get("date", "N/A"))

            status_str = build.get("status", "UNKNOWN")
            status_item = QTableWidgetItem(f"✓ {status_str}" if status_str == "SUCCESS" else f"✕ {status_str}")

            if status_str == "SUCCESS":
                status_item.setForeground(Qt.green)
            else:
                status_item.setForeground(Qt.red)

            size_mb = build.get("size_mb", 0.0)
            size_item = QTableWidgetItem(f"{size_mb:.1f} MB")

            for col_idx, item in enumerate([proj_item, exe_item, date_item, status_item, size_item]):
                item.setFlags(item.flags() ^ Qt.ItemIsEditable)
                self.table.setItem(row_idx, col_idx, item)
