import re
from PyQt6.QtWidgets import (
    QPlainTextEdit, QTextEdit, QWidget, QListWidget, QListWidgetItem, QCompleter,
    QVBoxLayout, QHBoxLayout, QTabWidget, QLabel, QStackedWidget, QMessageBox,
    QTabBar
)
from PyQt6.QtCore import Qt, QRect, QSize, pyqtSignal, QStringListModel
from PyQt6.QtGui import (
    QColor, QPainter, QTextFormat, QFont, QSyntaxHighlighter, QTextCharFormat,
    QTextCursor, QKeySequence, QShortcut
)

from pygments.lexers import HtmlLexer, CssLexer, JavascriptLexer, get_lexer_for_filename
from pygments.token import Keyword, Name, Comment, String, Error, Number, Operator, Generic, Token


AUTOCOMPLETE_DICT = {
    "html": [
        "a", "abbr", "address", "article", "aside", "audio", "b", "body", "br",
        "button", "canvas", "code", "div", "em", "footer", "form", "h1", "h2", "h3",
        "h4", "h5", "h6", "head", "header", "hr", "html", "iframe", "img", "input",
        "label", "li", "link", "main", "meta", "nav", "option", "p", "script",
        "section", "select", "span", "strong", "style", "table", "td", "th", "tr",
        "ul", "video", "class=", "id=", "src=", "href=", "style=", "type=", "placeholder=",
        "value=", "alt=", "width=", "height=", "rel=", "target="
    ],
    "css": [
        "align-items", "background", "background-color", "border", "border-radius",
        "box-shadow", "color", "cursor", "display", "flex", "flex-direction",
        "font-family", "font-size", "font-weight", "grid", "height", "justify-content",
        "line-height", "margin", "max-width", "min-height", "opacity", "padding",
        "position", "text-align", "text-decoration", "transition", "width", "z-index",
        "center", "absolute", "relative", "fixed", "none", "block", "inline-block", "solid"
    ],
    "js": [
        "addEventListener", "appendChild", "async", "await", "break", "case", "catch",
        "class", "const", "console.log", "document", "DOMContentLoaded", "else", "export",
        "fetch", "for", "function", "getElementById", "getElementsByClassName",
        "querySelector", "querySelectorAll", "if", "import", "innerHTML", "let", "new",
        "return", "setAttribute", "style", "textContent", "this", "try", "typeof", "var", "window"
    ]
}


class PygmentsHighlighter(QSyntaxHighlighter):
    """Syntax highlighter using Pygments tokenization."""

    def __init__(self, document, file_extension=".html"):
        super().__init__(document)
        self.set_lexer_by_ext(file_extension)

    def set_lexer_by_ext(self, ext):
        ext = ext.lower()
        if ext in ['.html', '.htm']:
            self.lexer = HtmlLexer()
        elif ext in ['.css']:
            self.lexer = CssLexer()
        elif ext in ['.js']:
            self.lexer = JavascriptLexer()
        else:
            try:
                self.lexer = get_lexer_for_filename(f"file{ext}")
            except Exception:
                self.lexer = HtmlLexer()

    def highlightBlock(self, text):
        if not text or not hasattr(self, 'lexer'):
            return

        # Tokenize block
        tokens = self.lexer.get_tokens(text)
        index = 0

        for token_type, value in tokens:
            length = len(value)
            fmt = self._get_format(token_type)
            if fmt:
                self.setFormat(index, length, fmt)
            index += length

    def _get_format(self, token_type):
        fmt = QTextCharFormat()

        if token_type in Keyword:
            fmt.setForeground(QColor("#c678dd" if True else "#a626a4"))
            fmt.setFontWeight(QFont.Weight.Bold)
        elif token_type in Name.Tag:
            fmt.setForeground(QColor("#e06c75"))
            fmt.setFontWeight(QFont.Weight.Bold)
        elif token_type in Name.Attribute:
            fmt.setForeground(QColor("#d19a66"))
        elif token_type in String:
            fmt.setForeground(QColor("#98c379"))
        elif token_type in Number:
            fmt.setForeground(QColor("#d19a66"))
        elif token_type in Comment:
            fmt.setForeground(QColor("#7f848e"))
            fmt.setFontItalic(True)
        elif token_type in Operator:
            fmt.setForeground(QColor("#56b6c2"))
        elif token_type in Error:
            fmt.setUnderlineStyle(QTextCharFormat.UnderlineStyle.SpellCheckUnderline)
            fmt.setForeground(QColor("#f43f5e"))
        else:
            return None

        return fmt


