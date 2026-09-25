"""Nuitka Builder plugin for Kora."""

import os
import subprocess
from typing import List, Optional
from builders.base_builder import BaseBuilder
from models.project_info import ProjectInfo
from models.build_strategy import BuildStrategy
from app.output_detector.detector import OutputDetector
from app.logger import logger


class NuitkaBuilder(BaseBuilder):
    """Nuitka build system integration."""

    name: str = "Nuitka"

    def is_available(self, python_path: str = "python") -> bool:
        """Checks if Nuitka module is available via python -m nuitka."""
        try:
            res = subprocess.run(
                [python_path, "-m", "nuitka", "--version"],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )
            return res.returncode == 0
        except Exception:
            return False

    def can_build(self, project_info: ProjectInfo) -> bool:
        """Nuitka can build standard Python projects."""
        return project_info.selected_entry_point is not None

    def prepare(self, project_info: ProjectInfo, workspace_dir: str) -> bool:
        os.makedirs(workspace_dir, exist_ok=True)
        return True

    def generate_command(
        self,
        project_info: ProjectInfo,
        strategy: BuildStrategy,
        python_path: str = "python"
    ) -> List[str]:
        """Generates Nuitka command."""
        entry_point = project_info.selected_entry_point
        if not entry_point:
            raise ValueError("No entry point selected for project.")

        entry_full_path = os.path.join(project_info.project_path, entry_point)

        cmd = [python_path, "-m", "nuitka"]

        # Standalone / Onefile mode
        if strategy.mode == "onefile" or project_info.is_onefile:
            cmd.append("--onefile")
        else:
            cmd.append("--standalone")

        # Disable console if GUI
        if strategy.is_gui or project_info.is_gui:
            cmd.append("--windows-disable-console")

        # Output dir
        output_dir = os.path.join(project_info.project_path, "dist")
        cmd.extend(["--output-dir", output_dir])

        # Icon
        if project_info.icon_path and os.path.exists(project_info.icon_path):
            cmd.append(f"--windows-icon-from-ico={project_info.icon_path}")

        # Assets (--include-data-files)
        for asset in project_info.selected_assets:
            full_asset = os.path.join(project_info.project_path, asset)
            if os.path.exists(full_asset):
                cmd.append(f"--include-data-files={full_asset}={asset}")

        # Non-interactive mode (assumes compilers are installed)
        cmd.append("--assume-yes-for-downloads")

        if strategy.custom_args:
            cmd.extend(strategy.custom_args)

        cmd.append(entry_full_path)
        return cmd

    def detect_output(self, project_info: ProjectInfo, output_dir: str) -> Optional[str]:
        detector = OutputDetector(project_info.project_path, output_dir)
        app_name = project_info.app_name or project_info.project_name
        return detector.detect_exe(app_name)
