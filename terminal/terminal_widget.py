"""
Embedded terminal panel using QProcess for PyCodeStudio.
"""

import os
import platform
from pathlib import Path
from typing import Optional

from PyQt6.QtCore import QProcess, QProcessEnvironment, Qt, pyqtSignal
from PyQt6.QtGui import QFont, QTextCursor
from PyQt6.QtWidgets import (
    QHBoxLayout,
    QLabel,
    QPushButton,
    QPlainTextEdit,
    QVBoxLayout,
    QWidget,
)

from utils.icon_loader import IconLoader
from utils.logger import logger


class IntegratedTerminalWidget(QWidget):
    """Embedded interactive terminal running native OS shell via QProcess."""

    def __init__(self, working_dir: Optional[Path] = None, parent=None):
        super().__init__(parent)
        self.working_dir = working_dir or Path.home()
        self.process: Optional[QProcess] = None

        layout = QVBoxLayout(self)
        layout.setContentsMargins(0, 0, 0, 0)
        layout.setSpacing(0)

        # Header toolbar
        header = QWidget()
        header.setStyleSheet("background-color: #252526; border-top: 1px solid #1e1e1e;")
        h_layout = QHBoxLayout(header)
        h_layout.setContentsMargins(8, 4, 8, 4)

        title = QLabel("TERMINAL")
        title.setStyleSheet("font-weight: bold; color: #bbbbbb; font-size: 11px;")
        h_layout.addWidget(title)
        h_layout.addStretch()

        btn_clear = QPushButton("Clear")
        btn_clear.setFlat(True)
        btn_clear.clicked.connect(self.clear_terminal)

        btn_kill = QPushButton("Restart Shell")
        btn_kill.setFlat(True)
        btn_kill.clicked.connect(self.restart_shell)

        h_layout.addWidget(btn_clear)
        h_layout.addWidget(btn_kill)

        layout.addWidget(header)

        # Terminal Output View
        self.output_view = QPlainTextEdit()
        self.output_view.setFont(QFont("Consolas", 11))
        self.output_view.setStyleSheet("""
            QPlainTextEdit {
                background-color: #1e1e1e;
                color: #cccccc;
                border: none;
                font-family: Consolas, 'Courier New', monospace;
            }
        """)
        layout.addWidget(self.output_view)

        # Keypress handler binding
        self.output_view.keyPressEvent = self._handle_key_press

        self.input_buffer = ""
        self.start_shell()

    def set_working_directory(self, path: Path) -> None:
        """Sets active working directory for new process commands."""
        self.working_dir = path.resolve()
        if self.process and self.process.state() == QProcess.ProcessState.Running:
            # Send CD command to shell
            cd_cmd = f'cd "{self.working_dir}"\n'
            self.write_command(cd_cmd)

    def start_shell(self) -> None:
        """Spawns native OS shell process."""
        if self.process and self.process.state() != QProcess.ProcessState.NotRunning:
            self.process.kill()

        self.process = QProcess(self)
        self.process.setWorkingDirectory(str(self.working_dir))

        env = QProcessEnvironment.systemEnvironment()
        self.process.setProcessEnvironment(env)

        self.process.readyReadStandardOutput.connect(self._read_std_out)
        self.process.readyReadStandardError.connect(self._read_std_err)

        sys_name = platform.system()
        if sys_name == "Windows":
            shell = os.environ.get("COMSPEC", "cmd.exe")
            self.process.start(shell, [])
        elif sys_name == "Darwin":  # macOS
            shell = os.environ.get("SHELL", "/bin/zsh")
            self.process.start(shell, ["-i"])
        else:  # Linux
            shell = os.environ.get("SHELL", "/bin/bash")
            self.process.start(shell, ["-i"])

    def restart_shell(self) -> None:
        """Kills active process and restarts shell."""
        self.output_view.appendPlainText("\n--- Restarting Shell ---\n")
        self.start_shell()

    def clear_terminal(self) -> None:
        """Clears terminal view text."""
        self.output_view.clear()

    def write_command(self, command: str) -> None:
        """Sends raw text command string to shell standard input."""
        if self.process and self.process.state() == QProcess.ProcessState.Running:
            if not command.endswith("\n"):
                command += "\n"
            self.process.write(command.encode("utf-8"))

    def _read_std_out(self) -> None:
        """Reads stdout from QProcess and appends to output view."""
        if self.process:
            data = self.process.readAllStandardOutput().data().decode("utf-8", errors="replace")
            self._append_output(data)

    def _read_std_err(self) -> None:
        """Reads stderr from QProcess and appends to output view."""
        if self.process:
            data = self.process.readAllStandardError().data().decode("utf-8", errors="replace")
            self._append_output(data)

    def _append_output(self, text: str) -> None:
        """Appends output text and scrolls to bottom."""
        cursor = self.output_view.textCursor()
        cursor.movePosition(QTextCursor.MoveOperation.End)
        cursor.insertText(text)
        self.output_view.setTextCursor(cursor)
        self.output_view.ensureCursorVisible()

    def _handle_key_press(self, event) -> None:
        """Intercepts keyboard typing in terminal area and sends to QProcess stdin."""
        if not self.process or self.process.state() != QProcess.ProcessState.Running:
            return

        key = event.key()
        text = event.text()

        if key in (Qt.Key.Key_Return, Qt.Key.Key_Enter):
            cmd = self.input_buffer + "\n"
            self.process.write(cmd.encode("utf-8"))
            self._append_output("\n")
            self.input_buffer = ""
        elif key == Qt.Key.Key_Backspace:
            if len(self.input_buffer) > 0:
                self.input_buffer = self.input_buffer[:-1]
                cursor = self.output_view.textCursor()
                cursor.deletePreviousChar()
        elif text and text.isprintable():
            self.input_buffer += text
            self._append_output(text)
        else:
            QPlainTextEdit.keyPressEvent(self.output_view, event)

    def closeEvent(self, event) -> None:
        """Terminates process on widget close."""
        if self.process and self.process.state() != QProcess.ProcessState.NotRunning:
            self.process.terminate()
            self.process.waitForFinished(1000)
        super().closeEvent(event)
