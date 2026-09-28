import os
from PySide6.QtWidgets import (
    QWidget, QVBoxLayout, QHBoxLayout, QLabel, QPushButton, QFrame, QFileDialog, QTableWidget, QTableWidgetItem, QHeaderView
)
from PySide6.QtCore import Qt, Signal
from exe_tow.ui.theme import Theme
from exe_tow.core.history_manager import HistoryManager

class DashboardView(QWidget):
    select_project_requested = Signal()
    build_project_requested = Signal(str)  # Project path

    def __init__(self, parent=None):
        super().__init__(parent)
        self.history_manager = HistoryManager()

        layout = QVBoxLayout(self)
        layout.setContentsMargins(24, 24, 24, 24)
        layout.setSpacing(20)

        # Welcome Banner Card
        banner = QFrame()
        banner.setObjectName("card")
        banner_layout = QVBoxLayout(banner)
        banner_layout.setContentsMargins(24, 24, 24, 24)

        title = QLabel("Welcome to EXE/TOW")
        title.setObjectName("heading")
        title.setStyleSheet("font-size: 24px;")
        banner_layout.addWidget(title)

        subtitle = QLabel("Convert Python projects and .py files into standalone Windows .exe executables with automated fallback & environment recovery.")
        subtitle.setObjectName("secondary")
        banner_layout.addWidget(subtitle)

        banner_layout.addSpacing(16)

        btn_row = QHBoxLayout()
        self.btn_select = QPushButton("SELECT PYTHON PROJECT")
        self.btn_select.setObjectName("primary")
        self.btn_select.setCursor(Qt.PointingHandCursor)
        self.btn_select.clicked.connect(self._on_select_click)
        btn_row.addWidget(self.btn_select)

        btn_row.addStretch()
        banner_layout.addLayout(btn_row)

        layout.addWidget(banner)

        # Quick Stats Overview Grid
        stats_layout = QHBoxLayout()

        self.card_total_builds = self._create_stat_card("Total Builds", "0", Theme.ACCENT_PRIMARY)
        self.card_success_rate = self._create_stat_card("Success Rate", "0%", "#7EE787")
        self.card_commands = self._create_stat_card("Executed Commands", "0", Theme.TEXT_PRIMARY)

        stats_layout.addWidget(self.card_total_builds)
        stats_layout.addWidget(self.card_success_rate)
        stats_layout.addWidget(self.card_commands)

        layout.addLayout(stats_layout)

        # Recent Builds Table Section
        lbl_recent = QLabel("Recent Builds")
        lbl_recent.setObjectName("heading")
        layout.addWidget(lbl_recent)

        self.table = QTableWidget()
        self.table.setColumnCount(5)
        self.table.setHorizontalHeaderLabels(["Project", "EXE Name", "Engine", "Status", "Date"])
        self.table.horizontalHeader().setSectionResizeMode(QHeaderView.Stretch)
        self.table.setSelectionBehavior(QTableWidget.SelectRows)
        self.table.setEditTriggers(QTableWidget.NoEditTriggers)
        layout.addWidget(self.table)

        self.refresh()

    def _create_stat_card(self, title: str, value: str, val_color: str) -> QFrame:
        card = QFrame()
        card.setObjectName("card")
        l = QVBoxLayout(card)
        l.setContentsMargins(16, 16, 16, 16)

        lbl_t = QLabel(title)
        lbl_t.setObjectName("secondary")
        l.addWidget(lbl_t)

        lbl_v = QLabel(value)
        lbl_v.setStyleSheet(f"font-size: 28px; font-weight: bold; color: {val_color};")
        lbl_v.setObjectName("value_lbl")
        l.addWidget(lbl_v)

        return card

    def _on_select_click(self):
        self.select_project_requested.emit()

    def refresh(self):
        builds = self.history_manager.get_build_history()
        cmds = self.history_manager.get_command_history()

        total = len(builds)
        succ = sum(1 for b in builds if b.get("status") == "SUCCESS")
        rate = f"{int((succ/total)*100)}%" if total > 0 else "N/A"

        # Update Stat cards
        self.card_total_builds.findChild(QLabel, "value_lbl").setText(str(total))
        self.card_success_rate.findChild(QLabel, "value_lbl").setText(rate)
        self.card_commands.findChild(QLabel, "value_lbl").setText(str(len(cmds)))

        # Update Recent Builds table
        recent_list = list(reversed(builds))[:10]
        self.table.setRowCount(len(recent_list))
        for row, item in enumerate(recent_list):
            self.table.setItem(row, 0, QTableWidgetItem(str(item.get("project_name", ""))))
            self.table.setItem(row, 1, QTableWidgetItem(str(item.get("exe_name", ""))))
            self.table.setItem(row, 2, QTableWidgetItem(str(item.get("build_engine", ""))))

            st_item = QTableWidgetItem(str(item.get("status", "")))
            if item.get("status") == "SUCCESS":
                st_item.setForeground(Qt.green)
            else:
                st_item.setForeground(Qt.red)
            self.table.setItem(row, 3, st_item)

            self.table.setItem(row, 4, QTableWidgetItem(str(item.get("date", ""))))
