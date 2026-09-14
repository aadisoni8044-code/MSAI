"""
OpenMS Primary Sidebar Panel Container
"""

import tkinter as tk
from openms.ui.file_explorer import FileExplorer
from openms.ui.ai_copilot import AICopilot
from openms.config import FUNCTION_HELP, THEMES


class PrimarySidebar(tk.Frame):
    """Primary Sidebar switcher container managing Explorer, Search, AI Copilot, and Reference views."""

    def __init__(self, parent, theme_manager, on_file_open=None, on_insert_code=None):
        theme = theme_manager.theme
        super().__init__(parent, bg=theme["bg_side"], width=260)
        self.pack_propagate(False)
        self.theme_manager = theme_manager
        self.on_file_open = on_file_open
        self.on_insert_code = on_insert_code

        self.views = {}
        self.active_view = None

        self._build_views()
        self.theme_manager.subscribe(self.apply_theme)
        self.show_view("explorer")

    def _build_views(self):
        # Explorer
        self.views["explorer"] = FileExplorer(self, self.theme_manager, self.on_file_open)

        # AI Copilot
        self.views["copilot"] = AICopilot(self, self.theme_manager, self.on_insert_code)

        # Function Reference
        ref_frame = tk.Frame(self, bg=self.theme_manager.theme["bg_side"])
        lbl_ref = tk.Label(
            ref_frame,
            text="FUNCTION REFERENCE",
            font=("Segoe UI", 9, "bold"),
            bg=self.theme_manager.theme["bg_side"],
            fg=self.theme_manager.theme["fg_text"],
            pady=6,
        )
        lbl_ref.pack(side="top", fill="x")

        ref_txt = tk.Text(
            ref_frame,
            bg=self.theme_manager.theme["bg_side"],
            fg=self.theme_manager.theme["fg_text"],
            font=("Segoe UI", 8),
            wrap="word",
            bd=0,
            highlightthickness=0,
            padx=6,
            pady=6,
        )
        ref_txt.pack(side="top", fill="both", expand=True)
        for fname, desc in FUNCTION_HELP.items():
            ref_txt.insert("end", f"• {fname}(): {desc}\n\n")
        ref_txt.config(state="disabled")
        self.views["ref"] = ref_frame

        # Search View
        search_frame = tk.Frame(self, bg=self.theme_manager.theme["bg_side"])
        lbl_s = tk.Label(
            search_frame,
            text="SEARCH",
            font=("Segoe UI", 9, "bold"),
            bg=self.theme_manager.theme["bg_side"],
            fg=self.theme_manager.theme["fg_text"],
            pady=6,
        )
        lbl_s.pack(side="top", fill="x")

        s_entry = tk.Entry(
            search_frame,
            bg=self.theme_manager.theme["bg_main"],
            fg=self.theme_manager.theme["fg_text"],
            bd=1,
            relief="solid",
        )
        s_entry.pack(side="top", fill="x", padx=8, pady=6)
        self.views["search"] = search_frame

        # Theme Switcher View
        theme_frame = tk.Frame(self, bg=self.theme_manager.theme["bg_side"])
        lbl_t = tk.Label(
            theme_frame,
            text="SELECT THEME",
            font=("Segoe UI", 9, "bold"),
            bg=self.theme_manager.theme["bg_side"],
            fg=self.theme_manager.theme["fg_text"],
            pady=6,
        )
        lbl_t.pack(side="top", fill="x")

        for theme_name in THEMES:
            btn = tk.Button(
                theme_frame,
                text=theme_name,
                font=("Segoe UI", 9),
                bg=self.theme_manager.theme["bg_side"],
                fg=self.theme_manager.theme["fg_text"],
                activebackground=self.theme_manager.theme["accent"],
                bd=0,
                command=lambda name=theme_name: self.theme_manager.set_theme(name),
                cursor="hand2",
            )
            btn.pack(side="top", fill="x", padx=8, pady=4)

        self.views["theme"] = theme_frame

    def show_view(self, name):
        if name in self.views:
            if self.active_view:
                self.active_view.pack_forget()
            self.active_view = self.views[name]
            self.active_view.pack(side="top", fill="both", expand=True)

    def apply_theme(self, theme):
        self.config(bg=theme["bg_side"])
