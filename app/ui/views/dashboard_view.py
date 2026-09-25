"""Dashboard View for Kora UI."""

import os
import tkinter as tk
from tkinter import ttk, filedialog
from typing import Callable, Optional
from models.project_info import ProjectInfo
from app.ui.theme import ColorPalette, DARK_PALETTE
from app.ui.components import Card, RadioCardGroup


class DashboardView(tk.Frame):
    """Dashboard view showcasing project selection, AST analysis summary, build settings, and primary build button."""

    def __init__(
        self,
        parent,
        colors: ColorPalette = DARK_PALETTE,
        on_select_project: Optional[Callable[[], None]] = None,
        on_start_build: Optional[Callable[[], None]] = None
    ):
        super().__init__(parent, bg=colors.bg_dark)
        self.colors = colors
        self.on_select_project = on_select_project
        self.on_start_build = on_start_build

        self.current_project: Optional[ProjectInfo] = None
        self._build_ui()

    def _build_ui(self):
        # Header Greeting
        header = tk.Frame(self, bg=self.colors.bg_dark)
        header.pack(fill=tk.X, padx=25, pady=(20, 15))

        lbl_greet = tk.Label(
            header,
            text="Build Python Application",
            font=("Segoe UI", 18, "bold"),
            fg=self.colors.text_primary,
            bg=self.colors.bg_dark
        )
        lbl_greet.pack(anchor="w")

        lbl_sub = tk.Label(
            header,
            text="Select a Python project to analyze dependencies and compile into a standalone Windows executable.",
            font=("Segoe UI", 10),
            fg=self.colors.text_secondary,
            bg=self.colors.bg_dark
        )
        lbl_sub.pack(anchor="w", pady=(2, 0))

        # Project Selection Card
        self.project_card = Card(self, colors=self.colors, padding=20)
        self.project_card.pack(fill=tk.X, padx=25, pady=10)

        self._render_empty_project_card()

        # Config Card
        self.config_card = Card(self, colors=self.colors, padding=20)
        self.config_card.pack(fill=tk.X, padx=25, pady=10)
        self._render_config_section()

        # Build Action Area
        action_frame = tk.Frame(self, bg=self.colors.bg_dark)
        action_frame.pack(fill=tk.X, padx=25, pady=15)

        self.btn_build = tk.Button(
            action_frame,
            text="⚡  BUILD EXE",
            font=("Segoe UI", 12, "bold"),
            fg="#FFFFFF",
            bg=self.colors.primary,
            activebackground=self.colors.primary_hover,
            activeforeground="#FFFFFF",
            bd=0,
            padx=25,
            pady=12,
            cursor="hand2",
            state=tk.DISABLED,
            command=self._on_build_clicked
        )
        self.btn_build.pack(side=tk.LEFT)

        self.lbl_status = tk.Label(
            action_frame,
            text="● Ready to build",
            font=("Segoe UI", 10),
            fg=self.colors.text_secondary,
            bg=self.colors.bg_dark
        )
        self.lbl_status.pack(side=tk.LEFT, padx=20)

    def _render_empty_project_card(self):
        for child in self.project_card.inner_frame.winfo_children():
            child.destroy()

        lbl_title = tk.Label(
            self.project_card.inner_frame,
            text="PROJECT SELECTION",
            font=("Segoe UI", 9, "bold"),
            fg=self.colors.text_secondary,
            bg=self.colors.card_bg
        )
        lbl_title.pack(anchor="w")

        lbl_desc = tk.Label(
            self.project_card.inner_frame,
            text="No project selected. Select a Python project directory to begin analysis.",
            font=("Segoe UI", 10),
            fg=self.colors.text_primary,
            bg=self.colors.card_bg
        )
        lbl_desc.pack(anchor="w", pady=(8, 12))

        btn_sel = tk.Button(
            self.project_card.inner_frame,
            text="Select Python Project",
            font=("Segoe UI", 9, "bold"),
            fg="#FFFFFF",
            bg=self.colors.primary,
            activebackground=self.colors.primary_hover,
            activeforeground="#FFFFFF",
            bd=0,
            padx=15,
            pady=8,
            cursor="hand2",
            command=self._on_select_clicked
        )
        btn_sel.pack(anchor="w")

    def set_project(self, project_info: ProjectInfo):
        self.current_project = project_info
        for child in self.project_card.inner_frame.winfo_children():
            child.destroy()

        # Title
        hdr = tk.Frame(self.project_card.inner_frame, bg=self.colors.card_bg)
        hdr.pack(fill=tk.X)

        tk.Label(hdr, text=project_info.project_name, font=("Segoe UI", 14, "bold"), fg=self.colors.text_primary, bg=self.colors.card_bg).pack(side=tk.LEFT)
        btn_chg = tk.Button(
            hdr,
            text="Change Project",
            font=("Segoe UI", 8, "bold"),
            fg=self.colors.text_secondary,
            bg=self.colors.card_elevated,
            activebackground=self.colors.card_border,
            bd=0,
            padx=10,
            pady=4,
            cursor="hand2",
            command=self._on_select_clicked
        )
        btn_chg.pack(side=tk.RIGHT)

        tk.Label(
            self.project_card.inner_frame,
            text=project_info.project_path,
            font=("Segoe UI", 9),
            fg=self.colors.text_secondary,
            bg=self.colors.card_bg
        ).pack(anchor="w", pady=(2, 10))

        # Analysis grid
        grid = tk.Frame(self.project_card.inner_frame, bg=self.colors.card_bg)
        grid.pack(fill=tk.X, pady=5)

        checks = [
            ("✓ Python files detected", f"{len(project_info.python_files)} files"),
            ("✓ Configuration files", f"{', '.join(project_info.config_files) or 'None'}"),
            ("✓ Virtual environment", f"{os.path.basename(project_info.venv_path) if project_info.venv_path else 'System Python'}"),
            ("✓ External assets detected", f"{len(project_info.detected_assets)} files")
        ]

        for i, (label, val) in enumerate(checks):
            col = i % 2
            row = i // 2
            f = tk.Frame(grid, bg=self.colors.card_bg)
            f.grid(row=row, column=col, sticky="w", padx=10, pady=4)
            tk.Label(f, text=label, font=("Segoe UI", 9, "bold"), fg=self.colors.success, bg=self.colors.card_bg).pack(side=tk.LEFT)
            tk.Label(f, text=f" : {val}", font=("Segoe UI", 9), fg=self.colors.text_primary, bg=self.colors.card_bg).pack(side=tk.LEFT)

        # Update combo entry values
        self.combo_entry['values'] = project_info.entry_point_candidates
        if project_info.selected_entry_point:
            self.combo_entry.set(project_info.selected_entry_point)

        self.btn_build.config(state=tk.NORMAL)
        self.lbl_status.config(text="● Project analyzed and ready to build", fg=self.colors.success)

    def _render_config_section(self):
        lbl_title = tk.Label(
            self.config_card.inner_frame,
            text="BUILD CONFIGURATION",
            font=("Segoe UI", 9, "bold"),
            fg=self.colors.text_secondary,
            bg=self.colors.card_bg
        )
        lbl_title.pack(anchor="w", pady=(0, 10))

        grid = tk.Frame(self.config_card.inner_frame, bg=self.colors.card_bg)
        grid.pack(fill=tk.X)

        # Entry Point
        tk.Label(grid, text="Main Entry Point File:", font=("Segoe UI", 9, "bold"), fg=self.colors.text_primary, bg=self.colors.card_bg).grid(row=0, column=0, sticky="w", pady=5)
        self.combo_entry = ttk.Combobox(grid, state="readonly", width=35)
        self.combo_entry.grid(row=0, column=1, sticky="w", padx=10, pady=5)

        # Package Mode Cards
        tk.Label(grid, text="Output Package Mode:", font=("Segoe UI", 9, "bold"), fg=self.colors.text_primary, bg=self.colors.card_bg).grid(row=1, column=0, sticky="w", pady=10)
        self.mode_group = RadioCardGroup(
            grid,
            options=[
                ("onefile", "One File EXE", "Single standalone executable"),
                ("onedir", "One Directory", "EXE folder with dependencies")
            ],
            initial_value="onefile",
            colors=self.colors
        )
        self.mode_group.grid(row=1, column=1, sticky="w", padx=10, pady=10)

        # App Type Cards
        tk.Label(grid, text="Application Type:", font=("Segoe UI", 9, "bold"), fg=self.colors.text_primary, bg=self.colors.card_bg).grid(row=2, column=0, sticky="w", pady=5)
        self.app_type_group = RadioCardGroup(
            grid,
            options=[
                ("console", "Console Application", "Displays terminal window"),
                ("gui", "GUI Application", "Hides terminal window")
            ],
            initial_value="console",
            colors=self.colors
        )
        self.app_type_group.grid(row=2, column=1, sticky="w", padx=10, pady=5)

    def _on_select_clicked(self):
        if self.on_select_project:
            self.on_select_project()

    def _on_build_clicked(self):
        if self.current_project:
            self.current_project.selected_entry_point = self.combo_entry.get()
            self.current_project.is_onefile = (self.mode_group.value == "onefile")
            self.current_project.is_gui = (self.app_type_group.value == "gui")
            if self.on_start_build:
                self.on_start_build()
