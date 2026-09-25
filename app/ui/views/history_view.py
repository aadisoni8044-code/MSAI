"""History View for Kora UI."""

import os
import tkinter as tk
from tkinter import ttk, messagebox
from typing import Callable, List, Dict, Any, Optional
from app.ui.theme import ColorPalette, DARK_PALETTE
from app.ui.components import Card


class HistoryView(tk.Frame):
    """Build History view featuring search, filtering, build summary cards, and log inspection."""

    def __init__(
        self,
        parent,
        colors: ColorPalette = DARK_PALETTE,
        get_history_func: Optional[Callable[[], List[Dict[str, Any]]]] = None,
        on_open_path: Optional[Callable[[str], None]] = None
    ):
        super().__init__(parent, bg=colors.bg_dark)
        self.colors = colors
        self.get_history_func = get_history_func
        self.on_open_path = on_open_path

        self._build_ui()

    def _build_ui(self):
        # Header
        header = tk.Frame(self, bg=self.colors.bg_dark)
        header.pack(fill=tk.X, padx=25, pady=(20, 15))

        lbl_title = tk.Label(
            header,
            text="Build History",
            font=("Segoe UI", 16, "bold"),
            fg=self.colors.text_primary,
            bg=self.colors.bg_dark
        )
        lbl_title.pack(side=tk.LEFT)

        btn_ref = tk.Button(
            header,
            text="🔄 Refresh History",
            font=("Segoe UI", 8, "bold"),
            fg=self.colors.text_primary,
            bg=self.colors.card_border,
            bd=0,
            padx=12,
            pady=6,
            cursor="hand2",
            command=self.refresh_history
        )
        btn_ref.pack(side=tk.RIGHT)

        # Container for History List
        self.list_container = tk.Frame(self, bg=self.colors.bg_dark)
        self.list_container.pack(fill=tk.BOTH, expand=True, padx=25, pady=10)

        self.refresh_history()

    def refresh_history(self):
        for child in self.list_container.winfo_children():
            child.destroy()

        history_items = self.get_history_func() if self.get_history_func else []

        if not history_items:
            empty_card = Card(self.list_container, colors=self.colors, padding=30)
            empty_card.pack(fill=tk.X, pady=20)

            tk.Label(
                empty_card.inner_frame,
                text="No Build History",
                font=("Segoe UI", 12, "bold"),
                fg=self.colors.text_primary,
                bg=self.colors.card_bg
            ).pack()

            tk.Label(
                empty_card.inner_frame,
                text="Your previous project build history and successful strategies will appear here.",
                font=("Segoe UI", 9),
                fg=self.colors.text_secondary,
                bg=self.colors.card_bg
            ).pack(pady=(4, 0))
            return

        # Render list of history cards
        for item in history_items:
            card = Card(self.list_container, colors=self.colors, padding=12)
            card.pack(fill=tk.X, pady=5)

            hdr = tk.Frame(card.inner_frame, bg=self.colors.card_bg)
            hdr.pack(fill=tk.X)

            status = item.get("status", "UNKNOWN")
            is_success = (status == "SUCCESS")
            st_col = self.colors.success if is_success else self.colors.error
            st_icon = "✓" if is_success else "×"

            tk.Label(hdr, text=f"{st_icon} {status}", font=("Segoe UI", 9, "bold"), fg=st_col, bg=self.colors.card_bg).pack(side=tk.LEFT)
            tk.Label(hdr, text=item.get("project_path", ""), font=("Segoe UI", 9), fg=self.colors.text_secondary, bg=self.colors.card_bg).pack(side=tk.LEFT, padx=15)

            details = f"Attempt #{item.get('attempt_number', 1)} · Builder: {item.get('builder_name', 'N/A')} · Duration: {round(item.get('duration', 0), 2)}s · {item.get('timestamp', '')}"
            tk.Label(card.inner_frame, text=details, font=("Segoe UI", 8), fg=self.colors.text_secondary, bg=self.colors.card_bg).pack(anchor="w", pady=(4, 0))
