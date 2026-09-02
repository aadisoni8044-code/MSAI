"""
MSAI Studio - Python Code Editor Component
"""
import re
from PyQt6.QtWidgets import (
    QWidget, QPlainTextEdit, QTextEdit, QHBoxLayout, QVBoxLayout, QLabel, QLineEdit,
    QPushButton, QFrame
)
from PyQt6.QtGui import (
    QSyntaxHighlighter, QTextCharFormat, QColor, QFont, QPen, QPainter, QTextCursor, QKeySequence, QShortcut
)
from PyQt6.QtCore import Qt, QRect, QSize, pyqtSignal
from resources.themes import DARK_THEME_COLORS

class PythonHighlighter(QSyntaxHighlighter):
    """Syntax highlighter for Python code."""

    def __init__(self, document, theme_colors=DARK_THEME_COLORS):
        super().__init__(document)
        self.colors = theme_colors
        self.highlighting_rules = []

        # Formats
        keyword_format = QTextCharFormat()
        keyword_format.setForeground(QColor(self.colors["keyword"]))
        keyword_format.setFontWeight(QFont.Weight.Bold)

        builtin_format = QTextCharFormat()
        builtin_format.setForeground(QColor(self.colors["builtin"]))

        string_format = QTextCharFormat()
        string_format.setForeground(QColor(self.colors["string"]))

        number_format = QTextCharFormat()
        number_format.setForeground(QColor(self.colors["number"]))

        comment_format = QTextCharFormat()
        comment_format.setForeground(QColor(self.colors["comment"]))
        comment_format.setFontItalic(True)

        func_format = QTextCharFormat()
        func_format.setForeground(QColor(self.colors["function"]))

        class_format = QTextCharFormat()
        class_format.setForeground(QColor(self.colors["class"]))
        class_format.setFontWeight(QFont.Weight.Bold)

        decorator_format = QTextCharFormat()
        decorator_format.setForeground(QColor(self.colors["decorator"]))

        # Keywords
        keywords = [
            "and", "as", "assert", "async", "await", "break", "class", "continue",
            "def", "del", "elif", "else", "except", "False", "finally", "for",
            "from", "global", "if", "import", "in", "is", "lambda", "None",
            "nonlocal", "not", "or", "pass", "raise", "return", "True", "try",
            "while", "with", "yield"
        ]
        for kw in keywords:
            pattern = rf"\b{kw}\b"
            self.highlighting_rules.append((re.compile(pattern), keyword_format))

        # Builtins
        builtins = [
            "abs", "all", "any", "bin", "bool", "bytes", "callable", "chr",
            "classmethod", "dict", "dir", "divmod", "enumerate", "eval", "exec",
            "filter", "float", "format", "frozenset", "getattr", "hasattr", "hash",
            "help", "hex", "id", "input", "int", "isinstance", "issubclass", "iter",
            "len", "list", "map", "max", "min", "next", "object", "oct", "open",
            "ord", "pow", "print", "property", "range", "repr", "reversed", "round",
            "set", "setattr", "slice", "sorted", "staticmethod", "str", "sum",
            "super", "tuple", "type", "zip", "self", "cls"
        ]
        for bi in builtins:
            pattern = rf"\b{bi}\b"
            self.highlighting_rules.append((re.compile(pattern), builtin_format))

        # Numbers
        self.highlighting_rules.append((re.compile(r"\b\d+(\.\d+)?\b"), number_format))

        # Functions def
        self.highlighting_rules.append((re.compile(r"\bdef\s+([A-Za-z_][A-Za-z0-9_]*)"), func_format))

        # Class def
        self.highlighting_rules.append((re.compile(r"\bclass\s+([A-Za-z_][A-Za-z0-9_]*)"), class_format))

        # Decorators
        self.highlighting_rules.append((re.compile(r"@[A-Za-z_][A-Za-z0-9_]*"), decorator_format))

        # Double and single quoted strings
        self.highlighting_rules.append((re.compile(r'"[^"\\]*(\\.[^"\\]*)*"'), string_format))
        self.highlighting_rules.append((re.compile(r"'[^'\\]*(\\.[^'\\]*)*'"), string_format))

        # Single-line comments
        self.highlighting_rules.append((re.compile(r"#.*"), comment_format))

    def highlightBlock(self, text):
        for pattern, fmt in self.highlighting_rules:
            for match in pattern.finditer(text):
                start, end = match.span()
                self.highlightBlockRange(text, start, end - start, fmt)

    def highlightBlockRange(self, text, start, length, fmt):
        self.setFormat(start, length, fmt)


class LineNumberArea(QWidget):
    def __init__(self, editor):
        super().__init__(editor)
        self.editor = editor

    def sizeHint(self):
        return QSize(self.editor.line_number_area_width(), 0)

    def paintEvent(self, event):
        self.editor.line_number_area_paint_event(event)


