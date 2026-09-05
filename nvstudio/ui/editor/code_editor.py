"""NV Studio Code Editor Component with Line Numbers, Auto-Closing Brackets, and Search Bar"""
import os
from typing import Optional, List, Tuple
from PyQt6.QtCore import QRect, QSize, Qt, pyqtSignal, QRegularExpression
from PyQt6.QtGui import (
    QColor, QFont, QFontMetrics, QIcon, QPainter, QTextCharFormat, QTextCursor,
    QTextDocument, QTextOption, QKeySequence, QAction, QShortcut
)
from PyQt6.QtWidgets import (
    QApplication, QFrame, QHBoxLayout, QLabel, QLineEdit, QPlainTextEdit,
    QPushButton, QTextEdit, QVBoxLayout, QWidget, QMenu
)

from nvstudio.core.config import config_manager
from nvstudio.core.highlighter import PygmentsHighlighter


class LineNumberArea(QWidget):
    """Line number margin widget rendered next to QPlainTextEdit."""

    def __init__(self, editor: 'CodeEditor'):
        super().__init__(editor)
        self.code_editor = editor

    def sizeHint(self) -> QSize:
        return QSize(self.code_editor.line_number_area_width(), 0)

    def paintEvent(self, event) -> None:
        self.code_editor.line_number_area_paint_event(event)


class SearchReplaceBar(QFrame):
    """In-editor search & replace toolbar overlay."""
    find_next_requested = pyqtSignal(str, bool, bool)  # (query, match_case, regex)
    find_prev_requested = pyqtSignal(str, bool, bool)
    replace_requested = pyqtSignal(str, str, bool, bool)
    replace_all_requested = pyqtSignal(str, str, bool, bool)
    closed = pyqtSignal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self.setObjectName("SearchReplaceBar")
        self.setStyleSheet("""
            #SearchReplaceBar {
                background-color: #10141d;
                border: 1px solid #283447;
                border-radius: 6px;
                padding: 4px;
            }
            QLineEdit {
                background-color: #161c28;
                color: #f1f5f9;
                border: 1px solid #2a364d;
                border-radius: 4px;
                padding: 4px 8px;
                font-size: 12px;
            }
            QLineEdit:focus {
                border: 1px solid #4f80ff;
            }
            QPushButton {
                background-color: #1a2233;
                color: #94a3b8;
                border: 1px solid #2a364d;
                border-radius: 4px;
                padding: 4px 8px;
                font-size: 11px;
            }
            QPushButton:hover {
                background-color: #25334d;
                color: #f8fafc;
            }
            QPushButton:checked {
                background-color: #3b82f6;
                color: #ffffff;
                border-color: #60a5fa;
            }
        """)

        layout = QVBoxLayout(self)
        layout.setContentsMargins(6, 6, 6, 6)
        layout.setSpacing(4)

        # Search Row
        search_row = QHBoxLayout()
        search_row.setSpacing(4)

        self.search_input = QLineEdit()
        self.search_input.setPlaceholderText("Find")
        self.search_input.returnPressed.connect(self._on_find_next)

        self.case_btn = QPushButton("Aa")
        self.case_btn.setCheckable(True)
        self.case_btn.setToolTip("Match Case")

        self.regex_btn = QPushButton(".*")
        self.regex_btn.setCheckable(True)
        self.regex_btn.setToolTip("Use Regular Expression")

        self.prev_btn = QPushButton("▲")
        self.prev_btn.setToolTip("Previous Match")
        self.prev_btn.clicked.connect(self._on_find_prev)

        self.next_btn = QPushButton("▼")
        self.next_btn.setToolTip("Next Match")
        self.next_btn.clicked.connect(self._on_find_next)

        self.close_btn = QPushButton("✕")
        self.close_btn.setToolTip("Close (Esc)")
        self.close_btn.clicked.connect(self.hide_bar)

        search_row.addWidget(self.search_input)
        search_row.addWidget(self.case_btn)
        search_row.addWidget(self.regex_btn)
        search_row.addWidget(self.prev_btn)
        search_row.addWidget(self.next_btn)
        search_row.addWidget(self.close_btn)

        # Replace Row
        replace_row = QHBoxLayout()
        replace_row.setSpacing(4)

        self.replace_input = QLineEdit()
        self.replace_input.setPlaceholderText("Replace")

        self.replace_btn = QPushButton("Replace")
        self.replace_btn.clicked.connect(self._on_replace)

        self.replace_all_btn = QPushButton("Replace All")
        self.replace_all_btn.clicked.connect(self._on_replace_all)

        replace_row.addWidget(self.replace_input)
        replace_row.addWidget(self.replace_btn)
        replace_row.addWidget(self.replace_all_btn)

        layout.addLayout(search_row)
        layout.addLayout(replace_row)

        self.hide()

    def show_bar(self, select_text: str = "") -> None:
        self.show()
        if select_text:
            self.search_input.setText(select_text)
        self.search_input.setFocus()
        self.search_input.selectAll()

    def hide_bar(self) -> None:
        self.hide()
        self.closed.emit()

    def _on_find_next(self) -> None:
        text = self.search_input.text()
        if text:
            self.find_next_requested.emit(text, self.case_btn.isChecked(), self.regex_btn.isChecked())

    def _on_find_prev(self) -> None:
        text = self.search_input.text()
        if text:
            self.find_prev_requested.emit(text, self.case_btn.isChecked(), self.regex_btn.isChecked())

    def _on_replace(self) -> None:
        query = self.search_input.text()
        repl = self.replace_input.text()
        if query:
            self.replace_requested.emit(query, repl, self.case_btn.isChecked(), self.regex_btn.isChecked())

    def _on_replace_all(self) -> None:
        query = self.search_input.text()
        repl = self.replace_input.text()
        if query:
            self.replace_all_requested.emit(query, repl, self.case_btn.isChecked(), self.regex_btn.isChecked())


