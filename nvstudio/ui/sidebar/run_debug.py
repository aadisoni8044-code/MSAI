"""NV Studio Run & Debug Runner Sidebar Panel"""
import os
import sys
from pathlib import Path
from typing import Optional
from PyQt6.QtCore import pyqtSignal
from PyQt6.QtWidgets import (
    QComboBox, QHBoxLayout, QLabel, QLineEdit,
    QPushButton, QTextEdit, QVBoxLayout, QWidget
)

from nvstudio.core.workspace import workspace_manager


class RunDebugPanel(QWidget):
    """Run and Debug configuration and script executor launcher panel."""
    run_file_requested = pyqtSignal(str, str)  # (file_path, args)

    def __init__(self, parent=None):
        super().__init__(parent)
        self.setObjectName("RunDebugPanel")

        layout = QVBoxLayout(self)
        layout.setContentsMargins(0, 0, 0, 0)
        layout.setSpacing(8)

        # Header
        header = QLabel("RUN & DEBUG")
        header.setObjectName("SidebarHeader")
        layout.addWidget(header)

        container = QWidget()
        c_layout = QVBoxLayout(container)
        c_layout.setContentsMargins(8, 0, 8, 0)
        c_layout.setSpacing(8)

        # Environment Selector
        c_layout.addWidget(QLabel("Environment:"))
        self.env_combo = QComboBox()
        self.env_combo.addItem(f"Python 3 ({sys.executable})")
        c_layout.addWidget(self.env_combo)

        # Arguments input
        c_layout.addWidget(QLabel("CLI Arguments:"))
        self.args_input = QLineEdit()
        self.args_input.setPlaceholderText("e.g. --verbose input.txt")
        c_layout.addWidget(self.args_input)

        # Run Button
        self.run_btn = QPushButton("▶ Run Active File")
        self.run_btn.setStyleSheet("background-color: #10b981; font-weight: bold;")
        self.run_btn.clicked.connect(self._on_run_clicked)
        c_layout.addWidget(self.run_btn)

        # Execution Log Preview
        c_layout.addWidget(QLabel("Execution Target:"))
        self.target_label = QLabel("No active editor file")
        self.target_label.setWordWrap(True)
        self.target_label.setStyleSheet("color: #94a3b8; font-size: 11px;")
        c_layout.addWidget(self.target_label)

        c_layout.addStretch()
        layout.addWidget(container)

        self.current_filepath: Optional[str] = None

    def set_active_filepath(self, filepath: Optional[str]) -> None:
        self.current_filepath = filepath
        if filepath and not filepath.startswith("__untitled__"):
            self.target_label.setText(f"File: {Path(filepath).name}\nPath: {filepath}")
            self.run_btn.setEnabled(True)
        else:
            self.target_label.setText("No saved file active")
            self.run_btn.setEnabled(False)

    def _on_run_clicked(self) -> None:
        if self.current_filepath:
            args = self.args_input.text().strip()
            self.run_file_requested.emit(self.current_filepath, args)
