"""
NV Studio Code Editor Panel
Provides multi-tab editor, line numbers, syntax highlighting, autocomplete suggestions, search and replace bar, and auto-save.
"""

import os
import re
import tkinter as tk
from tkinter import ttk
from typing import Callable, Dict, List, Optional
import customtkinter as ctk

from nvstudio.ui.theme import get_theme


HTML_AUTOCOMPLETE = [
    "<!DOCTYPE html>", "html", "head", "title", "body", "div", "span", "header",
    "footer", "nav", "main", "section", "article", "h1", "h2", "h3", "p", "a",
    "button", "input", "form", "ul", "ol", "li", "img", "script", "link", "style",
]

CSS_AUTOCOMPLETE = [
    "color", "background", "background-color", "font-family", "font-size",
    "font-weight", "padding", "margin", "display", "flex", "grid", "position",
    "width", "height", "border", "border-radius", "justify-content", "align-items",
    "box-shadow", "cursor", "transition", "transform", "opacity",
]

JS_AUTOCOMPLETE = [
    "function", "const", "let", "var", "return", "if", "else", "for", "while",
    "document.getElementById", "querySelector", "querySelectorAll", "addEventListener",
    "console.log", "console.error", "setTimeout", "fetch", "async", "await",
]


class SyntaxHighlighter:
    """Regex-based syntax highlighter for Tkinter Text widget."""

    def __init__(self, text_widget: tk.Text, theme: Dict[str, str]):
        self.text = text_widget
        self.theme = theme
        self._configure_tags()

    def update_theme(self, theme: Dict[str, str]) -> None:
        self.theme = theme
        self._configure_tags()

    def _configure_tags(self) -> None:
        t = self.theme
        self.text.tag_configure("syn_tag", foreground=t["syn_tag"], font=("Consolas", 11, "bold"))
        self.text.tag_configure("syn_attr", foreground=t["syn_attr"])
        self.text.tag_configure("syn_keyword", foreground=t["syn_keyword"], font=("Consolas", 11, "bold"))
        self.text.tag_configure("syn_string", foreground=t["syn_string"])
        self.text.tag_configure("syn_comment", foreground=t["syn_comment"], font=("Consolas", 11, "italic"))
        self.text.tag_configure("syn_number", foreground=t["syn_number"])

    def highlight(self, filename: str) -> None:
        ext = os.path.splitext(filename)[1].lower()
        for tag in ["syn_tag", "syn_attr", "syn_keyword", "syn_string", "syn_comment", "syn_number"]:
            self.text.tag_remove(tag, "1.0", tk.END)

        content = self.text.get("1.0", tk.END)
        if not content.strip():
            return

        if ext == ".html":
            self._highlight_pattern(r"<![^>]+>", "syn_comment")
            self._highlight_pattern(r"<!--[\s\S]*?-->", "syn_comment")
            self._highlight_pattern(r"</?[a-zA-Z0-9\-]+", "syn_tag")
            self._highlight_pattern(r'>', "syn_tag")
            self._highlight_pattern(r'\b[a-zA-Z\-]+(?=\=)', "syn_attr")
            self._highlight_pattern(r'"[^"]*"', "syn_string")
            self._highlight_pattern(r"'[^']*'", "syn_string")

        elif ext == ".css":
            self._highlight_pattern(r"/\*[\s\S]*?\*/", "syn_comment")
            self._highlight_pattern(r"\b(color|background|font|padding|margin|display|flex|grid|position|width|height|border|radius|box-shadow|cursor|transition|transform|opacity)\b", "syn_keyword")
            self._highlight_pattern(r"#[0-9a-fA-F]{3,8}\b", "syn_attr")
            self._highlight_pattern(r"\b\d+(px|em|rem|%|vh|vw|s|ms)?\b", "syn_number")
            self._highlight_pattern(r'"[^"]*"', "syn_string")

        elif ext in [".js", ".json"]:
            self._highlight_pattern(r"//.*$", "syn_comment")
            self._highlight_pattern(r"/\*[\s\S]*?\*/", "syn_comment")
            self._highlight_pattern(r"\b(function|const|let|var|return|if|else|for|while|async|await|import|export|class|new|this|true|false|null|undefined)\b", "syn_keyword")
            self._highlight_pattern(r'"[^"]*"', "syn_string")
            self._highlight_pattern(r"'[^']*'", "syn_string")
            self._highlight_pattern(r"`[^`]*`", "syn_string")
            self._highlight_pattern(r"\b\d+\b", "syn_number")

    def _highlight_pattern(self, pattern: str, tag: str) -> None:
        content = self.text.get("1.0", tk.END)
        for match in re.finditer(pattern, content, re.MULTILINE):
            start_idx = f"1.0 + {match.start()} chars"
            end_idx = f"1.0 + {match.end()} chars"
            self.text.tag_add(tag, start_idx, end_idx)


