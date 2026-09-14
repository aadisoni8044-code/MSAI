"""
Unit tests for OpenMS Runtime Engine and Interpreter
"""

import pytest
from openms.runtime import (
    OpenMSInterpreter,
    OpenMSError,
    OMSBox,
    OMSBall,
    OMSHouse,
    OMSGame,
    OMSPhoto,
    OMSBody2D,
    OMSBody3D,
)


class TestOpenMSInterpreter:

    @pytest.fixture
    def interpreter_env(self):
        logs = []
        def mock_write(msg):
            logs.append(str(msg))
        interp = OpenMSInterpreter(root=None, terminal_write=mock_write)
        return interp, logs

    def test_variable_assignment_and_eval(self, interpreter_env):
        interp, logs = interpreter_env
        code = "a = 10\nb = 20\nc = a + b\nmachine(c)"
        interp.run(code)
        assert interp.variables["a"] == 10
        assert interp.variables["b"] == 20
        assert interp.variables["c"] == 30
        assert "30" in logs

    def test_box_and_size_builtins(self, interpreter_env):
        interp, logs = interpreter_env
        code = 'b = box(50, "#ff0000")\nsize(b, 120)'
        interp.run(code)
        b_obj = interp.variables["b"]
        assert isinstance(b_obj, OMSBox)
        assert b_obj.size == 120
        assert b_obj.color == "#ff0000"

    def test_bol_builtin(self, interpreter_env):
        interp, logs = interpreter_env
        code = 'ball = bol(30, "#00ff00")'
        interp.run(code)
        ball_obj = interp.variables["ball"]
        assert isinstance(ball_obj, OMSBall)
        assert ball_obj.radius == 30
        assert ball_obj.color == "#00ff00"

    def test_house_and_game_builtins(self, interpreter_env):
        interp, logs = interpreter_env
        code = 'h = house(300, 250)\ng = game("My OpenMS World", 800, 600)'
        interp.run(code)
        h_obj = interp.variables["h"]
        g_obj = interp.variables["g"]
        assert isinstance(h_obj, OMSHouse)
        assert h_obj.width == 300
        assert h_obj.height == 250
        assert isinstance(g_obj, OMSGame)
        assert g_obj.title == "My OpenMS World"

    def test_photo_builtin(self, interpreter_env):
        interp, logs = interpreter_env
        code = 'p = photo("assets/sample.png")'
        interp.run(code)
        p_obj = interp.variables["p"]
        assert isinstance(p_obj, OMSPhoto)
        assert p_obj.path == "assets/sample.png"

    def test_time_builtin(self, interpreter_env):
        interp, logs = interpreter_env
        code = 't = time(3)'
        interp.run(code)
        assert interp.variables["t"] == 3
        assert any("[time] 3s timer" in line for line in logs)

    def test_boody_2d_and_3d(self, interpreter_env):
        interp, logs = interpreter_env
        code = 'b = box(100)\nv2d = boody_2D(b)\nv3d = boody_3D(b)'
        interp.run(code)
        v2d_obj = interp.variables["v2d"]
        v3d_obj = interp.variables["v3d"]
        assert isinstance(v2d_obj, OMSBody2D)
        assert isinstance(v3d_obj, OMSBody3D)
        assert v2d_obj.source == interp.variables["b"]

    def test_if_conditional_block(self, interpreter_env):
        interp, logs = interpreter_env
        code = """x = 10
if (x > 5):
    y = 100
    machine("Condition Met")
"""
        interp.run(code)
        assert interp.variables["y"] == 100
        assert "Condition Met" in logs

    def test_function_definition_and_call(self, interpreter_env):
        interp, logs = interpreter_env
        code = """function add_and_log(x, y):
    res = x + y
    machine("Result:", res)
    return_val = res

out = add_and_log(15, 25)
"""
        interp.run(code)
        assert "add_and_log" in interp.functions
        assert interp.variables.get("out") == 40
        assert "res" not in interp.variables  # local variable res should not leak to global scope
        assert any("Result: 40" in line for line in logs)

    def test_undefined_variable_raises_error(self, interpreter_env):
        interp, logs = interpreter_env
        code = "machine(non_existent_var)"
        interp.run(code)
        assert any("[OpenMS Error]" in line for line in logs)
