"""
Command Palette Modal Component (Ctrl+Shift+P)
"""

import tkinter as tk


class CommandPalette(tk.Toplevel):
    """VS Code Quick Command Palette Search Modal."""

    def __init__(self, parent, theme_manager, commands):
        super().__init__(parent)
        self.theme_manager = theme_manager
        self.commands = commands  # dict of command_title -> callback

        theme = theme_manager.theme
        self.title("Command Palette")
        self.geometry("560x320")
        self.configure(bg=theme["bg_main"])
        self.transient(parent)
        self.grab_set()

        self._build_ui()

    def _build_ui(self):
        theme = self.theme_manager.theme

        # Top entry
        entry_frame = tk.Frame(self, bg=theme["bg_sidebar"], padx=10, pady=8)
        entry_frame.pack(fill="x")

        self.entry = tk.Entry(
            entry_frame,
            font=("Segoe UI", 11),
            bg=theme["bg_main"],
            fg=theme["fg_text"],
            insertbackground=theme["fg_text"],
            bd=1,
            relief="solid",
        )
        self.entry.pack(fill="x")
        self.entry.focus_set()
        self.entry.bind("<KeyRelease>", self._filter_commands)
        self.entry.bind("<Return>", self._execute_selected)
        self.entry.bind("<Escape>", lambda e: self.destroy())

        # Listbox of commands
        list_frame = tk.Frame(self, bg=theme["bg_main"], padx=10, pady=6)
        list_frame.pack(fill="both", expand=True)

        self.listbox = tk.Listbox(
            list_frame,
            font=("Segoe UI", 10),
            bg=theme["bg_main"],
            fg=theme["fg_text"],
            selectbackground=theme["accent_blue"],
            selectforeground="#ffffff",
            bd=0,
            highlightthickness=0,
        )
        self.listbox.pack(fill="both", expand=True)
        self.listbox.bind("<Double-1>", self._execute_selected)

        self._filter_commands()

    def _filter_commands(self, event=None):
        query = self.entry.get().lower()
        self.listbox.delete(0, "end")
        self.filtered_keys = []
        for title in self.commands.keys():
            if query in title.lower():
                self.listbox.insert("end", f" >  {title}")
                self.filtered_keys.append(title)
        if self.filtered_keys:
            self.listbox.select_set(0)

    def _execute_selected(self, event=None):
        sel = self.listbox.curselection()
        if sel and sel[0] < len(self.filtered_keys):
            cmd_title = self.filtered_keys[sel[0]]
            cb = self.commands[cmd_title]
            self.destroy()
            cb()
