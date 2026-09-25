"""Settings Dialog component for Kora GUI."""

import tkinter as tk
from tkinter import ttk
from models.settings import Settings


class SettingsDialog(tk.Toplevel):
    """Dialog for configuring Kora preferences."""

    def __init__(self, parent, current_settings: Settings):
        super().__init__(parent)
        self.title("Kora — Settings")
        self.geometry("450x420")
        self.resizable(False, False)
        self.transient(parent)
        self.grab_set()

        self.settings = current_settings
        self.saved_settings = None

        self._build_ui()

    def _build_ui(self):
        frame = ttk.Frame(self, padding="20 20 20 20")
        frame.pack(fill=tk.BOTH, expand=True)

        # Python Interpreter
        ttk.Label(frame, text="Python Interpreter:").pack(anchor="w", pady=(0, 2))
        self.entry_python = ttk.Entry(frame)
        self.entry_python.insert(0, self.settings.python_interpreter)
        self.entry_python.pack(fill=tk.X, pady=(0, 10))

        # Default Output Dir
        ttk.Label(frame, text="Default Output Directory:").pack(anchor="w", pady=(0, 2))
        self.entry_output = ttk.Entry(frame)
        self.entry_output.insert(0, self.settings.default_output_dir)
        self.entry_output.pack(fill=tk.X, pady=(0, 10))

        # Max Attempts
        ttk.Label(frame, text="Maximum Build Attempts:").pack(anchor="w", pady=(0, 2))
        self.spin_attempts = ttk.Spinbox(frame, from_=1, to=10)
        self.spin_attempts.set(self.settings.max_build_attempts)
        self.spin_attempts.pack(fill=tk.X, pady=(0, 10))

        # Checkboxes
        self.var_auto_dep = tk.BooleanVar(value=self.settings.auto_install_dependencies)
        ttk.Checkbutton(frame, text="Automatic Dependency Installation", variable=self.var_auto_dep).pack(anchor="w", pady=4)

        self.var_auto_fix = tk.BooleanVar(value=self.settings.auto_safe_fixes)
        ttk.Checkbutton(frame, text="Automatic Safe Fixes", variable=self.var_auto_fix).pack(anchor="w", pady=4)

        self.var_remember = tk.BooleanVar(value=self.settings.remember_successful_strategy)
        ttk.Checkbutton(frame, text="Remember Successful Strategy per Project", variable=self.var_remember).pack(anchor="w", pady=4)

        self.var_keep_logs = tk.BooleanVar(value=self.settings.keep_build_logs)
        ttk.Checkbutton(frame, text="Keep Build Logs on Disk", variable=self.var_keep_logs).pack(anchor="w", pady=4)

        # Buttons
        btn_box = ttk.Frame(frame)
        btn_box.pack(fill=tk.X, side=tk.BOTTOM, pady=(15, 0))

        ttk.Button(btn_box, text="Save Settings", command=self._on_save).pack(side=tk.RIGHT, padx=5)
        ttk.Button(btn_box, text="Cancel", command=self.destroy).pack(side=tk.RIGHT, padx=5)

    def _on_save(self):
        try:
            max_att = int(self.spin_attempts.get())
        except ValueError:
            max_att = 5

        self.saved_settings = Settings(
            python_interpreter=self.entry_python.get().strip() or "python",
            default_output_dir=self.entry_output.get().strip() or "dist",
            max_build_attempts=max_att,
            auto_install_dependencies=self.var_auto_dep.get(),
            auto_safe_fixes=self.var_auto_fix.get(),
            remember_successful_strategy=self.var_remember.get(),
            keep_build_logs=self.var_keep_logs.get()
        )
        self.destroy()
