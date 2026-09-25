"""Settings View for Kora UI."""

import tkinter as tk
from tkinter import ttk, messagebox
from typing import Callable, Optional
from models.settings import Settings
from app.ui.theme import ColorPalette, DARK_PALETTE
from app.ui.components import Card


class SettingsView(tk.Frame):
    """Modern categorized Settings view for Kora preferences."""

    def __init__(
        self,
        parent,
        current_settings: Settings,
        colors: ColorPalette = DARK_PALETTE,
        on_save_settings: Optional[Callable[[Settings], None]] = None
    ):
        super().__init__(parent, bg=colors.bg_dark)
        self.colors = colors
        self.settings = current_settings
        self.on_save_settings = on_save_settings

        self._build_ui()

    def _build_ui(self):
        header = tk.Frame(self, bg=self.colors.bg_dark)
        header.pack(fill=tk.X, padx=25, pady=(20, 15))

        lbl_title = tk.Label(
            header,
            text="Settings",
            font=("Segoe UI", 16, "bold"),
            fg=self.colors.text_primary,
            bg=self.colors.bg_dark
        )
        lbl_title.pack(side=tk.LEFT)

        btn_save = tk.Button(
            header,
            text="Save Settings",
            font=("Segoe UI", 9, "bold"),
            fg="#FFFFFF",
            bg=self.colors.primary,
            activebackground=self.colors.primary_hover,
            bd=0,
            padx=15,
            pady=6,
            cursor="hand2",
            command=self._on_save_clicked
        )
        btn_save.pack(side=tk.RIGHT)

        card = Card(self, colors=self.colors, padding=20)
        card.pack(fill=tk.BOTH, expand=True, padx=25, pady=10)

        grid = tk.Frame(card.inner_frame, bg=self.colors.card_bg)
        grid.pack(fill=tk.X)

        # Python Interpreter
        tk.Label(grid, text="Python Interpreter Path:", font=("Segoe UI", 9, "bold"), fg=self.colors.text_primary, bg=self.colors.card_bg).grid(row=0, column=0, sticky="w", pady=8)
        self.entry_python = tk.Entry(grid, bg=self.colors.input_bg, fg=self.colors.text_primary, insertbackground="#FFFFFF", bd=1, relief=tk.FLAT, font=("Segoe UI", 9), width=45)
        self.entry_python.insert(0, self.settings.python_interpreter)
        self.entry_python.grid(row=0, column=1, sticky="w", padx=15, pady=8)

        # Output Dir
        tk.Label(grid, text="Default Output Directory:", font=("Segoe UI", 9, "bold"), fg=self.colors.text_primary, bg=self.colors.card_bg).grid(row=1, column=0, sticky="w", pady=8)
        self.entry_output = tk.Entry(grid, bg=self.colors.input_bg, fg=self.colors.text_primary, insertbackground="#FFFFFF", bd=1, relief=tk.FLAT, font=("Segoe UI", 9), width=45)
        self.entry_output.insert(0, self.settings.default_output_dir)
        self.entry_output.grid(row=1, column=1, sticky="w", padx=15, pady=8)

        # Max Attempts
        tk.Label(grid, text="Max Automatic Attempts:", font=("Segoe UI", 9, "bold"), fg=self.colors.text_primary, bg=self.colors.card_bg).grid(row=2, column=0, sticky="w", pady=8)
        self.entry_attempts = tk.Spinbox(grid, from_=1, to=10, bg=self.colors.input_bg, fg=self.colors.text_primary, bd=1, relief=tk.FLAT, font=("Segoe UI", 9), width=10)
        self.entry_attempts.delete(0, tk.END)
        self.entry_attempts.insert(0, str(self.settings.max_build_attempts))
        self.entry_attempts.grid(row=2, column=1, sticky="w", padx=15, pady=8)

        # Checkboxes
        self.var_auto_dep = tk.BooleanVar(value=self.settings.auto_install_dependencies)
        cb1 = tk.Checkbutton(grid, text="Automatic Dependency Installation", variable=self.var_auto_dep, font=("Segoe UI", 9), fg=self.colors.text_primary, bg=self.colors.card_bg, activebackground=self.colors.card_bg, activeforeground=self.colors.text_primary, selectcolor=self.colors.card_elevated)
        cb1.grid(row=3, column=0, columnspan=2, sticky="w", pady=6)

        self.var_auto_fix = tk.BooleanVar(value=self.settings.auto_safe_fixes)
        cb2 = tk.Checkbutton(grid, text="Automatic Safe Fixes", variable=self.var_auto_fix, font=("Segoe UI", 9), fg=self.colors.text_primary, bg=self.colors.card_bg, activebackground=self.colors.card_bg, activeforeground=self.colors.text_primary, selectcolor=self.colors.card_elevated)
        cb2.grid(row=4, column=0, columnspan=2, sticky="w", pady=6)

        self.var_remember = tk.BooleanVar(value=self.settings.remember_successful_strategy)
        cb3 = tk.Checkbutton(grid, text="Remember Successful Build Strategy per Project", variable=self.var_remember, font=("Segoe UI", 9), fg=self.colors.text_primary, bg=self.colors.card_bg, activebackground=self.colors.card_bg, activeforeground=self.colors.text_primary, selectcolor=self.colors.card_elevated)
        cb3.grid(row=5, column=0, columnspan=2, sticky="w", pady=6)

    def _on_save_clicked(self):
        try:
            max_att = int(self.entry_attempts.get())
        except ValueError:
            max_att = 5

        new_settings = Settings(
            python_interpreter=self.entry_python.get().strip() or "python",
            default_output_dir=self.entry_output.get().strip() or "dist",
            max_build_attempts=max_att,
            auto_install_dependencies=self.var_auto_dep.get(),
            auto_safe_fixes=self.var_auto_fix.get(),
            remember_successful_strategy=self.var_remember.get(),
            keep_build_logs=self.settings.keep_build_logs
        )
        if self.on_save_settings:
            self.on_save_settings(new_settings)
        messagebox.showinfo("Kora Settings", "Settings saved successfully.")
