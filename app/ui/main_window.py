"""Main Window component for Kora GUI application."""

import os
import sys
import threading
from typing import Optional
import tkinter as tk
from tkinter import ttk, filedialog, messagebox

from models.project_info import ProjectInfo
from models.build_strategy import BuildStrategy, BuildResult
from app.project_scanner.scanner import ProjectScanner
from app.configuration.manager import ConfigurationManager
from app.permission_manager.manager import PermissionManager
from app.build_engine.engine import BuildEngine
from app.output_detector.detector import OutputDetector
from app.ui.permission_dialog import PermissionDialog
from app.ui.settings_dialog import SettingsDialog
from app.ui.terminal_view import TerminalView
from app.logger import logger


class MainWindow(tk.Tk):
    """Main Application Window for Kora Desktop Application."""

    def __init__(self):
        super().__init__()
        self.title("KORA — PYTHON → EXE AUTOMATIC BUILD SYSTEM")
        self.geometry("900x700")
        self.minsize(800, 600)

        self.config_mgr = ConfigurationManager()
        self.settings = self.config_mgr.get_settings()
        self.permission_mgr = PermissionManager()

        self.current_project: Optional[ProjectInfo] = None
        self.build_engine: Optional[BuildEngine] = None
        self.last_build_result: Optional[BuildResult] = None
        self.is_building = False

        self._configure_styles()
        self._build_ui()

    def _configure_styles(self):
        style = ttk.Style()
        style.theme_use("clam")

        # Configure custom colors
        style.configure("TFrame", background="#F8FAFC")
        style.configure("TLabel", background="#F8FAFC", foreground="#0F172A", font=("Segoe UI", 9))
        style.configure("Header.TLabel", font=("Segoe UI", 16, "bold"), foreground="#4F46E5")
        style.configure("SubHeader.TLabel", font=("Segoe UI", 10, "bold"), foreground="#334155")
        style.configure("Status.TLabel", font=("Segoe UI", 10), foreground="#4F46E5")
        style.configure("Action.TButton", font=("Segoe UI", 10, "bold"), background="#4F46E5", foreground="#FFFFFF")
        style.map("Action.TButton", background=[("active", "#4338CA")])

    def _build_ui(self):
        # Top Header Bar
        header_frame = ttk.Frame(self, padding="15 15 15 10")
        header_frame.pack(fill=tk.X)

        title_lbl = ttk.Label(header_frame, text="KORA", style="Header.TLabel")
        title_lbl.pack(side=tk.LEFT)

        subtitle_lbl = ttk.Label(header_frame, text="  |  PYTHON → EXE AUTOMATIC BUILD SYSTEM", style="SubHeader.TLabel")
        subtitle_lbl.pack(side=tk.LEFT, pady=(4, 0))

        btn_settings = ttk.Button(header_frame, text="⚙ Settings", command=self.open_settings)
        btn_settings.pack(side=tk.RIGHT)

        ttk.Separator(self, orient=tk.HORIZONTAL).pack(fill=tk.X, padx=15)

        # Main Workspace
        workspace = ttk.Frame(self, padding="15 10 15 10")
        workspace.pack(fill=tk.BOTH, expand=True)

        # Top Project Selector Card
        project_card = ttk.LabelFrame(workspace, text=" 1. Project Selection ", padding="15 10 15 10")
        project_card.pack(fill=tk.X, pady=(0, 10))

        btn_select = ttk.Button(project_card, text="Select Python Project", command=self.select_project)
        btn_select.pack(side=tk.LEFT, padx=(0, 10))

        self.lbl_project_path = ttk.Label(project_card, text="No project folder selected", font=("Segoe UI", 9, "italic"))
        self.lbl_project_path.pack(side=tk.LEFT, fill=tk.X, expand=True)

        # Middle Summary & Config Card
        self.summary_card = ttk.LabelFrame(workspace, text=" 2. Project Analysis & Configuration ", padding="15 10 15 10")
        self.summary_card.pack(fill=tk.X, pady=(0, 10))

        # Config Grid
        grid = ttk.Frame(self.summary_card)
        grid.pack(fill=tk.X, pady=5)

        ttk.Label(grid, text="Main Entry File:").grid(row=0, column=0, sticky="w", pady=4, padx=5)
        self.combo_entry = ttk.Combobox(grid, state="readonly", width=35)
        self.combo_entry.grid(row=0, column=1, sticky="w", pady=4, padx=5)
        self.combo_entry.bind("<<ComboboxSelected>>", self._on_entry_changed)

        ttk.Label(grid, text="Package Mode:").grid(row=0, column=2, sticky="w", pady=4, padx=5)
        self.var_onefile = tk.BooleanVar(value=True)
        rb_onefile = ttk.Radiobutton(grid, text="One File EXE", variable=self.var_onefile, value=True)
        rb_onedir = ttk.Radiobutton(grid, text="One Directory", variable=self.var_onefile, value=False)
        rb_onefile.grid(row=0, column=3, sticky="w", pady=4)
        rb_onedir.grid(row=0, column=4, sticky="w", pady=4, padx=(5, 0))

        ttk.Label(grid, text="App Type:").grid(row=1, column=0, sticky="w", pady=4, padx=5)
        self.var_gui = tk.BooleanVar(value=False)
        rb_console = ttk.Radiobutton(grid, text="Console App", variable=self.var_gui, value=False)
        rb_gui = ttk.Radiobutton(grid, text="GUI App", variable=self.var_gui, value=True)
        rb_console.grid(row=1, column=1, sticky="w", pady=4, padx=5)
        rb_gui.grid(row=1, column=1, sticky="w", pady=4, padx=(110, 0))

        # Checklist summary frame
        self.frame_checklist = ttk.Frame(self.summary_card)
        self.frame_checklist.pack(fill=tk.X, pady=(5, 0))
        self.lbl_check_py = ttk.Label(self.frame_checklist, text="• Select a project folder to scan python structure")
        self.lbl_check_py.pack(anchor="w")

        # Build Action Button Box
        action_box = ttk.Frame(workspace)
        action_box.pack(fill=tk.X, pady=(0, 10))

        self.btn_build = ttk.Button(action_box, text="BUILD EXE", style="Action.TButton", command=self.start_build)
        self.btn_build.pack(side=tk.LEFT, padx=(0, 10), ipadx=15, ipady=5)

        self.btn_stop = ttk.Button(action_box, text="Stop Build", command=self.stop_build, state=tk.DISABLED)
        self.btn_stop.pack(side=tk.LEFT, padx=5, ipady=5)

        self.lbl_status = ttk.Label(action_box, text="Ready", style="Status.TLabel")
        self.lbl_status.pack(side=tk.LEFT, padx=15)

        # Terminal & Build Logs Panel
        self.terminal = TerminalView(workspace)
        self.terminal.pack(fill=tk.BOTH, expand=True, pady=(0, 10))

        # Output Action Footer Bar
        footer = ttk.Frame(workspace)
        footer.pack(fill=tk.X)

        self.lbl_output_file = ttk.Label(footer, text="Output: N/A", font=("Segoe UI", 9, "bold"))
        self.lbl_output_file.pack(side=tk.LEFT)

        self.btn_open_folder = ttk.Button(footer, text="Open Folder", command=self.open_output_folder, state=tk.DISABLED)
        self.btn_open_folder.pack(side=tk.RIGHT, padx=2)

        self.btn_test_exe = ttk.Button(footer, text="Test EXE", command=self.test_generated_exe, state=tk.DISABLED)
        self.btn_test_exe.pack(side=tk.RIGHT, padx=2)

        self.btn_report = ttk.Button(footer, text="Save Report", command=self.save_error_report, state=tk.DISABLED)
        self.btn_report.pack(side=tk.RIGHT, padx=2)

    def select_project(self):
        """Opens directory picker and scans selected Python project."""
        folder = filedialog.askdirectory(title="Select Python Project Folder")
        if not folder:
            return

        self.lbl_project_path.config(text=os.path.abspath(folder))
        self.terminal.clear_logs()
        self.terminal.append_log(f"Selected project directory: {folder}")
        self.terminal.append_log("Scanning project structure...")

        try:
            scanner = ProjectScanner(folder)
            self.current_project = scanner.scan()

            # Update entry points combobox
            self.combo_entry.config(values=self.current_project.entry_point_candidates)
            if self.current_project.selected_entry_point:
                self.combo_entry.set(self.current_project.selected_entry_point)

            # Update checklist summary UI
            for widget in self.frame_checklist.winfo_children():
                widget.destroy()

            ttk.Label(
                self.frame_checklist,
                text=f"✓ Python files detected: {len(self.current_project.python_files)}"
            ).pack(anchor="w")

            ttk.Label(
                self.frame_checklist,
                text=f"✓ Config files detected: {', '.join(self.current_project.config_files) or 'None'}"
            ).pack(anchor="w")

            ttk.Label(
                self.frame_checklist,
                text=f"✓ Virtual Environment: {self.current_project.venv_path or 'None (System Python)'}"
            ).pack(anchor="w")

            ttk.Label(
                self.frame_checklist,
                text=f"✓ Assets detected: {len(self.current_project.detected_assets)} files"
            ).pack(anchor="w")

            self.lbl_status.config(text="Project scanned successfully.")
            self.terminal.append_log(f"Scan complete. Found {len(self.current_project.python_files)} Python files.")

        except Exception as e:
            messagebox.showerror("Scan Error", f"Failed to scan project: {e}")
            self.lbl_status.config(text="Scan failed.")

    def _on_entry_changed(self, event):
        if self.current_project:
            self.current_project.selected_entry_point = self.combo_entry.get()

    def start_build(self):
        """Starts the automated build process in a background thread."""
        if not self.current_project:
            messagebox.showwarning("Kora", "Please select a Python project folder first.")
            return

        if not self.combo_entry.get():
            messagebox.showwarning("Kora", "Please select a main Python entry point file.")
            return

        self.current_project.selected_entry_point = self.combo_entry.get()
        self.current_project.is_onefile = self.var_onefile.get()
        self.current_project.is_gui = self.var_gui.get()

        # Show permission dialog
        perm_dialog = PermissionDialog(self)
        self.wait_window(perm_dialog)

        if not perm_dialog.granted:
            self.terminal.append_log("Build cancelled: Permissions not granted.")
            return

        self.permission_mgr.update_permissions(perm_dialog.permissions)

        # Prepare UI state for building
        self.is_building = True
        self.btn_build.config(state=tk.DISABLED)
        self.btn_stop.config(state=tk.NORMAL)
        self.btn_open_folder.config(state=tk.DISABLED)
        self.btn_test_exe.config(state=tk.DISABLED)
        self.btn_report.config(state=tk.DISABLED)
        self.lbl_output_file.config(text="Output: Building...")

        self.terminal.append_log("\n" + "="*50)
        self.terminal.append_log("Starting Kora Automated Build...")

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
                on_status_update=lambda msg: self.after(0, self._update_status, msg),
                on_log_line=lambda log_msg: self.after(0, self.terminal.append_log, log_msg),
                on_permission_needed=self._prompt_runtime_permission
            )

            self.after(0, self._on_build_finished, result)

        threading.Thread(target=build_worker, daemon=True).start()

    def _prompt_runtime_permission(self, action_type: str, description: str) -> bool:
        """Prompts user on main thread if runtime permission for an action/fix is needed."""
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
        """Cancels running build process."""
        if self.build_engine and self.is_building:
            if messagebox.askyesno("Stop Build", "Stop the current build process?"):
                self.terminal.append_log("\n[USER REQUEST] Stopping build process...")
                self.build_engine.cancel_build()
                self.btn_stop.config(state=tk.DISABLED)

    def _update_status(self, message: str):
        self.lbl_status.config(text=message)

    def _on_build_finished(self, result: BuildResult):
        self.is_building = False
        self.last_build_result = result
        self.btn_build.config(state=tk.NORMAL)
        self.btn_stop.config(state=tk.DISABLED)
        self.btn_report.config(state=tk.NORMAL)

        if result.status == "SUCCESS" and result.output_exe:
            self.lbl_status.config(text="SUCCESS ✓")
            self.lbl_output_file.config(text=f"Output: {result.output_exe}")
            self.btn_open_folder.config(state=tk.NORMAL)
            self.btn_test_exe.config(state=tk.NORMAL)
            messagebox.showinfo("Kora Build Completed", f"Build succeeded!\n\nGenerated EXE:\n{result.output_exe}")
        elif result.status == "CANCELLED":
            self.lbl_status.config(text="BUILD CANCELLED")
            self.lbl_output_file.config(text="Output: Cancelled")
        else:
            self.lbl_status.config(text="BUILD FAILED ❌")
            self.lbl_output_file.config(text="Output: Build Failed")
            messagebox.showerror("Kora Build Failed", f"All build strategies failed.\n\n{result.summary_message}")

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

    def save_error_report(self):
        if not self.last_build_result:
            return

        file_path = filedialog.asksaveasfilename(
            defaultextension=".txt",
            filetypes=[("Text Report", "*.txt"), ("All Files", "*.*")],
            initialfile=f"{self.current_project.project_name if self.current_project else 'kora'}_build_report.txt"
        )
        if file_path:
            try:
                res = self.last_build_result
                report_lines = [
                    "==========================================",
                    "           KORA BUILD REPORT              ",
                    "==========================================",
                    f"Project: {self.current_project.project_name if self.current_project else 'N/A'}",
                    f"Path: {res.project_path}",
                    f"Status: {res.status}",
                    f"Output EXE: {res.output_exe or 'None'}",
                    f"Total Duration: {round(res.total_duration, 2)}s",
                    f"Attempts Total: {len(res.attempts)}",
                    "------------------------------------------",
                    "ATTEMPTS SUMMARY:",
                ]
                for att in res.attempts:
                    report_lines.append(
                        f"Attempt #{att.attempt_number} [{att.builder_name}] -> {att.status} "
                        f"(Error: {att.error_type or 'None'})"
                    )
                report_lines.append("==========================================")
                report_lines.append("\nFULL LOGS:\n")
                report_lines.append(self.terminal.get_logs())

                with open(file_path, "w", encoding="utf-8") as f:
                    f.write("\n".join(report_lines))
                messagebox.showinfo("Kora", f"Build report saved to {file_path}")
            except Exception as e:
                messagebox.showerror("Kora", f"Failed to save report: {e}")

    def open_settings(self):
        dlg = SettingsDialog(self, self.settings)
        self.wait_window(dlg)
        if dlg.saved_settings:
            self.settings = dlg.saved_settings
            self.config_mgr.save_settings(self.settings)
            messagebox.showinfo("Kora", "Settings saved successfully.")


if __name__ == "__main__":
    app = MainWindow()
    app.mainloop()
