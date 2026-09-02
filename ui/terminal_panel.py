"""
MSAI Studio - Collapsible Terminal & Bottom Panels
"""
import os
import sys
from PyQt6.QtWidgets import (
    QWidget, QVBoxLayout, QHBoxLayout, QTabWidget, QTextEdit, QLineEdit,
    QPushButton, QLabel, QListWidget, QListWidgetItem
)
from PyQt6.QtGui import QFont, QTextCursor
from PyQt6.QtCore import pyqtSignal, Qt
from core.process_manager import ProcessManager

class TerminalPanel(QWidget):
    """
    Collapsible Bottom Panel containing Problems, Output, Debug Console, and Integrated Terminal.
    """
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setFixedHeight(220)

        main_layout = QVBoxLayout(self)
        main_layout.setContentsMargins(0, 0, 0, 0)

        # Header with tabs and panel collapse toggle
        self.tabs = QTabWidget(self)

        # 1. Problems Tab
        self.problems_list = QListWidget()
        self.problems_list.setStyleSheet("font-family: monospace;")
        self.tabs.addTab(self.problems_list, "⚠️ Problems")

        # 2. Output Tab
        self.output_edit = QTextEdit()
        self.output_edit.setReadOnly(True)
        self.output_edit.setFont(QFont("Consolas", 11))
        self.tabs.addTab(self.output_edit, "📄 Output")

        # 3. Debug Console Tab
        self.debug_edit = QTextEdit()
        self.debug_edit.setReadOnly(True)
        self.debug_edit.setFont(QFont("Consolas", 11))
        self.tabs.addTab(self.debug_edit, "🐞 Debug Console")

        # 4. Integrated Terminal Tab
        self.terminal_widget = QWidget()
        term_layout = QVBoxLayout(self.terminal_widget)
        term_layout.setContentsMargins(4, 4, 4, 4)

        self.term_output = QTextEdit()
        self.term_output.setReadOnly(True)
        self.term_output.setFont(QFont("Consolas", 11))
        self.term_output.append("MSAI Studio Terminal v1.0.0\nType Python or system commands below:\n")

        term_input_layout = QHBoxLayout()
        self.term_prompt = QLabel("$")
        self.term_prompt.setStyleSheet("color: #89b4fa; font-weight: bold;")
        self.term_input = QLineEdit()
        self.term_input.setPlaceholderText("Enter command...")
        self.term_input.returnPressed.connect(self._handle_terminal_input)

        self.btn_clear_term = QPushButton("Clear")
        self.btn_clear_term.clicked.connect(self.clear_terminal)

        term_input_layout.addWidget(self.term_prompt)
        term_input_layout.addWidget(self.term_input)
        term_input_layout.addWidget(self.btn_clear_term)

        term_layout.addWidget(self.term_output)
        term_layout.addLayout(term_input_layout)

        self.tabs.addTab(self.terminal_widget, "🖥️ Terminal")

        # Set Terminal as default selected tab
        self.tabs.setCurrentIndex(3)

        main_layout.addWidget(self.tabs)

        # Terminal Process Runner
        self.term_process = ProcessManager(self)
        self.term_process.output_signal.connect(self.append_terminal_output)
        self.term_process.error_signal.connect(self.append_terminal_output)

    def append_output(self, text: str):
        """Append text to Output tab."""
        self.output_edit.append(text)
        self.output_edit.moveCursor(QTextCursor.MoveOperation.End)

    def append_terminal_output(self, text: str):
        """Append text to Terminal tab."""
        self.term_output.append(text.rstrip())
        self.term_output.moveCursor(QTextCursor.MoveOperation.End)

    def clear_terminal(self):
        self.term_output.clear()

    def add_problem(self, file_path: str, line: int, message: str, severity: str = "Error"):
        item_text = f"[{severity}] {os.path.basename(file_path)}:{line} - {message}"
        item = QListWidgetItem(item_text)
        item.setForeground(Qt.GlobalColor.red if severity == "Error" else Qt.GlobalColor.yellow)
        self.problems_list.addItem(item)

    def clear_problems(self):
        self.problems_list.clear()

    def _handle_terminal_input(self):
        cmd = self.term_input.text().strip()
        if not cmd:
            return

        self.term_output.append(f"\n$ {cmd}")
        self.term_input.clear()

        if cmd == "clear":
            self.clear_terminal()
            return

        # Execute command in shell process
        shell_bin = "cmd.exe" if sys.platform == "win32" else "/bin/bash"
        args = ["/c", cmd] if sys.platform == "win32" else ["-c", cmd]
        self.term_process.start_process(shell_bin, args, working_dir=os.getcwd())
