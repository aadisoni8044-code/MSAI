"""
MSAI Studio - Run & Debug View Component
"""
from PyQt6.QtWidgets import (
    QWidget, QVBoxLayout, QHBoxLayout, QLabel, QPushButton, QTreeWidget, QTreeWidgetItem
)
from PyQt6.QtCore import pyqtSignal, Qt
from debug.debugger import Debugger

class DebugView(QWidget):
    """
    Run & Debug panel displaying debugging actions (start, stop, step over/into/out),
    breakpoints list, call stack, and frame variables inspection.
    """
    start_debug_requested = pyqtSignal()
    stop_debug_requested = pyqtSignal()

    def __init__(self, debugger: Debugger, parent=None):
        super().__init__(parent)
        self.debugger = debugger

        layout = QVBoxLayout(self)
        layout.setContentsMargins(8, 8, 8, 8)

        title = QLabel("RUN & DEBUG")
        title.setStyleSheet("font-size: 11px; font-weight: bold; color: #a6adc8;")
        layout.addWidget(title)

        # Action Buttons
        btn_layout = QHBoxLayout()
        self.btn_start = QPushButton("▶️ Debug")
        self.btn_start.setStyleSheet("background-color: #89b4fa; color: #11111b; font-weight: bold;")
        self.btn_stop = QPushButton("⏹️ Stop")
        self.btn_step_over = QPushButton("↷ Step")

        self.btn_start.clicked.connect(self.start_debug_requested.emit)
        self.btn_stop.clicked.connect(self.stop_debug_requested.emit)

        btn_layout.addWidget(self.btn_start)
        btn_layout.addWidget(self.btn_stop)
        btn_layout.addWidget(self.btn_step_over)
        layout.addLayout(btn_layout)

        # Variables Tree
        layout.addWidget(QLabel("<b>Variables</b>"))
        self.vars_tree = QTreeWidget()
        self.vars_tree.setHeaderLabels(["Name", "Value"])
        layout.addWidget(self.vars_tree)

        # Breakpoints Tree
        layout.addWidget(QLabel("<b>Breakpoints</b>"))
        self.bp_tree = QTreeWidget()
        self.bp_tree.setHeaderLabels(["File", "Line"])
        layout.addWidget(self.bp_tree)

    def refresh_breakpoints(self):
        self.bp_tree.clear()
        for filename, lines in self.debugger.breakpoints.items():
            for line in lines:
                item = QTreeWidgetItem([filename, str(line)])
                self.bp_tree.addTopLevelItem(item)

    def update_variables(self, variables: dict):
        self.vars_tree.clear()
        for k, v in variables.items():
            item = QTreeWidgetItem([k, str(v)])
            self.vars_tree.addTopLevelItem(item)
