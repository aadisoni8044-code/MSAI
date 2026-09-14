"""
OpenMS Code Editor Component with Line Numbers and Syntax Highlighting
"""

import tkinter as tk
from tkinter import font as tkfont
from openms.ui.highlighter import OpenMSHighlighter


class CodeEditor(tk.Frame):
    """Editor widget featuring line numbering, scroll synchronization, auto-indentation, and live syntax highlighting."""

    def __init__(self, parent, theme_manager, on_change=None, on_cursor_move=None):
        theme = theme_manager.theme
        super().__init__(parent, bg=theme["bg_editor"])
        self.theme_manager = theme_manager
        self.on_change = on_change
        self.on_cursor_move = on_cursor_move

        self.mono_font = tkfont.Font(family="Consolas", size=12)
        if self.mono_font.actual("family").lower() != "consolas":
            self.mono_font = tkfont.Font(family="Courier New", size=12)

        self._build_editor()
        self.highlighter = OpenMSHighlighter(self.code_text, theme)
        self.highlighter.configure_tags(theme)

        self.theme_manager.subscribe(self.apply_theme)

    def _build_editor(self):
        theme = self.theme_manager.theme

        # Scrollbar
        self.v_scroll = tk.Scrollbar(self, command=self._on_scrollbar_move)
        self.v_scroll.pack(side="right", fill="y")

        # Line Numbers Gutter
        self.linenumbers = tk.Text(
            self,
            width=5,
            padx=4,
            bg=theme["line_num_bg"],
            fg=theme["line_num_fg"],
            font=self.mono_font,
            state="disabled",
            bd=0,
            highlightthickness=0,
            takefocus=0,
        )
        self.linenumbers.pack(side="left", fill="y")

        # Main Code Text Area
        self.code_text = tk.Text(
            self,
            bg=theme["bg_editor"],
            fg=theme["fg_text"],
            insertbackground=theme["fg_text"],
            selectbackground=theme["accent"],
            font=self.mono_font,
            undo=True,
            wrap="none",
            bd=0,
            highlightthickness=0,
            padx=8,
            yscrollcommand=self._on_editor_scroll,
        )
        self.code_text.pack(side="left", fill="both", expand=True)

        # Key & Mouse Bindings
        self.code_text.bind("<KeyRelease>", self._on_key_release)
        self.code_text.bind("<Tab>", self._on_tab_key)
        self.code_text.bind("<Return>", self._on_return_key)
        self.code_text.bind("<ButtonRelease-1>", self._on_click)

    def _on_editor_scroll(self, first, last):
        self.v_scroll.set(first, last)
        self.linenumbers.yview_moveto(first)

    def _on_scrollbar_move(self, *args):
        self.code_text.yview(*args)
        self.linenumbers.yview(*args)

    def _on_tab_key(self, event):
        self.code_text.insert("insert", "    ")
        self._on_key_release()
        return "break"

    def _on_return_key(self, event):
        line_start = self.code_text.index("insert linestart")
        line_text = self.code_text.get(line_start, "insert")
        indent = len(line_text) - len(line_text.lstrip(" "))
        extra = "    " if line_text.rstrip().endswith(":") else ""
        self.code_text.insert("insert", "\n" + (" " * indent) + extra)
        self._on_key_release()
        return "break"

    def _on_key_release(self, event=None):
        self.update_line_numbers()
        self.highlighter.highlight()
        if self.on_change:
            self.on_change()
        if self.on_cursor_move:
            self._notify_cursor()

    def _on_click(self, event=None):
        if self.on_cursor_move:
            self._notify_cursor()

    def _notify_cursor(self):
        index = self.code_text.index("insert")
        line, col = index.split(".")
        self.on_cursor_move(f"Ln {line}, Col {int(col) + 1}")

    def update_line_numbers(self):
        content = self.code_text.get("1.0", "end-1c")
        n_lines = content.count("\n") + 1
        numbers = "\n".join(str(i) for i in range(1, n_lines + 1))
        self.linenumbers.config(state="normal")
        self.linenumbers.delete("1.0", "end")
        self.linenumbers.insert("1.0", numbers)
        self.linenumbers.config(state="disabled")
        self.linenumbers.yview_moveto(self.code_text.yview()[0])

    def get_code(self):
        return self.code_text.get("1.0", "end-1c")

    def set_code(self, content):
        self.code_text.delete("1.0", "end")
        self.code_text.insert("1.0", content)
        self.update_line_numbers()
        self.highlighter.highlight()

    def apply_theme(self, theme):
        self.config(bg=theme["bg_editor"])
        self.code_text.config(
            bg=theme["bg_editor"],
            fg=theme["fg_text"],
            insertbackground=theme["fg_text"],
            selectbackground=theme["accent"],
        )
        self.linenumbers.config(
            bg=theme["line_num_bg"],
            fg=theme["line_num_fg"],
        )
        self.highlighter.configure_tags(theme)
        self.highlighter.highlight()
