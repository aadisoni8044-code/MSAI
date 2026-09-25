"""Base Builder interface for all Python-to-EXE builders."""

from abc import ABC, abstractmethod
from typing import List, Optional, Dict, Any
from models.project_info import ProjectInfo
from models.build_strategy import BuildStrategy
from models.command_result import CommandResult


class BaseBuilder(ABC):
    """Abstract base class for all builder implementations in Kora."""

    name: str = "BaseBuilder"

    @abstractmethod
    def is_available(self, python_path: str = "python") -> bool:
        """Checks if the builder is installed and available in the target environment."""
        pass

    @abstractmethod
    def can_build(self, project_info: ProjectInfo) -> bool:
        """Checks if the builder is compatible with the given project configuration."""
        pass

    @abstractmethod
    def prepare(self, project_info: ProjectInfo, workspace_dir: str) -> bool:
        """Prepares workspace, configuration files, or temporary build assets before compilation."""
        pass

    @abstractmethod
    def generate_command(self, project_info: ProjectInfo, strategy: BuildStrategy, python_path: str = "python") -> List[str]:
        """Generates the command line arguments list to invoke the builder."""
        pass

    @abstractmethod
    def detect_output(self, project_info: ProjectInfo, output_dir: str) -> Optional[str]:
        """Detects and returns the generated EXE path after build."""
        pass
