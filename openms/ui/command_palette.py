"""
OpenMS Command Palette Modal (Ctrl+Shift+P)
"""

import tkinter as tk


class CommandPalette(tk.Toplevel):
    """Quick command launcher modal for actions, theme changes, and navigation."""

    def __init__(self, parent, commands):
        super().__init__(parent)
        self.title("Command Palette")
        self.geometry("600x320")
        self.configure(bg="#1e1e1e")
        self.transient(parent)
        self.grab_set()

        self.commands = commands  # list of dicts: {"label": str, "action": callable}
        self.filtered = list(commands)

        self._build_ui()

    def _build_ui(self):
        self.entry = tk.Entry(
            self,
            bg="#2d2d2d",
            fg="#ffffff",
            insertbackground="#ffffff",
            font=("Segoe UI", 11),
            bd=1,
            relief="solid",
        )
        self.entry.pack(side="top", fill="x", padx=12, pady=12)
        self.entry.focus_set()
        self.entry.bind("<KeyRelease>", self._on_filter)

        self.listbox = tk.Listbox(
            self,
            bg="#252526",
            fg="#cccccc",
            selectbackground="#007acc",
            selectforeground="#ffffff",
            font=("Segoe UI", 10),
            bd=0,
            highlightthickness=0,
        )
        self.listbox.pack(side="top", fill="both", expand=True, padx=12, pady=(0, 12))
        self.listbox.bind("<Double-1>", self._on_select)
        self.listbox.bind("<Return>", self._on_select)

        self._populate_list()

    def _populate_list(self):
        self.listbox.delete(0, "end")
        for cmd in self.filtered:
            self.listbox.insert("end", cmd["label"])
        if self.filtered:
            self.listbox.select_set(0)

    def _on_filter(self, event=None):
        query = self.entry.get().lower()
        self.filtered = [c for c in self.commands if query in c["label"].lower()]
        self._populate_list()

    def _on_select(self, event=None):
        sel = self.listbox.curselection()
        if sel:
            idx = sel[0]
            action = self.filtered[idx]["action"]
            self.destroy()
            action()
