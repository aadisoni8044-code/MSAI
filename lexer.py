"""
Lexer (Tokenizer) for Jps script.
Converts source code string into a sequence of tokens.
"""

from enum import Enum, auto
import re

class TokenType(Enum):
    IMPORT = auto()
    DOT = auto()
    IDENTIFIER = auto()
    ASSIGN = auto()
    LPAREN = auto()
    RPAREN = auto()
    NUMBER = auto()
    STRING = auto()
    COMMA = auto()
    PRINT = auto()
    NEWLINE = auto()
    EOF = auto()

class Token:
    def __init__(self, type_: TokenType, value: str, line: int, column: int):
        self.type = type_
        self.value = value
        self.line = line
        self.column = column

    def __repr__(self):
        return f"Token({self.type.name}, {repr(self.value)}, line={self.line}, col={self.column})"

    def __eq__(self, other):
        if not isinstance(other, Token):
            return False
        return (self.type == other.type and
                self.value == other.value and
                self.line == other.line and
                self.column == other.column)

class LexerError(Exception):
    def __init__(self, message: str, line: int, column: int):
        super().__init__(f"LexerError at line {line}, column {column}: {message}")
        self.message = message
        self.line = line
        self.column = column

class Lexer:
    KEYWORDS = {
        'import': TokenType.IMPORT,
        'print': TokenType.PRINT,
    }

    # Regular expression specification for token matching
    TOKEN_SPECIFICATION = [
        ('STRING',     r'"[^"\n]*"|\'[^\'\n]*\''), # String literal enclosed in " or '
        ('NUMBER',     r'\d+(\.\d+)?'),           # Integer or decimal number
        ('ASSIGN',     r'='),                      # Assignment operator
        ('LPAREN',     r'\('),                     # Left parenthesis
        ('RPAREN',     r'\)'),                     # Right parenthesis
        ('COMMA',      r','),                      # Comma
        ('DOT',        r'\.'),                     # Dot
        ('IDENTIFIER', r'[a-zA-Z_][a-zA-Z0-9_]*'), # Identifiers & Keywords
        ('NEWLINE',    r'\n'),                     # Line end
        ('SKIP',       r'[ \t]+'),                 # Skip spaces and tabs
        ('COMMENT',    r'(#|//).*'),               # Comments (# or //)
        ('MISMATCH',   r'.'),                      # Any other character
    ]

    def __init__(self, code: str):
        self.code = code
        # Fix line-ending normalization (\r\n -> \n)
        self.code = self.code.replace('\r\n', '\n').replace('\r', '\n')
        self.tokens: list[Token] = []

    def tokenize(self) -> list[Token]:
        regex_parts = [f"(?P<{name}>{pattern})" for name, pattern in self.TOKEN_SPECIFICATION]
        tok_regex = re.compile("|".join(regex_parts))

        line_num = 1
        line_start = 0

        for match in tok_regex.finditer(self.code):
            kind = match.lastgroup
            value = match.group()
            col = match.start() - line_start + 1

            if kind == 'SKIP' or kind == 'COMMENT':
                continue
            elif kind == 'NEWLINE':
                self.tokens.append(Token(TokenType.NEWLINE, '\n', line_num, col))
                line_num += 1
                line_start = match.end()
            elif kind == 'NUMBER':
                # Preserve number as string value in token
                num_val = float(value) if '.' in value else int(value)
                self.tokens.append(Token(TokenType.NUMBER, num_val, line_num, col))
            elif kind == 'STRING':
                # Strip quotation marks
                str_val = value[1:-1]
                self.tokens.append(Token(TokenType.STRING, str_val, line_num, col))
            elif kind == 'IDENTIFIER':
                # Check for reserved keywords
                tok_type = self.KEYWORDS.get(value, TokenType.IDENTIFIER)
                self.tokens.append(Token(tok_type, value, line_num, col))
            elif kind == 'DOT':
                self.tokens.append(Token(TokenType.DOT, '.', line_num, col))
            elif kind == 'ASSIGN':
                self.tokens.append(Token(TokenType.ASSIGN, '=', line_num, col))
            elif kind == 'LPAREN':
                self.tokens.append(Token(TokenType.LPAREN, '(', line_num, col))
            elif kind == 'RPAREN':
                self.tokens.append(Token(TokenType.RPAREN, ')', line_num, col))
            elif kind == 'COMMA':
                self.tokens.append(Token(TokenType.COMMA, ',', line_num, col))
            elif kind == 'MISMATCH':
                raise LexerError(f"Unexpected character {repr(value)}", line_num, col)

        self.tokens.append(Token(TokenType.EOF, '', line_num, len(self.code) - line_start + 1))
        return self.tokens
