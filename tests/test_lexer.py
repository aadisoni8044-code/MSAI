import pytest
from lexer import Lexer, TokenType, LexerError

def test_lexer_basic_tokens():
    code = "import.box\na = 10\nprint(a)"
    tokens = Lexer(code).tokenize()

    assert tokens[0].type == TokenType.IMPORT
    assert tokens[1].type == TokenType.DOT
    assert tokens[2].type == TokenType.IDENTIFIER
    assert tokens[2].value == "box"
    assert tokens[3].type == TokenType.NEWLINE

    assert tokens[4].type == TokenType.IDENTIFIER
    assert tokens[4].value == "a"
    assert tokens[5].type == TokenType.ASSIGN
    assert tokens[6].type == TokenType.NUMBER
    assert tokens[6].value == 10

def test_lexer_string_literal():
    code = 'print("hello world", \'jps script\')'
    tokens = Lexer(code).tokenize()

    assert tokens[0].type == TokenType.PRINT
    assert tokens[1].type == TokenType.LPAREN
    assert tokens[2].type == TokenType.STRING
    assert tokens[2].value == "hello world"
    assert tokens[3].type == TokenType.COMMA
    assert tokens[4].type == TokenType.STRING
    assert tokens[4].value == "jps script"

def test_lexer_comments_and_whitespace():
    code = "# comment line\na = 5 // trailing comment\n"
    tokens = Lexer(code).tokenize()

    assert tokens[0].type == TokenType.NEWLINE
    assert tokens[1].type == TokenType.IDENTIFIER
    assert tokens[1].value == "a"
    assert tokens[2].type == TokenType.ASSIGN
    assert tokens[3].type == TokenType.NUMBER
    assert tokens[3].value == 5

def test_lexer_error():
    code = "a = @invalid"
    with pytest.raises(LexerError) as exc_info:
        Lexer(code).tokenize()
    assert "@" in str(exc_info.value)
