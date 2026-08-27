"""
Minimap code preview widget for PyCodeStudio.
"""

from PyQt6.QtCore import QRectF, Qt
from PyQt6.QtGui import QColor, QFont, QPainter
from PyQt6.QtWidgets import QWidget


class MinimapWidget(QWidget):
    """Simplified minimap sidebar displaying zoomed out overview of current document."""

    def __init__(self, parent=None):
        super().__init__(parent)
        self.editor = None
        self.setFixedWidth(80)
        self.setStyleSheet("background-color: #212121;")

    def set_editor(self, editor) -> None:
        """Connects minimap to active editor."""
        if self.editor:
            try:
                self.editor.textChanged.disconnect(self.update)
                self.editor.cursorPositionChanged.disconnect(self.update)
            except Exception:
                pass

        self.editor = editor
        if self.editor:
            self.editor.textChanged.connect(self.update)
            self.editor.cursorPositionChanged.connect(self.update)
        self.update()

    def mousePressEvent(self, event) -> None:
        """Scrolls editor when clicking on minimap."""
        if not self.editor:
            return
        y = event.position().y()
        total_lines = max(1, self.editor.lines())
        clicked_line = int((y / max(1, self.height())) * total_lines)
        self.editor.setFirstVisibleLine(max(0, clicked_line - 5))

    def paintEvent(self, event) -> None:
        """Paints miniature representation of text lines and viewport indicator."""
        painter = QPainter(self)
        painter.fillRect(self.rect(), QColor("#1e1e1e"))

        if not self.editor:
            return

        lines_count = self.editor.lines()
        if lines_count == 0:
            return

        line_height = max(1.5, min(4.0, self.height() / lines_count))
        painter.setPen(QColor("#555555"))

        # Render line representations
        for i in range(min(lines_count, int(self.height() / line_height))):
            text = self.editor.text(i).strip()
            if text:
                w = min(self.width() - 8, max(4, len(text) * 1.2))
                y = i * line_height
                painter.fillRect(QRectF(4, y, w, max(1.0, line_height - 0.5)), QColor("#666666"))

        # Render visible viewport indicator
        first_line = self.editor.firstVisibleLine()
        visible_lines = max(10, self.editor.linesOnScreen() if hasattr(self.editor, "linesOnScreen") else 30)

        vp_y = first_line * line_height
        vp_h = max(15, visible_lines * line_height)

        painter.fillRect(
            QRectF(0, vp_y, self.width(), vp_h),
            QColor(255, 255, 255, 20)
        )
        painter.setPen(QColor("#007acc"))
        painter.drawRect(QRectF(0, vp_y, self.width() - 1, vp_h - 1))
