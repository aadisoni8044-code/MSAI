"""PyInstaller Builder plugin for Kora."""

import os
import subprocess
from typing import List, Optional
from builders.base_builder import BaseBuilder
from models.project_info import ProjectInfo
from models.build_strategy import BuildStrategy
from app.output_detector.detector import OutputDetector
from app.logger import logger


class PyInstallerBuilder(BaseBuilder):
    """PyInstaller build system integration."""

    name: str = "PyInstaller"

    def is_available(self, python_path: str = "python") -> bool:
        """Checks if PyInstaller module is available via python -m PyInstaller."""
        try:
            res = subprocess.run(
                [python_path, "-m", "PyInstaller", "--version"],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )
            return res.returncode == 0
        except Exception:
            return False

    def can_build(self, project_info: ProjectInfo) -> bool:
        """PyInstaller can build almost all standard Python projects."""
        return project_info.selected_entry_point is not None

    def prepare(self, project_info: ProjectInfo, workspace_dir: str) -> bool:
        """Prepares build environment for PyInstaller."""
        os.makedirs(workspace_dir, exist_ok=True)
        return True

    def generate_command(
        self,
        project_info: ProjectInfo,
        strategy: BuildStrategy,
        python_path: str = "python"
    ) -> List[str]:
        """Generates PyInstaller command."""
        entry_point = project_info.selected_entry_point
        if not entry_point:
            raise ValueError("No entry point selected for project.")

        entry_full_path = os.path.join(project_info.project_path, entry_point)

        cmd = [python_path, "-m", "PyInstaller"]

        # Onefile vs Onedir
        if strategy.mode == "onefile" or project_info.is_onefile:
            cmd.append("--onefile")
        else:
            cmd.append("--onedir")

        # Windowed (GUI) vs Console
        if strategy.is_gui or project_info.is_gui:
            cmd.append("--noconsole")
        else:
            cmd.append("--console")

        # Name
        app_name = project_info.app_name or project_info.project_name
        cmd.extend(["--name", app_name])

        # Icon
        if project_info.icon_path and os.path.exists(project_info.icon_path):
            cmd.extend(["--icon", project_info.icon_path])

        # Assets (--add-data)
        for asset in project_info.selected_assets:
            full_asset = os.path.join(project_info.project_path, asset)
            if os.path.exists(full_asset):
                dest = os.path.dirname(asset) or "."
                sep = ";" if os.name == "nt" else ":"
                cmd.extend(["--add-data", f"{full_asset}{sep}{dest}"])

        # Clean build directory
        cmd.append("--clean")
        cmd.append("-y")  # Overwrite output without asking

        # Custom extra args
        if strategy.custom_args:
            cmd.extend(strategy.custom_args)

        cmd.append(entry_full_path)
        return cmd

    def detect_output(self, project_info: ProjectInfo, output_dir: str) -> Optional[str]:
        """Detects output EXE using OutputDetector."""
        detector = OutputDetector(project_info.project_path, output_dir)
        app_name = project_info.app_name or project_info.project_name
        return detector.detect_exe(app_name)
