"""Permission request model and Settings model."""

from dataclasses import dataclass, field
from typing import Dict, Any


@dataclass
class PermissionRequest:
    """Represents permissions requested before running build actions."""
    folder_access: bool = True
    execute_commands: bool = True
    create_files: bool = True
    install_packages: bool = False
    internet_access: bool = False


@dataclass
class Settings:
    """Application settings and user preferences."""
    python_interpreter: str = "python"
    default_output_dir: str = "dist"
    build_workspace: str = ".kora_build"
    max_build_attempts: int = 5
    auto_install_dependencies: bool = False
    auto_safe_fixes: bool = False
    remember_successful_strategy: bool = True
    keep_build_logs: bool = True

    def to_dict(self) -> Dict[str, Any]:
        return {
            "python_interpreter": self.python_interpreter,
            "default_output_dir": self.default_output_dir,
            "build_workspace": self.build_workspace,
            "max_build_attempts": self.max_build_attempts,
            "auto_install_dependencies": self.auto_install_dependencies,
            "auto_safe_fixes": self.auto_safe_fixes,
            "remember_successful_strategy": self.remember_successful_strategy,
            "keep_build_logs": self.keep_build_logs,
        }
