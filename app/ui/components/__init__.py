"""Custom UI Components library for Kora."""

import tkinter as tk
from tkinter import ttk
from typing import Callable, List, Optional
from app.ui.theme import ColorPalette, DARK_PALETTE


class Card(tk.Frame):
    """Modern flat container card widget."""

    def __init__(
        self,
        parent,
        colors: ColorPalette = DARK_PALETTE,
        padding: int = 15,
        border_color: Optional[str] = None,
        bg: Optional[str] = None,
        **kwargs
    ):
        background = bg or colors.card_bg
        bd_col = border_color or colors.card_border
        super().__init__(parent, bg=background, highlightbackground=bd_col, highlightthickness=1, bd=0, **kwargs)
        self.colors = colors
        self.padding = padding
        self.inner_frame = tk.Frame(self, bg=background)
        self.inner_frame.pack(fill=tk.BOTH, expand=True, padx=padding, pady=padding)


class Sidebar(tk.Frame):
    """Modern sidebar widget with navigation buttons and collapse support."""

    NAV_ITEMS = [
        ("dashboard", "⌂", "Dashboard"),
        ("build", "⚡", "Build"),
        ("history", "◷", "History"),
        ("logs", "▤", "Logs"),
        ("settings", "⚙", "Settings")
    ]

    def __init__(
        self,
        parent,
        colors: ColorPalette = DARK_PALETTE,
        on_navigate: Optional[Callable[[str], None]] = None
    ):
        super().__init__(parent, bg=colors.sidebar_bg, width=220)
        self.colors = colors
        self.on_navigate = on_navigate
        self.is_collapsed = False
        self.active_tab = "dashboard"
        self.buttons: dict = {}

        self._build_ui()

    def _build_ui(self):
        self.pack_propagate(False)

        # Header Logo
        header = tk.Frame(self, bg=self.colors.sidebar_bg)
        header.pack(fill=tk.X, padx=15, pady=20)

        self.lbl_logo = tk.Label(
            header,
            text="KORA",
            font=("Segoe UI", 16, "bold"),
            fg=self.colors.primary,
            bg=self.colors.sidebar_bg
        )
        self.lbl_logo.pack(anchor="w")

        self.lbl_sub = tk.Label(
            header,
            text="Python → EXE",
            font=("Segoe UI", 8),
            fg=self.colors.text_secondary,
            bg=self.colors.sidebar_bg
        )
        self.lbl_sub.pack(anchor="w")

        # Nav list
        nav_frame = tk.Frame(self, bg=self.colors.sidebar_bg)
        nav_frame.pack(fill=tk.X, expand=True, anchor="n", pady=10)

        for key, icon, label in self.NAV_ITEMS:
            btn_frame = tk.Frame(nav_frame, bg=self.colors.sidebar_bg, cursor="hand2")
            btn_frame.pack(fill=tk.X, pady=2, padx=10)

            lbl = tk.Label(
                btn_frame,
                text=f"  {icon}   {label}",
                font=("Segoe UI", 10),
                fg=self.colors.text_secondary,
                bg=self.colors.sidebar_bg,
                anchor="w",
                padx=10,
                pady=10
            )
            lbl.pack(fill=tk.X)

            # Bind click events
            for widget in (btn_frame, lbl):
                widget.bind("<Button-1>", lambda e, k=key: self.set_active(k))
                widget.bind("<Enter>", lambda e, w=btn_frame, k=key: self._on_hover(w, k, True))
                widget.bind("<Leave>", lambda e, w=btn_frame, k=key: self._on_hover(w, k, False))

            self.buttons[key] = (btn_frame, lbl, label, icon)

        self.set_active("dashboard")

        # Version Footer
        footer = tk.Frame(self, bg=self.colors.sidebar_bg)
        footer.pack(fill=tk.X, side=tk.BOTTOM, padx=15, pady=15)
        lbl_v = tk.Label(footer, text="v1.0.0", font=("Segoe UI", 8), fg=self.colors.text_secondary, bg=self.colors.sidebar_bg)
        lbl_v.pack(anchor="w")

    def _on_hover(self, frame, key, is_hover):
        if key != self.active_tab:
            bg_col = self.colors.card_elevated if is_hover else self.colors.sidebar_bg
            frame.config(bg=bg_col)
            for child in frame.winfo_children():
                child.config(bg=bg_col)

    def set_active(self, key: str):
        self.active_tab = key
        for k, (btn_frame, lbl, label, icon) in self.buttons.items():
            if k == key:
                btn_frame.config(bg=self.colors.primary)
                lbl.config(bg=self.colors.primary, fg="#FFFFFF", font=("Segoe UI", 10, "bold"))
            else:
                btn_frame.config(bg=self.colors.sidebar_bg)
                lbl.config(bg=self.colors.sidebar_bg, fg=self.colors.text_secondary, font=("Segoe UI", 10))

        if self.on_navigate:
            self.on_navigate(key)


