"""
MSAI Studio - Activity Bar Component
"""
from PyQt6.QtWidgets import QWidget, QVBoxLayout, QPushButton, QButtonGroup, QFrame
from PyQt6.QtCore import pyqtSignal, QSize

class ActivityBar(QWidget):
    """
    Vertical Activity Bar on the left containing icons for switching sidebar views:
    Explorer, Search, Source Control, Run & Debug, Extensions, Settings, AI Assistant.
    """
    activity_changed = pyqtSignal(int)

    def __init__(self, parent=None):
        super().__init__(parent)
        self.setFixedWidth(50)
        self.setStyleSheet("""
            QWidget {
                background-color: #11111b;
                border-right: 1px solid #313244;
            }
            QPushButton {
                background: transparent;
                border: none;
                border-left: 3px solid transparent;
                font-size: 18px;
                padding: 10px 0;
            }
            QPushButton:hover {
                background-color: #1e1e2e;
            }
            QPushButton:checked {
                border-left: 3px solid #89b4fa;
                background-color: #1e1e2e;
            }
        """)

        layout = QVBoxLayout(self)
        layout.setContentsMargins(0, 0, 0, 0)
        layout.setSpacing(4)

        self.button_group = QButtonGroup(self)
        self.button_group.setExclusive(True)

        # Icons for sidebar sections
        items = [
            ("📁", "Explorer (Ctrl+Shift+E)"),
            ("🔍", "Search (Ctrl+Shift+F)"),
            ("🌿", "Source Control (Ctrl+Shift+G)"),
            ("▶️", "Run & Debug (Ctrl+Shift+D)"),
            ("🧩", "Extensions (Ctrl+Shift+X)"),
            ("🤖", "MSAI AI Assistant"),
        ]

        for idx, (icon, tooltip) in enumerate(items):
            btn = QPushButton(icon)
            btn.setToolTip(tooltip)
            btn.setCheckable(True)
            if idx == 0:
                btn.setChecked(True)
            self.button_group.addButton(btn, idx)
            layout.addWidget(btn)

        layout.addStretch()

        # Settings at bottom
        self.settings_btn = QPushButton("⚙️")
        self.settings_btn.setToolTip("Settings (Ctrl+,)")
        self.settings_btn.setCheckable(True)
        self.button_group.addButton(self.settings_btn, 6)
        layout.addWidget(self.settings_btn)

        self.button_group.idClicked.connect(self.activity_changed.emit)
