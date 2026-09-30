import os
import sys
import time
import subprocess
import shutil
from typing import Dict, Any, Optional
from PySide6.QtCore import QThread, Signal
from exe_tow.core.logger import BuildLogger


class BuilderThread(QThread):
    """
    QThread for executing PyInstaller in the background.
    Emits signals for step changes, progress updates, log lines, and completion.
    """

    # Signals
    step_changed = Signal(int, str, str) # (step_index 1..6, step_name, status: "running"|"completed"|"failed")
    progress_updated = Signal(int)       # (0..100)
    log_emitted = Signal(str)           # (log_line)
    build_finished = Signal(bool, dict) # (success, result_dict)

    def __init__(
        self,
        project_path: str,
        entry_file: str,
        app_name: str,
        exe_name: str,
        one_file: bool = True,
        windowed: bool = True,
        include_assets: bool = True,
        auto_dependencies: bool = True,
        parent=None
    ):
        super().__init__(parent)
        self.project_path = os.path.abspath(project_path)
        self.entry_file = entry_file
        self.app_name = app_name or "MyApplication"
        self.exe_name = exe_name or f"{self.app_name}.exe"
        self.one_file = one_file
        self.windowed = windowed
        self.include_assets = include_assets
        self.auto_dependencies = auto_dependencies

        self.logger = BuildLogger(callback=self._on_log)
        self._is_cancelled = False

    def _on_log(self, formatted_line: str):
        self.log_emitted.emit(formatted_line)

    def cancel(self):
        self._is_cancelled = True

    def run(self):
        start_time = time.time()
        dist_dir = os.path.join(self.project_path, "dist")
        build_dir = os.path.join(self.project_path, "build")

        try:
            # 01 SCANNING
            self.step_changed.emit(1, "SCANNING", "running")
            self.progress_updated.emit(10)
            self.logger.log("Starting build process...")
            self.logger.log(f"Project folder: {self.project_path}")
            self.logger.log(f"Target entry file: {self.entry_file}")
            time.sleep(0.3)
            self.step_changed.emit(1, "SCANNING", "completed")

            if self._is_cancelled:
                raise Exception("Build cancelled by user.")

            # 02 DETECTING
            self.step_changed.emit(2, "DETECTING", "running")
            self.progress_updated.emit(25)
            full_entry_path = os.path.join(self.project_path, self.entry_file)
            if not os.path.exists(full_entry_path):
                raise FileNotFoundError(f"Entry file does not exist: {full_entry_path}")
            self.logger.log("Entry file verified successfully.")
            time.sleep(0.3)
            self.step_changed.emit(2, "DETECTING", "completed")

            if self._is_cancelled:
                raise Exception("Build cancelled by user.")

            # 03 DEPENDENCIES
            self.step_changed.emit(3, "DEPENDENCIES", "running")
            self.progress_updated.emit(40)
            self.logger.log("Collecting dependencies and verifying environment...")
            time.sleep(0.3)
            self.step_changed.emit(3, "DEPENDENCIES", "completed")

            if self._is_cancelled:
                raise Exception("Build cancelled by user.")

            # 04 PACKAGING
            self.step_changed.emit(4, "PACKAGING", "running")
            self.progress_updated.emit(60)
            self.logger.log("Preparing PyInstaller configuration...")

            cmd = [
                sys.executable, "-m", "PyInstaller",
                "--noconfirm",
                "--clean",
                "--name", os.path.splitext(self.exe_name)[0],
                "--distpath", dist_dir,
                "--workpath", build_dir,
                "--specpath", build_dir
            ]

            if self.one_file:
                cmd.append("--onefile")
            else:
                cmd.append("--onedir")

            if self.windowed:
                cmd.append("--noconsole")
            else:
                cmd.append("--console")

            cmd.append(full_entry_path)

            self.logger.log(f"Executing command: {' '.join(cmd)}")
            self.step_changed.emit(4, "PACKAGING", "completed")

            # 05 BUILDING EXE
            self.step_changed.emit(5, "BUILDING EXE", "running")
            self.progress_updated.emit(75)

            process = subprocess.Popen(
                cmd,
                cwd=self.project_path,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
                bufsize=1
            )

            if process.stdout:
                for line in iter(process.stdout.readline, ''):
                    if self._is_cancelled:
                        process.terminate()
                        raise Exception("Build cancelled during execution.")
                    line_clean = line.strip()
                    if line_clean:
                        # Log cleanly to contained log panel
                        self.logger.log(line_clean)

            process.wait()

            if process.returncode != 0:
                raise RuntimeError(f"PyInstaller build failed with exit code {process.returncode}")

            self.step_changed.emit(5, "BUILDING EXE", "completed")

            # 06 FINALIZING
            self.step_changed.emit(6, "FINALIZING", "running")
            self.progress_updated.emit(95)
            self.logger.log("Finalizing executable files and cleaning temporary artifacts...")

            # Locate final executable file or output folder
            exe_base_name = os.path.splitext(self.exe_name)[0]
            if self.one_file:
                target_exe = os.path.join(dist_dir, f"{exe_base_name}.exe")
                if not os.path.exists(target_exe):
                    # Check without .exe extension or any generated file
                    all_dist = os.listdir(dist_dir) if os.path.exists(dist_dir) else []
                    if all_dist:
                        target_exe = os.path.join(dist_dir, all_dist[0])
            else:
                target_exe = os.path.join(dist_dir, exe_base_name)

            size_bytes = 0
            if os.path.exists(target_exe):
                if os.path.isfile(target_exe):
                    size_bytes = os.path.getsize(target_exe)
                elif os.path.isdir(target_exe):
                    for root, dirs, files in os.walk(target_exe):
                        for f in files:
                            size_bytes += os.path.getsize(os.path.join(root, f))

            size_mb = size_bytes / (1024 * 1024)
            duration = time.time() - start_time

            self.progress_updated.emit(100)
            self.step_changed.emit(6, "FINALIZING", "completed")
            self.logger.log(f"Build complete in {duration:.1f}s. Output size: {size_mb:.1f} MB.")

            res = {
                "exe_path": target_exe,
                "output_dir": dist_dir,
                "exe_name": self.exe_name,
                "size_mb": size_mb,
                "duration_sec": duration,
                "log_text": self.logger.get_text()
            }
            self.build_finished.emit(True, res)

        except Exception as e:
            duration = time.time() - start_time
            err_msg = str(e)
            self.logger.log(f"BUILD ERROR: {err_msg}")
            self.step_changed.emit(5, "BUILDING EXE", "failed")
            res = {
                "error_message": err_msg,
                "duration_sec": duration,
                "log_text": self.logger.get_text()
            }
            self.build_finished.emit(False, res)
