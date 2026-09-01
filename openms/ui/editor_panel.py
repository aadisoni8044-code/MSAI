"""
Tabbed Code Editor Panel Component
"""

import os
import tkinter as tk
from tkinter import ttk, messagebox
from openms.ui.syntax_highlighter import SyntaxHighlighter
from openms.config import DEFAULT_SCRIPT


class EditorTabFrame(tk.Frame):
    """A single editor tab containing line numbers canvas and text code area."""

    def __init__(self, parent, theme_manager, file_path=None, initial_content=None, on_cursor_change_cb=None):
        self.theme_manager = theme_manager
        theme = theme_manager.theme
        super().__init__(parent, bg=theme["bg_editor"])

        self.file_path = file_path
        self.is_dirty = False
        self.on_cursor_change = on_cursor_change_cb

        self.theme_manager.register(self.apply_theme)
        self._build_editor(initial_content)

    def _build_editor(self, initial_content):
        theme = self.theme_manager.theme

        # Scrollbar
        self.v_scrollbar = ttk.Scrollbar(self, orient="vertical", command=self._on_scrollbar_move)
        self.v_scrollbar.pack(side="right", fill="y")

        # Line numbers canvas/text
        self.linenumbers = tk.Text(
            self,
            width=4,
            padx=4,
            pady=6,
            takefocus=0,
            border=0,
            bg=theme["bg_editor"],
            fg=theme["line_number_fg"],
            state="disabled",
            wrap="none",
            font=("Consolas", 11),
            highlightthickness=0,
        )
        self.linenumbers.pack(side="left", fill="y")

        # Separator line
        self.sep = tk.Frame(self, width=1, bg=theme["border"])
        self.sep.pack(side="left", fill="y")

        # Code Text Widget
        self.code_text = tk.Text(
            self,
            bg=theme["bg_editor"],
            fg=theme["fg_editor"],
            insertbackground=theme["fg_editor"],
            selectbackground=theme["accent_blue"],
            selectforeground="#ffffff",
            font=("Consolas", 11),
            wrap="none",
            undo=True,
            padx=8,
            pady=6,
            border=0,
            highlightthickness=0,
            yscrollcommand=self._on_editor_scroll,
        )
        self.code_text.pack(fill="both", expand=True)

        # Highlighting engine
        self.highlighter = SyntaxHighlighter(self.code_text, self.theme_manager)

        # Content initialization
        content = initial_content if initial_content is not None else (
            self._read_file(self.file_path) if self.file_path else DEFAULT_SCRIPT
        )
        self.code_text.insert("1.0", content)

        # Event bindings
        self.code_text.bind("<<Modified>>", self._on_text_modified)
        self.code_text.bind("<KeyRelease>", self._on_key_release)
        self.code_text.bind("<Tab>", self._on_tab_key)
        self.code_text.bind("<Return>", self._on_return_key)
        self.code_text.bind("<ButtonRelease-1>", self._on_cursor_move)
        self.code_text.bind("<MouseWheel>", self._on_mousewheel)
        self.code_text.bind("<Button-4>", self._on_mousewheel)
        self.code_text.bind("<Button-5>", self._on_mousewheel)

        self.update_line_numbers()
        self.highlighter.highlight_all()

    def _read_file(self, path):
        try:
            with open(path, "r", encoding="utf-8", errors="replace") as f:
                return f.read()
        except Exception as e:
            messagebox.showerror("Error", f"Failed to load file: {e}")
            return ""

    def _on_text_modified(self, event=None):
        if self.code_text.edit_modified():
            self.is_dirty = True
            self.code_text.edit_modified(False)
            self.update_line_numbers()
            self.highlighter.highlight_all()

    def _on_key_release(self, event=None):
        self._on_cursor_move()

    def _on_cursor_move(self, event=None):
        if self.on_cursor_change:
            idx = self.code_text.index("insert")
            line, col = idx.split(".")
            self.on_cursor_change(int(line), int(col) + 1)

    def _on_editor_scroll(self, first, last):
        self.v_scrollbar.set(first, last)
        self.linenumbers.yview_moveto(first)

    def _on_scrollbar_move(self, *args):
        self.code_text.yview(*args)
        self.linenumbers.yview(*args)

    def _on_mousewheel(self, event):
        delta = -1 if getattr(event, "delta", 0) > 0 or event.num == 4 else 1
        self.code_text.yview_scroll(delta, "units")
        self.linenumbers.yview_scroll(delta, "units")
        return "break"

    def _on_tab_key(self, event):
        self.code_text.insert("insert", "    ")
        return "break"

    def _on_return_key(self, event):
        line_start = self.code_text.index("insert linestart")
        line_text = self.code_text.get(line_start, "insert")
        indent = len(line_text) - len(line_text.lstrip(" "))
        extra = "    " if line_text.rstrip().endswith(":") else ""
        self.code_text.insert("insert", "\n" + (" " * indent) + extra)
        self.update_line_numbers()
        return "break"

    def update_line_numbers(self):
        content = self.code_text.get("1.0", "end-1c")
        n_lines = content.count("\n") + 1
        numbers = "\n".join(str(i) for i in range(1, n_lines + 1))
        self.linenumbers.config(state="normal")
        self.linenumbers.delete("1.0", "end")
        self.linenumbers.insert("1.0", numbers)
        self.linenumbers.config(state="disabled")
        self.linenumbers.yview_moveto(self.code_text.yview()[0])

    def apply_theme(self, theme):
        self.config(bg=theme["bg_editor"])
        self.linenumbers.config(
            bg=theme["bg_editor"], fg=theme["line_number_fg"]
        )
        self.sep.config(bg=theme["border"])
        self.code_text.config(
            bg=theme["bg_editor"],
            fg=theme["fg_editor"],
            insertbackground=theme["fg_editor"],
            selectbackground=theme["accent_blue"],
        )
        self.highlighter.highlight_all()


