"""
OpenMS Syntax Highlighter
"""

import re


class OpenMSHighlighter:
    """Applies regex-based syntax highlighting rules for the OpenMS language."""

    KEYWORD_PATTERN = re.compile(r'\b(if|function|pass)\b')
    COREFUNC_PATTERN = re.compile(
        r'\b(machine|box|boody_2D|bol|photo|size|time|house|game|boody_3D|input|open)\b'
    )
    NUMBER_PATTERN = re.compile(r'\b\d+(\.\d+)?\b')
    STRING_PATTERN = re.compile(r'"[^"\n]*"|\'[^\'\n]*\'')
    COMMENT_PATTERN = re.compile(r'#.*|//.*')

    def __init__(self, text_widget, theme=None):
        self.text_widget = text_widget
        self.theme = theme

    def configure_tags(self, theme):
        self.theme = theme
        self.text_widget.tag_configure("keyword", foreground=theme.get("kw_color", "#c586c0"), font=("Consolas", 12, "bold"))
        self.text_widget.tag_configure("corefunc", foreground=theme.get("func_color", "#dcdcaa"), font=("Consolas", 12, "bold"))
        self.text_widget.tag_configure("number", foreground=theme.get("num_color", "#b5cea8"))
        self.text_widget.tag_configure("string", foreground=theme.get("str_color", "#ce9178"))
        self.text_widget.tag_configure("comment", foreground=theme.get("fg_dim", "#75715e"), font=("Consolas", 12, "italic"))

    def highlight(self):
        content = self.text_widget.get("1.0", "end-1c")
        for tag in ("keyword", "corefunc", "number", "string", "comment"):
            self.text_widget.tag_remove(tag, "1.0", "end")

        for m in self.COMMENT_PATTERN.finditer(content):
            self._tag_range("comment", m.start(), m.end())
        for m in self.STRING_PATTERN.finditer(content):
            self._tag_range("string", m.start(), m.end())
        for m in self.KEYWORD_PATTERN.finditer(content):
            self._tag_range("keyword", m.start(), m.end())
        for m in self.COREFUNC_PATTERN.finditer(content):
            self._tag_range("corefunc", m.start(), m.end())
        for m in self.NUMBER_PATTERN.finditer(content):
            self._tag_range("number", m.start(), m.end())

    def _tag_range(self, tag, start, end):
        self.text_widget.tag_add(tag, f"1.0+{start}c", f"1.0+{end}c")
