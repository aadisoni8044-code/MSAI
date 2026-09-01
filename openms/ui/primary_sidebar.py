"""
Primary Sidebar Container Component
"""

import tkinter as tk
from openms.ui.file_tree import FileTreeExplorer
from openms.config import THEMES


class PrimarySidebar(tk.Frame):
    """VS Code Collapsible Primary Sidebar containing tabbed views."""

    def __init__(self, parent, theme_manager, on_file_open_cb=None, on_run_code_cb=None):
        self.theme_manager = theme_manager
        theme = theme_manager.theme
        super().__init__(parent, bg=theme["bg_sidebar"], width=260)
        self.pack_propagate(False)

        self.on_file_open = on_file_open_cb
        self.on_run_code = on_run_code_cb
        self.views = {}
        self.active_view = "explorer"

        self.theme_manager.register(self.apply_theme)
        self._build_views()

    def _build_views(self):
        # View 1: Explorer
        self.file_tree = FileTreeExplorer(
            self, self.theme_manager, on_file_open_cb=self.on_file_open
        )
        self.views["explorer"] = self.file_tree

        # View 2: Search View
        search_frame = tk.Frame(self, bg=self.theme_manager.theme["bg_sidebar"])
        tk.Label(
            search_frame,
            text="SEARCH",
            font=("Segoe UI", 9, "bold"),
            bg=self.theme_manager.theme["bg_sidebar"],
            fg=self.theme_manager.theme["fg_sidebar"],
        ).pack(anchor="w", padx=10, pady=8)

        search_entry = tk.Entry(
            search_frame,
            bg=self.theme_manager.theme["bg_main"],
            fg=self.theme_manager.theme["fg_text"],
            insertbackground=self.theme_manager.theme["fg_text"],
            bd=1,
            relief="solid",
        )
        search_entry.pack(fill="x", padx=10, pady=4)
        tk.Label(
            search_frame,
            text="Type query to search files in workspace...",
            font=("Segoe UI", 8),
            bg=self.theme_manager.theme["bg_sidebar"],
            fg=self.theme_manager.theme["line_number_fg"],
        ).pack(anchor="w", padx=10)
        self.views["search"] = search_frame

        # View 3: Run & Debug
        run_frame = tk.Frame(self, bg=self.theme_manager.theme["bg_sidebar"])
        tk.Label(
            run_frame,
            text="RUN & DEBUG",
            font=("Segoe UI", 9, "bold"),
            bg=self.theme_manager.theme["bg_sidebar"],
            fg=self.theme_manager.theme["fg_sidebar"],
        ).pack(anchor="w", padx=10, pady=8)

        btn_run = tk.Button(
            run_frame,
            text="▶  Run OpenMS Script",
            font=("Segoe UI", 10, "bold"),
            bg=self.theme_manager.theme["accent_blue"],
            fg="#ffffff",
            activebackground=self.theme_manager.theme["accent_blue"],
            activeforeground="#ffffff",
            bd=0,
            padx=12,
            pady=6,
            command=lambda: self.on_run_code() if self.on_run_code else None,
        )
        btn_run.pack(fill="x", padx=10, pady=10)
        self.views["run"] = run_frame

        # View 4: AI Copilot info placeholder
        ai_frame = tk.Frame(self, bg=self.theme_manager.theme["bg_sidebar"])
        tk.Label(
            ai_frame,
            text="OPENMS AI COPILOT",
            font=("Segoe UI", 9, "bold"),
            bg=self.theme_manager.theme["bg_sidebar"],
            fg=self.theme_manager.theme["fg_sidebar"],
        ).pack(anchor="w", padx=10, pady=8)
        tk.Label(
            ai_frame,
            text="Use the AI Copilot Panel on the right drawer or shortcut Ctrl+Shift+A for live code suggestions.",
            font=("Segoe UI", 9),
            bg=self.theme_manager.theme["bg_sidebar"],
            fg=self.theme_manager.theme["fg_sidebar"],
            wraplength=220,
            justify="left",
        ).pack(anchor="w", padx=10, pady=6)
        self.views["ai"] = ai_frame

        # View 5: Settings & Theme Switcher
        settings_frame = tk.Frame(self, bg=self.theme_manager.theme["bg_sidebar"])
        tk.Label(
            settings_frame,
            text="SETTINGS & THEMES",
            font=("Segoe UI", 9, "bold"),
            bg=self.theme_manager.theme["bg_sidebar"],
            fg=self.theme_manager.theme["fg_sidebar"],
        ).pack(anchor="w", padx=10, pady=8)

        tk.Label(
            settings_frame,
            text="Color Theme:",
            font=("Segoe UI", 9),
            bg=self.theme_manager.theme["bg_sidebar"],
            fg=self.theme_manager.theme["fg_sidebar"],
        ).pack(anchor="w", padx=10, pady=4)

        for theme_key, theme_data in THEMES.items():
            btn = tk.Button(
                settings_frame,
                text=theme_data["name"],
                font=("Segoe UI", 9),
                bg=self.theme_manager.theme["bg_main"],
                fg=self.theme_manager.theme["fg_text"],
                activebackground=self.theme_manager.theme["accent_blue"],
                activeforeground="#ffffff",
                anchor="w",
                bd=1,
                padx=8,
                pady=4,
                command=lambda k=theme_key: self.theme_manager.set_theme(k),
            )
            btn.pack(fill="x", padx=10, pady=3)

        self.views["settings"] = settings_frame

        # Display initial active view
        self.show_view("explorer")

    def show_view(self, view_id):
        if view_id in self.views:
            for v in self.views.values():
                v.pack_forget()
            self.active_view = view_id
            self.views[view_id].pack(fill="both", expand=True)

    def apply_theme(self, theme):
        self.config(bg=theme["bg_sidebar"])
        for v in self.views.values():
            if isinstance(v, tk.Frame) and not isinstance(v, FileTreeExplorer):
                v.config(bg=theme["bg_sidebar"])
