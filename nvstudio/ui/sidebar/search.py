"""NV Studio Search and Replace Sidebar Panel"""
import os
import re
from pathlib import Path
from typing import List, Tuple
from PyQt6.QtCore import QThread, pyqtSignal, Qt, QRegularExpression
from PyQt6.QtWidgets import (
    QCheckBox, QHBoxLayout, QLabel, QLineEdit, QListWidget, QListWidgetItem,
    QPushButton, QVBoxLayout, QWidget, QMessageBox
)

from nvstudio.core.workspace import workspace_manager


class SearchWorker(QThread):
    """Background worker thread searching workspace files for matching queries."""
    result_found = pyqtSignal(str, int, str)  # (file_path, line_number, line_text)
    finished_search = pyqtSignal(int)          # total matches count

    def __init__(self, root_path: str, query: str, case_sensitive: bool, is_regex: bool, whole_word: bool, file_filter: str):
        super().__init__()
        self.root_path = root_path
        self.query = query
        self.case_sensitive = case_sensitive
        self.is_regex = is_regex
        self.whole_word = whole_word
        self.file_filter = file_filter
        self.stop_requested = False

    def run(self):
        if not self.root_path or not os.path.exists(self.root_path) or not self.query:
            self.finished_search.emit(0)
            return

        total_matches = 0
        pattern = self.query

        if not self.is_regex:
            pattern = re.escape(self.query)
        if self.whole_word:
            pattern = r'\b' + pattern + r'\b'

        flags = 0 if self.case_sensitive else re.IGNORECASE

        try:
            regex = re.compile(pattern, flags)
        except Exception:
            self.finished_search.emit(0)
            return

        filter_exts = [f.strip().lower() for f in self.file_filter.split(",")] if self.file_filter else []

        for root, dirs, files in os.walk(self.root_path):
            if self.stop_requested:
                break

            # Skip hidden dirs and common exclude folders (.git, __pycache__, venv)
            dirs[:] = [d for d in dirs if not d.startswith(".") and d not in ("node_modules", "venv", "__pycache__", "build", "dist")]

            for file in files:
                if self.stop_requested:
                    break

                if filter_exts:
                    ext = Path(file).suffix.lower()
                    if ext not in filter_exts and f".{ext}" not in filter_exts:
                        continue

                file_path = os.path.join(root, file)
                try:
                    with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
                        for line_num, line in enumerate(f, 1):
                            if self.stop_requested:
                                break
                            if regex.search(line):
                                self.result_found.emit(file_path, line_num, line.strip())
                                total_matches += 1
                except Exception:
                    continue

        self.finished_search.emit(total_matches)

    def cancel(self):
        self.stop_requested = True


