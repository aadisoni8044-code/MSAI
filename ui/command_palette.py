"""
MSAI Studio - Command Palette Component
"""
from PyQt6.QtWidgets import (
    QDialog, QVBoxLayout, QLineEdit, QListWidget, QListWidgetItem
)
from PyQt6.QtCore import Qt, pyqtSignal

class CommandPalette(QDialog):
    """
    VS Code style Ctrl+Shift+P Command Palette and Ctrl+P Quick Open modal dialog.
    """
    command_triggered = pyqtSignal(str)

    def __init__(self, commands: list, parent=None):
        super().__init__(parent, Qt.WindowType.FramelessWindowHint | Qt.WindowType.Popup)
        self.commands = commands
        self.setFixedWidth(550)
        self.setFixedHeight(300)

        self.setStyleSheet("""
            QDialog {
                background-color: #1e1e2e;
                border: 1px solid #89b4fa;
                border-radius: 6px;
            }
            QLineEdit {
                background-color: #181825;
                color: #cdd6f4;
                border: 1px solid #313244;
                padding: 8px;
                font-size: 13px;
                border-radius: 4px;
            }
            QListWidget {
                background-color: #1e1e2e;
                color: #cdd6f4;
                border: none;
                font-size: 12px;
            }
            QListWidget::item {
                padding: 6px 12px;
                border-radius: 3px;
            }
            QListWidget::item:selected {
                background-color: #89b4fa;
                color: #11111b;
            }
        """)

        layout = QVBoxLayout(self)
        layout.setContentsMargins(8, 8, 8, 8)

        self.search_input = QLineEdit()
        self.search_input.setPlaceholderText("Type a command or file name...")
        self.search_input.textChanged.connect(self._filter_commands)

        self.list_widget = QListWidget()
        self.list_widget.itemActivated.connect(self._on_item_selected)

        layout.addWidget(self.search_input)
        layout.addWidget(self.list_widget)

        self._populate_list(self.commands)

    def _populate_list(self, items: list):
        self.list_widget.clear()
        for cmd in items:
            self.list_widget.addItem(QListWidgetItem(cmd))
        if self.list_widget.count() > 0:
            self.list_widget.setCurrentRow(0)

    def _filter_commands(self, text: str):
        text = text.lower()
        filtered = [cmd for cmd in self.commands if text in cmd.lower()]
        self._populate_list(filtered)

    def _on_item_selected(self, item: QListWidgetItem):
        if item:
            self.command_triggered.emit(item.text())
            self.accept()

    def keyPressEvent(self, event):
        if event.key() in (Qt.Key.Key_Return, Qt.Key.Key_Enter):
            curr_item = self.list_widget.currentItem()
            if curr_item:
                self._on_item_selected(curr_item)
        elif event.key() == Qt.Key.Key_Escape:
            self.reject()
        else:
            super().keyPressEvent(event)
