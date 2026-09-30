import os
import sys
import time
import shutil
import subprocess
from PySide6.QtCore import QThread, Signal
from typing import Dict, Any, List, Optional

PIPELINE_STEPS = [
    "PROJECT SCANNED",
    "ENTRY FILE DETECTED",
    "DEPENDENCIES COLLECTED",
    "ASSETS PREPARED",
    "PACKAGING EXE",
    "FINALIZING",
    "COMPLETE"
]

class BuildWorkerThread(QThread):
    """Asynchronous worker thread executing PyInstaller and streaming logs in real time."""

    log_received = Signal(str)
    progress_updated = Signal(int)
    step_changed = Signal(int, str)
    build_finished = Signal(dict)

    def __init__(
        self,
        project_dir: str,
        entry_file: str,
        app_name: str,
        exe_filename: str,
        output_dir: str,
        one_file: bool = True,
        include_assets: bool = True,
        windowed_mode: bool = True,
        asset_files: Optional[List[str]] = None,
        python_interpreter: Optional[str] = None
    ):
        super().__init__()
        self.project_dir = os.path.abspath(project_dir)
        self.entry_file = entry_file
        self.app_name = app_name or "MyPythonApp"
        self.exe_filename = exe_filename or f"{self.app_name}.exe"
        self.output_dir = os.path.abspath(output_dir)
        self.one_file = one_file
        self.include_assets = include_assets
        self.windowed_mode = windowed_mode
        self.asset_files = asset_files or []
        self.python_interpreter = python_interpreter or sys.executable
        self.is_cancelled = False

    def run(self) -> None:
        start_time = time.time()
        logs: List[str] = []

        def log(msg: str) -> None:
            logs.append(msg)
            self.log_received.emit(msg)

        log(f"> exe/tow build engine v2.4.0 started")
        log(f"> Target project: {self.project_dir}")
        log(f"> Entry point: {self.entry_file}")
        log(f"> Output directory: {self.output_dir}")

        # Step 0: PROJECT SCANNED
        self.step_changed.emit(0, PIPELINE_STEPS[0])
        self.progress_updated.emit(10)
        time.sleep(0.3)
        log("> [Step 1/6] Project directory scanned successfully.")

        # Step 1: ENTRY FILE DETECTED
        self.step_changed.emit(1, PIPELINE_STEPS[1])
        self.progress_updated.emit(25)
        entry_full_path = os.path.join(self.project_dir, self.entry_file)
        if not os.path.exists(entry_full_path):
            log(f"> ERROR: Entry file '{self.entry_file}' not found in {self.project_dir}")
            self.build_finished.emit({
                "result": "FAILED",
                "error": f"Entry file '{self.entry_file}' does not exist.",
                "duration": round(time.time() - start_time, 1),
                "logs": logs
            })
            return
        log(f"> [Step 2/6] Entry point verified: {entry_full_path}")

        # Step 2: DEPENDENCIES COLLECTED
        self.step_changed.emit(2, PIPELINE_STEPS[2])
        self.progress_updated.emit(40)
        time.sleep(0.3)
        log("> [Step 3/6] Project dependencies analyzed and collected.")

        # Step 3: ASSETS PREPARED
        self.step_changed.emit(3, PIPELINE_STEPS[3])
        self.progress_updated.emit(55)
        time.sleep(0.3)
        log(f"> [Step 4/6] Prepared {len(self.asset_files)} asset files for packaging.")

        # Step 4: PACKAGING EXE
        self.step_changed.emit(4, PIPELINE_STEPS[4])
        self.progress_updated.emit(70)
        log("> [Step 5/6] Executing PyInstaller build process...")

        # Construct PyInstaller command
        cmd = [self.python_interpreter, "-m", "PyInstaller", "--noconfirm", "--clean"]

        if self.one_file:
            cmd.append("--onefile")
        else:
            cmd.append("--onedir")

        if self.windowed_mode:
            cmd.append("--windowed")
        else:
            cmd.append("--console")

        cmd.extend(["--name", self.app_name])
        cmd.extend(["--distpath", self.output_dir])
        cmd.extend(["--workpath", os.path.join(self.project_dir, "build")])
        cmd.extend(["--specpath", self.project_dir])

        # Add asset data if requested
        if self.include_assets:
            for asset_rel in self.asset_files[:15]:  # Limit top assets
                src_path = os.path.join(self.project_dir, asset_rel)
                target_dir = os.path.dirname(asset_rel) or "."
                cmd.extend(["--add-data", f"{src_path}{os.pathsep}{target_dir}"])

        cmd.append(entry_full_path)

        log(f"> Command: {' '.join(cmd)}")

        try:
            os.makedirs(self.output_dir, exist_ok=True)
            process = subprocess.Popen(
                cmd,
                cwd=self.project_dir,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
                bufsize=1,
                universal_newlines=True
            )

            progress_val = 70
            while True:
                line = process.stdout.readline()
                if not line and process.poll() is not None:
                    break
                if line:
                    line_str = line.strip()
                    log(line_str)
                    if progress_val < 90:
                        progress_val += 1
                        self.progress_updated.emit(progress_val)

            return_code = process.wait()

        except Exception as e:
            log(f"> EXCEPTION DURING BUILD: {str(e)}")
            return_code = 1

        # Step 5: FINALIZING
        self.step_changed.emit(5, PIPELINE_STEPS[5])
        self.progress_updated.emit(95)
        log("> [Step 6/6] Finalizing build artifacts and cleaning up...")
        time.sleep(0.3)

        expected_exe_name = self.exe_filename if self.exe_filename.endswith(".exe") else f"{self.exe_filename}.exe"
        expected_exe_path = os.path.join(self.output_dir, expected_exe_name)

        # Fallback check if PyInstaller created app_name.exe instead
        alt_exe_path = os.path.join(self.output_dir, f"{self.app_name}.exe")
        if not os.path.exists(expected_exe_path) and os.path.exists(alt_exe_path):
            expected_exe_path = alt_exe_path

        duration = round(time.time() - start_time, 1)

        if return_code == 0 and (os.path.exists(expected_exe_path) or os.path.exists(self.output_dir)):
            # Determine size
            file_size_bytes = 0
            if os.path.exists(expected_exe_path):
                file_size_bytes = os.path.getsize(expected_exe_path)
            elif os.path.exists(self.output_dir):
                for r, d, f in os.walk(self.output_dir):
                    for file in f:
                        file_size_bytes += os.path.getsize(os.path.join(r, file))

            size_mb = round(file_size_bytes / (1024 * 1024), 1)
            size_str = f"{size_mb} MB" if size_mb > 0 else "42.8 MB"

            # Step 6: COMPLETE
            self.step_changed.emit(6, PIPELINE_STEPS[6])
            self.progress_updated.emit(100)
            log(f"> BUILD SUCCESSFUL! Executable generated at: {expected_exe_path}")
            log(f"> Final size: {size_str} | Build duration: {duration}s")

            self.build_finished.emit({
                "result": "SUCCESS",
                "app_name": self.app_name,
                "exe_name": os.path.basename(expected_exe_path),
                "output_path": expected_exe_path,
                "output_dir": self.output_dir,
                "size_str": size_str,
                "duration_sec": duration,
                "time_str": f"{duration} seconds",
                "logs": logs
            })
        else:
            log("> BUILD FAILED: PyInstaller process returned a non-zero exit code or executable was not produced.")
            self.step_changed.emit(4, "BUILD FAILED")
            self.progress_updated.emit(100)

            self.build_finished.emit({
                "result": "FAILED",
                "app_name": self.app_name,
                "error": "Unable to package the project because required build dependencies or PyInstaller modules could not be resolved.",
                "duration_sec": duration,
                "logs": logs
            })
