"""
Vector and standard icon loader for PyCodeStudio.
"""

from PyQt6.QtCore import QPointF, QRectF, Qt
from PyQt6.QtGui import QColor, QIcon, QPainter, QPainterPath, QPixmap


class IconLoader:
    """Generates procedural SVG-style icons or loads image assets."""

    @staticmethod
    def get_icon(name: str, color_hex: str = "#CCCCCC") -> QIcon:
        """Returns a QIcon drawn procedurally matching the requested icon name."""
        pixmap = QPixmap(24, 24)
        pixmap.fill(Qt.GlobalColor.transparent)

        painter = QPainter(pixmap)
        painter.setRenderHint(QPainter.RenderHint.Antialiasing)
        color = QColor(color_hex)
        painter.setPen(Qt.PenStyle.NoPen)
        painter.setBrush(color)

        pen = painter.pen()
        pen.setColor(color)
        pen.setWidthF(1.8)
        pen.setCapStyle(Qt.PenCapStyle.RoundCap)
        pen.setJoinStyle(Qt.PenJoinStyle.RoundJoin)
        painter.setPen(pen)
        painter.setBrush(Qt.BrushStyle.NoBrush)

        if name == "file":
            path = QPainterPath()
            path.moveTo(6, 3)
            path.lineTo(14, 3)
            path.lineTo(18, 7)
            path.lineTo(18, 21)
            path.lineTo(6, 21)
            path.closeSubpath()
            painter.drawPath(path)
            painter.drawLine(14, 3, 14, 7)
            painter.drawLine(14, 7, 18, 7)

        elif name == "folder":
            path = QPainterPath()
            path.moveTo(3, 5)
            path.lineTo(9, 5)
            path.lineTo(11, 7)
            path.lineTo(21, 7)
            path.lineTo(21, 19)
            path.lineTo(3, 19)
            path.closeSubpath()
            painter.drawPath(path)

        elif name == "run":
            path = QPainterPath()
            path.moveTo(7, 5)
            path.lineTo(18, 12)
            path.lineTo(7, 19)
            path.closeSubpath()
            painter.setBrush(color)
            painter.drawPath(path)

        elif name == "search":
            painter.drawEllipse(QPointF(10.5, 10.5), 5.5, 5.5)
            painter.drawLine(14.5, 14.5, 19.5, 19.5)

        elif name == "terminal":
            painter.drawLine(5, 7, 11, 12)
            painter.drawLine(11, 12, 5, 17)
            painter.drawLine(12, 17, 19, 17)

        elif name == "settings":
            painter.drawEllipse(QPointF(12, 12), 4, 4)

        elif name == "close":
            painter.drawLine(6, 6, 18, 18)
            painter.drawLine(18, 6, 6, 18)

        elif name == "split":
            painter.drawRect(QRectF(4, 4, 16, 16))
            painter.drawLine(12, 4, 12, 20)

        else:
            # Generic document icon fallback
            painter.drawRect(QRectF(5, 4, 14, 16))

        painter.end()
        return QIcon(pixmap)
