"""
MSAI Studio - Extensions View Component
"""
from PyQt6.QtWidgets import (
    QWidget, QVBoxLayout, QHBoxLayout, QLabel, QListWidget, QListWidgetItem,
    QPushButton, QLineEdit
)
from PyQt6.QtCore import Qt

class ExtensionsView(QWidget):
    """
    Extensions view listing Python-focused extension tools:
    Python Tools, Formatter, Linter, Debugger, Code Runner, Theme Support.
    """
    def __init__(self, parent=None):
        super().__init__(parent)

        layout = QVBoxLayout(self)
        layout.setContentsMargins(8, 8, 8, 8)

        title = QLabel("EXTENSIONS")
        title.setStyleSheet("font-size: 11px; font-weight: bold; color: #a6adc8;")
        layout.addWidget(title)

        self.search_input = QLineEdit()
        self.search_input.setPlaceholderText("Search Extensions...")
        layout.addWidget(self.search_input)

        self.list_widget = QListWidget()
        self.list_widget.setStyleSheet("QListWidget::item { padding: 8px; border-bottom: 1px solid #313244; }")

        extensions = [
            ("🐍 Python Tools", "1.4.0", "Core Python language support, autocompletion & syntax features", True),
            ("✨ Python Formatter (Black)", "2.1.0", "Auto-format Python code using Black standards", True),
            ("🔍 Python Linter (Flake8)", "1.8.2", "Real-time Python linting and code quality checks", True),
            ("🐞 Python Debugger", "1.0.5", "Full breakpoint, call stack, and variable inspection support", True),
            ("▶️ Code Runner", "0.9.1", "Run code snippets or active Python scripts rapidly", True),
            ("🎨 Theme Support", "2.0.0", "Custom VS Code dark & light themes for MSAI Studio", True),
        ]

        for name, ver, desc, installed in extensions:
            item_widget = QWidget()
            item_layout = QVBoxLayout(item_widget)
            item_layout.setContentsMargins(4, 4, 4, 4)

            name_label = QLabel(f"<b>{name}</b> <span style='color: #a6adc8;'>v{ver}</span>")
            desc_label = QLabel(desc)
            desc_label.setStyleSheet("color: #a6adc8; font-size: 11px;")

            status_btn = QPushButton("Installed" if installed else "Install")
            status_btn.setEnabled(not installed)
            status_btn.setFixedWidth(80)
            status_btn.setStyleSheet("background-color: #313244; color: #a6adc8; border-radius: 3px;" if installed else "background-color: #89b4fa; color: #11111b; font-weight: bold;")

            top_h = QHBoxLayout()
            top_h.addWidget(name_label)
            top_h.addStretch()
            top_h.addWidget(status_btn)

            item_layout.addLayout(top_h)
            item_layout.addWidget(desc_label)

            list_item = QListWidgetItem(self.list_widget)
            list_item.setSizeHint(item_widget.sizeHint())
            self.list_widget.setItemWidget(list_item, item_widget)

        layout.addWidget(self.list_widget)
