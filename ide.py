"""
Jps Script Desktop IDE
Built with Tkinter and CustomTkinter / ttk.
Features:
- Multi-tab code editor with line numbers and Jps script syntax highlighting.
- Toolbar with Run button, New, Open, Save operations.
- Embedded terminal / output console for compilation and execution logs.
- Status bar showing active file info, cursor line/col, and execution status.
"""

import os
import sys
import re
import tkinter as tk
from tkinter import ttk, filedialog, messagebox
import customtkinter as ctk

from lexer import Lexer, LexerError
from parser import Parser, ParserError
from interpreter import Interpreter, InterpreterError

# Configure CustomTkinter theme
ctk.set_appearance_mode("Dark")
ctk.set_default_color_theme("blue")

DARK_BG = "#0B0F19"
EDITOR_BG = "#131B2E"
TEXT_FG = "#E2E8F0"
CURSOR_FG = "#00F0FF"
LINENUM_BG = "#0F172A"
LINENUM_FG = "#475569"
CONSOLE_BG = "#0A0D14"

# Syntax Highlighting Colors
COLOR_KEYWORD = "#00F0FF"   # Cyan (import, print)
COLOR_MODULE = "#A855F7"    # Purple (box, game)
COLOR_ACTION = "#38BDF8"    # Light Blue (body_2D, size, run, switch)
COLOR_STRING = "#10B981"    # Green
COLOR_NUMBER = "#F59E0B"    # Amber
COLOR_COMMENT = "#64748B"   # Slate Gray
COLOR_OPERATOR = "#EC4899"  # Pink

class TextLineNumbers(tk.Canvas):
    def __init__(self, parent, text_widget, **kwargs):
        super().__init__(parent, **kwargs)
        self.text_widget = text_widget
        self.config(bg=LINENUM_BG, highlightthickness=0, width=45)

    def redraw(self, *args):
        self.delete("all")
        i = self.text_widget.index("@0,0")
        while True:
            dline = self.text_widget.dlineinfo(i)
            if dline is None:
                break
            y = dline[1]
            linenum = str(i).split(".")[0]
            self.create_text(
                38, y + 2,
                anchor="ne",
                text=linenum,
                fill=LINENUM_FG,
                font=("Courier", 11)
            )
            i = self.text_widget.index(f"{i}+1line")

class CodeEditor(tk.Frame):
    KEYWORDS = r"\b(import|print)\b"
    MODULES = r"\b(box|game)\b"
    ACTIONS = r"\b(body_2D|size|run|switch)\b"
    STRINGS = r'"[^"\n]*"|\'[^\'\n]*\''
    NUMBERS = r"\b\d+(\.\d+)?\b"
    COMMENTS = r"(#|//).*$"

    def __init__(self, parent, **kwargs):
        super().__init__(parent, bg=EDITOR_BG, **kwargs)

        # Scrollbar
        self.v_scrollbar = ttk.Scrollbar(self, orient="vertical")
        self.v_scrollbar.pack(side="right", fill="y")

        # Text Widget
        self.text = tk.Text(
            self,
            wrap="none",
            bg=EDITOR_BG,
            fg=TEXT_FG,
            insertbackground=CURSOR_FG,
            selectbackground="#1E293B",
            selectforeground="#FFFFFF",
            font=("Courier", 12),
            undo=True,
            borderwidth=0,
            relief="flat",
            yscrollcommand=self._on_scroll
        )
        self.text.pack(side="right", fill="both", expand=True)
        self.v_scrollbar.config(command=self._on_text_scroll)

        # Line Numbers Canvas
        self.line_numbers = TextLineNumbers(self, self.text)
        self.line_numbers.pack(side="left", fill="y")

        # Bind events
        self.text.bind("<KeyRelease>", self._on_key_release)
        self.text.bind("<MouseWheel>", lambda e: self.after_idle(self.line_numbers.redraw))
        self.text.bind("<Button-1>", lambda e: self.after_idle(self.line_numbers.redraw))
        self.text.bind("<Configure>", lambda e: self.after_idle(self.line_numbers.redraw))

        self._setup_tags()

    def _setup_tags(self):
        self.text.tag_configure("keyword", foreground=COLOR_KEYWORD, font=("Courier", 12, "bold"))
        self.text.tag_configure("module", foreground=COLOR_MODULE, font=("Courier", 12, "bold"))
        self.text.tag_configure("action", foreground=COLOR_ACTION)
        self.text.tag_configure("string", foreground=COLOR_STRING)
        self.text.tag_configure("number", foreground=COLOR_NUMBER)
        self.text.tag_configure("comment", foreground=COLOR_COMMENT, font=("Courier", 12, "italic"))
        self.text.tag_configure("operator", foreground=COLOR_OPERATOR)

    def _on_scroll(self, *args):
        self.v_scrollbar.set(*args)
        self.line_numbers.redraw()

    def _on_text_scroll(self, *args):
        self.text.yview(*args)
        self.line_numbers.redraw()

    def _on_key_release(self, event=None):
        self.line_numbers.redraw()
        self.highlight_syntax()

    def highlight_syntax(self):
        content = self.text.get("1.0", "end-1c")
        for tag in ["keyword", "module", "action", "string", "number", "comment", "operator"]:
            self.text.tag_remove(tag, "1.0", "end")

        patterns = [
            ("comment", self.COMMENTS, re.MULTILINE),
            ("string", self.STRINGS, 0),
            ("keyword", self.KEYWORDS, 0),
            ("module", self.MODULES, 0),
            ("action", self.ACTIONS, 0),
            ("number", self.NUMBERS, 0),
            ("operator", r"[=\.]", 0),
        ]

        for tag, pattern, flags in patterns:
            for match in re.finditer(pattern, content, flags):
                start_idx = f"1.0+{match.start()}c"
                end_idx = f"1.0+{match.end()}c"
                self.text.tag_add(tag, start_idx, end_idx)

    def get_text(self) -> str:
        return self.text.get("1.0", "end-1c")

    def set_text(self, content: str):
        self.text.delete("1.0", "end")
        self.text.insert("1.0", content)
        self.highlight_syntax()
        self.line_numbers.redraw()

