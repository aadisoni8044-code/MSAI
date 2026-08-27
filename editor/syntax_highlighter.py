"""
QScintilla lexer and syntax highlighting configurator with Pygments fallback.
"""

from PyQt6.Qsci import (
    QsciLexer,
    QsciLexerCPP,
    QsciLexerCSS,
    QsciLexerHTML,
    QsciLexerJava,
    QsciLexerJavaScript,
    QsciLexerJSON,
    QsciLexerMarkdown,
    QsciLexerPython,
)
from PyQt6.QtGui import QColor, QFont
from pygments import lex
from pygments.lexers import get_lexer_by_name

from utils.logger import logger


class SyntaxHighlighterConfigurator:
    """Sets up QScintilla lexers and colors matching dark/light themes."""

    @staticmethod
    def setup_lexer(editor, language: str, is_dark: bool = True) -> QsciLexer:
        """Attaches and configures appropriate QsciLexer to editor for language."""
        lang = language.lower().strip()
        lexer = None

        font_family = editor.font_family if hasattr(editor, "font_family") else "Consolas"
        font_size = editor.font_size if hasattr(editor, "font_size") else 12
        font = QFont(font_family, font_size)

        if lang == "python":
            lexer = QsciLexerPython()
        elif lang in ("javascript", "js", "typescript", "ts"):
            lexer = QsciLexerJavaScript()
        elif lang in ("html", "htm", "xml"):
            lexer = QsciLexerHTML()
        elif lang == "css":
            lexer = QsciLexerCSS()
        elif lang == "json":
            lexer = QsciLexerJSON()
        elif lang in ("markdown", "md"):
            lexer = QsciLexerMarkdown()
        elif lang in ("cpp", "c", "c++", "h", "hpp"):
            lexer = QsciLexerCPP()
        elif lang == "java":
            lexer = QsciLexerJava()

        if lexer:
            lexer.setFont(font)
            bg_color = QColor("#1e1e1e") if is_dark else QColor("#ffffff")
            fg_color = QColor("#d4d4d4") if is_dark else QColor("#333333")

            lexer.setDefaultPaper(bg_color)
            lexer.setDefaultColor(fg_color)

            # Apply lexer to editor
            editor.setLexer(lexer)

            # Set paper color across style range
            for i in range(128):
                lexer.setPaper(bg_color, i)

            if is_dark:
                if isinstance(lexer, QsciLexerPython):
                    lexer.setColor(QColor("#569cd6"), QsciLexerPython.Keyword)
                    lexer.setColor(QColor("#ce9178"), QsciLexerPython.DoubleQuotedString)
                    lexer.setColor(QColor("#ce9178"), QsciLexerPython.SingleQuotedString)
                    lexer.setColor(QColor("#ce9178"), QsciLexerPython.TripleSingleQuotedString)
                    lexer.setColor(QColor("#ce9178"), QsciLexerPython.TripleDoubleQuotedString)
                    lexer.setColor(QColor("#6a9955"), QsciLexerPython.Comment)
                    lexer.setColor(QColor("#6a9955"), QsciLexerPython.CommentBlock)
                    lexer.setColor(QColor("#4ec9b0"), QsciLexerPython.ClassName)
                    lexer.setColor(QColor("#dcdcaa"), QsciLexerPython.FunctionMethodName)
                    lexer.setColor(QColor("#b5cea8"), QsciLexerPython.Number)
                    lexer.setColor(QColor("#d4d4d4"), QsciLexerPython.Identifier)
            else:
                if isinstance(lexer, QsciLexerPython):
                    lexer.setColor(QColor("#0000ff"), QsciLexerPython.Keyword)
                    lexer.setColor(QColor("#a31515"), QsciLexerPython.DoubleQuotedString)
                    lexer.setColor(QColor("#a31515"), QsciLexerPython.SingleQuotedString)
                    lexer.setColor(QColor("#008000"), QsciLexerPython.Comment)
                    lexer.setColor(QColor("#2b91af"), QsciLexerPython.ClassName)
                    lexer.setColor(QColor("#795e26"), QsciLexerPython.FunctionMethodName)

            return lexer
        else:
            # Fallback to plain text / custom Pygments setup
            editor.setLexer(None)
            return None

    @staticmethod
    def get_pygments_tokens(code: str, language: str):
        """Pygments fallback lexer for unsupported QScintilla languages."""
        try:
            lexer = get_lexer_by_name(language)
            return list(lex(code, lexer))
        except Exception as e:
            logger.debug(f"Pygments fallback unavailable for {language}: {e}")
            return []
