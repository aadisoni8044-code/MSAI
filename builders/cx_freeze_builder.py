"""cx_Freeze Builder plugin for Kora."""

import os
import subprocess
from typing import List, Optional
from builders.base_builder import BaseBuilder
from models.project_info import ProjectInfo
from models.build_strategy import BuildStrategy
from app.output_detector.detector import OutputDetector
from app.logger import logger


class cxFreezeBuilder(BaseBuilder):
    """cx_Freeze build system integration."""

    name: str = "cx_Freeze"

    def is_available(self, python_path: str = "python") -> bool:
        """Checks if cx_Freeze module is available."""
        try:
            res = subprocess.run(
                [python_path, "-c", "import cx_Freeze"],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )
            return res.returncode == 0
        except Exception:
            return False

    def can_build(self, project_info: ProjectInfo) -> bool:
        return project_info.selected_entry_point is not None

    def prepare(self, project_info: ProjectInfo, workspace_dir: str) -> bool:
        """Generates temporary setup.py file for cx_Freeze inside the workspace directory."""
        os.makedirs(workspace_dir, exist_ok=True)
        setup_file = os.path.join(workspace_dir, "cx_setup.py")

        entry_point = project_info.selected_entry_point
        app_name = project_info.app_name or project_info.project_name
        base = "Win32GUI" if project_info.is_gui else None

        assets_code = repr(project_info.selected_assets)
        dist_output_dir = os.path.join(project_info.project_path, "dist")

        setup_content = f"""import sys
from cx_Freeze import setup, Executable

build_exe_options = {{
    "packages": [],
    "include_files": {assets_code},
    "excludes": [],
    "build_exe": {repr(dist_output_dir)}
}}

base = {repr(base)} if sys.platform == "win32" else None

executables = [
    Executable(
        script={repr(entry_point)},
        base=base,
        target_name={repr(app_name + '.exe')}
    )
]

setup(
    name={repr(app_name)},
    version="1.0",
    description={repr(app_name)},
    options={{"build_exe": build_exe_options}},
    executables=executables
)
"""
        with open(setup_file, "w", encoding="utf-8") as f:
            f.write(setup_content)

        return True

    def generate_command(
        self,
        project_info: ProjectInfo,
        strategy: BuildStrategy,
        python_path: str = "python"
    ) -> List[str]:
        """Generates command to invoke cx_Freeze setup script."""
        workspace_dir = os.path.join(project_info.project_path, ".kora_build")
        setup_file = os.path.join(workspace_dir, "cx_setup.py")

        cmd = [python_path, setup_file, "build_exe"]
        if strategy.custom_args:
            cmd.extend(strategy.custom_args)

        return cmd

    def detect_output(self, project_info: ProjectInfo, output_dir: str) -> Optional[str]:
        detector = OutputDetector(project_info.project_path, output_dir)
        app_name = project_info.app_name or project_info.project_name
        return detector.detect_exe(app_name)
