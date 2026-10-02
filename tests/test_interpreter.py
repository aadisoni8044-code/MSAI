import pytest
from lexer import Lexer
from parser import Parser
from interpreter import Interpreter, InterpreterError

def test_interpreter_variables_and_print():
    code = """
import.box
a = body_2D.box()
b = size.box(500, 500)
print(a, b)
"""
    logs = []
    tokens = Lexer(code).tokenize()
    ast = Parser(tokens).parse()
    interp = Interpreter(output_func=lambda s: logs.append(s), interactive=False)
    interp.execute(ast)

    assert "a" in interp.variables
    assert "b" in interp.variables
    assert any("Body2D" in log for log in logs)
    assert any("(500, 500)" in log for log in logs)

def test_interpreter_engine_run():
    code = """
import.game
a = size.game(800, 600)
b = run.game()
print(a, b)
"""
    logs = []
    tokens = Lexer(code).tokenize()
    ast = Parser(tokens).parse()
    interp = Interpreter(output_func=lambda s: logs.append(s), interactive=False)
    interp.execute(ast)

    assert any("GAME engine execution completed" in log for log in logs)

def test_interpreter_undefined_variable():
    code = "print(x)"
    tokens = Lexer(code).tokenize()
    ast = Parser(tokens).parse()
    interp = Interpreter(interactive=False)
    with pytest.raises(InterpreterError) as exc_info:
        interp.execute(ast)
    assert "Undefined variable 'x'" in str(exc_info.value)