class CodeEditor(QPlainTextEdit):
    """
    Python Code Editor with line numbers, syntax highlighting, bracket matching,
    auto-closing, current line highlight, and search panel.
    """
    cursor_position_changed = pyqtSignal(int, int) # line, col
    file_modified = pyqtSignal(bool)

    def __init__(self, parent=None):
        super().__init__(parent)
        self.file_path = None
        self.line_number_area = LineNumberArea(self)

        self.blockCountChanged.connect(self.update_line_number_area_width)
        self.updateRequest.connect(self.update_line_number_area)
        self.cursorPositionChanged.connect(self.highlight_current_line)
        self.cursorPositionChanged.connect(self._emit_cursor_pos)
        self.textChanged.connect(lambda: self.file_modified.emit(True))

        self.update_line_number_area_width(0)
        self.highlight_current_line()

        # Syntax Highlighter
        self.highlighter = PythonHighlighter(self.document())

        # Editor appearance
        font = QFont("Consolas", 13)
        font.setStyleHint(QFont.StyleHint.Monospace)
        self.setFont(font)
        self.setTabStopDistance(self.fontMetrics().horizontalAdvance(' ') * 4)

        # Search Bar Overlay Widget
        self.search_panel = QFrame(self)
        self.search_panel.setStyleSheet("background-color: #1e1e2e; border: 1px solid #313244; border-radius: 4px;")
        sp_layout = QHBoxLayout(self.search_panel)
        sp_layout.setContentsMargins(4, 4, 4, 4)

        self.search_input = QLineEdit()
        self.search_input.setPlaceholderText("Find...")
        self.search_input.textChanged.connect(self._find_next)

        self.replace_input = QLineEdit()
        self.replace_input.setPlaceholderText("Replace...")

        self.btn_find_next = QPushButton("↓")
        self.btn_replace = QPushButton("Replace")
        self.btn_close_search = QPushButton("✕")

        self.btn_find_next.clicked.connect(self._find_next)
        self.btn_replace.clicked.connect(self._replace_one)
        self.btn_close_search.clicked.connect(self.search_panel.hide)

        sp_layout.addWidget(self.search_input)
        sp_layout.addWidget(self.replace_input)
        sp_layout.addWidget(self.btn_find_next)
        sp_layout.addWidget(self.btn_replace)
        sp_layout.addWidget(self.btn_close_search)
        self.search_panel.hide()

        # Keyboard shortcuts inside editor
        QShortcut(QKeySequence("Ctrl+F"), self, self.show_search_panel)

    def show_search_panel(self):
        self.search_panel.show()
        self.search_panel.resize(450, 40)
        self.search_panel.move(self.width() - 470, 10)
        self.search_input.setFocus()

    def _find_next(self):
        text = self.search_input.text()
        if text:
            self.find(text)

    def _replace_one(self):
        target = self.search_input.text()
        replacement = self.replace_input.text()
        if target:
            cursor = self.textCursor()
            if cursor.hasSelection() and cursor.selectedText() == target:
                cursor.insertText(replacement)
            self._find_next()

    def line_number_area_width(self):
        digits = 1
        max_val = max(1, self.blockCount())
        while max_val >= 10:
            max_val //= 10
            digits += 1
        space = 20 + self.fontMetrics().horizontalAdvance('9') * digits
        return space

    def update_line_number_area_width(self, _):
        self.setViewportMargins(self.line_number_area_width(), 0, 0, 0)

    def update_line_number_area(self, rect, dy):
        if dy:
            self.line_number_area.scroll(0, dy)
        else:
            self.line_number_area.update(0, rect.y(), self.line_number_area.width(), rect.height())

        if rect.contains(self.viewport().rect()):
            self.update_line_number_area_width(0)

    def resizeEvent(self, event):
        super().resizeEvent(event)
        cr = self.contentsRect()
        self.line_number_area.setGeometry(QRect(cr.left(), cr.top(), self.line_number_area_width(), cr.height()))
        if self.search_panel.isVisible():
            self.search_panel.move(self.width() - 470, 10)

    def line_number_area_paint_event(self, event):
        painter = QPainter(self.line_number_area)
        painter.fillRect(event.rect(), QColor(DARK_THEME_COLORS["bg_sidebar"]))

        block = self.firstVisibleBlock()
        block_number = block.blockNumber()
        top = int(self.blockBoundingGeometry(block).translated(self.contentOffset()).top())
        bottom = top + int(self.blockBoundingRect(block).height())

        while block.isValid() and top <= event.rect().bottom():
            if block.isVisible() and bottom >= event.rect().top():
                number = str(block_number + 1)
                is_current = block_number == self.textCursor().blockNumber()
                painter.setPen(QColor(DARK_THEME_COLORS["fg_main"]) if is_current else QColor(DARK_THEME_COLORS["line_number"]))
                painter.setFont(self.font())
                painter.drawText(
                    0, top, self.line_number_area.width() - 8, self.fontMetrics().height(),
                    Qt.AlignmentFlag.AlignRight, number
                )

            block = block.next()
            top = bottom
            bottom = top + int(self.blockBoundingRect(block).height())
            block_number += 1

    def highlight_current_line(self):
        extra_selections = []
        if not self.isReadOnly():
            selection = QTextEdit.ExtraSelection()
            line_color = QColor(DARK_THEME_COLORS["current_line"])
            selection.format.setBackground(line_color)
            selection.format.setProperty(QTextCharFormat.Property.FullWidthSelection, True)
            selection.cursor = self.textCursor()
            selection.cursor.clearSelection()
            extra_selections.append(selection)
        self.setExtraSelections(extra_selections)

    def keyPressEvent(self, event):
        # Auto closing brackets
        bracket_pairs = {'(': ')', '[': ']', '{': '}', '"': '"', "'": "'"}
        char = event.text()

        if char in bracket_pairs:
            cursor = self.textCursor()
            cursor.insertText(char + bracket_pairs[char])
            cursor.movePosition(QTextCursor.MoveOperation.Left)
            self.setTextCursor(cursor)
            return

        super().keyPressEvent(event)

    def _emit_cursor_pos(self):
        cursor = self.textCursor()
        line = cursor.blockNumber() + 1
        col = cursor.columnNumber() + 1
        self.cursor_position_changed.emit(line, col)
