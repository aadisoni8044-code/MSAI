import os
import sys
import re
import threading
from typing import Optional, List, Dict, Any
import tkinter as tk
from tkinter import ttk, filedialog, messagebox
import customtkinter as ctk

from lexer import Lexer, LexerError
from parser import Parser, ParserError
from interpreter import Interpreter, RuntimeErrorJps

# Set CustomTkinter theme
ctk.set_appearance_mode("Dark")
ctk.set_default_color_theme("blue")

# Theme Colors
BG_ACTIVITY_BAR = "#333333"
BG_SIDEBAR = "#252526"
BG_EDITOR = "#1E1E1E"
BG_STATUSBAR = "#007ACC"
BG_TERMINAL = "#181818"
FG_TEXT = "#D4D4D4"

# Syntax Highlighting Colors
COLOR_KEYWORD = "#569CD6"  # Blue (import, print)
COLOR_MODULE = "#DCDCAA"   # Yellow (box, game)
COLOR_NUMBER = "#B5CEA8"   # Green (numbers)
COLOR_STRING = "#CE9178"   # Orange (strings)
COLOR_COMMENT = "#6A9955"  # Muted Green (# comments)
COLOR_DEFAULT = "#D4D4D4"  # Off-white

COLOR_RUN_BTN = "#4EC9B0"   # VS Code Cyan/Teal Accent


class CodeEditor(tk.Frame):
    def __init__(self, parent, filepath=None, *args, **kwargs):
        super().__init__(parent, bg=BG_EDITOR, *args, **kwargs)
        self.filepath = filepath

        # Line number gutter
        self.line_numbers = tk.Text(
            self, width=4, padx=5, takefocus=0, border=0,
            bg="#1E1E1E", fg="#858585", state="disabled",
            font=("Consolas", 12), wrap="none"
        )
        self.line_numbers.pack(side="left", fill="y")

        # Main text area
        self.text = tk.Text(
            self, wrap="none", border=0, bg=BG_EDITOR, fg=FG_TEXT,
            insertbackground="white", selectbackground="#264F78",
            font=("Consolas", 12), undo=True
        )
        self.text.pack(side="left", fill="both", expand=True)

        # Scrollbar
        self.scrollbar = ttk.Scrollbar(self, orient="vertical", command=self._on_scroll)
        self.scrollbar.pack(side="right", fill="y")
        self.text.config(yscrollcommand=self._on_text_scroll)

        # Setup tags for syntax highlighting
        self.text.tag_config("keyword", foreground=COLOR_KEYWORD)
        self.text.tag_config("module", foreground=COLOR_MODULE)
        self.text.tag_config("number", foreground=COLOR_NUMBER)
        self.text.tag_config("string", foreground=COLOR_STRING)
        self.text.tag_config("comment", foreground=COLOR_COMMENT)

        # Bind events
        self.text.bind("<KeyRelease>", self._on_key_release)
        self.text.bind("<BackSpace>", self._on_key_release)
        self.text.bind("<Return>", self._on_key_release)

        if self.filepath and os.path.exists(self.filepath):
            self.load_file(self.filepath)

        self.update_line_numbers()
        self.highlight_syntax()

    def _on_scroll(self, *args):
        self.text.yview(*args)
        self.line_numbers.yview(*args)

    def _on_text_scroll(self, *args):
        self.scrollbar.set(*args)
        self.line_numbers.yview_moveto(args[0])

    def _on_key_release(self, event=None):
        self.update_line_numbers()
        self.highlight_syntax()

    def update_line_numbers(self):
        lines = self.text.get("1.0", "end-1c").split("\n")
        line_count = len(lines)
        line_str = "\n".join(str(i) for i in range(1, line_count + 1))

        self.line_numbers.config(state="normal")
        self.line_numbers.delete("1.0", "end")
        self.line_numbers.insert("1.0", line_str)
        self.line_numbers.config(state="disabled")

    def highlight_syntax(self):
        content = self.text.get("1.0", "end-1c")

        # Remove existing syntax tags
        for tag in ("keyword", "module", "number", "string", "comment"):
            self.text.tag_remove(tag, "1.0", "end")

        # Keywords
        for match in re.finditer(r"\b(import|print)\b", content):
            start = f"1.0+{match.start()}c"
            end = f"1.0+{match.end()}c"
            self.text.tag_add("keyword", start, end)

        # Modules
        for match in re.finditer(r"\b(box|game)\b", content):
            start = f"1.0+{match.start()}c"
            end = f"1.0+{match.end()}c"
            self.text.tag_add("module", start, end)

        # Strings
        for match in re.finditer(r'(".*?"|\'.*?\')', content):
            start = f"1.0+{match.start()}c"
            end = f"1.0+{match.end()}c"
            self.text.tag_add("string", start, end)

        # Numbers
        for match in re.finditer(r"\b\d+(\.\d+)?\b", content):
            start = f"1.0+{match.start()}c"
            end = f"1.0+{match.end()}c"
            self.text.tag_add("number", start, end)

        # Comments
        for match in re.finditer(r"#.*", content):
            start = f"1.0+{match.start()}c"
            end = f"1.0+{match.end()}c"
            self.text.tag_add("comment", start, end)

    def load_file(self, path):
        with open(path, "r", encoding="utf-8") as f:
            code = f.read()
        self.text.delete("1.0", "end")
        self.text.insert("1.0", code)
        self.filepath = path
        self.update_line_numbers()
        self.highlight_syntax()

    def save_file(self):
        if self.filepath:
            with open(self.filepath, "w", encoding="utf-8") as f:
                f.write(self.text.get("1.0", "end-1c"))