class LineNumberArea(QWidget):
    def __init__(self, editor):
        super().__init__(editor)
        self.editor = editor

    def sizeHint(self):
        return QSize(self.editor.line_number_area_width(), 0)

    def paintEvent(self, event):
        self.editor.lineNumberAreaPaintEvent(event)


class CodeEditor(QPlainTextEdit):
    """Rich Code Editor widget with line numbers, syntax highlighting, and autocomplete."""

    text_changed_auto = pyqtSignal()

    def __init__(self, filepath="", parent=None):
        super().__init__(parent)
        self.filepath = filepath
        self.is_modified = False

        # Font setup
        font = QFont("Consolas", 12)
        font.setStyleHint(QFont.StyleHint.Monospace)
        self.setFont(font)
        self.setTabStopDistance(self.fontMetrics().horizontalAdvance(' ') * 4)

        # Line Number Area
        self.line_number_area = LineNumberArea(self)
        self.blockCountChanged.connect(self.update_line_number_area_width)
        self.updateRequest.connect(self.update_line_number_area)
        self.cursorPositionChanged.connect(self.highlight_current_line)
        self.update_line_number_area_width(0)

        # Syntax Highlighter
        ext = "." + filepath.split(".")[-1] if "." in filepath else ".html"
        self.highlighter = PygmentsHighlighter(self.document(), ext)

        # Autocomplete setup
        self.completer = QCompleter(self)
        self.completer.setWidget(self)
        self.completer.setCompletionMode(QCompleter.CompletionMode.PopupCompletion)
        self.completer.setCaseSensitivity(Qt.CaseSensitivity.CaseInsensitive)
        self.completer.activated.connect(self.insert_completion)

        self.update_completer_words(ext)

        self.textChanged.connect(self._on_text_changed)

    def update_completer_words(self, ext):
        lang = "html"
        if ext in [".css"]:
            lang = "css"
        elif ext in [".js"]:
            lang = "js"

        words = AUTOCOMPLETE_DICT.get(lang, AUTOCOMPLETE_DICT["html"])
        model = QStringListModel(words, self.completer)
        self.completer.setModel(model)

    def line_number_area_width(self):
        digits = 1
        max_val = max(1, self.blockCount())
        while max_val >= 10:
            max_val //= 10
            digits += 1
        space = 15 + self.fontMetrics().horizontalAdvance('9') * digits
        return space

    def update_line_number_area_width(self, new_block_count):
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
        self.line_number_area.setGeometry(
            QRect(cr.left(), cr.top(), self.line_number_area_width(), cr.height())
        )

    def lineNumberAreaPaintEvent(self, event):
        painter = QPainter(self.line_number_area)
        painter.fillRect(event.rect(), QColor("#161d2b"))

        block = self.firstVisibleBlock()
        block_number = block.blockNumber()
        top = round(self.blockBoundingGeometry(block).translated(self.contentOffset()).top())
        bottom = top + round(self.blockBoundingRect(block).height())

        while block.isValid() and top <= event.rect().bottom():
            if block.isVisible() and bottom >= event.rect().top():
                number = str(block_number + 1)
                is_current = (block_number == self.textCursor().blockNumber())
                painter.setPen(QColor("#38bdf8") if is_current else QColor("#64748b"))
                painter.drawText(
                    0, top, self.line_number_area.width() - 8, self.fontMetrics().height(),
                    Qt.AlignmentFlag.AlignRight, number
                )

            block = block.next()
            block_number += 1
            top = bottom
            bottom = top + round(self.blockBoundingRect(block).height())

    def highlight_current_line(self):
        extra_selections = []
        if not self.isReadOnly():
            selection = QTextEdit.ExtraSelection()
            line_color = QColor("#1e293b")
            selection.format.setBackground(line_color)
            selection.format.setProperty(QTextFormat.Property.FullWidthSelection, True)
            selection.cursor = self.textCursor()
            selection.cursor.clearSelection()
            extra_selections.append(selection)

        self.setExtraSelections(extra_selections)

    def keyPressEvent(self, event):
        if self.completer and self.completer.popup().isVisible():
            if event.key() in (Qt.Key.Key_Enter, Qt.Key.Key_Return, Qt.Key.Key_Escape, Qt.Key.Key_Tab, Qt.Key.Key_Backtab):
                event.ignore()
                return

        is_shortcut = (event.modifiers() & Qt.KeyboardModifier.ControlModifier) and event.key() == Qt.Key.Key_Space
        super().keyPressEvent(event)

        completion_prefix = self.text_under_cursor()

        if not is_shortcut and (len(completion_prefix) < 2 or event.text().endswith(" ")):
            self.completer.popup().hide()
            return

        if completion_prefix != self.completer.completionPrefix():
            self.completer.setCompletionPrefix(completion_prefix)
            self.completer.popup().setCurrentIndex(self.completer.completionModel().index(0, 0))

        cr = self.cursorRect()
        cr.setWidth(
            self.completer.popup().sizeHintForColumn(0)
            + self.completer.popup().verticalScrollBar().sizeHint().width()
        )
        self.completer.complete(cr)

    def text_under_cursor(self):
        tc = self.textCursor()
        tc.select(QTextCursor.SelectionType.WordUnderCursor)
        return tc.selectedText()

    def insert_completion(self, completion):
        tc = self.textCursor()
        extra = len(completion) - len(self.completer.completionPrefix())
        tc.movePosition(QTextCursor.MoveOperation.Left)
        tc.movePosition(QTextCursor.MoveOperation.EndOfWord)
        tc.insertText(completion[len(self.completer.completionPrefix()):])
        self.setTextCursor(tc)

    def _on_text_changed(self):
        self.is_modified = True
        self.text_changed_auto.emit()


