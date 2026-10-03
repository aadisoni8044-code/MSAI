import pytest
from lexer import Lexer, TokenType, LexerError

def test_lexer_imports_and_calls():
    code = """import.game
import.box

a = size.game(1000, 1000)
c = run.box()
print(a, "hello", 123)
"""
    lexer = Lexer(code)
    tokens = lexer.tokenize()

    types = [t.type for t in tokens if t.type != TokenType.NEWLINE]
    assert TokenType.IMPORT in types
    assert TokenType.PRINT in types
    assert TokenType.EOF in types

def test_lexer_error():
    code = "a = @invalid"
    lexer = Lexer(code)
    with pytest.raises(LexerError):
        lexer.tokenize()
