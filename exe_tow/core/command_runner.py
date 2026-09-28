import os
import time
import subprocess
import shlex
import uuid
import threading
from typing import List, Callable, Optional
from exe_tow.core.models import CommandExecution, CommandStatus

class CommandRunner:
    def __init__(self, timeout: int = 600):
        self.default_timeout = timeout
        self.active_process: Optional[subprocess.Popen] = None
        self._cancelled = False

    def run_command(
        self,
        command_list: List[str],
        reason: str,
        cwd: Optional[str] = None,
        env: Optional[dict] = None,
        output_callback: Optional[Callable[[str], None]] = None,
        timeout: Optional[int] = None
    ) -> CommandExecution:
        cmd_id = str(uuid.uuid4())[:8]
        cmd_str = " ".join(shlex.quote(arg) for arg in command_list)

        execution = CommandExecution(
            id=cmd_id,
            command_text=cmd_str,
            reason=reason,
            status=CommandStatus.RUNNING
        )

        start_time = time.time()
        timeout_val = timeout if timeout is not None else self.default_timeout
        self._cancelled = False

        stdout_lines = []
        stderr_lines = []

        try:
            # Prepare execution environment
            cmd_env = os.environ.copy()
            if env:
                cmd_env.update(env)

            self.active_process = subprocess.Popen(
                command_list,
                cwd=cwd,
                env=cmd_env,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,  # Merge stderr into stdout for unified logging stream
                text=True,
                bufsize=1,
                universal_newlines=True
            )

            def stream_reader():
                assert self.active_process is not None
                if self.active_process.stdout:
                    for line in iter(self.active_process.stdout.readline, ''):
                        if not line:
                            break
                        stdout_lines.append(line)
                        if output_callback:
                            try:
                                output_callback(line)
                            except Exception:
                                pass
                    self.active_process.stdout.close()

            reader_thread = threading.Thread(target=stream_reader, daemon=True)
            reader_thread.start()

            # Wait for process completion or timeout
            while reader_thread.is_alive():
                if self._cancelled:
                    if self.active_process:
                        self.active_process.kill()
                    execution.status = CommandStatus.CANCELLED
                    execution.stdout = "".join(stdout_lines)
                    execution.duration = round(time.time() - start_time, 2)
                    return execution

                if (time.time() - start_time) > timeout_val:
                    if self.active_process:
                        self.active_process.kill()
                    execution.status = CommandStatus.FAILED
                    execution.stdout = "".join(stdout_lines)
                    execution.stderr = f"Command timed out after {timeout_val} seconds."
                    execution.duration = round(time.time() - start_time, 2)
                    return execution

                time.sleep(0.1)

            reader_thread.join(timeout=2.0)
            return_code = self.active_process.poll() if self.active_process else -1

            execution.exit_code = return_code
            execution.stdout = "".join(stdout_lines)
            execution.stderr = "".join(stderr_lines)
            execution.duration = round(time.time() - start_time, 2)

            if return_code == 0:
                execution.status = CommandStatus.SUCCESS
            else:
                execution.status = CommandStatus.FAILED

        except FileNotFoundError as e:
            execution.status = CommandStatus.FAILED
            execution.exit_code = 127
            execution.stderr = f"Executable not found: {str(e)}"
            execution.duration = round(time.time() - start_time, 2)
        except Exception as e:
            execution.status = CommandStatus.FAILED
            execution.exit_code = 1
            execution.stderr = f"Execution error: {str(e)}"
            execution.duration = round(time.time() - start_time, 2)
        finally:
            self.active_process = None

        return execution

    def cancel(self):
        self._cancelled = True
        if self.active_process:
            try:
                self.active_process.kill()
            except Exception:
                pass
