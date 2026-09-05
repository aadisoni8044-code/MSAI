"""NV Studio Interactive Subprocess Terminal supporting multiple terminal sessions"""
import os
import sys
import subprocess
from PyQt6.QtCore import QProcess, Qt, pyqtSignal
from PyQt6.QtGui import QFont, QTextCursor
from PyQt6.QtWidgets import (
    QHBoxLayout, QLineEdit, QPlainTextEdit, QPushButton, QTabWidget, QVBoxLayout, QWidget, QToolButton
)

from nvstudio.core.config import config_manager
from nvstudio.core.workspace import workspace_manager


class SingleTerminalSession(QWidget):
    """Single interactive subprocess terminal session view."""

    def __init__(self, session_id: int, parent=None):
        super().__init__(parent)
        self.session_id = session_id

        layout = QVBoxLayout(self)
        layout.setContentsMargins(4, 4, 4, 4)
        layout.setSpacing(4)

        # Output console
        self.output = QPlainTextEdit()
        self.output.setReadOnly(True)
        self.output.setStyleSheet("""
            QPlainTextEdit {
                background-color: #0d1117;
                color: #e6edf3;
                font-family: 'Consolas', 'Courier New', monospace;
                font-size: 12px;
                border: none;
            }
        """)
        layout.addWidget(self.output)

        # Command prompt input row
        input_row = QHBoxLayout()
        input_row.setSpacing(4)

        self.prompt_label = QLineEdit("$")
        self.prompt_label.setReadOnly(True)
        self.prompt_label.setFixedWidth(30)
        self.prompt_label.setStyleSheet("border: none; color: #4f80ff; font-weight: bold; background: transparent;")

        self.cmd_input = QLineEdit()
        self.cmd_input.setPlaceholderText("Enter terminal command...")
        self.cmd_input.returnPressed.connect(self.execute_command)

        self.clear_btn = QPushButton("Clear")
        self.clear_btn.setFixedWidth(50)
        self.clear_btn.clicked.connect(self.clear_output)

        input_row.addWidget(self.prompt_label)
        input_row.addWidget(self.cmd_input)
        input_row.addWidget(self.clear_btn)

        layout.addLayout(input_row)

        self.append_output(f"NV Studio Terminal Session {session_id} v1.0.0\nType commands below to execute system process.\n" + "-"*50)

    def append_output(self, text: str) -> None:
        self.output.moveCursor(QTextCursor.MoveOperation.End)
        self.output.insertPlainText(text + "\n")
        self.output.moveCursor(QTextCursor.MoveOperation.End)

    def clear_output(self) -> None:
        self.output.clear()

    def execute_command(self) -> None:
        cmd = self.cmd_input.text().strip()
        if not cmd:
            return

        self.cmd_input.clear()
        self.append_output(f"$ {cmd}")

        if cmd == "clear":
            self.clear_output()
            return

        cwd = workspace_manager.get_root_path() or os.getcwd()
        if cmd.startswith("cd "):
            new_dir = cmd[3:].strip()
            target = os.path.abspath(os.path.join(cwd, new_dir))
            if os.path.exists(target) and os.path.isdir(target):
                workspace_manager.open_folder(target)
                self.append_output(f"Changed directory to {target}")
            else:
                self.append_output(f"cd: no such file or directory: {new_dir}")
            return

        try:
            res = subprocess.run(
                cmd,
                shell=True,
                cwd=cwd,
                capture_output=True,
                text=True,
                timeout=15
            )
            if res.stdout:
                self.append_output(res.stdout.rstrip())
            if res.stderr:
                self.append_output(res.stderr.rstrip())
        except subprocess.TimeoutExpired:
            self.append_output("Command execution timed out (15s).")
        except Exception as e:
            self.append_output(f"Execution error: {e}")


class TerminalWidget(QWidget):
    """Container managing multiple terminal session tabs."""

    def __init__(self, parent=None):
        super().__init__(parent)

        layout = QVBoxLayout(self)
        layout.setContentsMargins(0, 0, 0, 0)
        layout.setSpacing(0)

        # Tab Widget for Terminal Sessions
        self.tab_widget = QTabWidget()
        self.tab_widget.setTabsClosable(True)
        self.tab_widget.tabCloseRequested.connect(self._close_terminal_session)

        # Add New Session (+) Button in Tab Corner
        self.add_session_btn = QToolButton()
        self.add_session_btn.setText("+")
        self.add_session_btn.setToolTip("New Terminal Session")
        self.add_session_btn.clicked.connect(self.new_terminal_session)
        self.tab_widget.setCornerWidget(self.add_session_btn, Qt.Corner.TopRightCorner)

        layout.addWidget(self.tab_widget)

        self.session_counter = 0
        self.new_terminal_session()

    @property
    def cmd_input(self):
        curr = self.tab_widget.currentWidget()
        return curr.cmd_input if curr else None

    @property
    def output(self):
        curr = self.tab_widget.currentWidget()
        return curr.output if curr else None

    def execute_command(self) -> None:
        curr = self.tab_widget.currentWidget()
        if curr:
            curr.execute_command()

    def new_terminal_session(self) -> SingleTerminalSession:
        self.session_counter += 1
        session = SingleTerminalSession(self.session_counter)
        idx = self.tab_widget.addTab(session, f"Terminal {self.session_counter}")
        self.tab_widget.setCurrentIndex(idx)
        return session

    def _close_terminal_session(self, index: int) -> None:
        if self.tab_widget.count() > 1:
            widget = self.tab_widget.widget(index)
            self.tab_widget.removeTab(index)
            widget.deleteLater()
