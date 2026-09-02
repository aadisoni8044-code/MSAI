"""
MSAI Studio - Search View Sidebar Component
"""
from PyQt6.QtWidgets import (
    QWidget, QVBoxLayout, QHBoxLayout, QLabel, QLineEdit, QPushButton,
    QCheckBox, QTreeWidget, QTreeWidgetItem
)
from PyQt6.QtCore import pyqtSignal, Qt
from core.search_engine import SearchEngine

class SearchView(QWidget):
    """
    Search & Replace panel supporting project-wide search with regex,
    case-sensitivity, and whole word matching.
    """
    file_match_selected = pyqtSignal(str, int) # file_path, line_number

    def __init__(self, parent=None):
        super().__init__(parent)
        self.project_path = ""

        layout = QVBoxLayout(self)
        layout.setContentsMargins(8, 8, 8, 8)

        title = QLabel("SEARCH")
        title.setStyleSheet("font-size: 11px; font-weight: bold; color: #a6adc8;")
        layout.addWidget(title)

        # Inputs
        self.search_input = QLineEdit()
        self.search_input.setPlaceholderText("Search")
        self.search_input.returnPressed.connect(self.perform_search)

        self.replace_input = QLineEdit()
        self.replace_input.setPlaceholderText("Replace")

        # Options
        opts_layout = QHBoxLayout()
        self.chk_case = QCheckBox("Aa")
        self.chk_case.setToolTip("Match Case")
        self.chk_word = QCheckBox("Ab")
        self.chk_word.setToolTip("Match Whole Word")
        self.chk_regex = QCheckBox(".*")
        self.chk_regex.setToolTip("Use Regular Expression")

        opts_layout.addWidget(self.chk_case)
        opts_layout.addWidget(self.chk_word)
        opts_layout.addWidget(self.chk_regex)

        # Action Buttons
        btn_layout = QHBoxLayout()
        self.btn_search = QPushButton("Search")
        self.btn_search.clicked.connect(self.perform_search)
        self.btn_replace_all = QPushButton("Replace All")
        self.btn_replace_all.clicked.connect(self.perform_replace_all)

        btn_layout.addWidget(self.btn_search)
        btn_layout.addWidget(self.btn_replace_all)

        # Results Tree Widget
        self.results_tree = QTreeWidget()
        self.results_tree.setHeaderHidden(True)
        self.results_tree.itemDoubleClicked.connect(self._on_item_double_clicked)

        layout.addWidget(self.search_input)
        layout.addWidget(self.replace_input)
        layout.addLayout(opts_layout)
        layout.addLayout(btn_layout)
        layout.addWidget(self.results_tree)

    def set_project_path(self, path: str):
        self.project_path = path

    def perform_search(self):
        query = self.search_input.text().strip()
        if not query or not self.project_path:
            return

        self.results_tree.clear()
        results = SearchEngine.search_in_directory(
            self.project_path,
            query,
            case_sensitive=self.chk_case.isChecked(),
            whole_word=self.chk_word.isChecked(),
            use_regex=self.chk_regex.isChecked()
        )

        for res in results:
            file_item = QTreeWidgetItem([f"📄 {res['relative_path']} ({len(res['matches'])} matches)"])
            file_item.setData(0, Qt.ItemDataRole.UserRole, res['file_path'])

            for match in res['matches']:
                match_item = QTreeWidgetItem([f"  Line {match['line_number']}: {match['line_text']}"])
                match_item.setData(0, Qt.ItemDataRole.UserRole, (res['file_path'], match['line_number']))
                file_item.addChild(match_item)

            self.results_tree.addTopLevelItem(file_item)
            file_item.setExpanded(True)

    def perform_replace_all(self):
        query = self.search_input.text().strip()
        replacement = self.replace_input.text()
        if not query or not self.project_path:
            return

        results = SearchEngine.search_in_directory(
            self.project_path,
            query,
            case_sensitive=self.chk_case.isChecked(),
            whole_word=self.chk_word.isChecked(),
            use_regex=self.chk_regex.isChecked()
        )

        for res in results:
            SearchEngine.replace_in_file(
                res['file_path'],
                query,
                replacement,
                case_sensitive=self.chk_case.isChecked(),
                whole_word=self.chk_word.isChecked(),
                use_regex=self.chk_regex.isChecked()
            )

        self.perform_search()

    def _on_item_double_clicked(self, item, col):
        data = item.data(0, Qt.ItemDataRole.UserRole)
        if isinstance(data, tuple):
            file_path, line = data
            self.file_match_selected.emit(file_path, line)
