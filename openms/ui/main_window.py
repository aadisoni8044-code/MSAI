"""
Main Application Window Component (VS Code UI / UX Architecture)
"""

import os
import time
import tkinter as tk
from tkinter import filedialog, messagebox

from openms.config import FUNCTION_HELP, THEMES
from openms.interpreter.engine import OpenMSInterpreter
from openms.ui.theme_manager import ThemeManager
from openms.ui.activity_bar import ActivityBar
from openms.ui.primary_sidebar import PrimarySidebar
from openms.ui.editor_panel import EditorPanel
from openms.ui.terminal_panel import TerminalPanel
from openms.ui.ai_copilot_panel import AICopilotPanel
from openms.ui.status_bar import StatusBar
from openms.ui.command_palette import CommandPalette
from openms.utils.file_manager import FileManager


class OpenMSIDE:
    """VS Code Clone Desktop IDE Window for OpenMS language."""

    def __init__(self, root):
        self.root = root
        self.root.title("OpenMS Code Studio - Desktop IDE")
        self.root.geometry("1280x800")
        self.root.minsize(900, 600)

        # Theme Manager
        self.theme_manager = ThemeManager("dark_plus")
        self.theme_manager.register(self.apply_theme)

        # Header
        self._build_header()

        # Workspace Panes
        self.main_container = tk.Frame(self.root, bg=self.theme_manager.theme["bg_main"])
        self.main_container.pack(fill="both", expand=True)

        # 1. Left Activity Bar
        self.activity_bar = ActivityBar(
            self.main_container,
            self.theme_manager,
            on_view_change_cb=self._on_activity_view_change,
        )
        self.activity_bar.pack(side="left", fill="y")

        # 2. Primary Sidebar (Collapsible)
        self.sidebar = PrimarySidebar(
            self.main_container,
            self.theme_manager,
            on_file_open_cb=self.open_file_by_path,
            on_run_code_cb=self.run_code,
        )
        self.sidebar.pack(side="left", fill="y")

        # 3. Center Area (Editor + Bottom Terminal)
        self.center_paned = tk.PanedWindow(
            self.main_container,
            orient="vertical",
            bg=self.theme_manager.theme["border"],
            sashwidth=3,
            bd=0,
        )
        self.center_paned.pack(side="left", fill="both", expand=True)

        # Editor Panel
        self.editor_panel = EditorPanel(
            self.center_paned,
            self.theme_manager,
            on_cursor_change_cb=self._on_cursor_change,
        )
        self.center_paned.add(self.editor_panel, stretch="always", minsize=200)

        # Bottom Terminal Panel
        self.terminal_panel = TerminalPanel(
            self.center_paned,
            self.theme_manager,
            on_run_code_cb=self.run_code,
        )
        self.center_paned.add(self.terminal_panel, stretch="never", height=180)

        # 4. Right Area (AI Copilot Panel)
        self.ai_panel = AICopilotPanel(
            self.main_container,
            self.theme_manager,
            on_insert_code_cb=self._insert_code_from_ai,
        )
        self.ai_panel.pack(side="right", fill="y")

        # 5. Bottom Status Bar
        self.status_bar = StatusBar(self.root, self.theme_manager)
        self.status_bar.pack(side="bottom", fill="x")

        # Interpreter Engine
        self.interpreter = OpenMSInterpreter(
            self.root,
            terminal_write=self.terminal_panel.write,
        )

        # Build Menu (after panels exist)
        self._build_menu()

        # Global Keybindings
        self._bind_keyboard_shortcuts()

    def _build_menu(self):
        theme = self.theme_manager.theme
        menubar = tk.Menu(self.root, bg=theme["bg_tab"], fg=theme["fg_sidebar"])

        # File Menu
        file_menu = tk.Menu(menubar, tearoff=0)
        file_menu.add_command(label="New Script", accelerator="Ctrl+N", command=self.new_file)
        file_menu.add_command(label="Open File...", accelerator="Ctrl+O", command=self.open_file_dialog)
        file_menu.add_command(label="Save", accelerator="Ctrl+S", command=self.save_file)
        file_menu.add_command(label="Save As...", accelerator="Ctrl+Shift+S", command=self.save_file_as)
        file_menu.add_separator()
        file_menu.add_command(label="Exit", command=self.root.quit)
        menubar.add_cascade(label="File", menu=file_menu)

        # View Menu
        view_menu = tk.Menu(menubar, tearoff=0)
        view_menu.add_command(label="Command Palette...", accelerator="Ctrl+Shift+P", command=self.show_command_palette)
        view_menu.add_separator()
        view_menu.add_command(label="Toggle Primary Sidebar", command=self.toggle_sidebar)
        view_menu.add_command(label="Toggle AI Copilot Drawer", command=self.toggle_ai_panel)
        menubar.add_cascade(label="View", menu=view_menu)

        # Run Menu
        run_menu = tk.Menu(menubar, tearoff=0)
        run_menu.add_command(label="Run OpenMS Script", accelerator="F5", command=self.run_code)
        run_menu.add_command(label="Clear Terminal", command=self.terminal_panel.clear)
        menubar.add_cascade(label="Run", menu=run_menu)

        # Preferences / Theme Menu
        theme_menu = tk.Menu(menubar, tearoff=0)
        for theme_key, theme_data in THEMES.items():
            theme_menu.add_command(
                label=theme_data["name"],
                command=lambda k=theme_key: self.theme_manager.set_theme(k),
            )
        menubar.add_cascade(label="Preferences", menu=theme_menu)

        # Help Menu
        help_menu = tk.Menu(menubar, tearoff=0)
        help_menu.add_command(label="Function Reference", command=self.show_function_reference)
        help_menu.add_command(label="About OpenMS Code Studio", command=self.show_about)
        menubar.add_cascade(label="Help", menu=help_menu)

        self.root.config(menu=menubar)

    def _build_header(self):
        theme = self.theme_manager.theme
        self.header = tk.Frame(self.root, bg=theme["bg_tab"], height=42)
        self.header.pack(fill="x", side="top")
        self.header.pack_propagate(False)

        # Logo Block
        logo_frame = tk.Frame(self.header, bg="#007acc", padx=12, pady=4)
        logo_frame.pack(side="left", fill="y")
        tk.Label(
            logo_frame,
            text="OpenMS",
            font=("Consolas", 14, "bold"),
            bg="#007acc",
            fg="#ffffff",
        ).pack(side="left")

        # Subtitle
        tk.Label(
            self.header,
            text="  Code Studio — Desktop IDE",
            font=("Segoe UI", 10),
            bg=theme["bg_tab"],
            fg=theme["fg_sidebar"],
        ).pack(side="left")

        # Top Right Run Button
        btn_run = tk.Button(
            self.header,
            text=" ▶ RUN SCRIPT ",
            font=("Segoe UI", 9, "bold"),
            bg="#007acc",
            fg="#ffffff",
            activebackground="#005999",
            activeforeground="#ffffff",
            bd=0,
            padx=12,
            pady=4,
            cursor="hand2",
            command=self.run_code,
        )
        btn_run.pack(side="right", padx=12, pady=6)

    def _bind_keyboard_shortcuts(self):
        self.root.bind("<Control-n>", lambda e: self.new_file())
        self.root.bind("<Control-o>", lambda e: self.open_file_dialog())
        self.root.bind("<Control-s>", lambda e: self.save_file())
        self.root.bind("<Control-S>", lambda e: self.save_file_as())
        self.root.bind("<Control-Shift-P>", lambda e: self.show_command_palette())
        self.root.bind("<Control-Shift-p>", lambda e: self.show_command_palette())
        self.root.bind("<F5>", lambda e: self.run_code())

    def _on_activity_view_change(self, view_id):
        self.sidebar.show_view(view_id)

    def _on_cursor_change(self, line, col):
        self.status_bar.set_cursor_pos(line, col)

    def new_file(self):
        if messagebox.askyesno("New Script", "Open a new blank script tab?"):
            self.editor_panel.open_tab("untitled.game", content="# New OpenMS script\n")
            self.status_bar.set_status("Created new file tab")

    def open_file_dialog(self):
        path = filedialog.askopenfilename(
            filetypes=[("OpenMS Files", "*.game *.function"), ("Text Files", "*.txt"), ("All Files", "*.*")]
        )
        if path:
            self.open_file_by_path(path)

    def open_file_by_path(self, path):
        try:
            content = FileManager.read_text_file(path)
            self.editor_panel.open_tab(path, content=content)
            self.terminal_panel.write(f"[File] Opened '{path}'")
            self.status_bar.set_status(f"Opened {os.path.basename(path)}")
        except Exception as e:
            messagebox.showerror("Open Failed", str(e))

    def save_file(self):
        active = self.editor_panel.get_active_tab()
        if not active:
            return
        path = active.get("path")
        if not path:
            self.save_file_as()
            return
        try:
            code = self.editor_panel.get_active_code()
            FileManager.write_text_file(path, code)
            self.terminal_panel.write(f"[File] Saved '{path}'")
            self.status_bar.set_status(f"Saved {os.path.basename(path)}")
        except Exception as e:
            messagebox.showerror("Save Failed", str(e))

    def save_file_as(self):
        active = self.editor_panel.get_active_tab()
        if not active:
            return
        path = filedialog.asksaveasfilename(
            defaultextension=".game",
            filetypes=[("OpenMS Game File", "*.game"), ("OpenMS Function File", "*.function"), ("All Files", "*.*")]
        )
        if path:
            try:
                code = self.editor_panel.get_active_code()
                FileManager.write_text_file(path, code)
                active["path"] = path
                self.terminal_panel.write(f"[File] Saved '{path}'")
                self.status_bar.set_status(f"Saved {os.path.basename(path)}")
            except Exception as e:
                messagebox.showerror("Save Failed", str(e))

    def run_code(self):
        code = self.editor_panel.get_active_code()
        self.terminal_panel.write("-" * 60)
        self.terminal_panel.write(f"[RUN] Executing OpenMS script @ {time.strftime('%H:%M:%S')}")
        self.status_bar.set_status("Running OpenMS Script...")
        try:
            self.interpreter.run(code)
            self.status_bar.set_status("Execution Finished Successfully")
        except Exception as e:
            self.terminal_panel.write(f"[Fatal Error] {type(e).__name__}: {e}")
            self.status_bar.set_status("Execution Error")
        self.terminal_panel.write("[DONE] Finished.")

    def _insert_code_from_ai(self, code_snippet):
        active = self.editor_panel.get_active_tab()
        if active:
            text_widget = active["frame"].code_text
            text_widget.insert("insert", "\n" + code_snippet + "\n")
            active["frame"].update_line_numbers()
            active["frame"].highlighter.highlight_all()

    def toggle_sidebar(self):
        if self.sidebar.winfo_viewable():
            self.sidebar.pack_forget()
        else:
            self.sidebar.pack(side="left", fill="y", before=self.center_paned)

    def toggle_ai_panel(self):
        if self.ai_panel.winfo_viewable():
            self.ai_panel.pack_forget()
        else:
            self.ai_panel.pack(side="right", fill="y")

    def show_command_palette(self):
        commands = {
            "Run OpenMS Script": self.run_code,
            "New Script": self.new_file,
            "Open File...": self.open_file_dialog,
            "Save File": self.save_file,
            "Save File As...": self.save_file_as,
            "Toggle Primary Sidebar": self.toggle_sidebar,
            "Toggle AI Copilot Drawer": self.toggle_ai_panel,
            "Clear Terminal": self.terminal_panel.clear,
            "Switch Theme to VS Code Dark+": lambda: self.theme_manager.set_theme("dark_plus"),
            "Switch Theme to VS Code Light+": lambda: self.theme_manager.set_theme("light_plus"),
            "Switch Theme to Monokai": lambda: self.theme_manager.set_theme("monokai"),
            "Switch Theme to Solarized Dark": lambda: self.theme_manager.set_theme("solarized_dark"),
            "Show Function Reference": self.show_function_reference,
            "About OpenMS Code Studio": self.show_about,
        }
        CommandPalette(self.root, self.theme_manager, commands)

    def show_function_reference(self):
        win = tk.Toplevel(self.root)
        win.title("OpenMS Language - 14 Function Reference")
        win.geometry("640x500")
        theme = self.theme_manager.theme
        win.configure(bg=theme["bg_main"])

        text = tk.Text(
            win,
            bg=theme["bg_main"],
            fg=theme["fg_text"],
            font=("Segoe UI", 10),
            wrap="word",
            padx=16,
            pady=16,
            border=0,
        )
        text.pack(fill="both", expand=True)

        text.tag_configure("title", font=("Segoe UI", 14, "bold"), foreground=theme["accent_blue"])
        text.tag_configure("fname", font=("Consolas", 11, "bold"), foreground=theme["accent_green"])
        text.tag_configure("desc", font=("Segoe UI", 10), foreground=theme["fg_text"])

        text.insert("end", "OpenMS Language Built-in Reference\n\n", "title")
        for fname, desc in FUNCTION_HELP.items():
            text.insert("end", f"{fname}()\n", "fname")
            text.insert("end", f"  {desc}\n\n", "desc")
        text.configure(state="disabled")

    def show_about(self):
        messagebox.showinfo(
            "About OpenMS Code Studio",
            "OpenMS Code Studio v1.0.0\n\n"
            "A modular VS Code-style Python desktop IDE & interpreter engine for the OpenMS language.\n\n"
            "Built with Python & Tkinter."
        )

    def apply_theme(self, theme):
        self.main_container.config(bg=theme["bg_main"])
        self.header.config(bg=theme["bg_tab"])
        self.center_paned.config(bg=theme["border"])
