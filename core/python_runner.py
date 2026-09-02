"""
MSAI Studio - Python Execution Engine
"""
import os
from PyQt6.QtCore import QObject, pyqtSignal
from core.process_manager import ProcessManager

class PythonRunner(QObject):
    """
    Handles execution of Python files using chosen interpreter, streaming stdio,
    and supporting stop/restart operations.
    """
    output_received = pyqtSignal(str)
    error_received = pyqtSignal(str)
    execution_started = pyqtSignal(str) # script_path
    execution_finished = pyqtSignal(int) # exit_code

    def __init__(self, parent=None):
        super().__init__(parent)
        self.process_manager = ProcessManager(self)
        self.process_manager.output_signal.connect(self.output_received)
        self.process_manager.error_signal.connect(self.error_received)
        self.process_manager.started_signal.connect(self._on_started)
        self.process_manager.finished_signal.connect(self._on_finished)

        self.current_script: str = ""
        self.interpreter_path: str = ""

    def set_interpreter(self, path: str):
        """Set Python interpreter executable path."""
        self.interpreter_path = path

    def run_file(self, script_path: str, interpreter_path: str = None, args: list = None):
        """Runs specified Python file asynchronously."""
        if not os.path.exists(script_path):
            self.error_received.emit(f"Error: Script file not found: {script_path}\n")
            return False

        python_bin = interpreter_path or self.interpreter_path or "python3"
        self.current_script = script_path

        cmd_args = ["-u", script_path]  # -u unbuffered binary stdout and stderr
        if args:
            cmd_args.extend(args)

        working_dir = os.path.dirname(os.path.abspath(script_path))

        self.output_received.emit(f"\n--- Running: {python_bin} {script_path} ---\n")
        self.process_manager.start_process(python_bin, cmd_args, working_dir=working_dir)
        return True

    def stop(self):
        """Stops script execution."""
        if self.process_manager.is_running():
            self.output_received.emit("\n--- Execution stopped by user ---\n")
            self.process_manager.stop_process()

    def restart(self, args: list = None):
        """Restarts execution of current script."""
        if self.current_script:
            self.stop()
            self.run_file(self.current_script, args=args)

    def write_input(self, text: str):
        """Send input to process."""
        self.process_manager.write_input(text)

    def is_running(self) -> bool:
        return self.process_manager.is_running()

    def _on_started(self):
        self.execution_started.emit(self.current_script)

    def _on_finished(self, exit_code: int):
        self.output_received.emit(f"\n--- Process finished with exit code {exit_code} ---\n")
        self.execution_finished.emit(exit_code)
