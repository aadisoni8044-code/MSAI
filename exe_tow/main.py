import os
import sys
from PySide6.QtWidgets import QApplication
from exe_tow.ui.main_window import MainWindow
from exe_tow.ui.views.build_view import BuildView
from exe_tow.ui.views.projects_view import ProjectsView
from exe_tow.ui.views.history_view import HistoryView


class ExeTowApp(MainWindow):
    """Integrated Application for exe/tow."""

    def __init__(self, parent=None):
        super().__init__(parent)

        # Create child views
        self.build_view = BuildView(self.history_manager, self)
        self.projects_view = ProjectsView(self.history_manager, self)
        self.history_view = HistoryView(self.history_manager, self)

        # Add to view stack
        self.view_stack.addWidget(self.build_view)     # Index 1
        self.view_stack.addWidget(self.projects_view)  # Index 2
        self.view_stack.addWidget(self.history_view)   # Index 3

        # Connect signals across views
        self.build_view.build_status_changed.connect(self.set_status_badge)
        self.build_view.project_changed.connect(self._on_project_data_changed)

        self.projects_view.open_project_requested.connect(self._on_open_project)
        self.projects_view.build_project_requested.connect(self._on_build_project)

    def _on_project_data_changed(self):
        self.dashboard_view.refresh_stats()
        self.projects_view.refresh_projects()
        self.history_view.refresh_history()

    def _on_open_project(self, project_path: str):
        if project_path:
            self.build_view.set_project_path(project_path)
            self.set_active_nav("build")

    def _on_build_project(self, project_path: str):
        if project_path:
            self.build_view.set_project_path(project_path)
        self.set_active_nav("build")


def main():
    app = QApplication(sys.argv)
    window = ExeTowApp()
    window.show()
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
