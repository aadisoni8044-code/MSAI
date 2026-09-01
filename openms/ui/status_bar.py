"""
Status Bar Component across bottom
"""

import tkinter as tk


class StatusBar(tk.Frame):
    """VS Code status bar widget across bottom edge."""

    def __init__(self, parent, theme_manager):
        self.theme_manager = theme_manager
        theme = theme_manager.theme
        super().__init__(parent, bg=theme["bg_status"], height=22)
        self.pack_propagate(False)

        self.line = 1
        self.col = 1
        self.status_text = "Ready"

        self.theme_manager.register(self.apply_theme)
        self._build_bar()

    def _build_bar(self):
        theme = self.theme_manager.theme

        # Left status text
        self.lbl_status = tk.Label(
            self,
            text=f"  ● {self.status_text}",
            font=("Segoe UI", 9),
            bg=theme["bg_status"],
            fg=theme["fg_status"],
        )
        self.lbl_status.pack(side="left")

        # Right status items
        self.lbl_lang = tk.Label(
            self,
            text="OpenMS Language  │  UTF-8  │  Spaces: 4  │",
            font=("Segoe UI", 9),
            bg=theme["bg_status"],
            fg=theme["fg_status"],
        )
        self.lbl_lang.pack(side="right", padx=6)

        self.lbl_pos = tk.Label(
            self,
            text=f"Ln {self.line}, Col {self.col}  │",
            font=("Segoe UI", 9),
            bg=theme["bg_status"],
            fg=theme["fg_status"],
        )
        self.lbl_pos.pack(side="right")

    def set_cursor_pos(self, line, col):
        self.line = line
        self.col = col
        self.lbl_pos.config(text=f"Ln {self.line}, Col {self.col}  │")

    def set_status(self, text):
        self.status_text = text
        self.lbl_status.config(text=f"  ● {self.status_text}")

    def apply_theme(self, theme):
        self.config(bg=theme["bg_status"])
        for w in (self.lbl_status, self.lbl_lang, self.lbl_pos):
            w.config(bg=theme["bg_status"], fg=theme["fg_status"])
