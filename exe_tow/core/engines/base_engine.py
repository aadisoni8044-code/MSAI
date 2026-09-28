from abc import ABC, abstractmethod
from typing import List, Dict, Any, Optional
from exe_tow.core.models import ProjectInfo, EnvironmentInfo, CommandExecution

class BaseEngine(ABC):
    def __init__(self, name: str):
        self.name = name

    @abstractmethod
    def build_command_candidates(
        self,
        project_info: ProjectInfo,
        env_info: EnvironmentInfo,
        exe_name: str,
        output_folder: str,
        build_mode: str,  # "ONE FILE" or "ONE DIRECTORY"
        extra_args: Optional[List[str]] = None
    ) -> List[List[str]]:
        """Return a sequence of build command candidate lists (arguments)."""
        pass

    @abstractmethod
    def find_output_exe(
        self,
        project_info: ProjectInfo,
        exe_name: str,
        output_folder: str,
        build_mode: str
    ) -> Optional[str]:
        """Locate the created executable in output directory."""
        pass
