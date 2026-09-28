from PySide6.QtWidgets import (
    QWidget, QVBoxLayout, QHBoxLayout, QLabel, QTableWidget, QTableWidgetItem,
    QHeaderView, QLineEdit, QPushButton, QDialog, QTextEdit
)
from PySide6.QtCore import Qt
from exe_tow.ui.theme import Theme
from exe_tow.core.history_manager import HistoryManager

class CommandDetailModal(QDialog):
    def __init__(self, cmd_data: dict, parent=None):
        super().__init__(parent)
        self.setWindowTitle("Command Execution Details")
        self.resize(700, 500)

        layout = QVBoxLayout(self)

        lbl_cmd = QLabel(f"Command: {cmd_data.get('command_text')}")
        lbl_cmd.setWordWrap(True)
        lbl_cmd.setStyleSheet("font-weight: bold; font-family: monospace;")
        layout.addWidget(lbl_cmd)

        txt = QTextEdit()
        txt.setReadOnly(True)

        output_str = f"Reason: {cmd_data.get('reason')}\n"
        output_str += f"Status: {cmd_data.get('status')}\n"
        output_str += f"Exit Code: {cmd_data.get('exit_code')}\n"
        output_str += f"Duration: {cmd_data.get('duration')}s\n"
        output_str += "="*50 + "\nSTDOUT / STDERR OUTPUT:\n"
        output_str += cmd_data.get('stdout', '') + "\n" + cmd_data.get('stderr', '')

        txt.setText(output_str)
        layout.addWidget(txt)

        btn_close = QPushButton("Close")
        btn_close.clicked.connect(self.accept)
        layout.addWidget(btn_close)

class CommandHistoryView(QWidget):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.history_manager = HistoryManager()
        self.all_records = []

        layout = QVBoxLayout(self)
        layout.setContentsMargins(24, 24, 24, 24)
        layout.setSpacing(16)

        hdr = QHBoxLayout()
        title = QLabel("Executed Command History")
        title.setObjectName("heading")
        hdr.addWidget(title)
        hdr.addStretch()

        self.btn_refresh = QPushButton("Refresh")
        self.btn_refresh.clicked.connect(self.refresh)
        hdr.addWidget(self.btn_refresh)
        layout.addLayout(hdr)

        # Search Bar
        self.txt_search = QLineEdit()
        self.txt_search.setPlaceholderText("Search commands by text, reason, or status...")
        self.txt_search.textChanged.connect(self._filter_table)
        layout.addWidget(self.txt_search)

        # Table
        self.table = QTableWidget()
        self.table.setColumnCount(5)
        self.table.setHorizontalHeaderLabels(["Time", "Command", "Status", "Exit Code", "Duration"])
        self.table.horizontalHeader().setSectionResizeMode(1, QHeaderView.Stretch)
        self.table.setSelectionBehavior(QTableWidget.SelectRows)
        self.table.setEditTriggers(QTableWidget.NoEditTriggers)
        self.table.cellDoubleClicked.connect(self._on_cell_double_click)
        layout.addWidget(self.table)

        self.refresh()

    def refresh(self):
        self.all_records = self.history_manager.get_command_history()
        self._populate_table(self.all_records)

    def _filter_table(self, query: str):
        query = query.lower().strip()
        if not query:
            self._populate_table(self.all_records)
            return

        filtered = [
            r for r in self.all_records
            if query in r.get("command_text", "").lower()
            or query in r.get("reason", "").lower()
            or query in r.get("status", "").lower()
        ]
        self._populate_table(filtered)

    def _populate_table(self, records: list):
        self.table.setRowCount(len(records))
        for row, r in enumerate(reversed(records)):
            self.table.setItem(row, 0, QTableWidgetItem(str(r.get("timestamp", ""))))
            self.table.setItem(row, 1, QTableWidgetItem(str(r.get("command_text", ""))))

            st_item = QTableWidgetItem(str(r.get("status", "")))
            if r.get("status") == "SUCCESS":
                st_item.setForeground(Qt.green)
            elif r.get("status") == "FAILED":
                st_item.setForeground(Qt.red)
            self.table.setItem(row, 2, st_item)

            self.table.setItem(row, 3, QTableWidgetItem(str(r.get("exit_code", ""))))
            self.table.setItem(row, 4, QTableWidgetItem(f"{r.get('duration', 0)}s"))

    def _on_cell_double_click(self, row, col):
        rev_records = list(reversed(self.all_records))
        if row < len(rev_records):
            modal = CommandDetailModal(rev_records[row], self)
            modal.exec()
