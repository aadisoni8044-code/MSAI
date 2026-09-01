"""
2D and 3D Builtin functions for OpenMS Language
"""

from openms.models import (
    OpenMSError, OMSBox, OMSBall, OMSHouse, OMSGame, OMSPhoto, OMSBody2D, OMSBody3D
)


class Builtins2D3D:
    """Provides 2D/3D language builtin implementations."""

    def __init__(self, renderer):
        self.renderer = renderer
        self.terminal_write = renderer.terminal_write

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
        self.terminal_write(f"[time] {seconds}s timer registered (simulated, non-blocking)")
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
