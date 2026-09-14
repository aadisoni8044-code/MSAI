"""
OpenMS Activity Bar Widget (VS Code Style Navigation Bar)
"""

import tkinter as tk


class ActivityBar(tk.Frame):
    """Leftmost vertical navigation bar to switch sidebar views or trigger quick actions."""

    def __init__(self, parent, theme_manager, on_view_change=None):
        theme = theme_manager.theme
        super().__init__(parent, bg=theme["bg_header"], width=50)
        self.pack_propagate(False)
        self.theme_manager = theme_manager
        self.on_view_change = on_view_change
        self.active_tab = "explorer"
        self.buttons = {}

        self._build_bar()
        self.theme_manager.subscribe(self.apply_theme)

    def _build_bar(self):
        items = [
            ("explorer", "📁", "Explorer"),
            ("search", "🔍", "Search"),
            ("copilot", "🤖", "AI Copilot"),
            ("ref", "📖", "Function Reference"),
        ]

        for key, icon, tooltip in items:
            btn = tk.Button(
                self,
                text=icon,
                font=("Segoe UI Symbol", 14),
                bg=self.theme_manager.theme["bg_header"],
                fg=self.theme_manager.theme["fg_text"],
                activebackground=self.theme_manager.theme["accent"],
                activeforeground="#ffffff",
                bd=0,
                relief="flat",
                command=lambda k=key: self.select_view(k),
                cursor="hand2",
            )
            btn.pack(side="top", fill="x", pady=6, padx=2)
            self.buttons[key] = btn

        # Theme toggle button at bottom
        theme_btn = tk.Button(
            self,
            text="🎨",
            font=("Segoe UI Symbol", 14),
            bg=self.theme_manager.theme["bg_header"],
            fg=self.theme_manager.theme["fg_text"],
            bd=0,
            relief="flat",
            command=lambda: self.select_view("theme"),
            cursor="hand2",
        )
        theme_btn.pack(side="bottom", fill="x", pady=8, padx=2)
        self.buttons["theme"] = theme_btn

        self.highlight_active()

    def select_view(self, key):
        if key != "theme":
            self.active_tab = key
            self.highlight_active()
        if self.on_view_change:
            self.on_view_change(key)

    def highlight_active(self):
        theme = self.theme_manager.theme
        for k, btn in self.buttons.items():
            if k == self.active_tab:
                btn.config(bg=theme["accent"], fg="#ffffff")
            else:
                btn.config(bg=theme["bg_header"], fg=theme["fg_text"])

    def apply_theme(self, theme):
        self.config(bg=theme["bg_header"])
        self.highlight_active()
