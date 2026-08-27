"""
Main QScintilla-based code editor component.
"""

from pathlib import Path
from typing import Optional

from PyQt6.QtCore import QTimer, pyqtSignal
from PyQt6.QtGui import QColor, QFont, QKeySequence, QShortcut
from PyQt6.Qsci import QsciScintilla

from editor.syntax_highlighter import SyntaxHighlighterConfigurator
from utils.file_utils import get_language_from_filename, read_file_content, write_file_content
from utils.logger import logger


class EditorWidget(QsciScintilla):
    """QScintilla text editor widget supporting syntax highlighting, folding, and auto-save."""

    text_changed_signal = pyqtSignal()
    cursor_position_changed_signal = pyqtSignal(int, int)  # line, col

    def __init__(self, file_path: Optional[Path] = None, settings: dict = None, parent=None):
        super().__init__(parent)
        self.file_path: Optional[Path] = file_path
        self.file_encoding: str = "utf-8"
        self.settings: dict = settings or {}
        self.is_modified: bool = False
        self.language: str = "text"

        self.font_family: str = self.settings.get("font_family", "Consolas")
        self.font_size: int = self.settings.get("font_size", 13)

        self._configure_editor()

        # Auto-save timer
        self.auto_save_timer = QTimer(self)
        self.auto_save_timer.timeout.connect(self._auto_save_trigger)
        self._update_auto_save_timer()

        # Connect signals
        self.textChanged.connect(self._on_text_changed)
        self.cursorPositionChanged.connect(self._on_cursor_position_changed)

        # Keyboard shortcuts (comment line)
        self.shortcut_comment = QShortcut(QKeySequence("Ctrl+/"), self)
        self.shortcut_comment.activated.connect(self.toggle_comment)

        if self.file_path and self.file_path.exists():
            self.load_file(self.file_path)
        else:
            self._apply_syntax_highlighting()

    def _configure_editor(self) -> None:
        """Sets up default QScintilla features and appearance."""
        # Font configuration
        font = QFont(self.font_family, self.font_size)
        self.setFont(font)

        # Encoding
        self.setUtf8(True)

        # Tabulation & Indentation
        tab_size = self.settings.get("tab_size", 4)
        use_spaces = self.settings.get("use_spaces", True)
        self.setTabWidth(tab_size)
        self.setIndentationsUseTabs(not use_spaces)
        self.setTabIndents(True)
        self.setAutoIndent(True)
        self.setBackspaceUnindents(True)

        # Word Wrap
        if self.settings.get("word_wrap", False):
            self.setWrapMode(QsciScintilla.WrapMode.WrapWord)
        else:
            self.setWrapMode(QsciScintilla.WrapMode.WrapNone)

        # Line Numbers Margin (Margin 0)
        if self.settings.get("show_line_numbers", True):
            self.setMarginType(0, QsciScintilla.MarginType.NumberMargin)
            self.setMarginWidth(0, "00000")
            self.setMarginLineNumbers(0, True)

        # Code Folding Margin (Margin 2)
        if self.settings.get("show_folding", True):
            self.setFolding(QsciScintilla.FoldStyle.BoxedTreeFoldStyle)
            self.setMarginWidth(2, 14)

        # Current Line Highlight
        if self.settings.get("highlight_current_line", True):
            self.setCaretLineVisible(True)
            self.setCaretLineBackgroundColor(QColor("#282828"))

        # Bracket Matching
        self.setBraceMatching(QsciScintilla.BraceMatch.SloppyBraceMatch)
        self.setMatchedBraceBackgroundColor(QColor("#3e3e42"))

        # Caret color
        self.setCaretForegroundColor(QColor("#aeafad"))
        self.setCaretWidth(2)

        # Colors / Margins background
        self.setMarginsBackgroundColor(QColor("#252526"))
        self.setMarginsForegroundColor(QColor("#858585"))

    def set_font_properties(self, family: str, size: int) -> None:
        """Updates editor font family and size."""
        self.font_family = family
        self.font_size = size
        font = QFont(self.font_family, self.font_size)
        self.setFont(font)
        self._apply_syntax_highlighting()

    def update_settings(self, settings: dict) -> None:
        """Applies updated user settings."""
        self.settings = settings
        self.font_family = settings.get("font_family", self.font_family)
        self.font_size = settings.get("font_size", self.font_size)
        self._configure_editor()
        self._apply_syntax_highlighting()
        self._update_auto_save_timer()

    def _apply_syntax_highlighting(self) -> None:
        """Applies syntax lexer based on current filename language."""
        if self.file_path:
            self.language = get_language_from_filename(self.file_path.name)
        is_dark = self.settings.get("theme", "dark") != "light"
        SyntaxHighlighterConfigurator.setup_lexer(self, self.language, is_dark=is_dark)

    def load_file(self, path: Path) -> bool:
        """Loads file contents from disk into editor."""
        content, enc = read_file_content(path)
        if content is not None:
            self.file_path = path
            self.file_encoding = enc
            self.setText(content)
            self.setModified(False)
            self.is_modified = False
            self._apply_syntax_highlighting()
            return True
        return False

    def save_file(self, path: Optional[Path] = None) -> bool:
        """Saves current editor contents to file."""
        target_path = path or self.file_path
        if not target_path:
            return False

        content = self.text()
        success = write_file_content(target_path, content, encoding=self.file_encoding)
        if success:
            self.file_path = target_path
            self.setModified(False)
            self.is_modified = False
            self.text_changed_signal.emit()
            return True
        return False

    def toggle_comment(self) -> None:
        """Toggles line comment on selected or current lines."""
        line_from, _, line_to, _ = self.getSelection()
        if line_from == -1:
            line_from = line_to = self.getCursorPosition()[0]

        comment_symbol = "#"
        if self.language in ("javascript", "cpp", "java", "css"):
            comment_symbol = "//"

        self.beginUndoAction()
        for line in range(line_from, line_to + 1):
            text = self.text(line)
            stripped = text.lstrip()
            if stripped.startswith(comment_symbol):
                idx = text.find(comment_symbol)
                self.setSelection(line, idx, line, idx + len(comment_symbol))
                self.removeSelectedText()
            else:
                self.insertAt(comment_symbol + " ", line, 0)
        self.endUndoAction()

    def _on_text_changed(self) -> None:
        """Internal text modified handler."""
        self.is_modified = True
        self.text_changed_signal.emit()

    def _on_cursor_position_changed(self, line: int, col: int) -> None:
        """Internal cursor position change signal emitter."""
        self.cursor_position_changed_signal.emit(line + 1, col + 1)

    def _update_auto_save_timer(self) -> None:
        """Restarts auto-save timer based on settings."""
        if self.settings.get("auto_save", False):
            delay_sec = self.settings.get("auto_save_delay", 5)
            self.auto_save_timer.start(delay_sec * 1000)
        else:
            self.auto_save_timer.stop()

    def _auto_save_trigger(self) -> None:
        """Triggered automatically after period of inactivity."""
        if self.is_modified and self.file_path:
            logger.info(f"Auto-saving file: {self.file_path}")
            self.save_file()