class SearchPanel(QWidget):
    """Workspace Search and Replace Sidebar Panel."""
    file_match_selected = pyqtSignal(str, int)  # (file_path, line_number)

    def __init__(self, parent=None):
        super().__init__(parent)
        self.setObjectName("SearchPanel")

        layout = QVBoxLayout(self)
        layout.setContentsMargins(0, 0, 0, 0)
        layout.setSpacing(8)

        # Header
        header = QLabel("SEARCH")
        header.setObjectName("SidebarHeader")
        layout.addWidget(header)

        form_widget = QWidget()
        form_layout = QVBoxLayout(form_widget)
        form_layout.setContentsMargins(8, 0, 8, 0)
        form_layout.setSpacing(6)

        # Search query input
        self.search_input = QLineEdit()
        self.search_input.setPlaceholderText("Search query...")
        self.search_input.returnPressed.connect(self.start_search)
        form_layout.addWidget(self.search_input)

        # Options Row
        options_layout = QHBoxLayout()
        options_layout.setSpacing(6)

        self.case_cb = QCheckBox("Aa")
        self.case_cb.setToolTip("Match Case")

        self.regex_cb = QCheckBox(".*")
        self.regex_cb.setToolTip("Use Regular Expression")

        self.word_cb = QCheckBox(r"\b")
        self.word_cb.setToolTip("Match Whole Word")

        options_layout.addWidget(self.case_cb)
        options_layout.addWidget(self.regex_cb)
        options_layout.addWidget(self.word_cb)
        options_layout.addStretch()

        form_layout.addLayout(options_layout)

        # Replace query input
        self.replace_input = QLineEdit()
        self.replace_input.setPlaceholderText("Replace with...")
        form_layout.addWidget(self.replace_input)

        # File Filter Input
        self.filter_input = QLineEdit()
        self.filter_input.setPlaceholderText("Include files (e.g. .py, .js)")
        form_layout.addWidget(self.filter_input)

        # Action Buttons
        btn_layout = QHBoxLayout()
        self.search_btn = QPushButton("Search Workspace")
        self.search_btn.clicked.connect(self.start_search)

        self.replace_all_btn = QPushButton("Replace All")
        self.replace_all_btn.clicked.connect(self.replace_all)

        btn_layout.addWidget(self.search_btn)
        btn_layout.addWidget(self.replace_all_btn)
        form_layout.addLayout(btn_layout)

        layout.addWidget(form_widget)

        # Results Label
        self.status_label = QLabel("No search results")
        self.status_label.setStyleSheet("color: #64748b; font-size: 11px; padding-left: 8px;")
        layout.addWidget(self.status_label)

        # Results List
        self.results_list = QListWidget()
        self.results_list.itemDoubleClicked.connect(self._on_item_double_clicked)
        layout.addWidget(self.results_list)

        self.search_worker: Optional[SearchWorker] = None

    def start_search(self) -> None:
        if self.search_worker and self.search_worker.isRunning():
            self.search_worker.cancel()
            self.search_worker.wait()

        root = workspace_manager.get_root_path()
        if not root:
            self.status_label.setText("No folder open in workspace")
            return

        query = self.search_input.text().strip()
        if not query:
            self.status_label.setText("Please enter search query")
            return

        self.results_list.clear()
        self.status_label.setText("Searching...")

        self.search_worker = SearchWorker(
            root_path=root,
            query=query,
            case_sensitive=self.case_cb.isChecked(),
            is_regex=self.regex_cb.isChecked(),
            whole_word=self.word_cb.isChecked(),
            file_filter=self.filter_input.text().strip()
        )
        self.search_worker.result_found.connect(self._on_result_found)
        self.search_worker.finished_search.connect(self._on_search_finished)
        self.search_worker.start()

    def _on_result_found(self, file_path: str, line_num: int, text: str) -> None:
        rel_path = os.path.relpath(file_path, workspace_manager.get_root_path() or "")
        item_text = f"{rel_path}:{line_num}  →  {text}"
        item = QListWidgetItem(item_text)
        item.setData(Qt.ItemDataRole.UserRole, (file_path, line_num))
        self.results_list.addItem(item)

    def _on_search_finished(self, total_matches: int) -> None:
        self.status_label.setText(f"Found {total_matches} match(es)")

    def _on_item_double_clicked(self, item: QListWidgetItem) -> None:
        data = item.data(Qt.ItemDataRole.UserRole)
        if data:
            file_path, line_num = data
            self.file_match_selected.emit(file_path, line_num)

    def replace_all(self) -> None:
        root = workspace_manager.get_root_path()
        query = self.search_input.text().strip()
        repl = self.replace_input.text()

        if not root or not query:
            return

        reply = QMessageBox.question(
            self,
            "Confirm Replace All",
            f"Replace all occurrences of '{query}' with '{repl}' across workspace files?",
            QMessageBox.StandardButton.Yes | QMessageBox.StandardButton.No,
            QMessageBox.StandardButton.No
        )
        if reply != QMessageBox.StandardButton.Yes:
            return

        total_replaced = 0
        # Re-run search pattern replacement file-by-file
        for i in range(self.results_list.count()):
            item = self.results_list.item(i)
            data = item.data(Qt.ItemDataRole.UserRole)
            if data:
                file_path, line_num = data
                try:
                    with open(file_path, "r", encoding="utf-8") as f:
                        content = f.read()

                    if self.case_cb.isChecked():
                        new_content = content.replace(query, repl)
                    else:
                        pattern = re.compile(re.escape(query), re.IGNORECASE)
                        new_content = pattern.sub(repl, content)

                    if new_content != content:
                        with open(file_path, "w", encoding="utf-8") as f:
                            f.write(new_content)
                        total_replaced += 1
                except Exception as e:
                    print(f"Replace error in {file_path}: {e}")

        QMessageBox.information(self, "Replace Complete", f"Replaced occurrences in {total_replaced} file(s).")
        self.start_search()
