"""
OpenMS Built-in Functions Implementation
"""

import os
from tkinter import filedialog, simpledialog
from openms.runtime.errors import OpenMSError
from openms.runtime.models import (
    OMSBox,
    OMSBall,
    OMSHouse,
    OMSGame,
    OMSPhoto,
    OMSBody2D,
    OMSBody3D,
)
from openms.runtime.renderer import OMSRenderer


class OMSBuiltins:
    """Provides built-in functions for the OpenMS runtime environment."""

    def __init__(self, root, terminal_write):
        self.root = root
        self.terminal_write = terminal_write
        self.renderer = OMSRenderer(root, terminal_write)

    # 1D Language Built-ins
    def b_machine(self, *args):
        formatted = " ".join(str(a) for a in args)
        self.terminal_write(formatted)
        return formatted

    def b_input(self, prompt="Enter value:"):
        val = simpledialog.askstring("OpenMS Input", str(prompt))
        return val if val is not None else ""

    def b_function(self, *args):
        raise OpenMSError("function is a keyword defining blocks, not a callable directly")

    def b_open(self, path=None):
        if not path:
            path = filedialog.askopenfilename(
                filetypes=[("Text Files", "*.txt"), ("OpenMS Files", "*.game *.function"), ("All Files", "*.*")]
            )
        if not path:
            return ""
        if not os.path.exists(path):
            raise OpenMSError(f"open(): File '{path}' does not exist")
        with open(path, "r", encoding="utf-8", errors="replace") as f:
            return f.read()

    def b_if(self, *args):
        raise OpenMSError("if is a keyword defining conditional blocks, not a callable directly")

    # 2D/3D Shape & Game Built-ins
    def b_box(self, size=100, color=None):
        return OMSBox(size, color)

    def b_bol(self, radius=50, color=None):
        return OMSBall(radius, color)

    def b_size(self, obj, value):
        if hasattr(obj, "size"):
            obj.size = value
        elif hasattr(obj, "radius"):
            obj.radius = value
        else:
            raise OpenMSError("size() target has no resizable property")
        return obj

    def b_photo(self, path):
        return OMSPhoto(path)

    def b_time(self, seconds=1):
        self.terminal_write(f"[time] {seconds}s timer registered (simulated)")
        return seconds

    def b_house(self, width=200, height=200):
        return OMSHouse(width, height)

    def b_game(self, title="OpenMS Game", width=640, height=480):
        return OMSGame(title, width, height)

    def b_boody_2D(self, obj):
        self.renderer.render_2d(obj)
        return OMSBody2D(obj)

    def b_boody_3D(self, obj):
        self.renderer.render_3d(obj)
        return OMSBody3D(obj)

    def get_builtins_map(self):
        return {
            "machine": self.b_machine,
            "input": self.b_input,
            "function": self.b_function,
            "open": self.b_open,
            "if": self.b_if,
            "box": self.b_box,
            "bol": self.b_bol,
            "size": self.b_size,
            "photo": self.b_photo,
            "time": self.b_time,
            "house": self.b_house,
            "game": self.b_game,
            "boody_2D": self.b_boody_2D,
            "boody_3D": self.b_boody_3D,
        }