class EditorPanel(tk.Frame):
    """VS Code Code Editor Panel with tabbed document support."""

    def __init__(self, parent, theme_manager, on_cursor_change_cb=None):
        self.theme_manager = theme_manager
        theme = theme_manager.theme
        super().__init__(parent, bg=theme["bg_main"])

        self.on_cursor_change = on_cursor_change_cb
        self.tabs = {}
        self.active_tab_id = None

        self.theme_manager.register(self.apply_theme)
        self._build_panel()

    def _build_panel(self):
        # Tab bar header
        self.tab_bar = tk.Frame(self, bg=self.theme_manager.theme["bg_tab"], height=35)
        self.tab_bar.pack(fill="x", side="top")
        self.tab_bar.pack_propagate(False)

        # Editor content container
        self.container = tk.Frame(self, bg=self.theme_manager.theme["bg_editor"])
        self.container.pack(fill="both", expand=True)

        # Open initial tab
        self.open_tab("untitled.game")

    def open_tab(self, file_path_or_title, content=None):
        tab_id = file_path_or_title
        if tab_id in self.tabs:
            self.select_tab(tab_id)
            return self.tabs[tab_id]

        file_path = file_path_or_title if os.path.exists(file_path_or_title) else None
        title = os.path.basename(file_path_or_title)

        tab_frame = EditorTabFrame(
            self.container,
            self.theme_manager,
            file_path=file_path,
            initial_content=content,
            on_cursor_change_cb=self.on_cursor_change,
        )

        tab_btn_frame = tk.Frame(self.tab_bar, bg=self.theme_manager.theme["bg_tab"])
        tab_btn_frame.pack(side="left", fill="y", padx=1)

        btn = tk.Button(
            tab_btn_frame,
            text=f"  {title} ",
            font=("Segoe UI", 9),
            bd=0,
            relief="flat",
            cursor="hand2",
            command=lambda: self.select_tab(tab_id),
        )
        btn.pack(side="left", fill="y")

        close_btn = tk.Button(
            tab_btn_frame,
            text="✕ ",
            font=("Segoe UI", 8),
            bd=0,
            relief="flat",
            cursor="hand2",
            command=lambda: self.close_tab(tab_id),
        )
        close_btn.pack(side="right", fill="y")

        self.tabs[tab_id] = {
            "title": title,
            "frame": tab_frame,
            "btn_frame": tab_btn_frame,
            "btn": btn,
            "close_btn": close_btn,
            "path": file_path,
        }

        self.select_tab(tab_id)
        return tab_frame

    def select_tab(self, tab_id):
        if tab_id not in self.tabs:
            return
        theme = self.theme_manager.theme

        for tid, tab_info in self.tabs.items():
            tab_info["frame"].pack_forget()
            tab_info["btn_frame"].config(bg=theme["bg_tab"])
            tab_info["btn"].config(bg=theme["bg_tab"], fg=theme["fg_sidebar"])
            tab_info["close_btn"].config(bg=theme["bg_tab"], fg=theme["fg_sidebar"])

        self.active_tab_id = tab_id
        active = self.tabs[tab_id]
        active["frame"].pack(fill="both", expand=True)
        active["btn_frame"].config(bg=theme["bg_active_tab"])
        active["btn"].config(bg=theme["bg_active_tab"], fg=theme["fg_active_tab"])
        active["close_btn"].config(bg=theme["bg_active_tab"], fg=theme["fg_active_tab"])

    def close_tab(self, tab_id):
        if tab_id not in self.tabs:
            return
        tab_info = self.tabs.pop(tab_id)
        tab_info["btn_frame"].destroy()
        tab_info["frame"].destroy()

        if self.active_tab_id == tab_id:
            self.active_tab_id = None
            if self.tabs:
                next_id = next(iter(self.tabs))
                self.select_tab(next_id)

    def get_active_tab(self):
        if self.active_tab_id and self.active_tab_id in self.tabs:
            return self.tabs[self.active_tab_id]
        return None

    def get_active_code(self):
        active = self.get_active_tab()
        if active:
            return active["frame"].code_text.get("1.0", "end-1c")
        return ""

    def set_active_code(self, code):
        active = self.get_active_tab()
        if active:
            active["frame"].code_text.delete("1.0", "end")
            active["frame"].code_text.insert("1.0", code)
            active["frame"].update_line_numbers()
            active["frame"].highlighter.highlight_all()

    def apply_theme(self, theme):
        self.config(bg=theme["bg_main"])
        self.tab_bar.config(bg=theme["bg_tab"])
        self.container.config(bg=theme["bg_editor"])
        if self.active_tab_id:
            self.select_tab(self.active_tab_id)
