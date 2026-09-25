"""Permission Dialog component for Kora GUI."""

import tkinter as tk
from tkinter import ttk
from models.settings import PermissionRequest


class PermissionDialog(tk.Toplevel):
    """Dialog prompting user to grant build permissions."""

    def __init__(self, parent, initial_permissions: PermissionRequest = None):
        super().__init__(parent)
        self.title("Kora — Permissions Required")
        self.geometry("480x380")
        self.resizable(False, False)
        self.transient(parent)
        self.grab_set()

        self.permissions = initial_permissions or PermissionRequest()
        self.granted = False

        self._build_ui()

    def _build_ui(self):
        frame = ttk.Frame(self, padding="20 20 20 20")
        frame.pack(fill=tk.BOTH, expand=True)

        header = ttk.Label(
            frame,
            text="Kora needs permission to execute build commands for the selected project.",
            font=("Segoe UI", 10, "bold"),
            wraplength=440,
            justify="left"
        )
        header.pack(anchor="w", pady=(0, 15))

        # Checkbuttons
        self.var_folder = tk.BooleanVar(value=self.permissions.folder_access)
        cb_folder = ttk.Checkbutton(frame, text="Project folder access", variable=self.var_folder)
        cb_folder.pack(anchor="w", pady=4)

        self.var_cmd = tk.BooleanVar(value=self.permissions.execute_commands)
        cb_cmd = ttk.Checkbutton(frame, text="Execute build commands", variable=self.var_cmd)
        cb_cmd.pack(anchor="w", pady=4)

        self.var_files = tk.BooleanVar(value=self.permissions.create_files)
        cb_files = ttk.Checkbutton(frame, text="Create files inside project / output directory", variable=self.var_files)
        cb_files.pack(anchor="w", pady=4)

        self.var_pkg = tk.BooleanVar(value=self.permissions.install_packages)
        cb_pkg = ttk.Checkbutton(frame, text="Install Python packages into virtual environment", variable=self.var_pkg)
        cb_pkg.pack(anchor="w", pady=4)

        self.var_net = tk.BooleanVar(value=self.permissions.internet_access)
        cb_net = ttk.Checkbutton(frame, text="Internet access for package installation, if required", variable=self.var_net)
        cb_net.pack(anchor="w", pady=4)

        # Safety note
        note = ttk.Label(
            frame,
            text="Safety Guarantee: Kora will never modify Windows system files, change registry settings, or execute arbitrary downloaded code.",
            font=("Segoe UI", 8, "italic"),
            foreground="#555555",
            wraplength=440,
            justify="left"
        )
        note.pack(anchor="w", pady=(15, 15))

        # Buttons
        btn_box = ttk.Frame(frame)
        btn_box.pack(fill=tk.X, side=tk.BOTTOM)

        btn_allow = ttk.Button(btn_box, text="Allow Build", command=self._on_allow)
        btn_allow.pack(side=tk.RIGHT, padx=5)

        btn_deny = ttk.Button(btn_box, text="Deny / Cancel", command=self._on_deny)
        btn_deny.pack(side=tk.RIGHT, padx=5)

    def _on_allow(self):
        self.permissions = PermissionRequest(
            folder_access=self.var_folder.get(),
            execute_commands=self.var_cmd.get(),
            create_files=self.var_files.get(),
            install_packages=self.var_pkg.get(),
            internet_access=self.var_net.get()
        )
        self.granted = True
        self.destroy()

    def _on_deny(self):
        self.granted = False
        self.destroy()
