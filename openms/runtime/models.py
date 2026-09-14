"""
OpenMS Runtime Language Models and Primitives
"""

class OMSBox:
    """A 2D/3D box (square/cube) primitive."""

    def __init__(self, size=100, color=None):
        self.size = size
        self.color = color or "#4a90e2"
        self.kind = "box"

    def __repr__(self):
        return f"<Box size={self.size} color={self.color}>"


class OMSBall:
    """A 2D/3D ball (circle/sphere) primitive, created via bol()."""

    def __init__(self, radius=50, color=None):
        self.radius = radius
        self.color = color or "#e94e77"
        self.kind = "ball"

    def __repr__(self):
        return f"<Ball radius={self.radius} color={self.color}>"


class OMSHouse:
    """A composite house shape."""

    def __init__(self, width=200, height=200):
        self.width = width
        self.height = height
        self.kind = "house"

    def __repr__(self):
        return f"<House {self.width}x{self.height}>"


class OMSGame:
    """A game world / canvas container that can hold other objects."""

    def __init__(self, title="OpenMS Game", width=640, height=480):
        self.title = title
        self.width = width
        self.height = height
        self.objects = []
        self.kind = "game"

    def __repr__(self):
        return f"<Game '{self.title}' {self.width}x{self.height} objects={len(self.objects)}>"


class OMSPhoto:
    """An image/photo asset reference, created via photo()."""

    def __init__(self, path):
        self.path = path
        self.kind = "photo"

    def __repr__(self):
        return f"<Photo '{self.path}'>"


class OMSBody2D:
    """The rendered 2D 'body' result of boody_2D(obj)."""

    def __init__(self, source):
        self.source = source
        self.kind = "body2d"

    def __repr__(self):
        return f"<Body2D of {self.source!r}>"


class OMSBody3D:
    """The rendered 3D 'body' result of boody_3D(obj)."""

    def __init__(self, source):
        self.source = source
        self.kind = "body3d"

    def __repr__(self):
        return f"<Body3D of {self.source!r}>"
