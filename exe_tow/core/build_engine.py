import os
import json
import time
import datetime
from pathlib import Path
from typing import Callable, Optional, List, Dict, Any

from exe_tow.config.settings import Settings
from exe_tow.core.models import (
    ProjectInfo, EnvironmentInfo, CommandExecution, CommandStatus,
    BuildRecord, ErrorCategory
)
from exe_tow.core.environment_detector import EnvironmentDetector
from exe_tow.core.project_analyzer import ProjectAnalyzer
from exe_tow.core.command_runner import CommandRunner
from exe_tow.core.knowledge_db import KnowledgeDatabase
from exe_tow.core.history_manager import HistoryManager
from exe_tow.core.log_manager import LogManager
from exe_tow.core.fallback_manager import FallbackManager
from exe_tow.core.recovery_manager import RecoveryManager
from exe_tow.core.engines.base_engine import BaseEngine
from exe_tow.core.engines.pyinstaller_engine import PyInstallerEngine

class BuildEngine:
    def __init__(self, settings: Optional[Settings] = None):
        self.settings = settings or Settings.load()
        self.log_manager = LogManager()
        self.history_manager = HistoryManager()
        self.knowledge_db = KnowledgeDatabase()
        self.command_runner = CommandRunner(timeout=self.settings.command_timeout)
        self.fallback_manager = FallbackManager(max_retries=self.settings.max_retries)

        self.engines: Dict[str, BaseEngine] = {
            "PyInstaller": PyInstallerEngine()
        }

    def run_build(
        self,
        project_path: str,
        exe_name: str,
        output_folder: str,
        build_mode: str = "ONE FILE",
        engine_name: str = "PyInstaller",
        status_callback: Optional[Callable[[str], None]] = None,
        log_callback: Optional[Callable[[str], None]] = None,
        attempt_callback: Optional[Callable[[CommandExecution], None]] = None
    ) -> BuildRecord:
        start_time = time.time()
        build_id = f"build_{int(time.time())}"

        def emit_log(msg: str):
            formatted = self.log_manager.log(msg)
            if log_callback:
                try:
                    log_callback(formatted)
                except Exception:
                    pass

        def emit_status(status_msg: str):
            if status_callback:
                try:
                    status_callback(status_msg)
                except Exception:
                    pass

        emit_status("Detecting Environment...")
        emit_log("Starting EXE/TOW build process...")
        emit_log(f"Project Path: {project_path}")
        emit_log(f"Target EXE Name: {exe_name}")
        emit_log(f"Output Directory: {output_folder}")
        emit_log(f"Build Mode: {build_mode}")

        # 1. Environment Detection
        env_detector = EnvironmentDetector(custom_python_path=self.settings.python_path)
        env_info = env_detector.detect()
        emit_log(f"Python detected: {env_info.python_executable} ({env_info.python_version})")
        emit_log(f"PyInstaller installed: {env_info.pyinstaller_installed}")

        # 2. Project Analysis
        emit_status("Analyzing Project...")
        analyzer = ProjectAnalyzer(project_path)
        project_info = analyzer.analyze()
        emit_log(f"Entry File: {project_info.entry_file}")
        if project_info.has_requirements:
            emit_log(f"Requirements detected at: {project_info.requirements_path}")

        # Ensure output folder
        out_dir = Path(output_folder)
        out_dir.mkdir(parents=True, exist_ok=True)

        engine = self.engines.get(engine_name, PyInstallerEngine())
        attempted_commands: List[CommandExecution] = []
        successful_exe: Optional[str] = None
        build_successful = False

        # 3. Check for PyInstaller installation dependency if auto_install is active
        if not env_info.pyinstaller_installed and self.settings.auto_install_dependencies:
            emit_status("Installing Dependencies...")
            emit_log("PyInstaller not detected. Attempting automatic installation via pip...")
            install_cmd = [env_info.python_executable, "-m", "pip", "install", "pyinstaller"]
            inst_exec = self.command_runner.run_command(
                command_list=install_cmd,
                reason="Auto-install PyInstaller dependency",
                output_callback=emit_log
            )
            attempted_commands.append(inst_exec)
            self.history_manager.save_command_execution(inst_exec)
            if attempt_callback:
                attempt_callback(inst_exec)

            if inst_exec.status == CommandStatus.SUCCESS:
                emit_log("PyInstaller successfully installed!")
                env_info.pyinstaller_installed = True
            else:
                emit_log("Failed to install PyInstaller automatically.")

        # 4. Generate build candidates & execution loop with fallbacks
        strategies = self.fallback_manager.generate_strategy_sequence(
            engine=engine,
            project_info=project_info,
            env_info=env_info,
            exe_name=exe_name,
            output_folder=output_folder,
            build_mode=build_mode
        )

        total_attempts = 0
        for strategy in strategies:
            if total_attempts >= self.settings.max_retries:
                emit_log(f"Reached maximum retry limit ({self.settings.max_retries}).")
                break

            total_attempts += 1
            cmd_list = strategy["command"]
            reason = strategy["reason"]

            emit_status(f"Building (Attempt {total_attempts}/{self.settings.max_retries})...")
            emit_log(f"Executing Strategy #{total_attempts}: {' '.join(cmd_list)}")

            execution = self.command_runner.run_command(
                command_list=cmd_list,
                reason=reason,
                cwd=project_info.project_path,
                output_callback=emit_log
            )
            execution.retry_count = total_attempts
            attempted_commands.append(execution)
            self.history_manager.save_command_execution(execution)
            if attempt_callback:
                attempt_callback(execution)

            if execution.status == CommandStatus.SUCCESS:
                # Check for output executable
                found_exe = engine.find_output_exe(project_info, exe_name, output_folder, build_mode)
                if found_exe and os.path.exists(found_exe):
                    successful_exe = found_exe
                    build_successful = True
                    emit_log(f"BUILD SUCCESSFUL! Executable created at: {successful_exe}")
                    self.knowledge_db.record_attempt(
                        command=execution.command_text,
                        environment_info=env_info.to_dict(),
                        project_type="single_file" if project_info.is_single_file else "directory",
                        status="SUCCESS"
                    )
                    break
                else:
                    emit_log("Build command succeeded but output executable was not located.")
            else:
                emit_log(f"Strategy #{total_attempts} FAILED with exit code {execution.exit_code}.")
                error_cat = RecoveryManager.classify_error(execution)
                emit_log(f"Classified error category: {error_cat.value}")
                self.knowledge_db.record_attempt(
                    command=execution.command_text,
                    environment_info=env_info.to_dict(),
                    project_type="single_file" if project_info.is_single_file else "directory",
                    status="FAILED",
                    error_category=error_cat.value
                )

                # Safe Recovery Action attempt if enabled and available
                if self.settings.auto_fallback and total_attempts < self.settings.max_retries:
                    rec_cmd = RecoveryManager.get_recovery_command(
                        error_cat, env_info.python_executable, env_info.pip_executable
                    )
                    if rec_cmd:
                        emit_status("Executing Recovery Action...")
                        emit_log(f"Attempting recovery action: {' '.join(rec_cmd)}")
                        rec_exec = self.command_runner.run_command(
                            command_list=rec_cmd,
                            reason=f"Recovery from {error_cat.value}",
                            cwd=project_info.project_path,
                            output_callback=emit_log
                        )
                        attempted_commands.append(rec_exec)
                        self.history_manager.save_command_execution(rec_exec)
                        if attempt_callback:
                            attempt_callback(rec_exec)

        duration = round(time.time() - start_time, 2)
        build_status_str = "SUCCESS" if build_successful else "FAILED"
        emit_status("BUILD COMPLETED" if build_successful else "BUILD FAILED")

        # Create build_info.json
        info_json_path = out_dir / "build_info.json"
        build_info_data = {
            "build_id": build_id,
            "project_name": project_info.project_name,
            "source_path": project_info.project_path,
            "python_version": env_info.python_version,
            "build_engine": engine_name,
            "build_mode": build_mode,
            "total_attempts": total_attempts,
            "build_successful": build_successful,
            "output_exe": successful_exe,
            "duration_seconds": duration,
            "timestamp": datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            "commands": [cmd.to_dict() for cmd in attempted_commands]
        }
        try:
            with open(info_json_path, "w", encoding="utf-8") as f:
                json.dump(build_info_data, f, indent=2)
        except Exception:
            pass

        record = BuildRecord(
            id=build_id,
            project_name=project_info.project_name,
            exe_name=exe_name,
            source_path=project_info.project_path,
            entry_file=project_info.entry_file,
            output_folder=output_folder,
            build_mode=build_mode,
            build_engine=engine_name,
            date=datetime.datetime.now().strftime("%d %b %Y %H:%M"),
            status=build_status_str,
            output_exe_path=successful_exe,
            duration=duration,
            commands_attempted=[c.to_dict() for c in attempted_commands],
            error_summary=None if build_successful else "All attempted build strategies failed."
        )

        self.history_manager.save_build_record(record)
        return record

    def stop_build(self):
        self.command_runner.cancel()
