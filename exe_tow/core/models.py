from dataclasses import dataclass, field
from enum import Enum, auto
from typing import List, Dict, Optional, Any
import datetime

class CommandStatus(Enum):
    PENDING = "PENDING"
    RUNNING = "RUNNING"
    SUCCESS = "SUCCESS"
    FAILED = "FAILED"
    SKIPPED = "SKIPPED"
    CANCELLED = "CANCELLED"

class ErrorCategory(Enum):
    PYINSTALLER_NOT_FOUND = "PYINSTALLER_NOT_FOUND"
    MISSING_MODULE = "MISSING_MODULE"
    INVALID_PATH = "INVALID_PATH"
    PERMISSION_ERROR = "PERMISSION_ERROR"
    PYTHON_NOT_FOUND = "PYTHON_NOT_FOUND"
    PIP_NOT_FOUND = "PIP_NOT_FOUND"
    BUILD_COMMAND_FAILED = "BUILD_COMMAND_FAILED"
    DEPENDENCY_ERROR = "DEPENDENCY_ERROR"
    OUTPUT_NOT_FOUND = "OUTPUT_NOT_FOUND"
    UNKNOWN_ERROR = "UNKNOWN_ERROR"

@dataclass
class CommandExecution:
    id: str
    command_text: str
    reason: str
    timestamp: str = field(default_factory=lambda: datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
    status: CommandStatus = CommandStatus.PENDING
    exit_code: Optional[int] = None
    stdout: str = ""
    stderr: str = ""
    duration: float = 0.0
    retry_count: int = 0

    def to_dict(self) -> Dict[str, Any]:
        return {
            "id": self.id,
            "command_text": self.command_text,
            "reason": self.reason,
            "timestamp": self.timestamp,
            "status": self.status.value if isinstance(self.status, CommandStatus) else str(self.status),
            "exit_code": self.exit_code,
            "stdout": self.stdout,
            "stderr": self.stderr,
            "duration": self.duration,
            "retry_count": self.retry_count
        }

    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> "CommandExecution":
        status_val = data.get("status", "PENDING")
        try:
            status_enum = CommandStatus(status_val)
        except ValueError:
            status_enum = CommandStatus.PENDING

        return cls(
            id=data.get("id", ""),
            command_text=data.get("command_text", ""),
            reason=data.get("reason", ""),
            timestamp=data.get("timestamp", ""),
            status=status_enum,
            exit_code=data.get("exit_code"),
            stdout=data.get("stdout", ""),
            stderr=data.get("stderr", ""),
            duration=data.get("duration", 0.0),
            retry_count=data.get("retry_count", 0)
        )

@dataclass
class EnvironmentInfo:
    python_executable: str
    python_version: str
    architecture: str
    pip_executable: Optional[str]
    pip_installed: bool
    pyinstaller_installed: bool
    pyinstaller_version: Optional[str] = None
    virtual_env: Optional[str] = None

    def to_dict(self) -> Dict[str, Any]:
        return {
            "python_executable": self.python_executable,
            "python_version": self.python_version,
            "architecture": self.architecture,
            "pip_executable": self.pip_executable,
            "pip_installed": self.pip_installed,
            "pyinstaller_installed": self.pyinstaller_installed,
            "pyinstaller_version": self.pyinstaller_version,
            "virtual_env": self.virtual_env
        }

@dataclass
class ProjectInfo:
    project_path: str
    entry_file: str
    project_name: str
    is_single_file: bool
    has_requirements: bool
    requirements_path: Optional[str]
    has_venv: bool
    venv_path: Optional[str]
    detected_imports: List[str] = field(default_factory=list)
    local_assets: List[str] = field(default_factory=list)

    def to_dict(self) -> Dict[str, Any]:
        return {
            "project_path": self.project_path,
            "entry_file": self.entry_file,
            "project_name": self.project_name,
            "is_single_file": self.is_single_file,
            "has_requirements": self.has_requirements,
            "requirements_path": self.requirements_path,
            "has_venv": self.has_venv,
            "venv_path": self.venv_path,
            "detected_imports": self.detected_imports,
            "local_assets": self.local_assets
        }

@dataclass
class BuildRecord:
    id: str
    project_name: str
    exe_name: str
    source_path: str
    entry_file: str
    output_folder: str
    build_mode: str
    build_engine: str
    date: str
    status: str
    output_exe_path: Optional[str]
    duration: float
    commands_attempted: List[Dict[str, Any]] = field(default_factory=list)
    error_summary: Optional[str] = None

    def to_dict(self) -> Dict[str, Any]:
        return {
            "id": self.id,
            "project_name": self.project_name,
            "exe_name": self.exe_name,
            "source_path": self.source_path,
            "entry_file": self.entry_file,
            "output_folder": self.output_folder,
            "build_mode": self.build_mode,
            "build_engine": self.build_engine,
            "date": self.date,
            "status": self.status,
            "output_exe_path": self.output_exe_path,
            "duration": self.duration,
            "commands_attempted": self.commands_attempted,
            "error_summary": self.error_summary
        }
