"""Logs View for Kora UI."""

import tkinter as tk
from typing import Optional
from app.ui.theme import ColorPalette, DARK_PALETTE
from app.ui.components import Card
from app.ui.terminal_view import TerminalView


class LogsView(tk.Frame):
    """Logs View dedicated to inspecting application logs, build logs, and error logs."""

    def __init__(self, parent, colors: ColorPalette = DARK_PALETTE):
        super().__init__(parent, bg=colors.bg_dark)
        self.colors = colors
        self._build_ui()

    def _build_ui(self):
        header = tk.Frame(self, bg=self.colors.bg_dark)
        header.pack(fill=tk.X, padx=25, pady=(20, 15))

        lbl_title = tk.Label(
            header,
            text="Build & Application Logs",
            font=("Segoe UI", 16, "bold"),
            fg=self.colors.text_primary,
            bg=self.colors.bg_dark
        )
        lbl_title.pack(anchor="w")

        container = tk.Frame(self, bg=self.colors.bg_dark)
        container.pack(fill=tk.BOTH, expand=True, padx=25, pady=10)

        self.terminal = TerminalView(container)
        self.terminal.pack(fill=tk.BOTH, expand=True)
