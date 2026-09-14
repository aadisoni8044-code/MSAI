"""
OpenMS Integrated Terminal / Console Panel
"""

import time
import tkinter as tk


class IntegratedTerminal(tk.Frame):
    """Bottom console output panel displaying script execution logs and errors."""

    def __init__(self, parent, theme_manager):
        theme = theme_manager.theme
        super().__init__(parent, bg=theme["bg_terminal"])
        self.theme_manager = theme_manager

        self._build_ui()
        self.theme_manager.subscribe(self.apply_theme)

    def _build_ui(self):
        theme = self.theme_manager.theme

        # Terminal Bar
        header = tk.Frame(self, bg=theme["bg_header"], height=28)
        header.pack(side="top", fill="x")

        title = tk.Label(
            header,
            text="TERMINAL LOG",
            font=("Segoe UI", 9, "bold"),
            bg=theme["bg_header"],
            fg=theme["fg_text"],
        )
        title.pack(side="left", padx=10)

        btn_clear = tk.Button(
            header,
            text="Clear",
            font=("Segoe UI", 8),
            bg=theme["bg_header"],
            fg=theme["fg_text"],
            bd=0,
            command=self.clear,
            cursor="hand2",
        )
        btn_clear.pack(side="right", padx=8)

        # Output Text Widget
        self.output_text = tk.Text(
            self,
            bg=theme["bg_terminal"],
            fg=theme["fg_text"],
            font=("Consolas", 10),
            wrap="word",
            state="disabled",
            bd=0,
            highlightthickness=0,
            padx=10,
            pady=6,
        )
        self.output_text.pack(side="top", fill="both", expand=True)

    def write(self, text):
        self.output_text.configure(state="normal")
        self.output_text.insert("end", str(text) + "\n")
        self.output_text.see("end")
        self.output_text.configure(state="disabled")

    def clear(self):
        self.output_text.configure(state="normal")
        self.output_text.delete("1.0", "end")
        self.output_text.configure(state="disabled")

    def apply_theme(self, theme):
        self.config(bg=theme["bg_terminal"])
        self.output_text.config(bg=theme["bg_terminal"], fg=theme["fg_text"])
