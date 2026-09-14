"""
OpenMS Status Bar Widget
"""

import tkinter as tk


class StatusBar(tk.Frame):
    """Bottom status bar displaying cursor line/column, theme, and language info."""

    def __init__(self, parent, theme_manager):
        theme = theme_manager.theme
        super().__init__(parent, bg=theme["bg_header"], height=24)
        self.pack_propagate(False)
        self.theme_manager = theme_manager

        self._build_ui()
        self.theme_manager.subscribe(self.apply_theme)

    def _build_ui(self):
        theme = self.theme_manager.theme

        self.lbl_file = tk.Label(
            self,
            text="untitled.game",
            font=("Segoe UI", 9),
            bg=theme["bg_header"],
            fg=theme["fg_text"],
        )
        self.lbl_file.pack(side="left", padx=10)

        self.lbl_cursor = tk.Label(
            self,
            text="Ln 1, Col 1",
            font=("Segoe UI", 9),
            bg=theme["bg_header"],
            fg=theme["fg_dim"],
        )
        self.lbl_cursor.pack(side="right", padx=10)

        self.lbl_theme = tk.Label(
            self,
            text=f"Theme: {self.theme_manager.active_theme_name}",
            font=("Segoe UI", 9),
            bg=theme["bg_header"],
            fg=theme["fg_dim"],
        )
        self.lbl_theme.pack(side="right", padx=10)

        self.lbl_lang = tk.Label(
            self,
            text="OpenMS Language",
            font=("Segoe UI", 9, "bold"),
            bg=theme["bg_header"],
            fg=theme["accent"],
        )
        self.lbl_lang.pack(side="right", padx=10)

    def update_info(self, file_name="untitled.game", cursor_pos="Ln 1, Col 1"):
        self.lbl_file.config(text=file_name)
        self.lbl_cursor.config(text=cursor_pos)
        self.lbl_theme.config(text=f"Theme: {self.theme_manager.active_theme_name}")

    def apply_theme(self, theme):
        self.config(bg=theme["bg_header"])
        for child in (self.lbl_file, self.lbl_cursor, self.lbl_theme, self.lbl_lang):
            child.config(bg=theme["bg_header"])
        self.lbl_lang.config(fg=theme["accent"])
