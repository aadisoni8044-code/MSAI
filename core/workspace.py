"""
MSAI Studio - Workspace Manager
"""
from typing import List, Dict, Optional
import os

class Workspace:
    """Manages workspace state, open files list, and recent projects."""

    def __init__(self, project_manager, config_manager):
        self.project_manager = project_manager
        self.config_manager = config_manager
        self.open_files: List[str] = []
        self.active_file: Optional[str] = None

    def add_open_file(self, file_path: str):
        """Track open file."""
        norm_path = os.path.abspath(file_path)
        if norm_path not in self.open_files:
            self.open_files.append(norm_path)
            self.config_manager.add_recent_file(norm_path)
        self.active_file = norm_path

    def remove_open_file(self, file_path: str):
        """Untrack open file."""
        norm_path = os.path.abspath(file_path)
        if norm_path in self.open_files:
            self.open_files.remove(norm_path)
        if self.active_file == norm_path:
            self.active_file = self.open_files[-1] if self.open_files else None
