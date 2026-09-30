import os
from datetime import datetime
from PySide6.QtWidgets import (
    QMainWindow, QWidget, QVBoxLayout, QHBoxLayout, QStackedWidget, QFrame, QApplication
)
from PySide6.QtCore import Qt, QSize
from PySide6.QtGui import QIcon

from exe_tow.core.storage import StorageManager
from exe_tow.core.builder import BuildWorkerThread
from exe_tow.ui.titlebar import TitleBar
from exe_tow.ui.sidebar import Sidebar
from exe_tow.ui.styles import DARK_STYLESHEET

from exe_tow.ui.views.dashboard_view import DashboardView
from exe_tow.ui.views.scanner_view import ScannerView
from exe_tow.ui.views.build_view import BuildView
from exe_tow.ui.views.build_monitor_view import BuildMonitorView
from exe_tow.ui.views.projects_view import ProjectsView
from exe_tow.ui.views.history_view import HistoryView
from exe_tow.ui.views.settings_view import SettingsView
from exe_tow.ui.views.about_view import AboutView

class MainWindow(QMainWindow):
    """Main desktop application window integrating titlebar, sidebar, stacked view routing, and build execution."""

    def __init__(self, logo_path: str = "assets/logo.png"):
        super().__init__()
        self.logo_path = logo_path
        self.storage = StorageManager()
        self.builder_thread = None
        self.current_scan_data = {}

        # Configure Frameless Window
        self.setWindowFlags(Qt.FramelessWindowHint | Qt.Window)
        self.setAttribute(Qt.WA_TranslucentBackground, False)
        self.setMinimumSize(1100, 680)
        self.resize(1240, 780)
        self.setWindowTitle("exe/tow - Python to Windows EXE Builder")

        if os.path.exists(self.logo_path):
            self.setWindowIcon(QIcon(self.logo_path))

        # Root Central Widget
        root_widget = QWidget()
        root_widget.setStyleSheet("background-color: #090A0D;")
        root_layout = QVBoxLayout(root_widget)
        root_layout.setContentsMargins(0, 0, 0, 0)
        root_layout.setSpacing(0)

        # Titlebar
        self.titlebar = TitleBar(self, logo_path=self.logo_path)
        root_layout.addWidget(self.titlebar)

        # Content Area (Sidebar + Stacked Views)
        body_layout = QHBoxLayout()
        body_layout.setContentsMargins(0, 0, 0, 0)
        body_layout.setSpacing(0)

        # Sidebar Navigation
        self.sidebar = Sidebar(self, logo_path=self.logo_path)
        self.sidebar.page_changed.connect(self.navigate_to)
        body_layout.addWidget(self.sidebar)

        # Stacked Views Widget
        self.stacked_widget = QStackedWidget()
        self.stacked_widget.setStyleSheet("background-color: #090A0D;")

        # Instantiate View Pages
        self.view_dashboard = DashboardView(self.storage)
        self.view_scanner = ScannerView()
        self.view_build = BuildView()
        self.view_monitor = BuildMonitorView()
        self.view_projects = ProjectsView(self.storage)
        self.view_history = HistoryView(self.storage)
        self.view_settings = SettingsView(self.storage)
        self.view_about = AboutView(logo_path=self.logo_path)

        # Add to stack
        self.views_map = {
            "dashboard": (0, self.view_dashboard),
            "scanner": (1, self.view_scanner),
            "build": (2, self.view_build),
            "monitor": (3, self.view_monitor),
            "projects": (4, self.view_projects),
            "history": (5, self.view_history),
            "settings": (6, self.view_settings),
            "about": (7, self.view_about)
        }

        for key, (idx, widget) in self.views_map.items():
            self.stacked_widget.addWidget(widget)

        body_layout.addWidget(self.stacked_widget)
        root_layout.addLayout(body_layout)

        self.setCentralWidget(root_widget)

        # Connect Workflows & Signals
        self._wire_signals()

        # Apply QSS Styling
        self.setStyleSheet(DARK_STYLESHEET)

        # Start on Dashboard
        self.navigate_to("dashboard")

    def _wire_signals(self):
        # Dashboard connections
        self.view_dashboard.select_project_clicked.connect(self.on_project_selected)
        self.view_dashboard.create_exe_clicked.connect(self.on_dashboard_create_clicked)

        # Scanner connections
        self.view_scanner.proceed_to_build_clicked.connect(self.on_scanner_proceed)

        # Build View connections
        self.view_build.start_build_clicked.connect(self.start_build_process)

        # Build Monitor connections
        self.view_monitor.build_again_clicked.connect(lambda: self.navigate_to("build"))

        # Projects View connections
        self.view_projects.select_project_for_build.connect(self.on_project_selected)

    def navigate_to(self, key: str):
        if key in self.views_map:
            idx, widget = self.views_map[key]
            self.stacked_widget.setCurrentIndex(idx)
            self.sidebar.set_active(key)

            # Refresh views when navigated to
            if key == "dashboard":
                self.view_dashboard.refresh_stats()
            elif key == "projects":
                self.view_projects.refresh_projects()
            elif key == "history":
                self.view_history.refresh_table()

    def on_project_selected(self, folder_path: str):
        if not folder_path:
            return
        self.view_dashboard.set_selected_project_path(folder_path)
        self.view_scanner.scan_directory(folder_path)
        self.navigate_to("scanner")

    def on_dashboard_create_clicked(self):
        if self.view_scanner.scan_result and self.view_scanner.scan_result.get("path"):
            self.navigate_to("scanner")
        else:
            # Trigger folder browse if none selected yet
            self.view_dashboard.browse_folder()

    def on_scanner_proceed(self, scan_data: dict):
        self.current_scan_data = scan_data
        self.view_build.load_project_data(scan_data)
        self.navigate_to("build")

    def start_build_process(self, build_config: dict):
        self.navigate_to("monitor")
        self.view_monitor.prepare_for_build(
            build_config.get("app_name", "MyPythonApp"),
            build_config.get("exe_filename", "MyPythonApp.exe")
        )

        # Create worker thread
        self.builder_thread = BuildWorkerThread(
            project_dir=build_config.get("project_dir", "."),
            entry_file=build_config.get("entry_file", "main.py"),
            app_name=build_config.get("app_name", "MyPythonApp"),
            exe_filename=build_config.get("exe_filename", "MyPythonApp.exe"),
            output_dir=build_config.get("output_dir", os.path.abspath("dist")),
            one_file=build_config.get("one_file", True),
            include_assets=build_config.get("include_assets", True),
            windowed_mode=build_config.get("windowed_mode", True),
            asset_files=build_config.get("asset_files", []),
            python_interpreter=self.storage.settings.get("python_interpreter")
        )

        self.builder_thread.log_received.connect(self.view_monitor.append_log_line)
        self.builder_thread.progress_updated.connect(self.view_monitor.update_progress)
        self.builder_thread.step_changed.connect(self.view_monitor.update_step)
        self.builder_thread.build_finished.connect(self.on_build_finished)

        self.builder_thread.start()

    def on_build_finished(self, result: dict):
        self.view_monitor.handle_build_finished(result)

        # Save to projects and history
        now_str = datetime.now().strftime("%Y-%m-%d %H:%M")
        proj_name = result.get("app_name", "MyPythonApp")
        res_str = result.get("result", "SUCCESS")
        entry_file = self.current_scan_data.get("entry_file", "main.py")
        proj_path = self.current_scan_data.get("path", ".")

        # Add history record
        history_record = {
            "date": now_str,
            "project": proj_name,
            "entry_file": entry_file,
            "result": res_str,
            "time": f"{result.get('duration_sec', 0)}s",
            "size": result.get("size_str", "0 MB"),
            "output_path": result.get("output_path", ""),
            "logs": result.get("logs", [])
        }
        self.storage.add_history_record(history_record)

        # Update project record
        proj_record = {
            "name": proj_name,
            "path": proj_path,
            "entry_file": entry_file,
            "last_build": now_str,
            "status": "BUILT" if res_str == "SUCCESS" else "FAILED",
            "files_count": self.current_scan_data.get("py_files_count", 0),
            "dep_count": self.current_scan_data.get("dep_count", 0),
            "asset_count": self.current_scan_data.get("asset_files_count", 0)
        }
        self.storage.add_project(proj_record)

        # Refresh stats
        self.view_dashboard.refresh_stats()