class CodeEditorTab(ctk.CTkFrame):
    """Single File Code Editor View with line numbers, text editor, and autocomplete."""

    def __init__(
        self,
        parent: tk.Widget,
        rel_path: str,
        content: str,
        theme_name: str,
        on_content_changed: Callable[[], None],
    ):
        super().__init__(parent, fg_color="transparent", corner_radius=0)
        self.rel_path = rel_path
        self.theme_name = theme_name
        self.theme = get_theme(theme_name)
        self.on_content_changed = on_content_changed

        self._create_widgets()
        self.set_content(content)

    def _create_widgets(self) -> None:
        # Frame Container
        self.editor_frame = ctk.CTkFrame(
            self, fg_color=self.theme["bg_editor"], corner_radius=0
        )
        self.editor_frame.pack(fill="both", expand=True)

        # Line Numbers Canvas
        self.line_canvas = tk.Canvas(
            self.editor_frame,
            width=45,
            bg=self.theme["line_number_bg"],
            highlightthickness=0,
            bd=0,
        )
        self.line_canvas.pack(side="left", fill="y")

        # Scrollbar
        self.scrollbar = ttk.Scrollbar(self.editor_frame, orient="vertical")
        self.scrollbar.pack(side="right", fill="y")

        # Text Widget
        self.text = tk.Text(
            self.editor_frame,
            bg=self.theme["bg_editor"],
            fg=self.theme["fg_text"],
            insertbackground=self.theme["accent"],
            selectbackground=self.theme["accent"],
            selectforeground=self.theme["accent_fg"],
            font=("Consolas", 11),
            bd=0,
            padx=8,
            pady=8,
            wrap="none",
            undo=True,
            yscrollcommand=self._on_scroll,
        )
        self.text.pack(side="left", fill="both", expand=True)
        self.scrollbar.config(command=self.text.yview)

        self.highlighter = SyntaxHighlighter(self.text, self.theme)

        # Event Bindings
        self.text.bind("<KeyRelease>", self._on_key_release)
        self.text.bind("<Button-1>", lambda e: self.after(10, self._update_line_numbers))
        self.text.bind("<MouseWheel>", lambda e: self.after(10, self._update_line_numbers))

        # Autocomplete Listbox popup
        self.ac_box: Optional[tk.Listbox] = None

    def set_content(self, content: str) -> None:
        self.text.delete("1.0", tk.END)
        self.text.insert("1.0", content)
        self._update_line_numbers()
        self.highlighter.highlight(self.rel_path)

    def get_content(self) -> str:
        return self.text.get("1.0", "end-1c")

    def apply_theme(self, theme_name: str) -> None:
        self.theme_name = theme_name
        self.theme = get_theme(theme_name)
        self.editor_frame.configure(fg_color=self.theme["bg_editor"])
        self.line_canvas.configure(bg=self.theme["line_number_bg"])
        self.text.configure(
            bg=self.theme["bg_editor"],
            fg=self.theme["fg_text"],
            insertbackground=self.theme["accent"],
            selectbackground=self.theme["accent"],
            selectforeground=self.theme["accent_fg"],
        )
        self.highlighter.update_theme(self.theme)
        self.highlighter.highlight(self.rel_path)
        self._update_line_numbers()

    def _on_scroll(self, *args) -> None:
        self.scrollbar.set(*args)
        self._update_line_numbers()

    def _update_line_numbers(self) -> None:
        self.line_canvas.delete("all")
        i = self.text.index("@0,0")
        while True:
            dline = self.text.dlineinfo(i)
            if dline is None:
                break
            y = dline[1]
            linenum = str(i).split(".")[0]
            self.line_canvas.create_text(
                36,
                y + 2,
                anchor="ne",
                text=linenum,
                fill=self.theme["line_number_fg"],
                font=("Consolas", 10),
            )
            i = self.text.index(f"{i}+1line")

    def _on_key_release(self, event: tk.Event) -> None:
        self._update_line_numbers()
        self.highlighter.highlight(self.rel_path)
        self.on_content_changed()

        # Handle Autocomplete popup
        if event.keysym in ["BackSpace", "Return", "Escape", "Tab", "Up", "Down"]:
            self._hide_autocomplete()
            return

        if event.char and event.char.isalnum():
            self._trigger_autocomplete()

    def _trigger_autocomplete(self) -> None:
        cursor_pos = self.text.index(tk.INSERT)
        line, col = cursor_pos.split(".")
        line_text = self.text.get(f"{line}.0", cursor_pos)

        word_match = re.search(r"(\w+)$", line_text)
        if not word_match:
            self._hide_autocomplete()
            return

        prefix = word_match.group(1).lower()
        ext = os.path.splitext(self.rel_path)[1].lower()

        suggestions = []
        if ext == ".html":
            suggestions = [s for s in HTML_AUTOCOMPLETE if s.lower().startswith(prefix)]
        elif ext == ".css":
            suggestions = [s for s in CSS_AUTOCOMPLETE if s.lower().startswith(prefix)]
        elif ext in [".js", ".json"]:
            suggestions = [s for s in JS_AUTOCOMPLETE if s.lower().startswith(prefix)]

        if suggestions and len(prefix) >= 2:
            self._show_autocomplete(suggestions, prefix)
        else:
            self._hide_autocomplete()

    def _show_autocomplete(self, suggestions: List[str], prefix: str) -> None:
        self._hide_autocomplete()

        bbox = self.text.bbox(tk.INSERT)
        if not bbox:
            return
        x, y, w, h = bbox

        self.ac_box = tk.Listbox(
            self.text,
            bg=self.theme["bg_panel"],
            fg=self.theme["fg_text"],
            selectbackground=self.theme["accent"],
            selectforeground=self.theme["accent_fg"],
            bd=1,
            relief="solid",
            font=("Consolas", 10),
            height=min(5, len(suggestions)),
        )
        for s in suggestions:
            self.ac_box.insert(tk.END, s)

        self.ac_box.place(x=x, y=y + h + 2, width=180)
        self.ac_box.bind("<Button-1>", lambda e: self._apply_autocomplete(prefix))

    def _apply_autocomplete(self, prefix: str) -> None:
        if not self.ac_box or not self.ac_box.curselection():
            return
        selected = self.ac_box.get(self.ac_box.curselection()[0])
        cursor_pos = self.text.index(tk.INSERT)
        start_pos = f"{cursor_pos} - {len(prefix)} chars"

        self.text.delete(start_pos, cursor_pos)
        self.text.insert(start_pos, selected)
        self._hide_autocomplete()
        self.highlighter.highlight(self.rel_path)

    def _hide_autocomplete(self) -> None:
        if self.ac_box:
            self.ac_box.destroy()
            self.ac_box = None