class RadioCardGroup(tk.Frame):
    """Segmented option cards container for selecting options like OneFile vs OneDir."""

    def __init__(
        self,
        parent,
        options: List[tuple],  # [(val, title, subtitle)]
        initial_value: str,
        on_change: Optional[Callable[[str], None]] = None,
        colors: ColorPalette = DARK_PALETTE
    ):
        super().__init__(parent, bg=colors.card_bg)
        self.colors = colors
        self.value = initial_value
        self.on_change = on_change
        self.cards: dict = {}

        self._build_ui(options)

    def _build_ui(self, options):
        for val, title, sub in options:
            card = Card(self, colors=self.colors, padding=10, cursor="hand2")
            card.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=5)

            lbl_t = tk.Label(
                card.inner_frame,
                text=title,
                font=("Segoe UI", 10, "bold"),
                fg=self.colors.text_primary,
                bg=self.colors.card_bg
            )
            lbl_t.pack(anchor="w")

            lbl_s = tk.Label(
                card.inner_frame,
                text=sub,
                font=("Segoe UI", 8),
                fg=self.colors.text_secondary,
                bg=self.colors.card_bg
            )
            lbl_s.pack(anchor="w", pady=(2, 0))

            for widget in (card, card.inner_frame, lbl_t, lbl_s):
                widget.bind("<Button-1>", lambda e, v=val: self.select(v))

            self.cards[val] = (card, lbl_t, lbl_s)

        self.select(self.value)

    def select(self, val: str):
        self.value = val
        for v, (card, lbl_t, lbl_s) in self.cards.items():
            if v == val:
                card.config(highlightbackground=self.colors.primary, highlightthickness=2, bg=self.colors.card_elevated)
                card.inner_frame.config(bg=self.colors.card_elevated)
                lbl_t.config(bg=self.colors.card_elevated, fg=self.colors.primary)
                lbl_s.config(bg=self.colors.card_elevated)
            else:
                card.config(highlightbackground=self.colors.card_border, highlightthickness=1, bg=self.colors.card_bg)
                card.inner_frame.config(bg=self.colors.card_bg)
                lbl_t.config(bg=self.colors.card_bg, fg=self.colors.text_primary)
                lbl_s.config(bg=self.colors.card_bg)

        if self.on_change:
            self.on_change(val)


class BuildPipelineWidget(tk.Frame):
    """Visual build pipeline stage progress widget."""

    STAGES = ["Project", "Analyze", "Dependencies", "Builder", "Compile", "Verify", "EXE"]

    def __init__(self, parent, colors: ColorPalette = DARK_PALETTE):
        super().__init__(parent, bg=colors.card_bg)
        self.colors = colors
        self.stage_labels: dict = {}
        self._build_ui()

    def _build_ui(self):
        for i, stage in enumerate(self.STAGES):
            frame = tk.Frame(self, bg=self.colors.card_bg)
            frame.pack(side=tk.LEFT, expand=True)

            lbl_icon = tk.Label(frame, text="○", font=("Segoe UI", 11), fg=self.colors.text_secondary, bg=self.colors.card_bg)
            lbl_icon.pack()

            lbl_name = tk.Label(frame, text=stage, font=("Segoe UI", 8), fg=self.colors.text_secondary, bg=self.colors.card_bg)
            lbl_name.pack()

            self.stage_labels[stage] = (lbl_icon, lbl_name)

            if i < len(self.STAGES) - 1:
                arr = tk.Label(self, text="→", font=("Segoe UI", 10), fg=self.colors.text_secondary, bg=self.colors.card_bg)
                arr.pack(side=tk.LEFT)

    def set_active_stage(self, current_stage: str, failed: bool = False):
        reached = True
        for stage in self.STAGES:
            icon_lbl, name_lbl = self.stage_labels[stage]
            if stage == current_stage:
                if failed:
                    icon_lbl.config(text="×", fg=self.colors.error)
                    name_lbl.config(fg=self.colors.error, font=("Segoe UI", 8, "bold"))
                else:
                    icon_lbl.config(text="●", fg=self.colors.primary)
                    name_lbl.config(fg=self.colors.primary, font=("Segoe UI", 8, "bold"))
                reached = False
            elif reached:
                icon_lbl.config(text="✓", fg=self.colors.success)
                name_lbl.config(fg=self.colors.success, font=("Segoe UI", 8))
            else:
                icon_lbl.config(text="○", fg=self.colors.text_secondary)
                name_lbl.config(fg=self.colors.text_secondary, font=("Segoe UI", 8))


class StrategyStatusWidget(tk.Frame):
    """Displays progress and status cards for fallback builders (PyInstaller, Nuitka, cx_Freeze)."""

    BUILDERS = ["PyInstaller", "Nuitka", "cx_Freeze"]

    def __init__(self, parent, colors: ColorPalette = DARK_PALETTE):
        super().__init__(parent, bg=colors.card_bg)
        self.colors = colors
        self.cards: dict = {}
        self._build_ui()

    def _build_ui(self):
        for bname in self.BUILDERS:
            card = Card(self, colors=self.colors, padding=10)
            card.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=4)

            lbl_b = tk.Label(card.inner_frame, text=bname, font=("Segoe UI", 9, "bold"), fg=self.colors.text_primary, bg=self.colors.card_bg)
            lbl_b.pack(anchor="w")

            lbl_st = tk.Label(card.inner_frame, text="Waiting...", font=("Segoe UI", 8), fg=self.colors.text_secondary, bg=self.colors.card_bg)
            lbl_st.pack(anchor="w", pady=(2, 0))

            self.cards[bname] = (card, lbl_b, lbl_st)

    def update_status(self, builder_name: str, status: str, message: str = ""):
        if builder_name in self.cards:
            card, lbl_b, lbl_st = self.cards[builder_name]
            if status == "RUNNING":
                card.config(highlightbackground=self.colors.primary, highlightthickness=1)
                lbl_st.config(text="● " + (message or "Building..."), fg=self.colors.primary)
            elif status == "SUCCESS":
                card.config(highlightbackground=self.colors.success, highlightthickness=1)
                lbl_st.config(text="✓ " + (message or "EXE Generated"), fg=self.colors.success)
            elif status == "FAILED":
                card.config(highlightbackground=self.colors.error, highlightthickness=1)
                lbl_st.config(text="× " + (message or "Failed"), fg=self.colors.error)
            else:
                card.config(highlightbackground=self.colors.card_border, highlightthickness=1)
                lbl_st.config(text=message or "Waiting", fg=self.colors.text_secondary)
