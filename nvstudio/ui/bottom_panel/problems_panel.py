"""NV Studio Problems & Linting Panel"""
from PyQt6.QtCore import pyqtSignal, Qt
from PyQt6.QtWidgets import QHeaderView, QTableWidget, QTableWidgetItem, QVBoxLayout, QWidget


class ProblemsPanel(QWidget):
    """Problems panel listing syntax errors and linter issues."""
    problem_selected = pyqtSignal(str, int)  # (filepath, line_number)

    def __init__(self, parent=None):
        super().__init__(parent)

        layout = QVBoxLayout(self)
        layout.setContentsMargins(4, 4, 4, 4)

        self.table = QTableWidget(0, 4)
        self.table.setHorizontalHeaderLabels(["Severity", "Description", "File", "Line"])
        self.table.horizontalHeader().setSectionResizeMode(1, QHeaderView.ResizeMode.Stretch)
        self.table.setSelectionBehavior(QTableWidget.SelectionBehavior.SelectRows)
        self.table.cellDoubleClicked.connect(self._on_cell_double_clicked)
        self.table.setStyleSheet("""
            QTableWidget {
                background-color: #0d1117;
                color: #e6edf3;
                border: none;
                gridline-color: #1e2636;
            }
            QHeaderView::section {
                background-color: #10141d;
                color: #94a3b8;
                padding: 4px;
                border: none;
            }
        """)

        layout.addWidget(self.table)

    def set_problems(self, problems_list: list) -> None:
        """Populate problems list: [{severity, desc, file, line}]."""
        self.table.setRowCount(0)
        for p in problems_list:
            row = self.table.rowCount()
            self.table.insertRow(row)

            self.table.setItem(row, 0, QTableWidgetItem(p.get("severity", "Info")))
            self.table.setItem(row, 1, QTableWidgetItem(p.get("desc", "")))
            self.table.setItem(row, 2, QTableWidgetItem(p.get("file", "")))
            self.table.setItem(row, 3, QTableWidgetItem(str(p.get("line", 1))))

    def _on_cell_double_clicked(self, row: int, col: int) -> None:
        file_item = self.table.item(row, 2)
        line_item = self.table.item(row, 3)
        if file_item and line_item:
            try:
                line_num = int(line_item.text())
                self.problem_selected.emit(file_item.text(), line_num)
            except ValueError:
                pass
