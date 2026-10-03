import pytest
from lexer import Lexer
from parser import Parser, ImportNode, AssignmentNode, CallNode, PrintNode, ParserError

def test_parser_basic():
    code = """import.game
import.box

a = size.game(1000, 1000)
b = run.box()
print(a, b)
"""
    tokens = Lexer(code).tokenize()
    ast = Parser(tokens).parse()

    assert len(ast.statements) == 5
    assert isinstance(ast.statements[0], ImportNode)
    assert ast.statements[0].module_name == "game"
    assert isinstance(ast.statements[2], AssignmentNode)
    assert ast.statements[2].var_name == "a"
    assert isinstance(ast.statements[2].value, CallNode)
    assert ast.statements[2].value.action == "size"
    assert ast.statements[2].value.module == "game"
    assert isinstance(ast.statements[4], PrintNode)

def test_parser_error():
    code = "a = size.game(1000,"
    tokens = Lexer(code).tokenize()
    with pytest.raises(ParserError):
        Parser(tokens).parse()
