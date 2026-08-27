"""
Command Palette (Ctrl+Shift+P) dialog for PyCodeStudio.
"""

from typing import Callable, Dict, List, Tuple

from PyQt6.QtCore import Qt
from PyQt6.QtWidgets import (
    QDialog,
    QLineEdit,
    QListWidget,
    QListWidgetItem,
    QVBoxLayout,
)


class CommandPaletteDialog(QDialog):
    """VS Code style Ctrl+Shift+P searchable action runner dialog."""

    def __init__(self, commands: List[Tuple[str, Callable[[], None]]], parent=None):
        super().__init__(parent)
        self.commands = commands  # List of ("Command Title", callback_fn)

        self.setWindowFlags(Qt.WindowType.FramelessWindowHint | Qt.WindowType.Dialog)
        self.setFixedWidth(540)
        self.setFixedHeight(320)
        self.setStyleSheet("""
            QDialog {
                background-color: #252526;
                border: 1px solid #007acc;
                border-radius: 6px;
            }
            QLineEdit {
                background-color: #3c3c3c;
                color: #ffffff;
                border: 1px solid #007acc;
                border-radius: 3px;
                padding: 8px 12px;
                font-size: 14px;
            }
            QListWidget {
                background-color: #252526;
                color: #cccccc;
                border: none;
                outline: none;
                font-size: 13px;
            }
            QListWidget::item {
                padding: 8px 12px;
                border-radius: 2px;
            }
            QListWidget::item:hover {
                background-color: #2a2d2e;
            }
            QListWidget::item:selected {
                background-color: #04395e;
                color: #ffffff;
            }
        """)

        layout = QVBoxLayout(self)
        layout.setContentsMargins(10, 10, 10, 10)
        layout.setSpacing(8)

        self.input_field = QLineEdit()
        self.input_field.setPlaceholderText("> Type a command to run...")
        self.input_field.textChanged.connect(self._filter_commands)

        self.list_widget = QListWidget()
        self.list_widget.itemActivated.connect(self._execute_selected)

        layout.addWidget(self.input_field)
        layout.addWidget(self.list_widget)

        self.populate_commands(self.commands)

    def populate_commands(self, commands: List[Tuple[str, Callable[[], None]]]) -> None:
        """Populates list widget with command choices."""
        self.list_widget.clear()
        for title, callback in commands:
            item = QListWidgetItem(title)
            item.setData(Qt.ItemDataRole.UserRole, callback)
            self.list_widget.addItem(item)

        if self.list_widget.count() > 0:
            self.list_widget.setCurrentRow(0)

    def _filter_commands(self, text: str) -> None:
        """Filters displayed commands using fuzzy substring search."""
        query = text.strip().lower().removeprefix(">").strip()
        self.list_widget.clear()

        for title, callback in self.commands:
            if not query or query in title.lower():
                item = QListWidgetItem(title)
                item.setData(Qt.ItemDataRole.UserRole, callback)
                self.list_widget.addItem(item)

        if self.list_widget.count() > 0:
            self.list_widget.setCurrentRow(0)

    def keyPressEvent(self, event) -> None:
        """Handles Escape and Arrow key navigation in input box."""
        key = event.key()
        if key == Qt.Key.Key_Escape:
            self.reject()
        elif key in (Qt.Key.Key_Down, Qt.Key.Key_Up):
            curr = self.list_widget.currentRow()
            delta = 1 if key == Qt.Key.Key_Down else -1
            nxt = max(0, min(self.list_widget.count() - 1, curr + delta))
            self.list_widget.setCurrentRow(nxt)
        elif key in (Qt.Key.Key_Return, Qt.Key.Key_Enter):
            self._execute_selected(self.list_widget.currentItem())
        else:
            super().keyPressEvent(event)

    def _execute_selected(self, item: QListWidgetItem) -> None:
        """Executes callback associated with selected command item."""
        if not item:
            return
        callback = item.data(Qt.ItemDataRole.UserRole)
        self.accept()
        if callback:
            callback()
