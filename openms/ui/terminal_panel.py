"""
Terminal / Console Log Panel Component
"""

import time
import tkinter as tk


class TerminalPanel(tk.Frame):
    """VS Code integrated terminal log panel across bottom."""

    def __init__(self, parent, theme_manager, on_run_code_cb=None):
        self.theme_manager = theme_manager
        theme = theme_manager.theme
        super().__init__(parent, bg=theme["bg_terminal"], height=180)

        self.on_run_code = on_run_code_cb

        self.theme_manager.register(self.apply_theme)
        self._build_terminal()

    def _build_terminal(self):
        theme = self.theme_manager.theme

        # Terminal header toolbar
        header = tk.Frame(self, bg=theme["bg_tab"], height=30)
        header.pack(fill="x", side="top")

        lbl = tk.Label(
            header,
            text="TERMINAL / CONSOLE LOG",
            font=("Segoe UI", 8, "bold"),
            bg=theme["bg_tab"],
            fg=theme["fg_sidebar"],
        )
        lbl.pack(side="left", padx=10)

        btn_run = tk.Button(
            header,
            text="▶ Run Script",
            font=("Segoe UI", 8, "bold"),
            bg=theme["accent_blue"],
            fg="#ffffff",
            activebackground=theme["accent_blue"],
            activeforeground="#ffffff",
            bd=0,
            padx=8,
            command=lambda: self.on_run_code() if self.on_run_code else None,
        )
        btn_run.pack(side="right", padx=6, pady=3)

        btn_clear = tk.Button(
            header,
            text="🗑 Clear",
            font=("Segoe UI", 8),
            bg=theme["bg_tab"],
            fg=theme["fg_sidebar"],
            bd=0,
            padx=6,
            command=self.clear,
        )
        btn_clear.pack(side="right", padx=4, pady=3)

        # Terminal Output Text Area
        self.terminal_text = tk.Text(
            self,
            bg=theme["bg_terminal"],
            fg=theme["fg_terminal"],
            insertbackground=theme["fg_terminal"],
            font=("Consolas", 10),
            wrap="word",
            border=0,
            padx=10,
            pady=6,
            state="disabled",
        )
        self.terminal_text.pack(fill="both", expand=True)

        self.write(f"OpenMS Code Studio Terminal Ready [{time.strftime('%H:%M:%S')}]")

    def write(self, text):
        self.terminal_text.configure(state="normal")
        self.terminal_text.insert("end", str(text) + "\n")
        self.terminal_text.see("end")
        self.terminal_text.configure(state="disabled")

    def clear(self):
        self.terminal_text.configure(state="normal")
        self.terminal_text.delete("1.0", "end")
        self.terminal_text.configure(state="disabled")

    def apply_theme(self, theme):
        self.config(bg=theme["bg_terminal"])
        self.terminal_text.config(
            bg=theme["bg_terminal"],
            fg=theme["fg_terminal"],
            insertbackground=theme["fg_terminal"],
        )
