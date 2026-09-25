"""Data models for Kora Build System."""

from dataclasses import dataclass, field
from typing import List, Dict, Optional, Any
from pathlib import Path


@dataclass
class ProjectInfo:
    """Holds information about a scanned Python project."""
    project_path: str
    project_name: str
    python_files: List[str] = field(default_factory=list)
    config_files: List[str] = field(default_factory=list)  # requirements.txt, setup.py, pyproject.toml, etc.
    venv_path: Optional[str] = None
    entry_point_candidates: List[str] = field(default_factory=list)
    selected_entry_point: Optional[str] = None
    imported_modules: List[str] = field(default_factory=list)
    detected_assets: List[str] = field(default_factory=list)
    selected_assets: List[str] = field(default_factory=list)

    # User build preferences for this project
    is_onefile: bool = True
    is_gui: bool = False
    app_name: Optional[str] = None
    icon_path: Optional[str] = None

    def to_dict(self) -> Dict[str, Any]:
        return {
            "project_path": self.project_path,
            "project_name": self.project_name,
            "python_files": self.python_files,
            "config_files": self.config_files,
            "venv_path": self.venv_path,
            "entry_point_candidates": self.entry_point_candidates,
            "selected_entry_point": self.selected_entry_point,
            "imported_modules": self.imported_modules,
            "detected_assets": self.detected_assets,
            "selected_assets": self.selected_assets,
            "is_onefile": self.is_onefile,
            "is_gui": self.is_gui,
            "app_name": self.app_name,
            "icon_path": self.icon_path
        }
