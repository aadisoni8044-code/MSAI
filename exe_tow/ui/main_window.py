"""
exe/tow - Main Application Window
Assembles top bar, sidebar navigation, stacked views, and view switching signals.
"""

import os
from PySide6.QtCore import Qt, QSize
from PySide6.QtWidgets import (
    QMainWindow, QWidget, QHBoxLayout, QVBoxLayout, QStackedWidget
)
from exe_tow.ui.theme import ThemeColors
from exe_tow.ui.styles import get_application_stylesheet
from exe_tow.ui.components.title_bar import TitleBar
from exe_tow.ui.components.sidebar import Sidebar

from exe_tow.ui.views.home_view import HomeView
from exe_tow.ui.views.build_view import BuildView
from exe_tow.ui.views.projects_view import ProjectsView
from exe_tow.ui.views.history_view import HistoryView
from exe_tow.ui.views.settings_view import SettingsView
from exe_tow.ui.views.about_view import AboutView


class MainWindow(QMainWindow):
    """Main desktop application window for exe/tow."""

    def __init__(self, settings_manager, history_manager, logo_path: str = "assets/logo.png"):
        super().__init__()
        self.settings = settings_manager
        self.history = history_manager
        self.logo_path = logo_path

        self.setWindowTitle("exe/tow - Desktop Python Compiler")
        self.resize(1180, 780)
        self.setMinimumSize(960, 640)

        # Frameless window style for custom title bar (applied when native window manager is active)
        if os.name == "nt" or os.environ.get("QT_QPA_PLATFORM") != "offscreen":
            self.setWindowFlags(Qt.FramelessWindowHint | Qt.Window)

        # Apply global application QSS stylesheet
        self.setStyleSheet(get_application_stylesheet())

        # Central Root Layout
        central_widget = QWidget()
        central_layout = QVBoxLayout(central_widget)
        central_layout.setContentsMargins(0, 0, 0, 0)
        central_layout.setSpacing(0)

        # 1. Custom Title Bar
        self.title_bar = TitleBar(self, logo_path=self.logo_path)
        central_layout.addWidget(self.title_bar)

        # 2. Main Content Split (Sidebar + Stacked Views)
        body_layout = QHBoxLayout()
        body_layout.setContentsMargins(0, 0, 0, 0)
        body_layout.setSpacing(0)

        self.sidebar = Sidebar()
        self.sidebar.sig_nav_changed.connect(self.navigate_to_key)
        body_layout.addWidget(self.sidebar)

        # Stacked Views Container
        self.views_stack = QStackedWidget()
        self.views_stack.setStyleSheet(f"background-color: {ThemeColors.BG_DARK};")

        # Views Mapping
        self.home_view = HomeView(self.settings)
        self.build_view = BuildView(self.settings, self.history)
        self.projects_view = ProjectsView(self.settings)
        self.history_view = HistoryView(self.history)
        self.settings_view = SettingsView(self.settings)
        self.about_view = AboutView(logo_path=self.logo_path)

        self.views = {
            "home": (0, self.home_view),
            "build": (1, self.build_view),
            "projects": (2, self.projects_view),
            "history": (3, self.history_view),
            "settings": (4, self.settings_view),
            "about": (5, self.about_view),
        }

        for key, (idx, view_widget) in self.views.items():
            self.views_stack.addWidget(view_widget)

        body_layout.addWidget(self.views_stack, stretch=1)
        central_layout.addLayout(body_layout)

        self.setCentralWidget(central_widget)

        # Connect Navigation Signals
        self.home_view.sig_navigate.connect(self.navigate_to_key)
        self.home_view.sig_project_selected.connect(self._on_project_selected)

        self.projects_view.sig_open_in_builder.connect(self._on_project_selected)

        self.build_view.sig_build_finished.connect(self._on_build_finished)

        # Default View: Home
        self.navigate_to_key("home")

    def navigate_to_key(self, key: str):
        if key in self.views:
            idx, widget = self.views[key]
            self.views_stack.setCurrentIndex(idx)
            self.sidebar.update_active_state(key)

            # Refresh views when activated
            if key == "projects":
                self.projects_view.refresh_projects()
            elif key == "history":
                self.history_view.refresh_history()

    def _on_project_selected(self, folder_path: str):
        self.build_view.set_project_folder(folder_path)
        self.title_bar.set_project_title(self.build_view.input_folder.text().strip())
        self.navigate_to_key("build")

    def _on_build_finished(self, summary: dict):
        self.history_view.refresh_history()
        self.projects_view.refresh_projects()
