"""
MSAI Studio - Title Bar & Menu Bar Component
"""
from PyQt6.QtWidgets import QWidget, QHBoxLayout, QLabel, QPushButton, QMenuBar, QMenu
from PyQt6.QtCore import Qt, pyqtSignal
from constants import APP_NAME

class TitleBar(QWidget):
    """
    VS Code-inspired Custom Title Bar with Window Controls, Logo, and Top Menus.
    """
    minimize_requested = pyqtSignal()
    maximize_requested = pyqtSignal()
    close_requested = pyqtSignal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self.setFixedHeight(38)
        self.setStyleSheet("""
            QWidget {
                background-color: #181825;
                color: #cdd6f4;
            }
            QMenuBar {
                background-color: transparent;
                color: #cdd6f4;
                font-size: 13px;
            }
            QMenuBar::item {
                background: transparent;
                padding: 4px 8px;
                border-radius: 4px;
            }
            QMenuBar::item:selected {
                background-color: #313244;
            }
            QMenu {
                background-color: #1e1e2e;
                color: #cdd6f4;
                border: 1px solid #313244;
                padding: 4px;
            }
            QMenu::item {
                padding: 6px 24px 6px 12px;
                border-radius: 3px;
            }
            QMenu::item:selected {
                background-color: #89b4fa;
                color: #11111b;
            }
        """)

        layout = QHBoxLayout(self)
        layout.setContentsMargins(8, 0, 8, 0)
        layout.setSpacing(12)

        # App Logo & Title
        self.logo_label = QLabel(f"<b>🐍 {APP_NAME}</b>")
        self.logo_label.setStyleSheet("color: #89b4fa; font-size: 14px; font-weight: bold;")

        # Menu Bar
        self.menu_bar = QMenuBar(self)
        self.file_menu = self.menu_bar.addMenu("File")
        self.edit_menu = self.menu_bar.addMenu("Edit")
        self.selection_menu = self.menu_bar.addMenu("Selection")
        self.view_menu = self.menu_bar.addMenu("View")
        self.run_menu = self.menu_bar.addMenu("Run")
        self.terminal_menu = self.menu_bar.addMenu("Terminal")
        self.help_menu = self.menu_bar.addMenu("Help")

        # Window Action Buttons
        self.min_btn = QPushButton("─")
        self.max_btn = QPushButton("▢")
        self.close_btn = QPushButton("✕")

        btn_style = """
            QPushButton {
                background: transparent;
                color: #a6adc8;
                border: none;
                font-size: 13px;
                width: 28px;
                height: 28px;
            }
            QPushButton:hover {
                background-color: #313244;
                color: #cdd6f4;
            }
        """
        close_btn_style = """
            QPushButton {
                background: transparent;
                color: #a6adc8;
                border: none;
                font-size: 13px;
                width: 28px;
                height: 28px;
            }
            QPushButton:hover {
                background-color: #f38ba8;
                color: #11111b;
            }
        """

        self.min_btn.setStyleSheet(btn_style)
        self.max_btn.setStyleSheet(btn_style)
        self.close_btn.setStyleSheet(close_btn_style)

        self.min_btn.clicked.connect(self.minimize_requested)
        self.max_btn.clicked.connect(self.maximize_requested)
        self.close_btn.clicked.connect(self.close_requested)

        layout.addWidget(self.logo_label)
        layout.addWidget(self.menu_bar)
        layout.addStretch()
        layout.addWidget(self.min_btn)
        layout.addWidget(self.max_btn)
        layout.addWidget(self.close_btn)
