"""Command Runner module for safe and controlled execution of subprocesses."""

import subprocess
import time
import threading
from typing import List, Optional, Callable
from models.command_result import CommandResult
from app.logger import logger


class CommandRunner:
    """Executes subprocess commands safely without shell execution, streaming logs, and handling cancellation."""

    DANGEROUS_PATTERNS = [
        "rmdir /s /q c:\\",
        "del /f /s /q c:\\",
        "format ",
        "reg delete",
        "bcdedit",
        "netsh",
        "vssadmin"
    ]

    def __init__(self):
        self._current_process: Optional[subprocess.Popen] = None
        self._stop_requested = False

    def is_command_safe(self, cmd_args: List[str]) -> bool:
        """Validates command against dangerous system operations."""
        cmd_str = " ".join(cmd_args).lower()
        for pattern in self.DANGEROUS_PATTERNS:
            if pattern in cmd_str:
                logger.error(f"Command failed safety validation: {cmd_str}")
                return False
        return True

    def run(
        self,
        cmd_args: List[str],
        cwd: Optional[str] = None,
        timeout: Optional[float] = None,
        on_stdout: Optional[Callable[[str], None]] = None,
        on_stderr: Optional[Callable[[str], None]] = None
    ) -> CommandResult:
        """Executes a command safely as a list of arguments."""
        if not self.is_command_safe(cmd_args):
            return CommandResult(
                command=cmd_args,
                exit_code=-1,
                stdout="",
                stderr="Command rejected by safety validation layer.",
                duration=0.0
            )

        logger.info(f"Executing command: {' '.join(cmd_args)} (CWD: {cwd})")
        self._stop_requested = False
        start_time = time.time()

        stdout_lines: List[str] = []
        stderr_lines: List[str] = []

        try:
            self._current_process = subprocess.Popen(
                cmd_args,
                cwd=cwd,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                bufsize=1,
                universal_newlines=True
            )

            def read_stream(stream, lines_acc, callback):
                for line in iter(stream.readline, ''):
                    if self._stop_requested:
                        break
                    lines_acc.append(line)
                    if callback:
                        try:
                            callback(line)
                        except Exception:
                            pass
                stream.close()

            t_stdout = threading.Thread(
                target=read_stream,
                args=(self._current_process.stdout, stdout_lines, on_stdout)
            )
            t_stderr = threading.Thread(
                target=read_stream,
                args=(self._current_process.stderr, stderr_lines, on_stderr)
            )

            t_stdout.start()
            t_stderr.start()

            timed_out = False
            try:
                self._current_process.wait(timeout=timeout)
            except subprocess.TimeoutExpired:
                timed_out = True
                self.cancel()

            t_stdout.join()
            t_stderr.join()

            duration = time.time() - start_time
            exit_code = self._current_process.returncode if self._current_process else -1

            return CommandResult(
                command=cmd_args,
                exit_code=exit_code if exit_code is not None else -1,
                stdout="".join(stdout_lines),
                stderr="".join(stderr_lines),
                duration=duration,
                cancelled=self._stop_requested,
                timed_out=timed_out
            )

        except Exception as e:
            duration = time.time() - start_time
            logger.error(f"Command execution error: {e}")
            return CommandResult(
                command=cmd_args,
                exit_code=-1,
                stdout="".join(stdout_lines),
                stderr=f"Execution error: {str(e)}\n" + "".join(stderr_lines),
                duration=duration,
                cancelled=self._stop_requested
            )
        finally:
            self._current_process = None

    def cancel(self):
        """Cancels current running subprocess."""
        self._stop_requested = True
        if self._current_process:
            try:
                logger.info("Terminating current build process...")
                self._current_process.terminate()
                time.sleep(0.5)
                if self._current_process.poll() is None:
                    self._current_process.kill()
            except Exception as e:
                logger.error(f"Error terminating process: {e}")
