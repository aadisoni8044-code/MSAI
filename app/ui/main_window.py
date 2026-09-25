"""Main Window controller for Kora application."""

import os
import sys
import threading
from typing import Optional
import tkinter as tk
from tkinter import filedialog, messagebox

from models.project_info import ProjectInfo
from models.build_strategy import BuildStrategy, BuildResult
from app.project_scanner.scanner import ProjectScanner
from app.configuration.manager import ConfigurationManager
from app.permission_manager.manager import PermissionManager
from app.build_engine.engine import BuildEngine
from app.output_detector.detector import OutputDetector
from app.ui.theme import ThemeManager, DARK_PALETTE
from app.ui.components import Sidebar
from app.ui.views import DashboardView, BuildView, HistoryView, LogsView, SettingsView
from app.ui.permission_dialog import PermissionDialog
from app.logger import logger


class MainWindow(tk.Tk):
    """Modern redesigned main window orchestrating layout, views, keyboard shortcuts, and build engine logic."""

    def __init__(self):
        super().__init__()
        self.title("KORA — PYTHON → EXE AUTOMATIC BUILD SYSTEM")
        self.geometry("1050x720")
        self.minsize(900, 600)

        self.theme_mgr = ThemeManager("Dark")
        self.colors = self.theme_mgr.colors
        self.configure(bg=self.colors.bg_dark)

        self.config_mgr = ConfigurationManager()
        self.settings = self.config_mgr.get_settings()
        self.permission_mgr = PermissionManager()

        self.current_project: Optional[ProjectInfo] = None
        self.build_engine: Optional[BuildEngine] = None
        self.last_build_result: Optional[BuildResult] = None
        self.is_building = False

        self._build_ui()
        self._bind_shortcuts()

    def _build_ui(self):
        # Sidebar Navigation
        self.sidebar = Sidebar(self, colors=self.colors, on_navigate=self.show_view)
        self.sidebar.pack(side=tk.LEFT, fill=tk.Y)

        # Main Workspace Stack
        self.workspace = tk.Frame(self, bg=self.colors.bg_dark)
        self.workspace.pack(side=tk.RIGHT, fill=tk.BOTH, expand=True)

        # Initialize Views
        self.views: dict = {}

        self.views["dashboard"] = DashboardView(
            self.workspace,
            colors=self.colors,
            on_select_project=self.select_project,
            on_start_build=self.start_build
        )

        self.views["build"] = BuildView(
            self.workspace,
            colors=self.colors,
            on_stop_build=self.stop_build,
            on_test_exe=self.test_generated_exe,
            on_open_folder=self.open_output_folder
        )

        self.views["history"] = HistoryView(
            self.workspace,
            colors=self.colors,
            get_history_func=self._get_build_history_data
        )

        self.views["logs"] = LogsView(self.workspace, colors=self.colors)

        self.views["settings"] = SettingsView(
            self.workspace,
            current_settings=self.settings,
            colors=self.colors,
            on_save_settings=self._on_settings_saved
        )

        self.show_view("dashboard")

    def show_view(self, view_key: str):
        for key, view in self.views.items():
            if key == view_key:
                view.pack(fill=tk.BOTH, expand=True)
            else:
                view.pack_forget()

        if view_key == "history":
            self.views["history"].refresh_history()

    def _bind_shortcuts(self):
        """Binds global keyboard shortcuts."""
        self.bind("<Control-o>", lambda e: self.select_project())
        self.bind("<Control-b>", lambda e: self.start_build())
        self.bind("<Control-l>", lambda e: self.views["build"].terminal.clear_logs())
        self.bind("<Control-Shift-C>", lambda e: self.views["build"].terminal.copy_logs())
        self.bind("<Escape>", lambda e: self.stop_build())

    def select_project(self):
        folder = filedialog.askdirectory(title="Select Python Project Folder")
        if not folder:
            return

        try:
            scanner = ProjectScanner(folder)
            self.current_project = scanner.scan()
            self.views["dashboard"].set_project(self.current_project)
            logger.info(f"Project selected: {folder}")
        except Exception as e:
            messagebox.showerror("Scan Error", f"Failed to scan project: {e}")

    def start_build(self):
        if not self.current_project:
            messagebox.showwarning("Kora", "Please select a Python project folder first.")
            return

        # Permission prompt
        perm_dialog = PermissionDialog(self)
        self.wait_window(perm_dialog)

        if not perm_dialog.granted:
            messagebox.showinfo("Kora", "Build cancelled: Permissions not granted.")
            return

        self.permission_mgr.update_permissions(perm_dialog.permissions)
        self.is_building = True

        # Switch to build view
        self.sidebar.set_active("build")
        self.views["build"].start_building()
        self.views["build"].terminal.clear_logs()

        self.build_engine = BuildEngine(
            settings=self.settings,
            permissions=self.permission_mgr.permissions
        )

        def build_worker():
            initial_strat = BuildStrategy(
                builder_name="PyInstaller",
                mode="onefile" if self.current_project.is_onefile else "onedir",
                is_gui=self.current_project.is_gui
            )

            result = self.build_engine.run_build(
                project_info=self.current_project,
                initial_strategy=initial_strat,
                on_status_update=lambda msg: self.after(0, self._on_build_status_update, msg),
                on_log_line=lambda log_msg: self.after(0, self.views["build"].terminal.append_log, log_msg),
                on_permission_needed=self._prompt_runtime_permission
            )

            self.after(0, self._on_build_finished, result)

        threading.Thread(target=build_worker, daemon=True).start()

    def _on_build_status_update(self, message: str):
        if "PyInstaller" in message:
            self.views["build"].strategy_widget.update_status("PyInstaller", "RUNNING")
            self.views["build"].pipeline_widget.set_active_stage("Builder")
        elif "Nuitka" in message:
            self.views["build"].strategy_widget.update_status("Nuitka", "RUNNING")
            self.views["build"].pipeline_widget.set_active_stage("Builder")
        elif "cx_Freeze" in message:
            self.views["build"].strategy_widget.update_status("cx_Freeze", "RUNNING")
            self.views["build"].pipeline_widget.set_active_stage("Builder")
        elif "Verifying" in message:
            self.views["build"].pipeline_widget.set_active_stage("Verify")

    def _prompt_runtime_permission(self, action_type: str, description: str) -> bool:
        res = [False]
        event = threading.Event()

        def prompt():
            res[0] = messagebox.askyesno(
                "Kora Permission Needed",
                f"Kora needs permission to perform:\n\n{description}\n\nDo you want to allow this?"
            )
            event.set()

        self.after(0, prompt)
        event.wait()
        return res[0]

    def stop_build(self):
        if self.build_engine and self.is_building:
            if messagebox.askyesno("Stop Build", "Stop the current build process?"):
                self.build_engine.cancel_build()

    def _on_build_finished(self, result: BuildResult):
        self.is_building = False
        self.last_build_result = result

        if result.status == "SUCCESS":
            self.views["build"].show_success(result)
            messagebox.showinfo("Kora Build Complete", f"Build succeeded!\n\nGenerated EXE:\n{result.output_exe}")
        else:
            self.views["build"].show_failure(result.summary_message)
            messagebox.showerror("Kora Build Failed", f"All build strategies failed.\n\n{result.summary_message}")

    def test_generated_exe(self):
        if self.last_build_result and self.last_build_result.output_exe:
            exe_path = self.last_build_result.output_exe
            detector = OutputDetector(self.current_project.project_path)
            test_res = detector.test_launch_exe(exe_path, timeout_seconds=3.0)

            if test_res.get("crashed_immediately"):
                messagebox.showerror(
                    "Launch Test Failed",
                    f"EXE crashed on launch test!\n\nMessage: {test_res.get('message')}\n\nStderr:\n{test_res.get('stderr')}"
                )
            else:
                messagebox.showinfo(
                    "Launch Test Passed",
                    f"EXE launched cleanly and ran stably!\n\nMessage: {test_res.get('message')}"
                )

    def open_output_folder(self):
        if self.last_build_result and self.last_build_result.output_exe:
            output_dir = os.path.dirname(self.last_build_result.output_exe)
            if os.path.exists(output_dir):
                if sys.platform == "win32":
                    os.startfile(output_dir)
                elif sys.platform == "darwin":
                    os.system(f"open '{output_dir}'")
                else:
                    os.system(f"xdg-open '{output_dir}'")

    def _get_build_history_data(self):
        if self.current_project:
            db = self.build_engine.db if self.build_engine else None
            if db:
                return db.get_build_history(self.current_project.project_path)
        return []

    def _on_settings_saved(self, new_settings):
        self.settings = new_settings
        self.config_mgr.save_settings(new_settings)


if __name__ == "__main__":
    app = MainWindow()
    app.mainloop()
