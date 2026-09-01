"""
File Tree Explorer View Component
"""

import os
import tkinter as tk
from tkinter import ttk, messagebox, simpledialog


class FileTreeExplorer(tk.Frame):
    """VS Code primary sidebar file tree widget."""

    def __init__(self, parent, theme_manager, on_file_open_cb=None):
        self.theme_manager = theme_manager
        theme = theme_manager.theme
        super().__init__(parent, bg=theme["bg_sidebar"])

        self.on_file_open = on_file_open_cb
        self.root_dir = os.getcwd()

        self.theme_manager.register(self.apply_theme)
        self._build_tree()
        self.refresh()

    def _build_tree(self):
        # Header toolbar
        header = tk.Frame(self, bg=self.theme_manager.theme["bg_sidebar"], height=28)
        header.pack(fill="x", side="top", padx=8, pady=4)

        lbl = tk.Label(
            header,
            text="EXPLORER",
            font=("Segoe UI", 9, "bold"),
            bg=self.theme_manager.theme["bg_sidebar"],
            fg=self.theme_manager.theme["fg_sidebar"],
        )
        lbl.pack(side="left")

        btn_new = tk.Button(
            header,
            text="+",
            font=("Segoe UI", 10, "bold"),
            bd=0,
            bg=self.theme_manager.theme["bg_sidebar"],
            fg=self.theme_manager.theme["fg_sidebar"],
            activebackground=self.theme_manager.theme["bg_sidebar"],
            command=self._new_file_dialog,
        )
        btn_new.pack(side="right", padx=2)

        btn_ref = tk.Button(
            header,
            text="⟳",
            font=("Segoe UI", 10),
            bd=0,
            bg=self.theme_manager.theme["bg_sidebar"],
            fg=self.theme_manager.theme["fg_sidebar"],
            activebackground=self.theme_manager.theme["bg_sidebar"],
            command=self.refresh,
        )
        btn_ref.pack(side="right", padx=2)

        # Treeview frame
        tree_frame = tk.Frame(self, bg=self.theme_manager.theme["bg_sidebar"])
        tree_frame.pack(fill="both", expand=True, padx=4, pady=2)

        style = ttk.Style()
        style.theme_use("clam")
        self._configure_tree_style()

        self.tree = ttk.Treeview(tree_frame, selectmode="browse", show="tree")
        self.tree.pack(fill="both", expand=True)

        self.tree.bind("<Double-1>", self._on_double_click)

    def _configure_tree_style(self):
        theme = self.theme_manager.theme
        style = ttk.Style()
        style.configure(
            "Treeview",
            background=theme["bg_sidebar"],
            foreground=theme["fg_sidebar"],
            fieldbackground=theme["bg_sidebar"],
            rowheight=22,
            font=("Segoe UI", 9),
            borderwidth=0,
        )
        style.map(
            "Treeview",
            background=[("selected", theme["accent_blue"])],
            foreground=[("selected", "#ffffff")],
        )

    def set_root_dir(self, directory):
        if os.path.exists(directory):
            self.root_dir = directory
            self.refresh()

    def refresh(self):
        self.tree.delete(*self.tree.get_children())
        root_node = self.tree.insert("", "end", text=os.path.basename(self.root_dir) or self.root_dir, open=True)
        self._populate_node(root_node, self.root_dir)

    def _populate_node(self, parent_node, path):
        try:
            entries = sorted(os.listdir(path))
        except PermissionError:
            return

        for entry in entries:
            if entry.startswith(".") or entry in ("__pycache__", "node_modules", "venv"):
                continue
            full_path = os.path.join(path, entry)
            is_dir = os.path.isdir(full_path)
            icon = "📁 " if is_dir else "📄 "
            node = self.tree.insert(parent_node, "end", text=f"{icon}{entry}", open=False, values=[full_path, is_dir])
            if is_dir:
                # Add dummy item to make expandable
                self.tree.insert(node, "end", text="...")

        self.tree.bind("<<TreeviewOpen>>", self._on_expand)

    def _on_expand(self, event):
        item_id = self.tree.focus()
        children = self.tree.get_children(item_id)
        if len(children) == 1 and self.tree.item(children[0], "text") == "...":
            self.tree.delete(children[0])
            values = self.tree.item(item_id, "values")
            if values:
                self._populate_node(item_id, values[0])

    def _on_double_click(self, event):
        item_id = self.tree.focus()
        values = self.tree.item(item_id, "values")
        if values and len(values) >= 2:
            path, is_dir = values[0], values[1] == "True" or values[1] == "1"
            if not is_dir and os.path.isfile(path):
                if self.on_file_open:
                    self.on_file_open(path)

    def _new_file_dialog(self):
        fname = simpledialog.askstring("New File", "Enter filename (e.g. script.game):")
        if fname:
            target_path = os.path.join(self.root_dir, fname)
            try:
                with open(target_path, "w", encoding="utf-8") as f:
                    f.write("# New OpenMS file\n")
                self.refresh()
                if self.on_file_open:
                    self.on_file_open(target_path)
            except Exception as e:
                messagebox.showerror("Error", f"Failed to create file: {e}")

    def apply_theme(self, theme):
        self.config(bg=theme["bg_sidebar"])
        self._configure_tree_style()
