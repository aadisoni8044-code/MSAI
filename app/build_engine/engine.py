"""Build Engine module orchestrating the automated Python to EXE compilation process."""

import os
import time
from typing import List, Optional, Callable, Dict, Any
from models.project_info import ProjectInfo
from models.build_strategy import BuildStrategy, BuildAttempt, BuildResult
from models.settings import Settings, PermissionRequest
from app.environment_manager.manager import EnvironmentManager
from app.dependency_manager.manager import DependencyManager
from app.command_runner.runner import CommandRunner
from app.output_detector.detector import OutputDetector
from app.error_analyzer.analyzer import ErrorAnalyzer
from app.permission_manager.manager import PermissionManager
from database.build_history import BuildHistoryDB
from builders import BaseBuilder, PyInstallerBuilder, NuitkaBuilder, cxFreezeBuilder
from app.logger import logger, get_build_logger


class BuildEngine:
    """Orchestrates strategy selection, build execution, error handling, automatic safe fixes, and retries."""

    def __init__(
        self,
        settings: Optional[Settings] = None,
        permissions: Optional[PermissionRequest] = None,
        db_path: str = "kora_history.db"
    ):
        self.settings = settings or Settings()
        self.permission_mgr = PermissionManager(permissions or PermissionRequest())
        self.runner = CommandRunner()
        self.analyzer = ErrorAnalyzer()
        self.db = BuildHistoryDB(db_path)
        self.build_logger = get_build_logger()

        self.builders: List[BaseBuilder] = [
            PyInstallerBuilder(),
            NuitkaBuilder(),
            cxFreezeBuilder()
        ]

    def run_build(
        self,
        project_info: ProjectInfo,
        initial_strategy: Optional[BuildStrategy] = None,
        on_status_update: Optional[Callable[[str], None]] = None,
        on_log_line: Optional[Callable[[str], None]] = None,
        on_permission_needed: Optional[Callable[[str, str], bool]] = None
    ) -> BuildResult:
        """Executes the build process through initial strategy and configured fallbacks."""

        def log(msg: str):
            logger.info(msg)
            self.build_logger.info(msg)
            if on_log_line:
                try:
                    on_log_line(msg)
                except Exception:
                    pass

        def update_status(msg: str):
            if on_status_update:
                try:
                    on_status_update(msg)
                except Exception:
                    pass

        start_time = time.time()
        self.db.save_project(project_info)

        update_status("Preparing environment...")
        log("=== Starting Kora Build Process ===")
        log(f"Project: {project_info.project_name} ({project_info.project_path})")

        env_mgr = EnvironmentManager(project_info.project_path, self.settings.python_interpreter)
        python_exe = env_mgr.get_python_interpreter()
        log(f"Selected Python Interpreter: {python_exe}")

        dep_mgr = DependencyManager(python_exe, self.runner)

        # Check permission for build execution
        if not self.permission_mgr.check_execute_commands():
            log("ERROR: Command execution permission denied by user.")
            return BuildResult(
                status="CANCELLED",
                project_path=project_info.project_path,
                summary_message="Build cancelled: Permission to execute commands was not granted."
            )

        # Check build memory for successful strategy if enabled
        known_strategy_dict = None
        if self.settings.remember_successful_strategy:
            known_strategy_dict = self.db.get_successful_strategy(project_info.project_path)

        # Determine strategy sequence
        strategies_to_try: List[tuple[BaseBuilder, BuildStrategy]] = []

        if initial_strategy:
            target_builder = self._find_builder_by_name(initial_strategy.builder_name)
            if target_builder:
                strategies_to_try.append((target_builder, initial_strategy))

        elif known_strategy_dict:
            k_builder = self._find_builder_by_name(known_strategy_dict["builder_name"])
            if k_builder:
                log(f"Found previously successful strategy: {known_strategy_dict['builder_name']}")
                k_strat = BuildStrategy(
                    builder_name=known_strategy_dict["builder_name"],
                    mode=known_strategy_dict["mode"],
                    is_gui=bool(known_strategy_dict["is_gui"])
                )
                strategies_to_try.append((k_builder, k_strat))

        # Add remaining fallback builders
        for b in self.builders:
            if not any(sb.name == b.name for sb, _ in strategies_to_try):
                mode = "onefile" if project_info.is_onefile else "onedir"
                strat = BuildStrategy(builder_name=b.name, mode=mode, is_gui=project_info.is_gui)
                strategies_to_try.append((b, strat))

        attempts: List[BuildAttempt] = []
        max_attempts = self.settings.max_build_attempts
        attempt_count = 0
        output_dir = os.path.join(project_info.project_path, self.settings.default_output_dir)

        for builder, strategy in strategies_to_try:
            if attempt_count >= max_attempts:
                log(f"Reached maximum build attempt limit ({max_attempts}). Stopping.")
                break

            attempt_count += 1
            log(f"\n--- Attempt #{attempt_count} using {builder.name} ---")
            update_status(f"Building with {builder.name} (Attempt {attempt_count}/{max_attempts})...")

            # Availability check & installation if missing
            if not builder.is_available(python_exe):
                log(f"Builder '{builder.name}' is not installed in {python_exe}.")

                # Check permission / ask user to install builder
                allow_install = self.settings.auto_install_dependencies or self.permission_mgr.check_install_packages()
                if not allow_install and on_permission_needed:
                    allow_install = on_permission_needed("INSTALL_PACKAGE", builder.name)

                if allow_install:
                    log(f"Installing missing builder package '{builder.name}'...")
                    update_status(f"Installing {builder.name}...")
                    pkg_name = builder.name.lower()
                    install_res = dep_mgr.install_package(pkg_name)
                    if not install_res.is_success:
                        log(f"Failed to install builder '{builder.name}'. Skipping.")
                        continue
                else:
                    log(f"Permission to install '{builder.name}' was denied. Skipping this builder.")
                    continue

            # Workspace preparation
            workspace = os.path.join(project_info.project_path, self.settings.build_workspace)
            builder.prepare(project_info, workspace)

            # Generate Command
            try:
                cmd = builder.generate_command(project_info, strategy, python_exe)
            except Exception as e:
                log(f"Error generating command for {builder.name}: {e}")
                continue

            log(f"Executing: {' '.join(cmd)}")

            # Execute Command
            cmd_result = self.runner.run(
                cmd,
                cwd=project_info.project_path,
                on_stdout=lambda line: log(line.strip()),
                on_stderr=lambda line: log(f"STDERR: {line.strip()}")
            )

            attempt = BuildAttempt(
                attempt_number=attempt_count,
                builder_name=builder.name,
                strategy=strategy,
                command=cmd,
                command_result=cmd_result,
                status="SUCCESS" if cmd_result.is_success else "FAILED"
            )

            if cmd_result.cancelled:
                attempt.status = "CANCELLED"
                attempts.append(attempt)
                self.db.record_build_attempt(project_info.project_path, attempt)
                log("Build cancelled by user.")
                return BuildResult(
                    status="CANCELLED",
                    project_path=project_info.project_path,
                    attempts=attempts,
                    total_duration=time.time() - start_time,
                    summary_message="Build was manually stopped by user."
                )

            # Verify Output EXE if command succeeded
            if cmd_result.is_success:
                update_status("Verifying generated EXE...")
                detector = OutputDetector(project_info.project_path, output_dir)
                app_name = project_info.app_name or project_info.project_name
                exe_path = detector.detect_exe(app_name)

                if exe_path:
                    verification = detector.verify_exe(exe_path)
                    if verification["is_valid"]:
                        log(f"Build SUCCESSFUL! Generated EXE: {exe_path} ({verification['size_mb']} MB)")
                        attempt.status = "SUCCESS"
                        attempts.append(attempt)
                        self.db.record_build_attempt(project_info.project_path, attempt)
                        self.db.record_successful_strategy(
                            project_info.project_path,
                            strategy,
                            project_info.selected_entry_point or ""
                        )
                        update_status("Build successful!")
                        return BuildResult(
                            status="SUCCESS",
                            project_path=project_info.project_path,
                            output_exe=exe_path,
                            attempts=attempts,
                            total_duration=time.time() - start_time,
                            summary_message=f"EXE built successfully with {builder.name}!"
                        )

            # Build Failed -> Analyze Error
            log(f"Build failed with exit code {cmd_result.exit_code}.")
            analysis = self.analyzer.analyze(cmd_result, builder.name)
            attempt.error_type = analysis["error_type"]
            attempt.error_message = analysis["summary"]

            # Try Safe Automatic Fix if available
            if analysis["can_safe_fix"]:
                fix = analysis["suggested_fix"]
                log(f"Possible safe fix identified: {fix['description']}")

                allow_fix = self.settings.auto_safe_fixes
                if not allow_fix and on_permission_needed:
                    allow_fix = on_permission_needed(fix["action"], fix["description"])

                if allow_fix:
                    log(f"Applying fix: {fix['description']}")
                    attempt.applied_fix = fix["description"]
                    if fix["action"] in ("INSTALL_PACKAGE", "INSTALL_BUILDER"):
                        dep_mgr.install_package(fix["package"])
                        # Retry current builder once after fix
                        log("Retrying build after applying fix...")
                        cmd_result_retry = self.runner.run(
                            cmd,
                            cwd=project_info.project_path,
                            on_stdout=lambda line: log(line.strip()),
                            on_stderr=lambda line: log(f"STDERR: {line.strip()}")
                        )
                        if cmd_result_retry.is_success:
                            detector = OutputDetector(project_info.project_path, output_dir)
                            exe_path = detector.detect_exe(project_info.app_name)
                            if exe_path and detector.verify_exe(exe_path)["is_valid"]:
                                log("Retry build SUCCESSFUL after fix!")
                                attempt.status = "SUCCESS"
                                attempts.append(attempt)
                                self.db.record_build_attempt(project_info.project_path, attempt)
                                self.db.record_successful_strategy(
                                    project_info.project_path,
                                    strategy,
                                    project_info.selected_entry_point or ""
                                )
                                return BuildResult(
                                    status="SUCCESS",
                                    project_path=project_info.project_path,
                                    output_exe=exe_path,
                                    attempts=attempts,
                                    total_duration=time.time() - start_time,
                                    summary_message=f"EXE built successfully after automatic fix with {builder.name}!"
                                )

            attempts.append(attempt)
            self.db.record_build_attempt(project_info.project_path, attempt)

        log("\n=== BUILD FAILED ===")
        log(f"All {attempt_count} build strategies failed.")
        update_status("Build failed.")

        return BuildResult(
            status="FAILED",
            project_path=project_info.project_path,
            attempts=attempts,
            total_duration=time.time() - start_time,
            summary_message=f"Build failed after {attempt_count} attempts. Check build logs for details."
        )

    def cancel_build(self):
        """Cancels current active subprocess command."""
        logger.info("Cancelling active build engine process...")
        self.runner.cancel()

    def _find_builder_by_name(self, name: str) -> Optional[BaseBuilder]:
        for b in self.builders:
            if b.name.lower() == name.lower():
                return b
        return None