class TabbedEditorWorkspace(QWidget):
    """Tabbed workspace managing open file editors."""

    file_saved = pyqtSignal(str)
    file_modified = pyqtSignal(str, bool)

    def __init__(self, parent=None):
        super().__init__(parent)
        layout = QVBoxLayout(self)
        layout.setContentsMargins(0, 0, 0, 0)
        layout.setSpacing(0)

        self.tab_widget = QTabWidget()
        self.tab_widget.setTabsClosable(True)
        self.tab_widget.setMovable(True)
        self.tab_widget.tabCloseRequested.connect(self.close_tab)

        layout.addWidget(self.tab_widget)
        self.open_editors = {}  # filepath -> CodeEditor

    def open_file(self, filepath):
        filepath = str(filepath)
        if filepath in self.open_editors:
            editor = self.open_editors[filepath]
            index = self.tab_widget.indexOf(editor)
            self.tab_widget.setCurrentIndex(index)
            return editor

        editor = CodeEditor(filepath=filepath)
        try:
            with open(filepath, "r", encoding="utf-8") as f:
                editor.setPlainText(f.read())
            editor.is_modified = False
        except Exception as e:
            QMessageBox.warning(self, "Error Reading File", f"Could not read {filepath}: {e}")

        file_name = filepath.split("/")[-1].split("\\")[-1]
        index = self.tab_widget.addTab(editor, file_name)
        self.tab_widget.setCurrentIndex(index)
        self.open_editors[filepath] = editor

        editor.text_changed_auto.connect(lambda: self._on_editor_modified(filepath))
        return editor

    def save_file(self, filepath=None):
        if not filepath:
            current_editor = self.current_editor()
            if not current_editor:
                return False
            filepath = current_editor.filepath

        if filepath in self.open_editors:
            editor = self.open_editors[filepath]
            try:
                with open(filepath, "w", encoding="utf-8") as f:
                    f.write(editor.toPlainText())
                editor.is_modified = False
                self._update_tab_title(filepath)
                self.file_saved.emit(filepath)
                return True
            except Exception as e:
                QMessageBox.critical(self, "Save Error", f"Failed to save {filepath}: {e}")
                return False
        return False

    def save_all(self):
        for fp in list(self.open_editors.keys()):
            self.save_file(fp)

    def current_editor(self):
        current_widget = self.tab_widget.currentWidget()
        if isinstance(current_widget, CodeEditor):
            return current_widget
        return None

    def close_tab(self, index):
        widget = self.tab_widget.widget(index)
        if isinstance(widget, CodeEditor):
            filepath = widget.filepath
            if widget.is_modified:
                reply = QMessageBox.question(
                    self, "Unsaved Changes",
                    f"File '{filepath.split('/')[-1]}' has unsaved changes. Save now?",
                    QMessageBox.StandardButton.Save | QMessageBox.StandardButton.Discard | QMessageBox.StandardButton.Cancel
                )
                if reply == QMessageBox.StandardButton.Save:
                    self.save_file(filepath)
                elif reply == QMessageBox.StandardButton.Cancel:
                    return

            self.tab_widget.removeTab(index)
            if filepath in self.open_editors:
                del self.open_editors[filepath]

    def _on_editor_modified(self, filepath):
        self._update_tab_title(filepath)
        if filepath in self.open_editors:
            self.file_modified.emit(filepath, self.open_editors[filepath].is_modified)

    def _update_tab_title(self, filepath):
        if filepath in self.open_editors:
            editor = self.open_editors[filepath]
            index = self.tab_widget.indexOf(editor)
            file_name = filepath.split("/")[-1].split("\\")[-1]
            if editor.is_modified:
                self.tab_widget.setTabText(index, f"● {file_name}")
            else:
                self.tab_widget.setTabText(index, file_name)
