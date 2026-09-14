"""
OpenMS Multi-Tab Editor Notebook Widget
"""

import os
import tkinter as tk
from tkinter import ttk
from openms.ui.editor import CodeEditor


class TabbedEditor(tk.Frame):
    """Tabbed notebook managing multiple open file tabs."""

    def __init__(self, parent, theme_manager, on_code_change=None, on_cursor_move=None):
        theme = theme_manager.theme
        super().__init__(parent, bg=theme["bg_main"])
        self.theme_manager = theme_manager
        self.on_code_change = on_code_change
        self.on_cursor_move = on_cursor_move

        self.tabs = {}  # tab_id -> {"editor": CodeEditor, "path": str, "title": str}

        self._build_notebook()
        self.theme_manager.subscribe(self.apply_theme)

    def _build_notebook(self):
        self.notebook = ttk.Notebook(self)
        self.notebook.pack(fill="both", expand=True)
        self.notebook.bind("<<NotebookTabChanged>>", self._on_tab_changed)

    def add_tab(self, title="untitled.game", content="", path=None):
        frame = tk.Frame(self.notebook, bg=self.theme_manager.theme["bg_editor"])
        editor = CodeEditor(
            frame,
            self.theme_manager,
            on_change=self.on_code_change,
            on_cursor_move=self.on_cursor_move,
        )
        editor.pack(fill="both", expand=True)
        editor.set_code(content)

        self.notebook.add(frame, text=title)
        tab_id = self.notebook.tabs()[-1]
        self.tabs[tab_id] = {"editor": editor, "path": path, "title": title, "frame": frame}
        self.notebook.select(frame)

        return editor

    def get_current_editor(self):
        selected_id = self.notebook.select()
        if selected_id in self.tabs:
            return self.tabs[selected_id]["editor"]
        return None

    def get_current_tab_info(self):
        selected_id = self.notebook.select()
        return self.tabs.get(selected_id, None)

    def set_current_tab_info(self, title=None, path=None):
        selected_id = self.notebook.select()
        if selected_id in self.tabs:
            if title is not None:
                self.tabs[selected_id]["title"] = title
                self.notebook.tab(selected_id, text=title)
            if path is not None:
                self.tabs[selected_id]["path"] = path

    def _on_tab_changed(self, event):
        if self.on_code_change:
            self.on_code_change()

    def apply_theme(self, theme):
        self.config(bg=theme["bg_main"])
