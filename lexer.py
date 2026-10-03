from enum import Enum, auto
from typing import List, Any, Optional

class TokenType(Enum):
    IMPORT = auto()
    PRINT = auto()
    IDENTIFIER = auto()
    NUMBER = auto()
    STRING = auto()
    DOT = auto()
    EQUALS = auto()
    LPAREN = auto()
    RPAREN = auto()
    COMMA = auto()
    NEWLINE = auto()
    EOF = auto()

class Token:
    def __init__(self, type_: TokenType, value: Any, line: int, column: int):
        self.type = type_
        self.value = value
        self.line = line
        self.column = column

    def __repr__(self) -> str:
        return f"Token({self.type.name}, {repr(self.value)}, Line:{self.line}, Col:{self.column})"

class LexerError(Exception):
    def __init__(self, message: str, line: int, column: int):
        self.message = message
        self.line = line
        self.column = column
        super().__init__(f"Lexer Error [Line {line}, Col {column}]: {message}")

class Lexer:
    def __init__(self, source_code: str):
        self.source = source_code
        self.position = 0
        self.line = 1
        self.column = 1
        self.length = len(source_code)

    def _peek(self, offset: int = 0) -> Optional[str]:
        pos = self.position + offset
        if pos < self.length:
            return self.source[pos]
        return None

    def _advance(self) -> Optional[str]:
        if self.position >= self.length:
            return None
        char = self.source[self.position]
        self.position += 1
        if char == '\n':
            self.line += 1
            self.column = 1
        else:
            self.column += 1
        return char

    def tokenize(self) -> List[Token]:
        tokens: List[Token] = []

        while self.position < self.length:
            char = self._peek()

            if char is None:
                break

            # Whitespace handling (spaces, tabs, carriage returns)
            if char in (' ', '\t', '\r'):
                self._advance()
                continue

            if char == '\n':
                line, col = self.line, self.column
                self._advance()
                tokens.append(Token(TokenType.NEWLINE, '\n', line, col))
                continue

            # Comments starting with #
            if char == '#':
                while self._peek() is not None and self._peek() != '\n':
                    self._advance()
                continue

            line, col = self.line, self.column

            if char == '.':
                self._advance()
                tokens.append(Token(TokenType.DOT, '.', line, col))
            elif char == '=':
                self._advance()
                tokens.append(Token(TokenType.EQUALS, '=', line, col))
            elif char == '(':
                self._advance()
                tokens.append(Token(TokenType.LPAREN, '(', line, col))
            elif char == ')':
                self._advance()
                tokens.append(Token(TokenType.RPAREN, ')', line, col))
            elif char == ',':
                self._advance()
                tokens.append(Token(TokenType.COMMA, ',', line, col))
            elif char == '"' or char == "'":
                tokens.append(self._read_string(char, line, col))
            elif char.isdigit():
                tokens.append(self._read_number(line, col))
            elif char.isalpha() or char == '_':
                tokens.append(self._read_identifier(line, col))
            else:
                raise LexerError(f"Unexpected character '{char}'", line, col)

        tokens.append(Token(TokenType.EOF, None, self.line, self.column))
        return tokens

    def _read_string(self, quote_char: str, start_line: int, start_col: int) -> Token:
        self._advance() # consume quote
        str_val = ""
        while self._peek() is not None and self._peek() != quote_char:
            if self._peek() == '\n':
                raise LexerError("Unterminated string literal", start_line, start_col)
            str_val += self._advance()

        if self._peek() is None:
            raise LexerError("Unterminated string literal", start_line, start_col)

        self._advance() # consume closing quote
        return Token(TokenType.STRING, str_val, start_line, start_col)

    def _read_number(self, start_line: int, start_col: int) -> Token:
        num_str = ""
        is_float = False
        while self._peek() is not None and (self._peek().isdigit() or (self._peek() == '.' and not is_float and self._peek_next_is_digit())):
            char = self._advance()
            if char == '.':
                is_float = True
            num_str += char

        val = float(num_str) if is_float else int(num_str)
        return Token(TokenType.NUMBER, val, start_line, start_col)

    def _peek_next_is_digit(self) -> bool:
        nxt = self._peek(1)
        return nxt is not None and nxt.isdigit()

    def _read_identifier(self, start_line: int, start_col: int) -> Token:
        ident_str = ""
        while self._peek() is not None and (self._peek().isalnum() or self._peek() == '_'):
            ident_str += self._advance()

        if ident_str == 'import':
            return Token(TokenType.IMPORT, ident_str, start_line, start_col)
        elif ident_str == 'print':
            return Token(TokenType.PRINT, ident_str, start_line, start_col)
        else:
            return Token(TokenType.IDENTIFIER, ident_str, start_line, start_col)
