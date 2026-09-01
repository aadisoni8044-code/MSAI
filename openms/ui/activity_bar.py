"""
Activity Bar Component (Far-left vertical icon navigation bar)
"""

import tkinter as tk


class ActivityBar(tk.Frame):
    """VS Code-style Activity Bar on the far left."""

    def __init__(self, parent, theme_manager, on_view_change_cb=None):
        self.theme_manager = theme_manager
        theme = theme_manager.theme
        super().__init__(parent, bg=theme["bg_activity"], width=48)
        self.pack_propagate(False)

        self.on_view_change = on_view_change_cb
        self.active_view = "explorer"
        self.buttons = {}

        self.theme_manager.register(self.apply_theme)
        self._build_bar()

    def _build_bar(self):
        items = [
            ("explorer", "📄", "Explorer (Ctrl+Shift+E)"),
            ("search", "🔍", "Search (Ctrl+Shift+F)"),
            ("run", "▶", "Run & Debug (Ctrl+Shift+D)"),
            ("ai", "🤖", "AI Assistant (Ctrl+Shift+A)"),
            ("settings", "⚙", "Settings & Themes (Ctrl+,)"),
        ]

        for view_id, icon, tooltip in items:
            btn = tk.Button(
                self,
                text=icon,
                font=("Segoe UI Symbol", 14),
                bd=0,
                relief="flat",
                cursor="hand2",
                command=lambda v=view_id: self.select_view(v),
            )
            btn.pack(side="top", fill="x", pady=6, padx=2)
            self.buttons[view_id] = btn

        self.update_button_styles()

    def select_view(self, view_id):
        self.active_view = view_id
        self.update_button_styles()
        if self.on_view_change:
            self.on_view_change(view_id)

    def update_button_styles(self):
        theme = self.theme_manager.theme
        for view_id, btn in self.buttons.items():
            if view_id == self.active_view:
                btn.config(
                    bg=theme["active_activity"],
                    fg=theme["fg_activity"],
                    activebackground=theme["active_activity"],
                    activeforeground=theme["fg_activity"],
                )
            else:
                btn.config(
                    bg=theme["bg_activity"],
                    fg=theme["fg_sidebar"],
                    activebackground=theme["bg_activity"],
                    activeforeground=theme["fg_activity"],
                )

    def apply_theme(self, theme):
        self.config(bg=theme["bg_activity"])
        self.update_button_styles()
