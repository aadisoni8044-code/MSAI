"""
Unit tests for OpenMS Language Interpreter Engine
"""

import pytest
import tkinter as tk
from openms.interpreter.engine import OpenMSInterpreter
from openms.models import OMSBox, OMSBall, OMSGame, OpenMSError


@pytest.fixture
def tk_root():
    root = tk.Tk()
    root.withdraw()
    yield root
    root.destroy()


def test_interpreter_basic_assignment_and_eval(tk_root):
    logs = []
    interp = OpenMSInterpreter(tk_root, logs.append)

    interp.run("x = 10 + 20 * 2\ny = x / 2")
    assert interp.variables["x"] == 50
    assert interp.variables["y"] == 25.0


def test_interpreter_builtins_1d(tk_root):
    logs = []
    interp = OpenMSInterpreter(tk_root, logs.append)

    interp.run('machine("Hello", "OpenMS")')
    assert any("Hello OpenMS" in l for l in logs)


def test_interpreter_comparison_expression(tk_root):
    logs = []
    interp = OpenMSInterpreter(tk_root, logs.append)

    interp.run('x = 10\ny = 10\nmachine(x == y)')
    assert any("True" in l for l in logs)


def test_interpreter_builtins_2d3d(tk_root):
    logs = []
    interp = OpenMSInterpreter(tk_root, logs.append)

    code = """
b = box(200, '#123456')
size(b, 250)
s = bol(30)
g = game('Test Game')
g2 = boody_2D(b)
g3 = boody_3D(s)
"""
    interp.run(code)
    assert isinstance(interp.variables["b"], OMSBox)
    assert interp.variables["b"].size == 250
    assert isinstance(interp.variables["s"], OMSBall)
    assert isinstance(interp.variables["g"], OMSGame)


def test_interpreter_if_statement(tk_root):
    logs = []
    interp = OpenMSInterpreter(tk_root, logs.append)

    code = """
x = 100
if(x > 50):
    y = 500
"""
    interp.run(code)
    assert interp.variables["y"] == 500


def test_interpreter_custom_function(tk_root):
    logs = []
    interp = OpenMSInterpreter(tk_root, logs.append)

    code = """
function make_box(s):
    res = box(s)

make_box(180)
"""
    interp.run(code)
    assert "make_box" in interp.functions


def test_interpreter_undefined_variable_error(tk_root):
    logs = []
    interp = OpenMSInterpreter(tk_root, logs.append)

    with pytest.raises(OpenMSError):
        interp.run("x = unknown_var + 5")
