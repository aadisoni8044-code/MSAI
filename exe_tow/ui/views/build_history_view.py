import os
import subprocess
from PySide6.QtWidgets import (
    QWidget, QVBoxLayout, QHBoxLayout, QLabel, QTableWidget, QTableWidgetItem,
    QHeaderView, QPushButton, QDialog, QTextEdit
)
from PySide6.QtCore import Qt
from exe_tow.ui.theme import Theme
from exe_tow.core.history_manager import HistoryManager

class BuildDetailModal(QDialog):
    def __init__(self, build_data: dict, parent=None):
        super().__init__(parent)
        self.setWindowTitle(f"Build Details: {build_data.get('exe_name')}")
        self.resize(700, 500)

        layout = QVBoxLayout(self)

        txt = QTextEdit()
        txt.setReadOnly(True)

        info = []
        info.append(f"PROJECT NAME:  {build_data.get('project_name')}")
        info.append(f"EXE NAME:      {build_data.get('exe_name')}")
        info.append(f"DATE:          {build_data.get('date')}")
        info.append(f"BUILD ENGINE:  {build_data.get('build_engine')}")
        info.append(f"BUILD MODE:    {build_data.get('build_mode')}")
        info.append(f"STATUS:        {build_data.get('status')}")
        info.append(f"DURATION:      {build_data.get('duration')} seconds")
        info.append(f"OUTPUT EXE:    {build_data.get('output_exe_path')}")
        info.append(f"SOURCE PATH:   {build_data.get('source_path')}")

        info.append("\n" + "="*50)
        info.append("ATTEMPTED COMMANDS:")
        for idx, cmd in enumerate(build_data.get('commands_attempted', [])):
            info.append(f"\n[Attempt #{idx+1}] Status: {cmd.get('status')} | Exit: {cmd.get('exit_code')}")
            info.append(f"Command: {cmd.get('command_text')}")

        txt.setText("\n".join(info))
        layout.addWidget(txt)

        btn_row = QHBoxLayout()
        btn_open_folder = QPushButton("Open Output Folder")
        out_folder = build_data.get("output_folder")
        btn_open_folder.clicked.connect(lambda: self._open_folder(out_folder))
        btn_row.addWidget(btn_open_folder)

        btn_close = QPushButton("Close")
        btn_close.clicked.connect(self.accept)
        btn_row.addWidget(btn_close)

        layout.addLayout(btn_row)

    def _open_folder(self, folder_path):
        if folder_path and os.path.exists(folder_path):
            if os.name == 'nt':
                os.startfile(folder_path)
            else:
                subprocess.Popen(["xdg-open", folder_path])

class BuildHistoryView(QWidget):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.history_manager = HistoryManager()
        self.all_records = []

        layout = QVBoxLayout(self)
        layout.setContentsMargins(24, 24, 24, 24)
        layout.setSpacing(16)

        hdr = QHBoxLayout()
        title = QLabel("Build History")
        title.setObjectName("heading")
        hdr.addWidget(title)
        hdr.addStretch()

        self.btn_refresh = QPushButton("Refresh")
        self.btn_refresh.clicked.connect(self.refresh)
        hdr.addWidget(self.btn_refresh)
        layout.addLayout(hdr)

        self.table = QTableWidget()
        self.table.setColumnCount(6)
        self.table.setHorizontalHeaderLabels(["Project", "EXE Name", "Date", "Engine", "Result", "Duration"])
        self.table.horizontalHeader().setSectionResizeMode(QHeaderView.Stretch)
        self.table.setSelectionBehavior(QTableWidget.SelectRows)
        self.table.setEditTriggers(QTableWidget.NoEditTriggers)
        self.table.cellDoubleClicked.connect(self._on_cell_double_click)
        layout.addWidget(self.table)

        self.refresh()

    def refresh(self):
        self.all_records = self.history_manager.get_build_history()
        self.table.setRowCount(len(self.all_records))
        for row, r in enumerate(reversed(self.all_records)):
            self.table.setItem(row, 0, QTableWidgetItem(str(r.get("project_name", ""))))
            self.table.setItem(row, 1, QTableWidgetItem(str(r.get("exe_name", ""))))
            self.table.setItem(row, 2, QTableWidgetItem(str(r.get("date", ""))))
            self.table.setItem(row, 3, QTableWidgetItem(str(r.get("build_engine", ""))))

            st_item = QTableWidgetItem(str(r.get("status", "")))
            if r.get("status") == "SUCCESS":
                st_item.setForeground(Qt.green)
            else:
                st_item.setForeground(Qt.red)
            self.table.setItem(row, 4, st_item)

            self.table.setItem(row, 5, QTableWidgetItem(f"{r.get('duration', 0)}s"))

    def _on_cell_double_click(self, row, col):
        rev_records = list(reversed(self.all_records))
        if row < len(rev_records):
            modal = BuildDetailModal(rev_records[row], self)
            modal.exec()
