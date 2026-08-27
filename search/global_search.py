"""
Global search across project files for PyCodeStudio.
"""

import re
from pathlib import Path
from typing import List, Tuple

from PyQt6.QtCore import Qt, pyqtSignal
from PyQt6.QtWidgets import (
    QCheckBox,
    QHBoxLayout,
    QLabel,
    QLineEdit,
    QListWidget,
    QListWidgetItem,
    QPushButton,
    QVBoxLayout,
    QWidget,
)

from utils.file_utils import read_file_content
from utils.logger import logger


class GlobalSearchPanel(QWidget):
    """Sidebar/panel searching for string or regex patterns across project files."""

    file_selected = pyqtSignal(Path, int)  # file_path, line_number

    def __init__(self, root_path: Path = None, parent=None):
        super().__init__(parent)
        self.root_path = root_path or Path.home()

        layout = QVBoxLayout(self)
        layout.setContentsMargins(8, 8, 8, 8)
        layout.setSpacing(6)

        title = QLabel("SEARCH IN FILES")
        title.setStyleSheet("font-weight: bold; color: #bbbbbb; font-size: 11px;")
        layout.addWidget(title)

        # Search Query Input
        self.query_input = QLineEdit()
        self.query_input.setPlaceholderText("Search")
        self.query_input.returnPressed.connect(self.perform_search)
        layout.addWidget(self.query_input)

        # Options Row
        opts_row = QHBoxLayout()
        self.match_case_check = QCheckBox("Aa")
        self.match_case_check.setToolTip("Match Case")

        self.regex_check = QCheckBox(".*")
        self.regex_check.setToolTip("Use Regular Expression")

        self.btn_search = QPushButton("Search")
        self.btn_search.clicked.connect(self.perform_search)

        opts_row.addWidget(self.match_case_check)
        opts_row.addWidget(self.regex_check)
        opts_row.addStretch()
        opts_row.addWidget(self.btn_search)

        layout.addLayout(opts_row)

        # Include / Exclude Filter Input
        self.filter_input = QLineEdit()
        self.filter_input.setPlaceholderText("Files to include (e.g. *.py, *.js)")
        layout.addWidget(self.filter_input)

        # Results summary label
        self.status_label = QLabel("No search executed")
        self.status_label.setStyleSheet("color: #888888; font-size: 11px;")
        layout.addWidget(self.status_label)

        # Results List Widget
        self.results_list = QListWidget()
        self.results_list.itemDoubleClicked.connect(self._on_item_double_clicked)
        layout.addWidget(self.results_list)

    def set_root_directory(self, path: Path) -> None:
        """Sets project directory target for global search."""
        self.root_path = path.resolve()

    def perform_search(self) -> None:
        """Executes search across all text files in project directory."""
        query = self.query_input.text().strip()
        self.results_list.clear()

        if not query:
            self.status_label.setText("Please enter a search query")
            return

        if not self.root_path.exists():
            self.status_label.setText("Invalid search directory")
            return

        is_regex = self.regex_check.isChecked()
        case_sensitive = self.match_case_check.isChecked()
        flags = 0 if case_sensitive else re.IGNORECASE

        filter_pattern = self.filter_input.text().strip()
        extensions = None
        if filter_pattern:
            extensions = [e.strip().replace("*", "") for e in filter_pattern.split(",") if e.strip()]

        total_matches = 0
        total_files = 0

        # Traverse directory
        for file_path in self.root_path.rglob("*"):
            if not file_path.is_file():
                continue

            # Skip hidden files and build output folders
            if any(part.startswith(".") or part in ("__pycache__", "node_modules", "dist", "build") for part in file_path.parts):
                continue

            # Extension filter check
            if extensions:
                if not any(file_path.name.endswith(ext) for ext in extensions):
                    continue

            content, _ = read_file_content(file_path)
            if content is None:
                continue

            lines = content.splitlines()
            file_match_count = 0

            try:
                pattern = query if is_regex else re.escape(query)
                regex = re.compile(pattern, flags)

                for idx, line in enumerate(lines, start=1):
                    if regex.search(line):
                        file_match_count += 1
                        total_matches += 1

                        rel_path = file_path.relative_to(self.root_path)
                        item_text = f"{rel_path}:{idx}: {line.strip()}"
                        item = QListWidgetItem(item_text)
                        item.setData(Qt.ItemDataRole.UserRole, (str(file_path.resolve()), idx))
                        self.results_list.addItem(item)

                if file_match_count > 0:
                    total_files += 1

            except re.error:
                self.status_label.setText("Invalid regex pattern")
                return

        self.status_label.setText(f"{total_matches} matches in {total_files} files")

    def _on_item_double_clicked(self, item: QListWidgetItem) -> None:
        """Emits signal to open target file and scroll to line."""
        data = item.data(Qt.ItemDataRole.UserRole)
        if data:
            file_path_str, line_num = data
            self.file_selected.emit(Path(file_path_str), line_num)
