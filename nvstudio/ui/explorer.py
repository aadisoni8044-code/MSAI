"""
NV Studio Project & File Explorer Sidebar
Displays file hierarchy and allows file creation, opening folders, renaming, and deleting files.
"""

import os
import tkinter as tk
from tkinter import filedialog, messagebox, ttk
from typing import Callable, Dict, Optional
import customtkinter as ctk

from nvstudio.ui.theme import get_theme
from nvstudio.workspace import WorkspaceManager


class FileExplorer(ctk.CTkFrame):
    """Left Panel Project/File Explorer sidebar widget."""

    def __init__(
        self,
        parent: tk.Widget,
        workspace: WorkspaceManager,
        theme_name: str,
        on_file_select: Callable[[str], None],
        on_folder_change: Callable[[str], None],
    ):
        super().__init__(parent, fg_color="transparent", corner_radius=0)

        self.workspace = workspace
        self.theme_name = theme_name
        self.theme = get_theme(theme_name)
        self.on_file_select = on_file_select
        self.on_folder_change = on_folder_change

        self._create_header()
        self._create_action_toolbar()
        self._create_treeview()
        self.refresh_tree()

    def _create_header(self) -> None:
        """Header showing project title and Open Folder button."""
        header_frame = ctk.CTkFrame(
            self, fg_color=self.theme["bg_sidebar"], corner_radius=0, height=40
        )
        header_frame.pack(fill="x", side="top")

        lbl_title = ctk.CTkLabel(
            header_frame,
            text="PROJECT EXPLORER",
            font=ctk.CTkFont(size=11, weight="bold"),
            text_color=self.theme["fg_subtext"],
        )
        lbl_title.pack(side="left", padx=12, pady=8)

        btn_open = ctk.CTkButton(
            header_frame,
            text="📁 Open",
            font=ctk.CTkFont(size=11, weight="bold"),
            fg_color=self.theme["bg_input"],
            hover_color=self.theme["border"],
            text_color=self.theme["fg_text"],
            width=55,
            height=24,
            command=self._open_folder_dialog,
        )
        btn_open.pack(side="right", padx=10, pady=8)

    def _create_action_toolbar(self) -> None:
        """Quick action buttons: Create File, Create Folder, Rename, Delete."""
        tb_frame = ctk.CTkFrame(
            self, fg_color=self.theme["bg_sidebar"], corner_radius=0, height=32
        )
        tb_frame.pack(fill="x", side="top", pady=(1, 0))

        # + File Button
        btn_add_file = ctk.CTkButton(
            tb_frame,
            text="+ File",
            font=ctk.CTkFont(size=11),
            fg_color="transparent",
            hover_color=self.theme["bg_input"],
            text_color=self.theme["fg_text"],
            width=50,
            height=26,
            command=self._prompt_create_file,
        )
        btn_add_file.pack(side="left", padx=(8, 2), pady=3)

        # Rename Button
        btn_rename = ctk.CTkButton(
            tb_frame,
            text="✏️ Rename",
            font=ctk.CTkFont(size=11),
            fg_color="transparent",
            hover_color=self.theme["bg_input"],
            text_color=self.theme["fg_text"],
            width=65,
            height=26,
            command=self._prompt_rename_selected,
        )
        btn_rename.pack(side="left", padx=2, pady=3)

        # Delete Button
        btn_delete = ctk.CTkButton(
            tb_frame,
            text="🗑️ Delete",
            font=ctk.CTkFont(size=11),
            fg_color="transparent",
            hover_color=self.theme["danger"],
            text_color=self.theme["fg_text"],
            width=60,
            height=26,
            command=self._prompt_delete_selected,
        )
        btn_delete.pack(side="left", padx=2, pady=3)

    def _create_treeview(self) -> None:
        """Creates Tkinter Treeview for folder/file structure styling."""
        tree_container = ctk.CTkFrame(
            self, fg_color=self.theme["bg_sidebar"], corner_radius=0
        )
        tree_container.pack(fill="both", expand=True, side="top")

        style = ttk.Style()
        style.theme_use("default")

        bg = self.theme["bg_sidebar"]
        fg = self.theme["fg_text"]
        select_bg = self.theme["accent"]

        style.configure(
            "NVStudio.Treeview",
            background=bg,
            foreground=fg,
            fieldbackground=bg,
            rowheight=26,
            borderwidth=0,
            font=("Segoe UI", 10),
        )
        style.map("NVStudio.Treeview", background=[("selected", select_bg)])

        self.tree = ttk.Treeview(
            tree_container,
            style="NVStudio.Treeview",
            selectmode="browse",
            show="tree",
        )

        scrollbar = ttk.Scrollbar(
            tree_container, orient="vertical", command=self.tree.yview
        )
        self.tree.configure(yscrollcommand=scrollbar.set)

        scrollbar.pack(side="right", fill="y")
        self.tree.pack(side="left", fill="both", expand=True)

        self.tree.bind("<<TreeviewSelect>>", self._on_tree_select)
        self.tree.bind("<Double-1>", self._on_tree_double_click)

    def set_theme(self, theme_name: str) -> None:
        """Updates explorer colors based on active theme."""
        self.theme_name = theme_name
        self.theme = get_theme(theme_name)
        self.refresh_tree()

    def refresh_tree(self) -> None:
        """Clears and rebuilds treeview from workspace files."""
        for item in self.tree.get_children():
            self.tree.delete(item)

        root_node = self.tree.insert(
            "",
            "end",
            text=f" 📂 {self.workspace.root_path.name}",
            open=True,
            values=["root"],
        )

        files = self.workspace.list_files()
        for rel_file in files:
            parts = rel_file.parts
            parent = root_node
            for i, part in enumerate(parts):
                is_last = i == len(parts) - 1
                if is_last:
                    icon = self._get_file_icon(part)
                    self.tree.insert(
                        parent,
                        "end",
                        text=f" {icon} {part}",
                        values=[str(rel_file)],
                    )
                else:
                    # Folder check
                    existing = None
                    for child in self.tree.get_children(parent):
                        if self.tree.item(child, "text").strip() == f"📁 {part}":
                            existing = child
                            break
                    if existing:
                        parent = existing
                    else:
                        parent = self.tree.insert(
                            parent, "end", text=f" 📁 {part}", values=["folder"]
                        )

    @staticmethod
    def _get_file_icon(filename: str) -> str:
        ext = os.path.splitext(filename)[1].lower()
        if ext == ".html":
            return "🌐"
        elif ext == ".css":
            return "🎨"
        elif ext in [".js", ".json"]:
            return "⚡"
        elif ext in [".png", ".jpg", ".jpeg", ".svg"]:
            return "🖼️"
        return "📄"

    def _get_selected_rel_path(self) -> Optional[str]:
        selected = self.tree.selection()
        if not selected:
            return None
        item_vals = self.tree.item(selected[0], "values")
        if item_vals and item_vals[0] not in ["root", "folder"]:
            return item_vals[0]
        return None

    def _on_tree_select(self, event: tk.Event) -> None:
        rel_path = self._get_selected_rel_path()
        if rel_path:
            self.on_file_select(rel_path)

    def _on_tree_double_click(self, event: tk.Event) -> None:
        rel_path = self._get_selected_rel_path()
        if rel_path:
            self.on_file_select(rel_path)

    def _open_folder_dialog(self) -> None:
        folder = filedialog.askdirectory(
            title="Select Project Folder",
            initialdir=str(self.workspace.root_path),
        )
        if folder:
            self.workspace.set_root_path(folder)
            self.refresh_tree()
            self.on_folder_change(folder)

    def _prompt_create_file(self) -> None:
        dialog = ctk.CTkInputDialog(
            text="Enter file name (e.g., index.html, style.css, script.js):",
            title="Create New File",
        )
        filename = dialog.get_input()
        if filename:
            filename = filename.strip()
            if filename:
                success = self.workspace.create_file(filename)
                if success:
                    self.refresh_tree()
                    self.on_file_select(filename)
                else:
                    messagebox.showerror(
                        "Error", f"Failed to create file '{filename}'."
                    )

    def _prompt_rename_selected(self) -> None:
        rel_path = self._get_selected_rel_path()
        if not rel_path:
            messagebox.showinfo("Rename", "Please select a file to rename.")
            return

        dialog = ctk.CTkInputDialog(
            text=f"Enter new name for '{rel_path}':", title="Rename File"
        )
        new_name = dialog.get_input()
        if new_name:
            new_name = new_name.strip()
            if new_name and new_name != rel_path:
                success = self.workspace.rename_file(rel_path, new_name)
                if success:
                    self.refresh_tree()
                    self.on_file_select(new_name)
                else:
                    messagebox.showerror("Error", "Failed to rename file.")

    def _prompt_delete_selected(self) -> None:
        rel_path = self._get_selected_rel_path()
        if not rel_path:
            messagebox.showinfo("Delete", "Please select a file to delete.")
            return

        confirm = messagebox.askyesno(
            "Confirm Delete",
            f"Are you sure you want to delete '{rel_path}'?",
        )
        if confirm:
            success = self.workspace.delete_file(rel_path)
            if success:
                self.refresh_tree()
