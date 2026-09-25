"""Build strategy and attempt models."""

from dataclasses import dataclass, field
from typing import List, Optional, Dict, Any
from models.command_result import CommandResult


@dataclass
class BuildStrategy:
    """Strategy configuration for building an EXE."""
    builder_name: str  # 'PyInstaller', 'Nuitka', 'cx_Freeze'
    mode: str  # 'onefile', 'onedir'
    is_gui: bool = False
    custom_args: List[str] = field(default_factory=list)

    def to_dict(self) -> Dict[str, Any]:
        return {
            "builder_name": self.builder_name,
            "mode": self.mode,
            "is_gui": self.is_gui,
            "custom_args": self.custom_args
        }


@dataclass
class BuildAttempt:
    """Records a single build attempt in a build process."""
    attempt_number: int
    builder_name: str
    strategy: BuildStrategy
    command: List[str]
    command_result: Optional[CommandResult] = None
    status: str = "PENDING"  # PENDING, IN_PROGRESS, SUCCESS, FAILED, CANCELLED
    error_type: Optional[str] = None
    error_message: Optional[str] = None
    applied_fix: Optional[str] = None
    timestamp: Optional[str] = None


@dataclass
class BuildResult:
    """Final result of a build execution."""
    status: str  # SUCCESS, PARTIAL_SUCCESS, FAILED, CANCELLED
    project_path: str
    output_exe: Optional[str] = None
    attempts: List[BuildAttempt] = field(default_factory=list)
    total_duration: float = 0.0
    summary_message: str = ""
    is_true_onefile: bool = True
