"""NV Studio Bottom Dock Panel Container assembling Terminal, Output, Problems, and Debug Console"""
from PyQt6.QtCore import pyqtSignal
from PyQt6.QtWidgets import QHBoxLayout, QTabWidget, QVBoxLayout, QWidget

from nvstudio.ui.bottom_panel.terminal import TerminalWidget
from nvstudio.ui.bottom_panel.output_panel import OutputPanel
from nvstudio.ui.bottom_panel.problems_panel import ProblemsPanel
from nvstudio.ui.bottom_panel.debug_console import DebugConsolePanel


class BottomPanel(QWidget):
    """Bottom dock panel tabbed container."""

    def __init__(self, parent=None):
        super().__init__(parent)
        self.setObjectName("BottomPanel")

        layout = QVBoxLayout(self)
        layout.setContentsMargins(0, 0, 0, 0)
        layout.setSpacing(0)

        self.tab_widget = QTabWidget()

        self.terminal = TerminalWidget()
        self.output = OutputPanel()
        self.problems = ProblemsPanel()
        self.debug_console = DebugConsolePanel()

        self.tab_widget.addTab(self.terminal, "TERMINAL")
        self.tab_widget.addTab(self.output, "OUTPUT")
        self.tab_widget.addTab(self.problems, "PROBLEMS")
        self.tab_widget.addTab(self.debug_console, "DEBUG CONSOLE")

        layout.addWidget(self.tab_widget)
