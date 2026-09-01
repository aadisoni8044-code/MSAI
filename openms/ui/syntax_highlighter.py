"""
Syntax Highlighter for OpenMS Code Studio
"""

from openms.config import (
    KEYWORD_PATTERN, COREFUNC_PATTERN, NUMBER_PATTERN, STRING_PATTERN, COMMENT_PATTERN
)


class SyntaxHighlighter:
    """Applies theme syntax highlighting tags onto a Tkinter Text widget."""

    def __init__(self, text_widget, theme_manager):
        self.text_widget = text_widget
        self.theme_manager = theme_manager

    def setup_tags(self):
        syntax = self.theme_manager.theme["syntax"]
        font_family = "Consolas"
        font_size = 11

        self.text_widget.tag_configure("keyword", foreground=syntax["keyword"], font=(font_family, font_size, "bold"))
        self.text_widget.tag_configure("corefunc", foreground=syntax["corefunc"], font=(font_family, font_size, "bold"))
        self.text_widget.tag_configure("number", foreground=syntax["number"], font=(font_family, font_size))
        self.text_widget.tag_configure("string", foreground=syntax["string"], font=(font_family, font_size))
        self.text_widget.tag_configure("comment", foreground=syntax["comment"], font=(font_family, font_size, "italic"))

    def highlight_all(self):
        self.setup_tags()
        content = self.text_widget.get("1.0", "end-1c")

        for tag in ("keyword", "corefunc", "number", "string", "comment"):
            self.text_widget.tag_remove(tag, "1.0", "end")

        for m in STRING_PATTERN.finditer(content):
            self._tag_range("string", m.start(), m.end())
        for m in COMMENT_PATTERN.finditer(content):
            self._tag_range("comment", m.start(), m.end())
        for m in KEYWORD_PATTERN.finditer(content):
            self._tag_range("keyword", m.start(), m.end())
        for m in COREFUNC_PATTERN.finditer(content):
            self._tag_range("corefunc", m.start(), m.end())
        for m in NUMBER_PATTERN.finditer(content):
            self._tag_range("number", m.start(), m.end())

    def _tag_range(self, tag, start, end):
        self.text_widget.tag_add(tag, f"1.0+{start}c", f"1.0+{end}c")
