"""
exe/tow - Navigation Sidebar
Left sidebar panel containing app views navigation.
Highlight current section with a subtle white/gray accent.
"""

from PySide6.QtCore import Signal, Qt
from PySide6.QtWidgets import (
    QFrame, QVBoxLayout, QPushButton, QLabel, QSpacerItem, QSizePolicy
)
from exe_tow.ui.theme import ThemeColors

NAV_ITEMS = [
    ("home", "⚡ Home"),
    ("build", "📦 Build EXE"),
    ("projects", "📁 Projects"),
    ("history", "📜 Build History"),
    ("settings", "⚙ Settings"),
    ("about", "ℹ About"),
]

class Sidebar(QFrame):
    """Sidebar navigation bar for exe/tow."""

    sig_nav_changed = Signal(str)  # Emits key (e.g. 'home', 'build')

    def __init__(self, parent=None):
        super().__init__(parent)
        self.setObjectName("Sidebar")
        self.setFixedWidth(200)

        layout = QVBoxLayout(self)
        layout.setContentsMargins(12, 16, 12, 16)
        layout.setSpacing(6)

        # Navigation Header
        nav_label = QLabel("NAVIGATION")
        nav_label.setStyleSheet(f"color: {ThemeColors.TEXT_MUTED}; font-size: 10px; font-weight: 700; letter-spacing: 1px;")
        layout.addWidget(nav_label)
        layout.addSpacing(6)

        self.buttons = {}
        self.current_key = "home"

        for key, label in NAV_ITEMS:
            btn = QPushButton(label)
            btn.setObjectName("SidebarNavButton")
            btn.setCursor(Qt.PointingHandCursor)
            btn.clicked.connect(lambda checked=False, k=key: self.select_item(k))
            self.buttons[key] = btn
            layout.addWidget(btn)

        layout.addStretch()

        # Status Footer Widget
        footer_card = QFrame()
        footer_card.setObjectName("CardPanel")
        footer_layout = QVBoxLayout(footer_card)
        footer_layout.setContentsMargins(10, 10, 10, 10)

        version_title = QLabel("exe/tow v1.0.0")
        version_title.setStyleSheet(f"color: {ThemeColors.TEXT_PRIMARY}; font-size: 11px; font-weight: 600;")
        status_sub = QLabel("● Engine Ready")
        status_sub.setStyleSheet(f"color: {ThemeColors.STATUS_SUCCESS}; font-size: 10px; font-weight: 500;")

        footer_layout.addWidget(version_title)
        footer_layout.addWidget(status_sub)

        layout.addWidget(footer_card)

        # Default select 'home'
        self.update_active_state("home")

    def select_item(self, key: str):
        if key in self.buttons:
            self.update_active_state(key)
            self.sig_nav_changed.emit(key)

    def update_active_state(self, active_key: str):
        self.current_key = active_key
        for key, btn in self.buttons.items():
            is_active = (key == active_key)
            btn.setProperty("active", "true" if is_active else "false")
            btn.style().unpolish(btn)
            btn.style().polish(btn)
