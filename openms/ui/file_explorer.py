"""
OpenMS File Explorer Widget
"""

import os
import tkinter as tk
from tkinter import ttk, messagebox


class FileExplorer(tk.Frame):
    """File Tree Explorer widget for browsing, opening, and creating files."""

    def __init__(self, parent, theme_manager, on_file_open=None):
        theme = theme_manager.theme
        super().__init__(parent, bg=theme["bg_side"])
        self.theme_manager = theme_manager
        self.on_file_open = on_file_open
        self.workspace_dir = os.getcwd()

        self._build_ui()
        self.theme_manager.subscribe(self.apply_theme)
        self.refresh()

    def _build_ui(self):
        theme = self.theme_manager.theme

        # Header toolbar
        header = tk.Frame(self, bg=theme["bg_side"], height=32)
        header.pack(side="top", fill="x", padx=8, pady=4)

        lbl = tk.Label(
            header,
            text="EXPLORER",
            font=("Segoe UI", 9, "bold"),
            bg=theme["bg_side"],
            fg=theme["fg_dim"],
        )
        lbl.pack(side="left")

        btn_refresh = tk.Button(
            header,
            text="🔄",
            bg=theme["bg_side"],
            fg=theme["fg_text"],
            bd=0,
            command=self.refresh,
            cursor="hand2",
        )
        btn_refresh.pack(side="right")

        # Treeview
        style = ttk.Style()
        style.theme_use("default")
        self.tree = ttk.Treeview(self, show="tree", selectmode="browse")
        self.tree.pack(side="top", fill="both", expand=True, padx=4, pady=4)
        self.tree.bind("<Double-1>", self._on_double_click)

    def refresh(self):
        for item in self.tree.get_children():
            self.tree.delete(item)

        root_node = self.tree.insert("", "end", text=os.path.basename(self.workspace_dir) or "Workspace", open=True)
        try:
            entries = sorted(os.listdir(self.workspace_dir))
            for entry in entries:
                if entry.startswith(".") or entry == "__pycache__":
                    continue
                full_path = os.path.join(self.workspace_dir, entry)
                if os.path.isdir(full_path):
                    node = self.tree.insert(root_node, "end", text=f"📁 {entry}", values=[full_path])
                else:
                    self.tree.insert(root_node, "end", text=f"📄 {entry}", values=[full_path])
        except Exception as e:
            print(f"[FileExplorer Error] {e}")

    def _on_double_click(self, event):
        item = self.tree.selection()
        if not item:
            return
        vals = self.tree.item(item[0], "values")
        if vals and os.path.isfile(vals[0]):
            if self.on_file_open:
                self.on_file_open(vals[0])

    def apply_theme(self, theme):
        self.config(bg=theme["bg_side"])
