"""
OpenMS Language Runtime Primitive Models
"""

class OpenMSError(Exception):
    """Raised whenever the OpenMS interpreter hits a language-level error."""
    pass


class OMSBox:
    """A 2D/3D box (square/cube) primitive."""
    def __init__(self, size=100, color=None):
        self.size = size
        self.color = color or "#4a90e2"
        self.kind = "box"

    def __repr__(self):
        return f"Box(size={self.size}, color='{self.color}')"


class OMSBall:
    """A 2D/3D sphere/circle primitive."""
    def __init__(self, radius=50, color=None):
        self.radius = radius
        self.color = color or "#e94e77"
        self.kind = "bol"

    def __repr__(self):
        return f"Ball(radius={self.radius}, color='{self.color}')"


class OMSHouse:
    """A composite house shape primitive."""
    def __init__(self, width=200, height=200):
        self.width = width
        self.height = height
        self.kind = "house"

    def __repr__(self):
        return f"House(width={self.width}, height={self.height})"


class OMSGame:
    """A game world primitive that can contain other shapes."""
    def __init__(self, title="OpenMS Game", width=640, height=480):
        self.title = title
        self.width = width
        self.height = height
        self.objects = []
        self.kind = "game"

    def add(self, obj):
        self.objects.append(obj)

    def __repr__(self):
        return f"Game(title='{self.title}', size={self.width}x{self.height}, items={len(self.objects)})"


class OMSPhoto:
    """An image asset reference."""
    def __init__(self, path):
        self.path = path
        self.kind = "photo"

    def __repr__(self):
        return f"Photo(path='{self.path}')"


class OMSBody2D:
    """A rendered 2D physics body wrapper around a primitive."""
    def __init__(self, source):
        self.source = source
        self.kind = "boody_2D"

    def __repr__(self):
        return f"Body2D({self.source!r})"


class OMSBody3D:
    """A rendered 3D physics body wrapper around a primitive."""
    def __init__(self, source):
        self.source = source
        self.kind = "boody_3D"

    def __repr__(self):
        return f"Body3D({self.source!r})"
