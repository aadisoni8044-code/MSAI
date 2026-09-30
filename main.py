import sys
import os
from pathlib import Path

from PySide6.QtWidgets import (
    QApplication, QMainWindow, QWidget, QHBoxLayout, QVBoxLayout, QStackedWidget, QFileDialog
)
from PySide6.QtCore import Qt
from PySide6.QtGui import QIcon

from exe_tow.core.storage import StorageManager
from exe_tow.core.builder import BuildWorker
from exe_tow.ui.theme import DARK_THEME_QSS
from exe_tow.ui.titlebar import TitleBar
from exe_tow.ui.sidebar import Sidebar

from exe_tow.ui.views.dashboard import DashboardView
from exe_tow.ui.views.build_exe import BuildExeView
from exe_tow.ui.views.building import BuildingView
from exe_tow.ui.views.success import SuccessView
from exe_tow.ui.views.error import ErrorView
from exe_tow.ui.views.projects import ProjectsView, HistoryView
from exe_tow.ui.views.settings import SettingsView, AboutView


class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowFlags(Qt.FramelessWindowHint | Qt.Window)
        self.resize(1100, 720)
        self.setMinimumSize(950, 600)

        # Assets & Storage
        self.assets_dir = Path(__file__).parent / "assets"
        self.logo_path = str(self.assets_dir / "logo.png")
        self.storage_mgr = StorageManager()

        # Apply QSS Theme
        self.setStyleSheet(DARK_THEME_QSS)

        # Main Central Container
        central = QWidget()
        self.setCentralWidget(central)

        main_layout = QVBoxLayout(central)
        main_layout.setContentsMargins(0, 0, 0, 0)
        main_layout.setSpacing(0)

        # Title Bar
        self.title_bar = TitleBar(self, logo_path=self.logo_path)
        self.title_bar.minimize_requested.connect(self.showMinimized)
        self.title_bar.maximize_requested.connect(self.toggle_maximize)
        self.title_bar.close_requested.connect(self.close)
        main_layout.addWidget(self.title_bar)

        # Body (Sidebar + Content Stack)
        body = QWidget()
        body_layout = QHBoxLayout(body)
        body_layout.setContentsMargins(0, 0, 0, 0)
        body_layout.setSpacing(0)

        self.sidebar = Sidebar(self)
        self.sidebar.navigation_changed.connect(self.switch_view)
        body_layout.addWidget(self.sidebar)

        # Stacked Views Widget
        self.stack = QStackedWidget()
        body_layout.addWidget(self.stack, stretch=1)

        main_layout.addWidget(body, stretch=1)

        # Initialize Views
        self.views = {}

        self.view_dashboard = DashboardView(self.storage_mgr)
        self.view_dashboard.navigate_requested.connect(self.sidebar.select_nav)
        self.view_dashboard.open_folder_requested.connect(self.open_project_from_dashboard)
        self.stack.addWidget(self.view_dashboard)
        self.views["dashboard"] = self.view_dashboard

        self.view_build_exe = BuildExeView(self.storage_mgr)
        self.view_build_exe.start_build_requested.connect(self.start_build_process)
        self.stack.addWidget(self.view_build_exe)
        self.views["build_exe"] = self.view_build_exe

        self.view_building = BuildingView()
        self.stack.addWidget(self.view_building)
        self.views["building"] = self.view_building

        self.view_success = SuccessView()
        self.view_success.build_again_requested.connect(lambda: self.sidebar.select_nav("build_exe"))
        self.stack.addWidget(self.view_success)
        self.views["success"] = self.view_success

        self.view_error = ErrorView()
        self.view_error.try_again_requested.connect(lambda: self.sidebar.select_nav("build_exe"))
        self.stack.addWidget(self.view_error)
        self.views["error"] = self.view_error

        self.view_projects = ProjectsView(self.storage_mgr)
        self.view_projects.open_project_requested.connect(self.open_and_load_project)
        self.view_projects.build_project_requested.connect(self.open_and_load_project)
        self.stack.addWidget(self.view_projects)
        self.views["projects"] = self.view_projects

        self.view_history = HistoryView(self.storage_mgr)
        self.stack.addWidget(self.view_history)
        self.views["history"] = self.view_history

        self.view_settings = SettingsView(self.storage_mgr)
        self.stack.addWidget(self.view_settings)
        self.views["settings"] = self.view_settings

        self.view_about = AboutView(logo_path=self.logo_path)
        self.stack.addWidget(self.view_about)
        self.views["about"] = self.view_about

        self.build_worker = None

    def toggle_maximize(self):
        if self.isMaximized():
            self.showNormal()
        else:
            self.showMaximized()

    def switch_view(self, route_name: str):
        if route_name in self.views:
            self.stack.setCurrentWidget(self.views[route_name])
            if route_name == "dashboard":
                self.view_dashboard.refresh_stats()
            elif route_name == "projects":
                self.view_projects.refresh_projects()
            elif route_name == "history":
                self.view_history.refresh_history()

    def open_project_from_dashboard(self):
        folder = QFileDialog.getExistingDirectory(self, "Select Python Project Folder")
        if folder:
            self.open_and_load_project(folder)

    def open_and_load_project(self, folder_path: str):
        self.view_build_exe.set_project_folder(folder_path)
        self.sidebar.select_nav("build_exe")

    def start_build_process(self, build_config: dict):
        self.view_building.reset()
        self.stack.setCurrentWidget(self.view_building)
        self.title_bar.set_status("Building...", state="building")

        # Save project info
        self.storage_mgr.add_or_update_project({
            "folder_path": build_config["folder_path"],
            "project_name": build_config["project_name"],
            "main_file": build_config["main_file"],
            "status": "Building"
        })

        # Start Async Worker Thread
        self.build_worker = BuildWorker(build_config)
        self.build_worker.progress.connect(self.view_building.update_progress)
        self.build_worker.log.connect(self.view_building.append_log)
        self.build_worker.finished_success.connect(self.on_build_success)
        self.build_worker.finished_error.connect(self.on_build_error)
        self.build_worker.start()

    def on_build_success(self, summary: dict):
        self.title_bar.set_status("Ready", state="ready")
        self.storage_mgr.add_history_entry(summary)
        self.storage_mgr.add_or_update_project({
            "folder_path": summary["folder_path"],
            "project_name": summary["project_name"],
            "status": "Success"
        })
        self.view_success.set_summary(summary)
        self.stack.setCurrentWidget(self.view_success)

    def on_build_error(self, error_summary: dict):
        self.title_bar.set_status("Error", state="error")
        self.storage_mgr.add_history_entry(error_summary)
        self.storage_mgr.add_or_update_project({
            "folder_path": error_summary["folder_path"],
            "project_name": error_summary["project_name"],
            "status": "Failed"
        })
        self.view_error.set_error(error_summary)
        self.stack.setCurrentWidget(self.view_error)


def main():
    app = QApplication(sys.argv)
    window = MainWindow()
    window.show()
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
