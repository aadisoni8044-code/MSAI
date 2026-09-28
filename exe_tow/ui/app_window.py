import os
import subprocess
from PySide6.QtWidgets import QMainWindow, QWidget, QHBoxLayout, QStackedWidget, QMessageBox
from PySide6.QtCore import Qt

from exe_tow.ui.theme import Theme
from exe_tow.ui.components.sidebar import Sidebar
from exe_tow.ui.views.dashboard_view import DashboardView
from exe_tow.ui.views.build_view import BuildView
from exe_tow.ui.views.projects_view import ProjectsView
from exe_tow.ui.views.cmd_history_view import CommandHistoryView
from exe_tow.ui.views.build_history_view import BuildHistoryView
from exe_tow.ui.views.settings_view import SettingsView
from exe_tow.ui.workers import BuildWorker
from exe_tow.config.settings import Settings

class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("EXE/TOW — Python to Windows EXE Builder")
        self.resize(1180, 760)

        self.worker = None

        central_widget = QWidget(self)
        self.setCentralWidget(central_widget)

        main_layout = QHBoxLayout(central_widget)
        main_layout.setContentsMargins(0, 0, 0, 0)
        main_layout.setSpacing(0)

        # Sidebar
        self.sidebar = Sidebar(self)
        self.sidebar.nav_changed.connect(self._switch_view)
        main_layout.addWidget(self.sidebar)

        # Stacked Views
        self.stack = QStackedWidget(self)
        main_layout.addWidget(self.stack, stretch=1)

        # Instantiate Views
        self.views = {
            "dashboard": DashboardView(self),
            "build": BuildView(self),
            "projects": ProjectsView(self),
            "cmd_history": CommandHistoryView(self),
            "build_history": BuildHistoryView(self),
            "settings": SettingsView(self)
        }

        for key, view_widget in self.views.items():
            self.stack.addWidget(view_widget)

        # Connect Dashboard Signals
        self.views["dashboard"].select_project_requested.connect(lambda: self.sidebar._on_nav_clicked("build"))

        # Connect Build View Signals
        self.views["build"].start_build_signal.connect(self._start_build_process)
        self.views["build"].stop_build_signal.connect(self._stop_build_process)

        self._switch_view("dashboard")

    def _switch_view(self, key: str):
        if key in self.views:
            view = self.views[key]
            self.stack.setCurrentWidget(view)

            # Refresh views if they support it
            if hasattr(view, "refresh"):
                view.refresh()

    def _start_build_process(self, build_config: dict):
        if self.worker and self.worker.isRunning():
            QMessageBox.warning(self, "Warning", "A build is already running!")
            return

        self.worker = BuildWorker(build_config, self)

        build_view: BuildView = self.views["build"]

        self.worker.status_signal.connect(build_view.update_status)
        self.worker.log_signal.connect(build_view.terminal.append_log)
        self.worker.attempt_signal.connect(
            lambda exec_obj: build_view.add_attempt_indicator(
                exec_obj.retry_count, exec_obj.command_text, exec_obj.status.value
            )
        )
        self.worker.finished_signal.connect(self._on_build_finished)

        self.worker.start()

    def _stop_build_process(self):
        if self.worker and self.worker.isRunning():
            self.worker.stop()
            self.views["build"].terminal.append_log("[SYSTEM] User requested build cancellation.")

    def _on_build_finished(self, build_record):
        build_view: BuildView = self.views["build"]
        build_view.set_building_state(False)

        if build_record.status == "SUCCESS":
            if build_record.output_exe_path:
                build_view.show_build_success(build_record.output_exe_path)

            # Auto open folder if enabled in settings
            settings = Settings.load()
            if settings.open_output_after_build and build_record.output_folder:
                if os.path.exists(build_record.output_folder):
                    try:
                        if os.name == 'nt':
                            os.startfile(build_record.output_folder)
                        else:
                            subprocess.Popen(["xdg-open", build_record.output_folder])
                    except Exception:
                        pass
        else:
            QMessageBox.critical(self, "Build Failed", f"EXE/TOW build failed.\n\n{build_record.error_summary or 'All attempted build strategies failed.'}")

        # Refresh dashboard and history views
        self.views["dashboard"].refresh()
        self.views["cmd_history"].refresh()
        self.views["build_history"].refresh()