class VSCodeIDE(ctk.CTk):
    def __init__(self, workspace_dir=None):
        super().__init__()
        self.title("Jps Script Studio - Visual Studio Code Edition")
        self.geometry("1100x720")
        self.configure(fg_color=BG_EDITOR)

        self.workspace_dir = workspace_dir or os.getcwd()
        self.open_tabs = {}  # filepath -> (tab frame, editor)

        self._build_ui()
        self.refresh_file_tree()

    def _build_ui(self):
        # Top Header / Action Bar
        self.top_bar = ctk.CTkFrame(self, height=40, fg_color="#2D2D2D", corner_radius=0)
        self.top_bar.pack(side="top", fill="x")

        self.app_title = ctk.CTkLabel(
            self.top_bar, text="JPS SCRIPT STUDIO", font=("Segoe UI", 13, "bold"), text_color="#CCCCCC"
        )
        self.app_title.pack(side="left", padx=15)

        self.run_btn = ctk.CTkButton(
            self.top_bar,
            text="▶ Run Script",
            font=("Segoe UI", 12, "bold"),
            fg_color=COLOR_RUN_BTN,
            hover_color="#3BAA96",
            text_color="#000000",
            width=110,
            height=28,
            command=self.run_active_script
        )
        self.run_btn.pack(side="right", padx=15, pady=6)

        # Main Body Container
        self.body_frame = ctk.CTkFrame(self, fg_color=BG_EDITOR, corner_radius=0)
        self.body_frame.pack(side="top", fill="both", expand=True)

        # 1. Activity Bar (Far Left)
        self.activity_bar = ctk.CTkFrame(self.body_frame, width=50, fg_color=BG_ACTIVITY_BAR, corner_radius=0)
        self.activity_bar.pack(side="left", fill="y")

        self.btn_files = ctk.CTkButton(
            self.activity_bar, text="📁", width=40, height=40, fg_color="transparent",
            hover_color="#3E3E42", font=("Segoe UI", 18), command=self.toggle_sidebar
        )
        self.btn_files.pack(side="top", pady=10)

        self.btn_run = ctk.CTkButton(
            self.activity_bar, text="⚙", width=40, height=40, fg_color="transparent",
            hover_color="#3E3E42", font=("Segoe UI", 18), command=self.run_active_script
        )
        self.btn_run.pack(side="top", pady=10)

        self.btn_settings = ctk.CTkButton(
            self.activity_bar, text="🛠", width=40, height=40, fg_color="transparent",
            hover_color="#3E3E42", font=("Segoe UI", 18),
            command=lambda: messagebox.showinfo("Settings", "Jps Script IDE Settings & Configuration")
        )
        self.btn_settings.pack(side="bottom", pady=10)

        # 2. Side Panel / File Explorer (Left)
        self.sidebar = ctk.CTkFrame(self.body_frame, width=220, fg_color=BG_SIDEBAR, corner_radius=0)
        self.sidebar.pack(side="left", fill="y")

        self.explorer_label = ctk.CTkLabel(
            self.sidebar, text="EXPLORER", font=("Segoe UI", 11, "bold"), text_color="#BBBBBB"
        )
        self.explorer_label.pack(side="top", anchor="w", padx=10, pady=(10, 5))

        # Explorer Action Buttons
        self.file_actions = ctk.CTkFrame(self.sidebar, fg_color="transparent")
        self.file_actions.pack(side="top", fill="x", padx=5, pady=2)

        self.btn_new = ctk.CTkButton(
            self.file_actions, text="+ New", width=60, height=24, font=("Segoe UI", 11), command=self.create_new_file
        )
        self.btn_new.pack(side="left", padx=2)

        self.btn_rename = ctk.CTkButton(
            self.file_actions, text="Rename", width=60, height=24, font=("Segoe UI", 11), command=self.rename_file
        )
        self.btn_rename.pack(side="left", padx=2)

        self.btn_delete = ctk.CTkButton(
            self.file_actions, text="Delete", width=60, height=24, font=("Segoe UI", 11), fg_color="#D13438", hover_color="#A82A2D", command=self.delete_file
        )
        self.btn_delete.pack(side="left", padx=2)

        # File Listbox / Treeview
        self.file_listbox = tk.Listbox(
            self.sidebar, bg=BG_SIDEBAR, fg="#CCCCCC", selectbackground="#37373D",
            selectforeground="#FFFFFF", border=0, highlightthickness=0, font=("Segoe UI", 11)
        )
        self.file_listbox.pack(side="top", fill="both", expand=True, padx=5, pady=5)
        self.file_listbox.bind("<Double-Button-1>", self._on_file_double_click)

        # Main Workspace Pane (Editor + Terminal)
        self.workspace_pane = ctk.CTkFrame(self.body_frame, fg_color=BG_EDITOR, corner_radius=0)
        self.workspace_pane.pack(side="left", fill="both", expand=True)

        # 3. Main Editor Window (Center) - Tabview
        self.tabview = ctk.CTkTabview(self.workspace_pane, fg_color=BG_EDITOR, corner_radius=0)
        self.tabview.pack(side="top", fill="both", expand=True)

        # 5. Integrated Terminal Panel (Bottom)
        self.terminal_frame = ctk.CTkFrame(self.workspace_pane, height=200, fg_color=BG_TERMINAL, corner_radius=0)
        self.terminal_frame.pack(side="bottom", fill="x")

        self.terminal_title = ctk.CTkLabel(
            self.terminal_frame, text="TERMINAL / COMPILER CONSOLE", font=("Segoe UI", 10, "bold"), text_color="#858585"
        )
        self.terminal_title.pack(side="top", anchor="w", padx=10, pady=(4, 2))

        self.terminal = ctk.CTkTextbox(
            self.terminal_frame, height=160, fg_color=BG_TERMINAL, text_color="#CCCCCC",
            font=("Consolas", 11), corner_radius=0
        )
        self.terminal.pack(side="bottom", fill="both", expand=True, padx=5, pady=(0, 5))

        self.log_terminal("Jps Script Compiler Environment Loaded Successfully.\n")

    def toggle_sidebar(self):
        if self.sidebar.winfo_viewable():
            self.sidebar.pack_forget()
        else:
            self.sidebar.pack(side="left", fill="y", before=self.workspace_pane)

    def log_terminal(self, message: str, is_error: bool = False):
        self.terminal.configure(state="normal")
        if is_error:
            self.terminal.insert("end", message, "error")
        else:
            self.terminal.insert("end", message)
        self.terminal.see("end")

    def clear_terminal(self):
        self.terminal.configure(state="normal")
        self.terminal.delete("1.0", "end")

    def refresh_file_tree(self):
        self.file_listbox.delete(0, tk.END)
        if not os.path.exists(self.workspace_dir):
            return

        files = sorted(os.listdir(self.workspace_dir))
        for f in files:
            if f.endswith(".jps") or f.endswith(".jap"):
                self.file_listbox.insert(tk.END, f)

    def _on_file_double_click(self, event):
        selection = self.file_listbox.curselection()
        if selection:
            filename = self.file_listbox.get(selection[0])
            filepath = os.path.join(self.workspace_dir, filename)
            self.open_file_in_tab(filepath)

    def open_file_in_tab(self, filepath):
        filename = os.path.basename(filepath)
        if filepath in self.open_tabs:
            self.tabview.set(filename)
            return

        tab = self.tabview.add(filename)
        editor = CodeEditor(tab, filepath=filepath)
        editor.pack(fill="both", expand=True)

        self.open_tabs[filepath] = (tab, editor)
        self.tabview.set(filename)

    def create_new_file(self):
        dialog = ctk.CTkInputDialog(text="Enter filename (.jps or .jap):", title="New File")
        filename = dialog.get_input()
        if filename:
            if not (filename.endswith(".jps") or filename.endswith(".jap")):
                filename += ".jps"
            filepath = os.path.join(self.workspace_dir, filename)
            if not os.path.exists(filepath):
                with open(filepath, "w", encoding="utf-8") as f:
                    f.write("# New Jps Script\n")
            self.refresh_file_tree()
            self.open_file_in_tab(filepath)

    def rename_file(self):
        selection = self.file_listbox.curselection()
        if not selection:
            messagebox.showwarning("Rename File", "Select a file from the explorer to rename.")
            return

        old_filename = self.file_listbox.get(selection[0])
        old_path = os.path.join(self.workspace_dir, old_filename)

        dialog = ctk.CTkInputDialog(text=f"Rename '{old_filename}' to:", title="Rename File")
        new_filename = dialog.get_input()
        if new_filename:
            new_path = os.path.join(self.workspace_dir, new_filename)
            os.rename(old_path, new_path)
            if old_path in self.open_tabs:
                tab, editor = self.open_tabs.pop(old_path)
                editor.filepath = new_path
                self.open_tabs[new_path] = (tab, editor)
            self.refresh_file_tree()

    def delete_file(self):
        selection = self.file_listbox.curselection()
        if not selection:
            messagebox.showwarning("Delete File", "Select a file from the explorer to delete.")
            return

        filename = self.file_listbox.get(selection[0])
        filepath = os.path.join(self.workspace_dir, filename)

        if messagebox.askyesno("Confirm Delete", f"Are you sure you want to delete {filename}?"):
            if filepath in self.open_tabs:
                # remove tab
                self.tabview.delete(filename)
                self.open_tabs.pop(filepath)
            os.remove(filepath)
            self.refresh_file_tree()

    def get_active_editor(self) -> Optional[CodeEditor]:
        try:
            active_tab_name = self.tabview.get()
            for filepath, (tab, editor) in self.open_tabs.items():
                if os.path.basename(filepath) == active_tab_name:
                    return editor
        except Exception:
            pass
        return None

    def run_active_script(self):
        editor = self.get_active_editor()
        if not editor:
            self.log_terminal("[Error] No active editor tab open to run.\n", is_error=True)
            return

        editor.save_file()
        code = editor.text.get("1.0", "end-1c")

        self.clear_terminal()
        self.log_terminal(f"=== Compiling & Executing: {os.path.basename(editor.filepath)} ===\n")

        def _execute():
            try:
                tokens = Lexer(code).tokenize()
                parser = Parser(tokens)
                ast = parser.parse()

                interpreter = Interpreter(output_callback=lambda msg: self.log_terminal(msg))
                interpreter.evaluate(ast, run_gui_loop=True)

                self.log_terminal("\n[Process finished with exit code 0]\n")

            except LexerError as le:
                self.log_terminal(f"\n{str(le)}\n", is_error=True)
            except ParserError as pe:
                self.log_terminal(f"\n{str(pe)}\n", is_error=True)
            except RuntimeErrorJps as re:
                self.log_terminal(f"\n{str(re)}\n", is_error=True)
            except Exception as e:
                self.log_terminal(f"\n[Unexpected Error]: {str(e)}\n", is_error=True)

        # Run in thread so GUI remains responsive
        threading.Thread(target=_execute, daemon=True).start()


if __name__ == "__main__":
    app = VSCodeIDE()
    app.mainloop()
