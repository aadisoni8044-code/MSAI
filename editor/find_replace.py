"""
In-file Find & Replace panel for PyCodeStudio.
"""

import re
from PyQt6.QtCore import Qt, pyqtSignal
from PyQt6.QtWidgets import (
    QCheckBox,
    QHBoxLayout,
    QLabel,
    QLineEdit,
    QPushButton,
    QVBoxLayout,
    QWidget,
)


class FindReplacePanel(QWidget):
    """Find and Replace floating/docked toolbar for active code editor."""

    closed_signal = pyqtSignal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self.editor = None
        self._init_ui()

    def _init_ui(self) -> None:
        """Constructs Find and Replace panel UI layout."""
        self.setObjectName("findReplacePanel")
        self.setStyleSheet("""
            #findReplacePanel {
                background-color: #252526;
                border: 1px solid #454545;
                border-radius: 4px;
            }
            QLabel {
                color: #cccccc;
            }
            QPushButton {
                padding: 4px 8px;
            }
        """)

        layout = QVBoxLayout(self)
        layout.setContentsMargins(8, 6, 8, 6)
        layout.setSpacing(4)

        # Row 1: Find Row
        find_row = QHBoxLayout()
        find_row.setSpacing(6)

        self.find_input = QLineEdit()
        self.find_input.setPlaceholderText("Find")
        self.find_input.textChanged.connect(self._on_find_text_changed)
        self.find_input.returnPressed.connect(self.find_next)

        self.match_case_check = QCheckBox("Aa")
        self.match_case_check.setToolTip("Match Case")
        self.match_case_check.stateChanged.connect(self._on_find_text_changed)

        self.regex_check = QCheckBox(".*")
        self.regex_check.setToolTip("Use Regular Expression")
        self.regex_check.stateChanged.connect(self._on_find_text_changed)

        self.btn_next = QPushButton("↓")
        self.btn_next.setToolTip("Find Next")
        self.btn_next.clicked.connect(self.find_next)

        self.btn_prev = QPushButton("↑")
        self.btn_prev.setToolTip("Find Previous")
        self.btn_prev.clicked.connect(self.find_prev)

        self.status_label = QLabel("0/0")
        self.status_label.setStyleSheet("color: #888888; padding: 0 4px;")

        self.btn_close = QPushButton("✕")
        self.btn_close.setToolTip("Close (Esc)")
        self.btn_close.setFlat(True)
        self.btn_close.clicked.connect(self.close_panel)

        find_row.addWidget(self.find_input)
        find_row.addWidget(self.match_case_check)
        find_row.addWidget(self.regex_check)
        find_row.addWidget(self.btn_prev)
        find_row.addWidget(self.btn_next)
        find_row.addWidget(self.status_label)
        find_row.addWidget(self.btn_close)

        # Row 2: Replace Row
        replace_row = QHBoxLayout()
        replace_row.setSpacing(6)

        self.replace_input = QLineEdit()
        self.replace_input.setPlaceholderText("Replace")

        self.btn_replace = QPushButton("Replace")
        self.btn_replace.clicked.connect(self.replace_next)

        self.btn_replace_all = QPushButton("Replace All")
        self.btn_replace_all.clicked.connect(self.replace_all)

        replace_row.addWidget(self.replace_input)
        replace_row.addWidget(self.btn_replace)
        replace_row.addWidget(self.btn_replace_all)

        layout.addLayout(find_row)
        layout.addLayout(replace_row)

    def set_editor(self, editor) -> None:
        """Binds an editor instance to this find/replace bar."""
        self.editor = editor
        self.update_match_count()

    def show_and_focus(self) -> None:
        """Shows panel and focuses the search input."""
        self.show()
        if self.editor and self.editor.hasSelectedText():
            selected = self.editor.selectedText()
            if selected and "\n" not in selected:
                self.find_input.setText(selected)
        self.find_input.selectAll()
        self.find_input.setFocus()

    def close_panel(self) -> None:
        """Hides the find/replace panel."""
        self.hide()
        if self.editor:
            self.editor.setFocus()
        self.closed_signal.emit()

    def keyPressEvent(self, event) -> None:
        """Handles Escape key to close find bar."""
        if event.key() == Qt.Key.Key_Escape:
            self.close_panel()
        else:
            super().keyPressEvent(event)

    def _on_find_text_changed(self) -> None:
        """Recalculates matches when search text or options change."""
        self.update_match_count()
        self.find_next()

    def _get_search_params(self):
        """Returns tuple of (query, is_regex, case_sensitive)."""
        query = self.find_input.text()
        is_regex = self.regex_check.isChecked()
        case_sensitive = self.match_case_check.isChecked()
        return query, is_regex, case_sensitive

    def update_match_count(self) -> None:
        """Counts search matches in the active document."""
        if not self.editor:
            self.status_label.setText("0/0")
            return

        query, is_regex, case_sensitive = self._get_search_params()
        if not query:
            self.status_label.setText("0/0")
            return

        text = self.editor.text()
        flags = 0 if case_sensitive else re.IGNORECASE

        try:
            pattern = query if is_regex else re.escape(query)
            matches = list(re.finditer(pattern, text, flags))
            self.status_label.setText(f"{len(matches)} matches")
        except re.error:
            self.status_label.setText("Invalid Regex")

    def find_next(self) -> None:
        """Finds next occurrence in editor."""
        if not self.editor:
            return
        query, is_regex, case_sensitive = self._get_search_params()
        if not query:
            return

        line, col = self.editor.getCursorPosition()
        found = self.editor.findFirst(
            query,
            is_regex,
            case_sensitive,
            False,  # whole word
            True,   # wrap
            True,   # forward
            line,
            col,
            True    # show match
        )
        if not found:
            # try wrapping around from top
            self.editor.findFirst(query, is_regex, case_sensitive, False, True, True, 0, 0, True)

    def find_prev(self) -> None:
        """Finds previous occurrence in editor."""
        if not self.editor:
            return
        query, is_regex, case_sensitive = self._get_search_params()
        if not query:
            return

        line, col = self.editor.getCursorPosition()
        self.editor.findFirst(
            query,
            is_regex,
            case_sensitive,
            False,
            True,
            False,  # backward search
            line,
            col,
            True
        )

    def replace_next(self) -> None:
        """Replaces current match and finds next."""
        if not self.editor:
            return
        if self.editor.hasSelectedText():
            self.editor.replace(self.replace_input.text())
            self.find_next()
            self.update_match_count()
        else:
            self.find_next()

    def replace_all(self) -> None:
        """Replaces all occurrences in the document."""
        if not self.editor:
            return
        query, is_regex, case_sensitive = self._get_search_params()
        replace_text = self.replace_input.text()

        if not query:
            return

        text = self.editor.text()
        flags = 0 if case_sensitive else re.IGNORECASE

        try:
            pattern = query if is_regex else re.escape(query)
            new_text, count = re.subn(pattern, replace_text, text, flags=flags)
            if count > 0:
                line, col = self.editor.getCursorPosition()
                self.editor.setText(new_text)
                self.editor.setCursorPosition(min(line, self.editor.lines() - 1), col)
                self.update_match_count()
        except re.error:
            self.status_label.setText("Invalid Regex")
