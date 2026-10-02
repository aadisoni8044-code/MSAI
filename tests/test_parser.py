import pytest
from lexer import Lexer
from parser import (
    Parser, ParserError, ImportNode, AssignmentNode,
    FunctionCallNode, PrintNode, LiteralNode, IdentifierNode
)

def test_parse_import():
    tokens = Lexer("import.game").tokenize()
    ast = Parser(tokens).parse()
    assert len(ast.statements) == 1
    stmt = ast.statements[0]
    assert isinstance(stmt, ImportNode)
    assert stmt.module_name == "game"

def test_parse_assignment_and_function_call():
    code = "a = body_2D.box()\nb = size.box(500, 500)\nc = run.box"
    tokens = Lexer(code).tokenize()
    ast = Parser(tokens).parse()

    assert len(ast.statements) == 3

    stmt1 = ast.statements[0]
    assert isinstance(stmt1, AssignmentNode)
    assert stmt1.var_name == "a"
    assert isinstance(stmt1.expr, FunctionCallNode)
    assert stmt1.expr.action == "body_2D"
    assert stmt1.expr.module == "box"
    assert len(stmt1.expr.arguments) == 0

    stmt2 = ast.statements[1]
    assert isinstance(stmt2, AssignmentNode)
    assert isinstance(stmt2.expr, FunctionCallNode)
    assert len(stmt2.expr.arguments) == 2

    stmt3 = ast.statements[2]
    assert isinstance(stmt3, AssignmentNode)
    assert isinstance(stmt3.expr, FunctionCallNode)
    assert stmt3.expr.action == "run"
    assert stmt3.expr.module == "box"

def test_parse_print():
    code = "print(a, b, 'hello')"
    tokens = Lexer(code).tokenize()
    ast = Parser(tokens).parse()

    assert len(ast.statements) == 1
    stmt = ast.statements[0]
    assert isinstance(stmt, PrintNode)
    assert len(stmt.arguments) == 3
    assert isinstance(stmt.arguments[0], IdentifierNode)
    assert isinstance(stmt.arguments[2], LiteralNode)

def test_parser_error():
    tokens = Lexer("import.").tokenize()
    with pytest.raises(ParserError):
        Parser(tokens).parse()