class CodeEditorPanel(ctk.CTkFrame):
    """Center Code Editor Panel with Tab navigation, Search & Replace, Save button, and line numbers."""

    def __init__(
        self,
        parent: tk.Widget,
        theme_name: str,
        on_content_saved: Callable[[str, str], None],
        on_run_requested: Callable[[], None],
    ):
        super().__init__(parent, fg_color="transparent", corner_radius=0)

        self.theme_name = theme_name
        self.theme = get_theme(theme_name)
        self.on_content_saved = on_content_saved
        self.on_run_requested = on_run_requested

        self.tabs: Dict[str, CodeEditorTab] = {}
        self.active_tab_key: Optional[str] = None

        self._create_top_bar()
        self._create_search_replace_bar()
        self._create_editor_container()

    def _create_top_bar(self) -> None:
        """Top Header containing file tab buttons and Save / Search buttons."""
        self.top_bar = ctk.CTkFrame(
            self, fg_color=self.theme["bg_sidebar"], corner_radius=0, height=38
        )
        self.top_bar.pack(fill="x", side="top")

        # Tab Scrollable Frame
        self.tabs_frame = ctk.CTkFrame(
            self.top_bar, fg_color="transparent", corner_radius=0
        )
        self.tabs_frame.pack(side="left", fill="both", expand=True, padx=4)

        # Right Action Buttons
        btn_save = ctk.CTkButton(
            self.top_bar,
            text="💾 Save",
            font=ctk.CTkFont(size=11, weight="bold"),
            fg_color=self.theme["bg_input"],
            hover_color=self.theme["border"],
            text_color=self.theme["fg_text"],
            width=65,
            height=26,
            command=self.save_active_file,
        )
        btn_save.pack(side="right", padx=6, pady=6)

        btn_find = ctk.CTkButton(
            self.top_bar,
            text="🔍 Find",
            font=ctk.CTkFont(size=11),
            fg_color="transparent",
            hover_color=self.theme["bg_input"],
            text_color=self.theme["fg_text"],
            width=60,
            height=26,
            command=self.toggle_search_bar,
        )
        btn_find.pack(side="right", padx=2, pady=6)

    def _create_search_replace_bar(self) -> None:
        """Collapsible Search and Replace Toolbar."""
        self.search_frame = ctk.CTkFrame(
            self, fg_color=self.theme["bg_panel"], corner_radius=0, height=36
        )
        # Initially hidden

        self.entry_find = ctk.CTkEntry(
            self.search_frame,
            placeholder_text="Find...",
            width=140,
            height=26,
            font=ctk.CTkFont(size=11),
        )
        self.entry_find.pack(side="left", padx=6, pady=5)

        self.entry_replace = ctk.CTkEntry(
            self.search_frame,
            placeholder_text="Replace...",
            width=140,
            height=26,
            font=ctk.CTkFont(size=11),
        )
        self.entry_replace.pack(side="left", padx=4, pady=5)

        btn_next = ctk.CTkButton(
            self.search_frame,
            text="Find Next",
            width=65,
            height=26,
            font=ctk.CTkFont(size=11),
            command=self._find_next,
        )
        btn_next.pack(side="left", padx=4)

        btn_rep = ctk.CTkButton(
            self.search_frame,
            text="Replace",
            width=60,
            height=26,
            font=ctk.CTkFont(size=11),
            command=self._replace_one,
        )
        btn_rep.pack(side="left", padx=2)

        btn_rep_all = ctk.CTkButton(
            self.search_frame,
            text="All",
            width=40,
            height=26,
            font=ctk.CTkFont(size=11),
            command=self._replace_all,
        )
        btn_rep_all.pack(side="left", padx=2)

        btn_close_s = ctk.CTkButton(
            self.search_frame,
            text="✕",
            width=26,
            height=26,
            fg_color="transparent",
            text_color=self.theme["fg_subtext"],
            command=self.toggle_search_bar,
        )
        btn_close_s.pack(side="right", padx=6)

    def _create_editor_container(self) -> None:
        """Main editor area containing active file tab frames."""
        self.container = ctk.CTkFrame(
            self, fg_color=self.theme["bg_editor"], corner_radius=0
        )
        self.container.pack(fill="both", expand=True, side="top")

    def toggle_search_bar(self) -> None:
        if self.search_frame.winfo_ismapped():
            self.search_frame.pack_forget()
        else:
            self.search_frame.pack(fill="x", side="top", before=self.container)
            self.entry_find.focus_set()

    def open_tab(self, rel_path: str, content: str) -> None:
        """Opens or switches to a file tab."""
        if rel_path in self.tabs:
            self.switch_to_tab(rel_path)
            return

        # Create new tab view
        tab_view = CodeEditorTab(
            self.container,
            rel_path=rel_path,
            content=content,
            theme_name=self.theme_name,
            on_content_changed=lambda: self._on_file_edited(rel_path),
        )
        self.tabs[rel_path] = tab_view
        self.switch_to_tab(rel_path)
        self._rerender_tab_buttons()

    def switch_to_tab(self, rel_path: str) -> None:
        """Switches active view to target file tab."""
        if rel_path not in self.tabs:
            return

        for k, v in self.tabs.items():
            v.pack_forget()

        self.tabs[rel_path].pack(fill="both", expand=True)
        self.active_tab_key = rel_path
        self._rerender_tab_buttons()

    def close_tab(self, rel_path: str) -> None:
        """Closes a file tab."""
        if rel_path in self.tabs:
            self.tabs[rel_path].destroy()
            del self.tabs[rel_path]

        if self.active_tab_key == rel_path:
            self.active_tab_key = next(iter(self.tabs.keys())) if self.tabs else None
            if self.active_tab_key:
                self.switch_to_tab(self.active_tab_key)

        self._rerender_tab_buttons()

    def _rerender_tab_buttons(self) -> None:
        """Renders file tab buttons in top bar."""
        for child in self.tabs_frame.winfo_children():
            child.destroy()

        for rel_path in list(self.tabs.keys()):
            is_active = rel_path == self.active_tab_key
            filename = os.path.basename(rel_path)

            bg = self.theme["bg_tab_active"] if is_active else self.theme["bg_tab"]
            fg = self.theme["fg_text"] if is_active else self.theme["fg_subtext"]

            tab_btn_frame = ctk.CTkFrame(
                self.tabs_frame, fg_color=bg, corner_radius=6, height=28
            )
            tab_btn_frame.pack(side="left", padx=2, pady=4)

            btn = ctk.CTkButton(
                tab_btn_frame,
                text=filename,
                font=ctk.CTkFont(size=11, weight="bold" if is_active else "normal"),
                fg_color="transparent",
                hover_color=self.theme["bg_input"],
                text_color=fg,
                height=26,
                command=lambda p=rel_path: self.switch_to_tab(p),
            )
            btn.pack(side="left", padx=(6, 2))

            btn_close = ctk.CTkButton(
                tab_btn_frame,
                text="×",
                font=ctk.CTkFont(size=12),
                fg_color="transparent",
                hover_color=self.theme["danger"],
                text_color=fg,
                width=18,
                height=26,
                command=lambda p=rel_path: self.close_tab(p),
            )
            btn_close.pack(side="right", padx=(0, 4))

    def _on_file_edited(self, rel_path: str) -> None:
        if rel_path in self.tabs:
            content = self.tabs[rel_path].get_content()
            self.on_content_saved(rel_path, content)

    def save_active_file(self) -> None:
        if self.active_tab_key and self.active_tab_key in self.tabs:
            content = self.tabs[self.active_tab_key].get_content()
            self.on_content_saved(self.active_tab_key, content)

    def set_theme(self, theme_name: str) -> None:
        self.theme_name = theme_name
        self.theme = get_theme(theme_name)

        self.top_bar.configure(fg_color=self.theme["bg_sidebar"])
        self.search_frame.configure(fg_color=self.theme["bg_panel"])
        self.container.configure(fg_color=self.theme["bg_editor"])

        for tab in self.tabs.values():
            tab.apply_theme(theme_name)

        self._rerender_tab_buttons()

    def _find_next(self) -> None:
        if not self.active_tab_key or self.active_tab_key not in self.tabs:
            return
        query = self.entry_find.get()
        if not query:
            return

        txt = self.tabs[self.active_tab_key].text
        start_pos = txt.index(tk.INSERT)
        pos = txt.search(query, start_pos, stopindex=tk.END, nocase=True)
        if not pos:
            pos = txt.search(query, "1.0", stopindex=start_pos, nocase=True)

        if pos:
            end_pos = f"{pos}+{len(query)}c"
            txt.tag_remove("sel", "1.0", tk.END)
            txt.tag_add("sel", pos, end_pos)
            txt.mark_set(tk.INSERT, end_pos)
            txt.see(pos)

    def _replace_one(self) -> None:
        if not self.active_tab_key or self.active_tab_key not in self.tabs:
            return
        txt = self.tabs[self.active_tab_key].text
        if txt.tag_ranges("sel"):
            query = self.entry_find.get()
            rep = self.entry_replace.get()
            sel_text = txt.get("sel.first", "sel.last")
            if sel_text.lower() == query.lower():
                txt.replace("sel.first", "sel.last", rep)
                self._find_next()

    def _replace_all(self) -> None:
        if not self.active_tab_key or self.active_tab_key not in self.tabs:
            return
        query = self.entry_find.get()
        rep = self.entry_replace.get()
        if not query:
            return

        txt = self.tabs[self.active_tab_key].text
        content = txt.get("1.0", tk.END)
        new_content = re.sub(re.escape(query), rep, content, flags=re.IGNORECASE)
        txt.delete("1.0", tk.END)
        txt.insert("1.0", new_content)
        self._on_file_edited(self.active_tab_key)
