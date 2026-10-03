import pytest
from lexer import Lexer
from parser import Parser
from interpreter import Interpreter, RuntimeErrorJps

def test_interpreter_execution():
    code = """import.game
import.box

a = size.game(800, 600)
b = body_2D.box()
c = size.box(200, 200)
d = run.box()
e = switch.box()

print(a, b)
"""
    output_logs = []
    def log_cb(text):
        output_logs.append(text)

    tokens = Lexer(code).tokenize()
    ast = Parser(tokens).parse()
    interp = Interpreter(output_callback=log_cb)
    interp.evaluate(ast, run_gui_loop=False)

    full_output = "".join(output_logs)
    assert "(800, 600)" in full_output
    assert "<Box" in full_output

def test_interpreter_unimported_error():
    code = "b = size.box(100, 100)"
    tokens = Lexer(code).tokenize()
    ast = Parser(tokens).parse()
    interp = Interpreter()
    with pytest.raises(RuntimeErrorJps):
        interp.evaluate(ast, run_gui_loop=False)
