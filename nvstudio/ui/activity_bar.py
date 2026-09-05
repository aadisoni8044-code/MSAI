"""NV Studio Activity Bar (Left Navigation Bar)"""
from typing import Dict, Optional
from PyQt6.QtCore import Qt, pyqtSignal, QSize
from PyQt6.QtWidgets import QFrame, QPushButton, QVBoxLayout, QWidget, QButtonGroup


class ActivityBar(QFrame):
    """Leftmost activity bar providing quick panel toggle buttons."""
    activity_changed = pyqtSignal(str)  # Emits panel name: 'explorer', 'search', 'source_control', 'run_debug', 'extensions', 'settings'

    ACTIVITIES = [
        ("explorer", "📁", "Explorer (Ctrl+Shift+E)"),
        ("search", "🔍", "Search (Ctrl+Shift+F)"),
        ("source_control", "🌿", "Source Control (Ctrl+Shift+G)"),
        ("run_debug", "▶", "Run & Debug (Ctrl+Shift+D)"),
        ("extensions", "🧩", "Extensions (Ctrl+Shift+X)"),
    ]

    def __init__(self, parent=None):
        super().__init__(parent)
        self.setObjectName("ActivityBar")

        layout = QVBoxLayout(self)
        layout.setContentsMargins(0, 8, 0, 8)
        layout.setSpacing(4)

        self.buttons: Dict[str, QPushButton] = {}
        self.button_group = QButtonGroup(self)
        self.button_group.setExclusive(True)

        # Top activity buttons
        for act_id, symbol, tooltip in self.ACTIVITIES:
            btn = QPushButton(symbol)
            btn.setToolTip(tooltip)
            btn.setCheckable(True)
            btn.setMinimumSize(QSize(48, 48))
            btn.setProperty("active", "false")
            btn.clicked.connect(lambda checked, name=act_id: self._on_button_clicked(name))

            layout.addWidget(btn)
            self.buttons[act_id] = btn
            self.button_group.addButton(btn)

        layout.addStretch()

        # Bottom Settings button
        settings_btn = QPushButton("⚙")
        settings_btn.setToolTip("Settings (Ctrl+,)")
        settings_btn.setCheckable(True)
        settings_btn.setMinimumSize(QSize(48, 48))
        settings_btn.setProperty("active", "false")
        settings_btn.clicked.connect(lambda: self._on_button_clicked("settings"))
        layout.addWidget(settings_btn)
        self.buttons["settings"] = settings_btn
        self.button_group.addButton(settings_btn)

        # Default active activity
        self.set_active_activity("explorer")

    def _on_button_clicked(self, name: str) -> None:
        self.set_active_activity(name)
        self.activity_changed.emit(name)

    def set_active_activity(self, name: str) -> None:
        for act_id, btn in self.buttons.items():
            is_active = (act_id == name)
            btn.setChecked(is_active)
            btn.setProperty("active", "true" if is_active else "false")
            btn.style().unpolish(btn)
            btn.style().polish(btn)
