"""
MSAI Studio - Process Manager
"""
import sys
from PyQt6.QtCore import QObject, QProcess, pyqtSignal

class ProcessManager(QObject):
    """
    Asynchronous process runner using QProcess to execute shell commands
    and Python scripts without freezing the UI.
    """
    output_signal = pyqtSignal(str)
    error_signal = pyqtSignal(str)
    started_signal = pyqtSignal()
    finished_signal = pyqtSignal(int)

    def __init__(self, parent=None):
        super().__init__(parent)
        self.process = QProcess(self)
        self.process.readyReadStandardOutput.connect(self._handle_stdout)
        self.process.readyReadStandardError.connect(self._handle_stderr)
        self.process.started.connect(self.started_signal)
        self.process.finished.connect(self._handle_finished)

    def start_process(self, command: str, args: list, working_dir: str = None):
        """Starts an external process."""
        if self.is_running():
            self.stop_process()

        if working_dir:
            self.process.setWorkingDirectory(working_dir)

        self.process.start(command, args)

    def write_input(self, text: str):
        """Send input to running process standard input."""
        if self.is_running():
            if not text.endswith("\n"):
                text += "\n"
            self.process.write(text.encode("utf-8"))

    def stop_process(self):
        """Terminates or kills active process."""
        if self.is_running():
            self.process.terminate()
            if not self.process.waitForFinished(1000):
                self.process.kill()

    def is_running(self) -> bool:
        """Returns True if process is running."""
        return self.process.state() != QProcess.ProcessState.NotRunning

    def _handle_stdout(self):
        data = self.process.readAllStandardOutput().data().decode("utf-8", errors="replace")
        self.output_signal.emit(data)

    def _handle_stderr(self):
        data = self.process.readAllStandardError().data().decode("utf-8", errors="replace")
        self.error_signal.emit(data)

    def _handle_finished(self, exit_code: int, exit_status):
        self.finished_signal.emit(exit_code)
