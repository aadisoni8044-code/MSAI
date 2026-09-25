"""Dependency Manager module for checking and installing missing Python packages."""

import subprocess
from typing import List, Optional
from app.command_runner.runner import CommandRunner
from models.command_result import CommandResult
from app.logger import logger


class DependencyManager:
    """Handles package checking and installation via pip."""

    def __init__(self, python_path: str, command_runner: CommandRunner):
        self.python_path = python_path
        self.runner = command_runner

    def is_package_installed(self, package_name: str) -> bool:
        """Checks if a given package is installed in the target Python environment."""
        res = self.runner.run([self.python_path, "-m", "pip", "show", package_name])
        return res.exit_code == 0

    def install_package(self, package_name: str) -> CommandResult:
        """Installs a package via pip."""
        logger.info(f"Installing package '{package_name}' via {self.python_path}...")
        cmd = [self.python_path, "-m", "pip", "install", package_name]
        return self.runner.run(cmd)

    def install_requirements(self, requirements_file: str) -> CommandResult:
        """Installs dependencies from a requirements.txt file."""
        logger.info(f"Installing requirements from '{requirements_file}'...")
        cmd = [self.python_path, "-m", "pip", "install", "-r", requirements_file]
        return self.runner.run(cmd)
