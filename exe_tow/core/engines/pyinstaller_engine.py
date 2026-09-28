import os
from pathlib import Path
from typing import List, Optional
from exe_tow.core.engines.base_engine import BaseEngine
from exe_tow.core.models import ProjectInfo, EnvironmentInfo

class PyInstallerEngine(BaseEngine):
    def __init__(self):
        super().__init__(name="PyInstaller")

    def build_command_candidates(
        self,
        project_info: ProjectInfo,
        env_info: EnvironmentInfo,
        exe_name: str,
        output_folder: str,
        build_mode: str,
        extra_args: Optional[List[str]] = None
    ) -> List[List[str]]:
        mode_flag = "--onefile" if build_mode == "ONE FILE" else "--onedir"
        clean_flag = "--noconfirm"
        name_clean = Path(exe_name).stem if exe_name.lower().endswith(".exe") else exe_name

        candidates = []

        # Strategy 1: python -m PyInstaller
        cmd1 = [
            env_info.python_executable,
            "-m", "PyInstaller",
            mode_flag,
            clean_flag,
            "--name", name_clean,
            "--distpath", output_folder,
            "--workpath", str(Path(output_folder) / "build"),
            "--specpath", str(Path(output_folder) / "spec")
        ]
        if extra_args:
            cmd1.extend(extra_args)
        cmd1.append(project_info.entry_file)
        candidates.append(cmd1)

        # Strategy 2: standalone pyinstaller executable
        cmd2 = [
            "pyinstaller",
            mode_flag,
            clean_flag,
            "--name", name_clean,
            "--distpath", output_folder,
            "--workpath", str(Path(output_folder) / "build"),
            "--specpath", str(Path(output_folder) / "spec")
        ]
        if extra_args:
            cmd2.extend(extra_args)
        cmd2.append(project_info.entry_file)
        candidates.append(cmd2)

        # Strategy 3: python -m PyInstaller with --clean flag
        cmd3 = [
            env_info.python_executable,
            "-m", "PyInstaller",
            "--clean",
            mode_flag,
            clean_flag,
            "--name", name_clean,
            "--distpath", output_folder,
            "--workpath", str(Path(output_folder) / "build"),
            "--specpath", str(Path(output_folder) / "spec")
        ]
        if extra_args:
            cmd3.extend(extra_args)
        cmd3.append(project_info.entry_file)
        candidates.append(cmd3)

        return candidates

    def find_output_exe(
        self,
        project_info: ProjectInfo,
        exe_name: str,
        output_folder: str,
        build_mode: str
    ) -> Optional[str]:
        target_filename = exe_name if exe_name.endswith(".exe") else f"{exe_name}.exe"

        # Search direct output_folder
        direct = Path(output_folder) / target_filename
        if direct.exists():
            return str(direct)

        # Search in subfolder if ONE DIRECTORY mode
        name_clean = Path(exe_name).stem if exe_name.lower().endswith(".exe") else exe_name
        dir_mode_path = Path(output_folder) / name_clean / target_filename
        if dir_mode_path.exists():
            return str(dir_mode_path)

        # Walk dist/output_folder recursively to find matching .exe
        for root, _, files in os.walk(output_folder):
            if target_filename in files:
                return str(Path(root) / target_filename)

        return None