class CodeEditor(QPlainTextEdit):
    """Full-featured QPlainTextEdit IDE editor component."""
    cursor_position_changed = pyqtSignal(int, int)  # (line, column)
    file_saved = pyqtSignal()

    AUTO_CLOSE_PAIRS = {
        '(': ')',
        '[': ']',
        '{': '}',
        '"': '"',
        "'": "'",
    }

    def __init__(self, filepath: Optional[str] = None, parent=None):
        super().__init__(parent)
        self.setObjectName("CodeEditor")
        self.filepath = filepath

        self.line_number_area = LineNumberArea(self)
        self.highlighter = PygmentsHighlighter(self.document(), filepath or "script.py")

        self.search_bar = SearchReplaceBar(self)
        self.search_bar.find_next_requested.connect(self.find_next)
        self.search_bar.find_prev_requested.connect(self.find_prev)
        self.search_bar.replace_requested.connect(self.replace_text)
        self.search_bar.replace_all_requested.connect(self.replace_all_text)

        self.blockCountChanged.connect(self.update_line_number_area_width)
        self.updateRequest.connect(self.update_line_number_area)
        self.cursorPositionChanged.connect(self.highlight_current_line)
        self.cursorPositionChanged.connect(self._emit_cursor_pos)

        self.apply_editor_settings()

    def apply_editor_settings(self) -> None:
        """Apply font, word wrap, tab size, and display configurations."""
        font_family = config_manager.get("editor.font_family", "Consolas, 'Courier New', monospace")
        font_size = config_manager.get("editor.font_size", 13)
        font = QFont()
        font.setFamilies([font_family.split(",")[0].strip("'\" ")])
        font.setPointSize(font_size)
        font.setStyleHint(QFont.StyleHint.Monospace)
        self.setFont(font)

        tab_size = config_manager.get("editor.tab_size", 4)
        metrics = QFontMetrics(font)
        self.setTabStopDistance(tab_size * metrics.horizontalAdvance(' '))

        word_wrap = config_manager.get("editor.word_wrap", True)
        self.setLineWrapMode(QPlainTextEdit.LineWrapMode.WidgetWidth if word_wrap else QPlainTextEdit.LineWrapMode.NoWrap)

        self.update_line_number_area_width(0)
        self.highlight_current_line()

    def set_filepath(self, filepath: str) -> None:
        self.filepath = filepath
        self.highlighter.set_filepath(filepath)

    def line_number_area_width(self) -> int:
        digits = max(1, len(str(self.blockCount())))
        space = 14 + self.fontMetrics().horizontalAdvance('9') * digits
        return space

    def update_line_number_area_width(self, new_block_count: int) -> None:
        self.setViewportMargins(self.line_number_area_width(), 0, 0, 0)

    def update_line_number_area(self, rect: QRect, dy: int) -> None:
        if dy:
            self.line_number_area.scroll(0, dy)
        else:
            self.line_number_area.update(0, rect.y(), self.line_number_area.width(), rect.height())

        if rect.contains(self.viewport().rect()):
            self.update_line_number_area_width(0)

    def resizeEvent(self, event) -> None:
        super().resizeEvent(event)
        cr = self.contentsRect()
        self.line_number_area.setGeometry(
            QRect(cr.left(), cr.top(), self.line_number_area_width(), cr.height())
        )
        if self.search_bar.isVisible():
            sb_w = min(420, cr.width() - 40)
            self.search_bar.setGeometry(cr.right() - sb_w - 20, cr.top() + 10, sb_w, 75)

    def line_number_area_paint_event(self, event) -> None:
        painter = QPainter(self.line_number_area)
        painter.fillRect(event.rect(), QColor("#10141d"))

        block = self.firstVisibleBlock()
        block_number = block.blockNumber()
        top = round(self.blockBoundingGeometry(block).translated(self.contentOffset()).top())
        bottom = top + round(self.blockBoundingRect(block).height())

        current_block_num = self.textCursor().blockNumber()

        while block.isValid() and top <= event.rect().bottom():
            if block.isVisible() and bottom >= event.rect().top():
                number = str(block_number + 1)
                if block_number == current_block_num:
                    painter.setPen(QColor("#4f80ff"))
                    painter.setFont(QFont(self.font().family(), self.font().pointSize(), QFont.Weight.Bold))
                else:
                    painter.setPen(QColor("#475569"))
                    painter.setFont(self.font())

                painter.drawText(
                    0, top, self.line_number_area.width() - 8, self.fontMetrics().height(),
                    Qt.AlignmentFlag.AlignRight, number
                )

            block = block.next()
            top = bottom
            bottom = top + round(self.blockBoundingRect(block).height())
            block_number += 1

    def highlight_current_line(self) -> None:
        extra_selections = []

        if not self.isReadOnly() and config_manager.get("editor.highlight_active_line", True):
            selection = QTextEdit.ExtraSelection()
            line_color = QColor("#161d2b")
            selection.format.setBackground(line_color)
            selection.format.setProperty(QTextCharFormat.Property.FullWidthSelection, True)
            selection.cursor = self.textCursor()
            selection.cursor.clearSelection()
            extra_selections.append(selection)

        self.setExtraSelections(extra_selections)

    def _emit_cursor_pos(self) -> None:
        cursor = self.textCursor()
        line = cursor.blockNumber() + 1
        col = cursor.positionInBlock() + 1
        self.cursor_position_changed.emit(line, col)

    def keyPressEvent(self, event) -> None:
        """Handle key combinations for auto-closing brackets, smart indentation, and shortcuts."""
        key = event.key()
        text = event.text()

        # Handle Tab key (Insert spaces)
        if key == Qt.Key.Key_Tab and not event.modifiers():
            tab_size = config_manager.get("editor.tab_size", 4)
            self.insertPlainText(" " * tab_size)
            return

        # Auto-closing brackets & quotes
        if config_manager.get("editor.auto_close_brackets", True) and text in self.AUTO_CLOSE_PAIRS:
            closing_char = self.AUTO_CLOSE_PAIRS[text]
            cursor = self.textCursor()
            if cursor.hasSelection():
                sel_text = cursor.selectedText()
                cursor.insertText(f"{text}{sel_text}{closing_char}")
            else:
                cursor.insertText(f"{text}{closing_char}")
                cursor.movePosition(QTextCursor.MoveOperation.Left)
                self.setTextCursor(cursor)
            return

        # Auto-indentation on Enter key
        if key in (Qt.Key.Key_Return, Qt.Key.Key_Enter):
            cursor = self.textCursor()
            line_text = cursor.block().text()
            indent = ""
            for char in line_text:
                if char in (" ", "\t"):
                    indent += char
                else:
                    break
            if line_text.rstrip().endswith((":", "{", "[", "(")):
                tab_size = config_manager.get("editor.tab_size", 4)
                indent += " " * tab_size

            super().keyPressEvent(event)
            self.insertPlainText(indent)
            return

        super().keyPressEvent(event)

    def zoom_in(self) -> None:
        font = self.font()
        font.setPointSize(font.pointSize() + 1)
        self.setFont(font)
        self.update_line_number_area_width(0)

    def zoom_out(self) -> None:
        font = self.font()
        if font.pointSize() > 6:
            font.setPointSize(font.pointSize() - 1)
            self.setFont(font)
            self.update_line_number_area_width(0)

    def show_search_bar(self) -> None:
        selected = self.textCursor().selectedText()
        cr = self.contentsRect()
        sb_w = min(420, cr.width() - 40)
        self.search_bar.setGeometry(cr.right() - sb_w - 20, cr.top() + 10, sb_w, 75)
        self.search_bar.show_bar(selected)

    def find_next(self, query: str, match_case: bool = False, is_regex: bool = False) -> bool:
        flags = QTextDocument.FindFlag(0)
        if match_case:
            flags |= QTextDocument.FindFlag.FindCaseSensitively

        if is_regex:
            rx = QRegularExpression(query)
            if not match_case:
                rx.setPatternOptions(QRegularExpression.PatternOption.CaseInsensitiveOption)
            found_cursor = self.document().find(rx, self.textCursor(), flags)
        else:
            found_cursor = self.document().find(query, self.textCursor(), flags)

        if not found_cursor.isNull():
            self.setTextCursor(found_cursor)
            return True
        else:
            # Wrap around search from start
            if is_regex:
                found_cursor = self.document().find(rx, 0, flags)
            else:
                found_cursor = self.document().find(query, 0, flags)
            if not found_cursor.isNull():
                self.setTextCursor(found_cursor)
                return True
        return False

    def find_prev(self, query: str, match_case: bool = False, is_regex: bool = False) -> bool:
        flags = QTextDocument.FindFlag.FindBackward
        if match_case:
            flags |= QTextDocument.FindFlag.FindCaseSensitively

        if is_regex:
            rx = QRegularExpression(query)
            if not match_case:
                rx.setPatternOptions(QRegularExpression.PatternOption.CaseInsensitiveOption)
            found_cursor = self.document().find(rx, self.textCursor(), flags)
        else:
            found_cursor = self.document().find(query, self.textCursor(), flags)

        if not found_cursor.isNull():
            self.setTextCursor(found_cursor)
            return True
        return False

    def replace_text(self, query: str, replace_with: str, match_case: bool = False, is_regex: bool = False) -> None:
        cursor = self.textCursor()
        if cursor.hasSelection():
            cursor.insertText(replace_with)
        self.find_next(query, match_case, is_regex)

    def replace_all_text(self, query: str, replace_with: str, match_case: bool = False, is_regex: bool = False) -> int:
        if not query:
            return 0

        flags = QTextDocument.FindFlag(0)
        if match_case:
            flags |= QTextDocument.FindFlag.FindCaseSensitively

        doc = self.document()
        cursor = QTextCursor(doc)
        cursor.movePosition(QTextCursor.MoveOperation.Start)

        count = 0
        self.textCursor().beginEditBlock()

        if is_regex:
            rx = QRegularExpression(query)
            if not match_case:
                rx.setPatternOptions(QRegularExpression.PatternOption.CaseInsensitiveOption)
            while True:
                found = doc.find(rx, cursor, flags)
                if found.isNull():
                    break
                found.insertText(replace_with)
                cursor = found
                count += 1
        else:
            while True:
                found = doc.find(query, cursor, flags)
                if found.isNull():
                    break
                found.insertText(replace_with)
                cursor = found
                count += 1

        self.textCursor().endEditBlock()
        return count