class JpsIDE(ctk.CTk):
    def __init__(self):
        super().__init__()

        self.title("Jps Script IDE & Compiler Platform")
        self.geometry("1100, 750")

        # Active tab files dictionary {tab_frame: filepath}
        self.tab_files = {}

        self._build_menu()
        self._build_toolbar()
        self._build_main_area()
        self._build_console()
        self._build_statusbar()

        # Open initial empty tab
        self.new_file()

    def _build_menu(self):
        menubar = tk.Menu(self)

        file_menu = tk.Menu(menubar, tearoff=0)
        file_menu.add_command(label="New File", command=self.new_file, accelerator="Ctrl+N")
        file_menu.add_command(label="Open File...", command=self.open_file, accelerator="Ctrl+O")
        file_menu.add_command(label="Save", command=self.save_file, accelerator="Ctrl+S")
        file_menu.add_command(label="Save As...", command=self.save_as_file)
        file_menu.add_separator()
        file_menu.add_command(label="Close Tab", command=self.close_tab, accelerator="Ctrl+W")
        file_menu.add_command(label="Exit", command=self.quit)
        menubar.add_cascade(label="File", menu=file_menu)

        run_menu = tk.Menu(menubar, tearoff=0)
        run_menu.add_command(label="Run Script", command=self.run_code, accelerator="F5")
        menubar.add_cascade(label="Run", menu=run_menu)

        self.config(menu=menubar)

        # Bind shortcuts
        self.bind("<Control-n>", lambda e: self.new_file())
        self.bind("<Control-o>", lambda e: self.open_file())
        self.bind("<Control-s>", lambda e: self.save_file())
        self.bind("<Control-w>", lambda e: self.close_tab())
        self.bind("<F5>", lambda e: self.run_code())

    def _build_toolbar(self):
        self.toolbar = ctk.CTkFrame(self, height=45, fg_color="#0F172A", corner_radius=0)
        self.toolbar.pack(side="top", fill="x")

        # Run Button
        self.btn_run = ctk.CTkButton(
            self.toolbar,
            text="▶ Run Script (F5)",
            fg_color="#10B981",
            hover_color="#059669",
            text_color="#FFFFFF",
            font=("Arial", 12, "bold"),
            width=140,
            height=32,
            command=self.run_code
        )
        self.btn_run.pack(side="left", padx=10, pady=6)

        # File Operations Buttons
        self.btn_new = ctk.CTkButton(
            self.toolbar,
            text="📄 New",
            fg_color="#1E293B",
            hover_color="#334155",
            width=80,
            height=32,
            command=self.new_file
        )
        self.btn_new.pack(side="left", padx=4, pady=6)

        self.btn_open = ctk.CTkButton(
            self.toolbar,
            text="📂 Open",
            fg_color="#1E293B",
            hover_color="#334155",
            width=80,
            height=32,
            command=self.open_file
        )
        self.btn_open.pack(side="left", padx=4, pady=6)

        self.btn_save = ctk.CTkButton(
            self.toolbar,
            text="💾 Save",
            fg_color="#1E293B",
            hover_color="#334155",
            width=80,
            height=32,
            command=self.save_file
        )
        self.btn_save.pack(side="left", padx=4, pady=6)

        self.btn_clear_console = ctk.CTkButton(
            self.toolbar,
            text="🧹 Clear Console",
            fg_color="#1E293B",
            hover_color="#334155",
            width=120,
            height=32,
            command=self.clear_console
        )
        self.btn_clear_console.pack(side="right", padx=10, pady=6)

    def _build_main_area(self):
        # Configure custom notebook style
        style = ttk.Style()
        style.theme_use("default")
        style.configure("TNotebook", background=DARK_BG, borderwidth=0)
        style.configure("TNotebook.Tab", background="#1E293B", foreground="#94A3B8", padding=[12, 6], font=("Arial", 10))
        style.map("TNotebook.Tab", background=[("selected", EDITOR_BG)], foreground=[("selected", "#00F0FF")])

        self.notebook = ttk.Notebook(self)
        self.notebook.pack(side="top", fill="both", expand=True)

    def _build_console(self):
        self.console_frame = ctk.CTkFrame(self, height=200, fg_color=CONSOLE_BG, corner_radius=0)
        self.console_frame.pack(side="bottom", fill="x")

        # Header bar
        header = ctk.CTkFrame(self.console_frame, height=28, fg_color="#0F172A", corner_radius=0)
        header.pack(side="top", fill="x")

        lbl = ctk.CTkLabel(header, text="Terminal Console / Output", font=("Arial", 11, "bold"), text_color="#00F0FF")
        lbl.pack(side="left", padx=10)

        # Console Text Output Widget
        self.console_text = tk.Text(
            self.console_frame,
            height=8,
            bg=CONSOLE_BG,
            fg="#E2E8F0",
            font=("Courier", 11),
            borderwidth=0,
            relief="flat"
        )
        self.console_text.pack(side="top", fill="both", expand=True, padx=8, pady=4)

        # Tags for colored logging
        self.console_text.tag_config("info", foreground="#38BDF8")
        self.console_text.tag_config("success", foreground="#10B981")
        self.console_text.tag_config("error", foreground="#EF4444")
        self.console_text.tag_config("warning", foreground="#F59E0B")

    def _build_statusbar(self):
        self.statusbar = ctk.CTkFrame(self, height=24, fg_color="#0F172A", corner_radius=0)
        self.statusbar.pack(side="bottom", fill="x")

        self.status_label = ctk.CTkLabel(self.statusbar, text="Ready", font=("Arial", 10), text_color="#94A3B8")
        self.status_label.pack(side="left", padx=10)

    def log_console(self, text: str, tag: str = "info"):
        self.console_text.config(state="normal")
        self.console_text.insert("end", text, tag)
        self.console_text.see("end")
        self.console_text.config(state="disabled")

    def clear_console(self):
        self.console_text.config(state="normal")
        self.console_text.delete("1.0", "end")
        self.console_text.config(state="disabled")

    def get_current_editor(self) -> CodeEditor:
        selected = self.notebook.select()
        if not selected:
            return None
        tab_frame = self.notebook.nametowidget(selected)
        return tab_frame.editor

    def new_file(self):
        tab_frame = ttk.Frame(self.notebook)
        editor = CodeEditor(tab_frame)
        editor.pack(fill="both", expand=True)
        tab_frame.editor = editor

        tab_title = f"Untitled-{len(self.notebook.tabs()) + 1}.jps"
        self.notebook.add(tab_frame, text=f" {tab_title} ")
        self.notebook.select(tab_frame)

        self.tab_files[tab_frame] = None
        self.status_label.configure(text=f"Created new file: {tab_title}")

    def open_file(self, filepath: str = None):
        if not filepath:
            filepath = filedialog.askopenfilename(
                title="Open Jps Script File",
                filetypes=[
                    ("Jps Script Files", "*.jps *.jap"),
                    ("Jps Script (*.jps)", "*.jps"),
                    ("Jap Script (*.jap)", "*.jap"),
                    ("All Files", "*.*")
                ]
            )
        if not filepath:
            return

        try:
            with open(filepath, "r", encoding="utf-8") as f:
                content = f.read()

            tab_frame = ttk.Frame(self.notebook)
            editor = CodeEditor(tab_frame)
            editor.pack(fill="both", expand=True)
            editor.set_text(content)
            tab_frame.editor = editor

            filename = os.path.basename(filepath)
            self.notebook.add(tab_frame, text=f" {filename} ")
            self.notebook.select(tab_frame)

            self.tab_files[tab_frame] = filepath
            self.log_console(f"[IDE] Opened file: {filepath}\n", "info")
            self.status_label.configure(text=f"Opened: {filepath}")

        except Exception as e:
            messagebox.showerror("Open File Error", str(e))

    def save_file(self):
        selected = self.notebook.select()
        if not selected:
            return
        tab_frame = self.notebook.nametowidget(selected)
        filepath = self.tab_files.get(tab_frame)

        if not filepath:
            return self.save_as_file()

        try:
            content = tab_frame.editor.get_text()
            with open(filepath, "w", encoding="utf-8") as f:
                f.write(content)

            filename = os.path.basename(filepath)
            self.notebook.tab(tab_frame, text=f" {filename} ")
            self.log_console(f"[IDE] Saved file: {filepath}\n", "success")
            self.status_label.configure(text=f"Saved: {filepath}")
        except Exception as e:
            messagebox.showerror("Save File Error", str(e))

    def save_as_file(self):
        selected = self.notebook.select()
        if not selected:
            return
        tab_frame = self.notebook.nametowidget(selected)

        filepath = filedialog.asksaveasfilename(
            title="Save As Jps Script File",
            defaultextension=".jps",
            filetypes=[
                ("Jps Script (*.jps)", "*.jps"),
                ("Jap Script (*.jap)", "*.jap"),
                ("All Files", "*.*")
            ]
        )
        if not filepath:
            return

        self.tab_files[tab_frame] = filepath
        self.save_file()

    def close_tab(self):
        selected = self.notebook.select()
        if not selected:
            return
        tab_frame = self.notebook.nametowidget(selected)
        if len(self.notebook.tabs()) > 1:
            self.notebook.forget(tab_frame)
            if tab_frame in self.tab_files:
                del self.tab_files[tab_frame]
        else:
            self.new_file()
            self.notebook.forget(tab_frame)
            if tab_frame in self.tab_files:
                del self.tab_files[tab_frame]

    def run_code(self):
        editor = self.get_current_editor()
        if not editor:
            return

        code_str = editor.get_text()
        if not code_str.strip():
            self.log_console("[IDE] Editor is empty. Nothing to execute.\n", "warning")
            return

        self.log_console("\n" + "─"*50 + "\n", "info")
        self.log_console("[IDE] Starting Compilation & Execution...\n", "info")
        self.status_label.configure(text="Executing Jps Script...")

        # Tokenization Phase
        try:
            lexer = Lexer(code_str)
            tokens = lexer.tokenize()
        except LexerError as le:
            self.log_console(f"[Lexer Error] {le.message} (Line {le.line}, Col {le.column})\n", "error")
            self.status_label.configure(text=f"Lexer Error at line {le.line}")
            return
        except Exception as e:
            self.log_console(f"[Lexer Unexpected Error] {e}\n", "error")
            return

        # Parsing Phase
        try:
            parser = Parser(tokens)
            ast = parser.parse()
        except ParserError as pe:
            self.log_console(f"[Parser Error] {pe.message} (Line {pe.line}, Col {pe.column})\n", "error")
            self.status_label.configure(text=f"Parser Error at line {pe.line}")
            return
        except Exception as e:
            self.log_console(f"[Parser Unexpected Error] {e}\n", "error")
            return

        # Execution Phase
        try:
            interpreter = Interpreter(output_func=lambda msg: self.log_console(msg, "info"), interactive=True)
            interpreter.execute(ast)
            self.log_console("[IDE] Execution finished successfully.\n", "success")
            self.status_label.configure(text="Execution Finished Successfully")
        except InterpreterError as ie:
            self.log_console(f"[Runtime Error] {ie.message} (Line {ie.line})\n", "error")
            self.status_label.configure(text=f"Runtime Error at line {ie.line}")
        except Exception as e:
            self.log_console(f"[Runtime Unexpected Error] {e}\n", "error")

if __name__ == "__main__":
    app = JpsIDE()
    app.mainloop()
