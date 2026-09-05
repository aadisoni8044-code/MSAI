"""Pygments-based QSyntaxHighlighter for PyQt6 Code Editor"""
from PyQt6.QtCore import QRegularExpression
from PyQt6.QtGui import QColor, QFont, QSyntaxHighlighter, QTextCharFormat
from pygments.lexer import Lexer
from pygments.lexers import (
    CppLexer,
    CssLexer,
    GoLexer,
    HtmlLexer,
    JavascriptLexer,
    JsonLexer,
    MarkdownLexer,
    PythonLexer,
    RustLexer,
    SqlLexer,
    YamlLexer,
    get_lexer_for_filename,
    get_lexer_by_name,
)
from pygments.styles import get_style_by_name
from pygments.token import Token

# NV Studio Dark Syntax Palette
NV_SYNTAX_PALETTE = {
    Token.Keyword: "#f472b6",         # Pink / Magenta
    Token.Keyword.Namespace: "#f472b6",
    Token.Keyword.Type: "#38bdf8",      # Light Cyan
    Token.Name.Class: "#38bdf8",
    Token.Name.Function: "#60a5fa",     # Blue
    Token.Name.Builtin: "#f59e0b",      # Amber / Orange
    Token.Name.Builtin.Pseudo: "#f59e0b",
    Token.Name.Variable: "#cbd5e1",     # Soft white/grey
    Token.Name.Tag: "#f472b6",          # HTML Tag
    Token.Name.Attribute: "#fbbf24",    # HTML Attribute
    Token.String: "#a3e635",            # Lime green
    Token.String.Doc: "#818cf8",        # Purple docstrings
    Token.Number: "#f87171",            # Light red
    Token.Comment: "#64748b",           # Slate comment
    Token.Comment.Preproc: "#818cf8",
    Token.Operator: "#38bdf8",          # Cyan operators
    Token.Punctuation: "#94a3b8",       # Soft slate
    Token.Generic.Heading: "#38bdf8",
    Token.Generic.Subheading: "#818cf8",
    Token.Generic.Strong: "#f472b6",
    Token.Generic.Emph: "#fbbf24",
    Token.Error: "#ef4444",
}


def get_lexer_for_file(filepath: str) -> Lexer:
    """Detect Pygments lexer based on file extension."""
    try:
        return get_lexer_for_filename(filepath)
    except Exception:
        ext = filepath.split(".")[-1].lower() if "." in filepath else ""
        if ext in ("py", "pyw"):
            return PythonLexer()
        elif ext in ("js", "jsx", "ts", "tsx"):
            return JavascriptLexer()
        elif ext in ("html", "htm"):
            return HtmlLexer()
        elif ext in ("css", "scss"):
            return CssLexer()
        elif ext in ("json",):
            return JsonLexer()
        elif ext in ("md", "markdown"):
            return MarkdownLexer()
        elif ext in ("cpp", "c", "h", "hpp"):
            return CppLexer()
        elif ext in ("rs",):
            return RustLexer()
        elif ext in ("go",):
            return GoLexer()
        elif ext in ("sql",):
            return SqlLexer()
        elif ext in ("yaml", "yml"):
            return YamlLexer()
        return PythonLexer()


class PygmentsHighlighter(QSyntaxHighlighter):
    """QSyntaxHighlighter using Pygments lexer tokenization for dynamic syntax coloring."""

    def __init__(self, document, filepath: str = "script.py"):
        super().__init__(document)
        self.lexer = get_lexer_for_file(filepath)
        self.formats = {}
        self._init_formats()

    def _init_formats(self) -> None:
        """Create QTextCharFormat dictionary mapping Pygments tokens to NV Studio style."""
        for token, hex_color in NV_SYNTAX_PALETTE.items():
            fmt = QTextCharFormat()
            fmt.setForeground(QColor(hex_color))
            if token in (Token.Keyword, Token.Name.Class, Token.Name.Function):
                fmt.setFontWeight(QFont.Weight.Bold)
            elif token in (Token.Comment, Token.String.Doc):
                fmt.setFontItalic(True)
            self.formats[token] = fmt

    def set_filepath(self, filepath: str) -> None:
        """Update lexer when file mode changes."""
        self.lexer = get_lexer_for_file(filepath)
        self.rehighlight()

    def highlightBlock(self, text: str) -> None:
        """Process line of text and apply styling formats according to Pygments tokens."""
        if not text or not self.lexer:
            return

        # Tokenize block text using Pygments lexer
        tokens = self.lexer.get_tokens(text)
        length_offset = 0

        for token_type, value in tokens:
            token_len = len(value)
            # Find best format match by checking token taxonomy hierarchy
            curr_type = token_type
            fmt = None
            while curr_type:
                if curr_type in self.formats:
                    fmt = self.formats[curr_type]
                    break
                curr_type = curr_type.parent

            if fmt:
                self.setFormat(length_offset, token_len, fmt)
            length_offset += token_len
