"""
OpenMS Desktop IDE Main Window Application
"""

import os
import time
import tkinter as tk
from tkinter import filedialog, messagebox, ttk
from openms.config import APP_NAME, APP_VERSION, DEFAULT_SCRIPT
from openms.ui.theme_manager import ThemeManager
from openms.ui.activity_bar import ActivityBar
from openms.ui.sidebar import PrimarySidebar
from openms.ui.editor_tab import TabbedEditor
from openms.ui.terminal import IntegratedTerminal
from openms.ui.status_bar import StatusBar
from openms.ui.command_palette import CommandPalette
from openms.runtime.interpreter import OpenMSInterpreter


class OpenMSIDE:
    """
    OpenMS Standalone Desktop IDE Application Window.
    Implements a VS Code-style UI with Activity Bar, Primary Sidebar,
    Tabbed Editor, Integrated Terminal, AI Copilot, Command Palette,
    and Live Theme Switcher.
    """

    def __init__(self, root):
        self.root = root
        self.root.title(f"{APP_NAME} v{APP_VERSION}")
        self.root.geometry("1440x920")
        self.root.minsize(1024, 640)

        self.theme_manager = ThemeManager()
        self.root.configure(bg=self.theme_manager.theme["bg_main"])

        # Core Components Initialization
        self._build_menu()
        self._build_layout()

        self.interpreter = OpenMSInterpreter(
            root=self.root,
            terminal_write=self.terminal.write
        )

        # Initial default document tab
        self.tabbed_editor.add_tab("untitled.game", DEFAULT_SCRIPT)

        self._bind_shortcuts()
        self.theme_manager.subscribe(self.apply_theme)

    def _build_menu(self):
        menubar = tk.Menu(self.root)

        # File Menu
        file_menu = tk.Menu(menubar, tearoff=0)
        file_menu.add_command(label="New File", command=self.new_file, accelerator="Ctrl+N")
        file_menu.add_command(label="Open File...", command=self.open_file, accelerator="Ctrl+O")
        file_menu.add_command(label="Save", command=self.save_file, accelerator="Ctrl+S")
        file_menu.add_command(label="Save As...", command=self.save_file_as)
        file_menu.add_separator()
        file_menu.add_command(label="Exit", command=self.root.quit)
        menubar.add_cascade(label="File", menu=file_menu)

        # Edit Menu
        edit_menu = tk.Menu(menubar, tearoff=0)
        edit_menu.add_command(label="Command Palette...", command=self.open_command_palette, accelerator="Ctrl+Shift+P")
        menubar.add_cascade(label="Edit", menu=edit_menu)

        # Run Menu
        run_menu = tk.Menu(menubar, tearoff=0)
        run_menu.add_command(label="Run OpenMS Script", command=self.run_code, accelerator="F5")
        run_menu.add_command(label="Clear Terminal Log", command=self.clear_terminal)
        menubar.add_cascade(label="Run", menu=run_menu)

        # Theme Menu
        theme_menu = tk.Menu(menubar, tearoff=0)
        for name in self.theme_manager.get_theme_names():
            theme_menu.add_command(
                label=name, command=lambda n=name: self.theme_manager.set_theme(n)
            )
        menubar.add_cascade(label="Themes", menu=theme_menu)

        self.root.config(menu=menubar)

    def _build_layout(self):
        theme = self.theme_manager.theme

        # Top Header Bar
        header = tk.Frame(self.root, bg=theme["bg_header"], height=42)
        header.pack(side="top", fill="x")
        header.pack_propagate(False)

        logo_lbl = tk.Label(
            header,
            text=" OpenMS ",
            font=("Segoe UI", 12, "bold"),
            bg=theme["accent"],
            fg="#ffffff",
            padx=8,
            pady=4,
        )
        logo_lbl.pack(side="left", padx=12, pady=6)

        sub_lbl = tk.Label(
            header,
            text="Desktop IDE",
            font=("Segoe UI", 10),
            bg=theme["bg_header"],
            fg=theme["fg_text"],
        )
        sub_lbl.pack(side="left", padx=4)

        btn_run = tk.Button(
            header,
            text="▶ Run Script (F5)",
            font=("Segoe UI", 9, "bold"),
            bg="#28a745",
            fg="#ffffff",
            activebackground="#218838",
            activeforeground="#ffffff",
            bd=0,
            padx=12,
            pady=4,
            command=self.run_code,
            cursor="hand2",
        )
        btn_run.pack(side="right", padx=12, pady=6)

        # Main Central Workspace
        workspace = tk.Frame(self.root, bg=theme["bg_main"])
        workspace.pack(side="top", fill="both", expand=True)

        # Left Activity Bar
        self.activity_bar = ActivityBar(
            workspace,
            self.theme_manager,
            on_view_change=self._on_activity_view_change
        )
        self.activity_bar.pack(side="left", fill="y")

        # Primary Sidebar Panel
        self.sidebar = PrimarySidebar(
            workspace,
            self.theme_manager,
            on_file_open=self.open_file_by_path,
            on_insert_code=self.insert_code_to_editor
        )
        self.sidebar.pack(side="left", fill="y")

        # Right Split Frame (Editor Top + Terminal Bottom)
        right_panel = tk.PanedWindow(
            workspace,
            orient="vertical",
            bg=theme["border"],
            bd=0,
            sashwidth=4,
        )
        right_panel.pack(side="right", fill="both", expand=True)

        # Tabbed Editor Area
        self.tabbed_editor = TabbedEditor(
            right_panel,
            self.theme_manager,
            on_code_change=self.on_code_changed,
            on_cursor_move=self.on_cursor_moved
        )
        right_panel.add(self.tabbed_editor, minsize=200)

        # Integrated Terminal Panel
        self.terminal = IntegratedTerminal(right_panel, self.theme_manager)
        right_panel.add(self.terminal, minsize=100)

        # Bottom Status Bar
        self.status_bar = StatusBar(self.root, self.theme_manager)
        self.status_bar.pack(side="bottom", fill="x")

    def _on_activity_view_change(self, view_key):
        self.sidebar.show_view(view_key)

    def new_file(self):
        self.tabbed_editor.add_tab("untitled.game", "")

    def open_file(self):
        path = filedialog.askopenfilename(
            filetypes=[("OpenMS Files", "*.game *.function"), ("Text Files", "*.txt"), ("All Files", "*.*")]
        )
        if path:
            self.open_file_by_path(path)

    def open_file_by_path(self, path):
        try:
            with open(path, "r", encoding="utf-8", errors="replace") as f:
                content = f.read()
            title = os.path.basename(path)
            editor = self.tabbed_editor.add_tab(title, content, path)
            self.terminal.write(f"[File] Opened '{path}'")
        except Exception as e:
            messagebox.showerror("Error Opening File", str(e))

    def save_file(self):
        info = self.tabbed_editor.get_current_tab_info()
        if not info:
            return
        if not info["path"]:
            self.save_file_as()
            return
        self._write_to(info["path"])

    def save_file_as(self):
        path = filedialog.asksaveasfilename(
            defaultextension=".game",
            filetypes=[("OpenMS Game File", "*.game"), ("OpenMS Function File", "*.function"), ("All Files", "*.*")]
        )
        if not path:
            return
        title = os.path.basename(path)
        self.tabbed_editor.set_current_tab_info(title=title, path=path)
        self._write_to(path)

    def _write_to(self, path):
        try:
            editor = self.tabbed_editor.get_current_editor()
            if editor:
                content = editor.get_code()
                with open(path, "w", encoding="utf-8") as f:
                    f.write(content)
                self.terminal.write(f"[File] Saved '{path}'")
        except Exception as e:
            messagebox.showerror("Error Saving File", str(e))

    def run_code(self):
        editor = self.tabbed_editor.get_current_editor()
        if not editor:
            return
        code = editor.get_code()
        self.terminal.write("-" * 60)
        self.terminal.write(f"[RUN] Executing OpenMS script @ {time.strftime('%H:%M:%S')}")
        try:
            self.interpreter.run(code)
        except Exception as e:
            self.terminal.write(f"[Fatal Error] {e}")
        self.terminal.write("[DONE] Execution finished.")

    def clear_terminal(self):
        self.terminal.clear()

    def insert_code_to_editor(self, code_snippet):
        editor = self.tabbed_editor.get_current_editor()
        if editor:
            editor.code_text.insert("insert", code_snippet)

    def open_command_palette(self, event=None):
        cmds = [
            {"label": "Run OpenMS Script", "action": self.run_code},
            {"label": "New Script File", "action": self.new_file},
            {"label": "Open Script File", "action": self.open_file},
            {"label": "Save Current File", "action": self.save_file},
            {"label": "Clear Terminal Output", "action": self.clear_terminal},
        ]
        for name in self.theme_manager.get_theme_names():
            cmds.append({
                "label": f"Set Theme: {name}",
                "action": lambda n=name: self.theme_manager.set_theme(n)
            })
        CommandPalette(self.root, cmds)

    def on_code_changed(self):
        info = self.tabbed_editor.get_current_tab_info()
        file_name = info["title"] if info else "untitled.game"
        self.status_bar.update_info(file_name=file_name)

    def on_cursor_moved(self, pos_str):
        info = self.tabbed_editor.get_current_tab_info()
        file_name = info["title"] if info else "untitled.game"
        self.status_bar.update_info(file_name=file_name, cursor_pos=pos_str)

    def _bind_shortcuts(self):
        self.root.bind("<F5>", lambda e: self.run_code())
        self.root.bind("<Control-n>", lambda e: self.new_file())
        self.root.bind("<Control-o>", lambda e: self.open_file())
        self.root.bind("<Control-s>", lambda e: self.save_file())
        self.root.bind("<Control-Shift-P>", self.open_command_palette)
        self.root.bind("<Control-Shift-p>", self.open_command_palette)

    def apply_theme(self, theme):
        self.root.configure(bg=theme["bg_main"])
