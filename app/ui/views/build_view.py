"""Build View for Kora UI."""

import os
import tkinter as tk
from tkinter import ttk, filedialog, messagebox
from typing import Callable, Optional
from models.build_strategy import BuildResult
from app.ui.theme import ColorPalette, DARK_PALETTE
from app.ui.components import Card, BuildPipelineWidget, StrategyStatusWidget
from app.ui.terminal_view import TerminalView


class BuildView(tk.Frame):
    """Build view featuring real-time visual build pipeline, strategy status cards, compact error cards, and tabbed terminal logs."""

    def __init__(
        self,
        parent,
        colors: ColorPalette = DARK_PALETTE,
        on_stop_build: Optional[Callable[[], None]] = None,
        on_test_exe: Optional[Callable[[], None]] = None,
        on_open_folder: Optional[Callable[[], None]] = None
    ):
        super().__init__(parent, bg=colors.bg_dark)
        self.colors = colors
        self.on_stop_build = on_stop_build
        self.on_test_exe = on_test_exe
        self.on_open_folder = on_open_folder

        self.last_result: Optional[BuildResult] = None
        self._build_ui()

    def _build_ui(self):
        # Header Status Bar
        header = tk.Frame(self, bg=self.colors.bg_dark)
        header.pack(fill=tk.X, padx=25, pady=(20, 10))

        self.lbl_build_title = tk.Label(
            header,
            text="Build Progress & Output",
            font=("Segoe UI", 16, "bold"),
            fg=self.colors.text_primary,
            bg=self.colors.bg_dark
        )
        self.lbl_build_title.pack(side=tk.LEFT)

        self.btn_stop = tk.Button(
            header,
            text="Stop Build",
            font=("Segoe UI", 9, "bold"),
            fg="#FFFFFF",
            bg=self.colors.error,
            activebackground="#DC2626",
            bd=0,
            padx=12,
            pady=6,
            cursor="hand2",
            state=tk.DISABLED,
            command=self._on_stop_clicked
        )
        self.btn_stop.pack(side=tk.RIGHT)

        # Build Pipeline Widget
        self.pipeline_card = Card(self, colors=self.colors, padding=15)
        self.pipeline_card.pack(fill=tk.X, padx=25, pady=5)
        self.pipeline_widget = BuildPipelineWidget(self.pipeline_card.inner_frame, colors=self.colors)
        self.pipeline_widget.pack(fill=tk.X)

        # Fallback Strategy Cards
        self.strategy_card = Card(self, colors=self.colors, padding=12)
        self.strategy_card.pack(fill=tk.X, padx=25, pady=5)
        self.strategy_widget = StrategyStatusWidget(self.strategy_card.inner_frame, colors=self.colors)
        self.strategy_widget.pack(fill=tk.X)

        # Compact Error Card Overlay (Hidden by default)
        self.error_card = Card(self, colors=self.colors, padding=12, border_color=self.colors.error, bg=self.colors.card_elevated)
        self._render_error_card_content("No error")

        # Success Screen Card Overlay (Hidden by default)
        self.success_card = Card(self, colors=self.colors, padding=15, border_color=self.colors.success, bg=self.colors.card_elevated)
        self._render_success_card_content("N/A", "0 MB")

        # Tabbed Output Logs Area
        logs_container = tk.Frame(self, bg=self.colors.bg_dark)
        logs_container.pack(fill=tk.BOTH, expand=True, padx=25, pady=10)

        self.terminal = TerminalView(logs_container)
        self.terminal.pack(fill=tk.BOTH, expand=True)

    def _render_error_card_content(self, error_msg: str, suggested_action: str = ""):
        for child in self.error_card.inner_frame.winfo_children():
            child.destroy()

        hdr = tk.Frame(self.error_card.inner_frame, bg=self.colors.card_elevated)
        hdr.pack(fill=tk.X)

        tk.Label(hdr, text="× BUILD FAILED", font=("Segoe UI", 10, "bold"), fg=self.colors.error, bg=self.colors.card_elevated).pack(side=tk.LEFT)
        tk.Label(self.error_card.inner_frame, text=error_msg, font=("Segoe UI", 9), fg=self.colors.text_primary, bg=self.colors.card_elevated, wraplength=700, justify="left").pack(anchor="w", pady=(4, 2))

        if suggested_action:
            tk.Label(self.error_card.inner_frame, text=f"Suggested Action: {suggested_action}", font=("Segoe UI", 9, "bold"), fg=self.colors.warning, bg=self.colors.card_elevated).pack(anchor="w", pady=(2, 0))

    def _render_success_card_content(self, exe_path: str, size_str: str):
        for child in self.success_card.inner_frame.winfo_children():
            child.destroy()

        hdr = tk.Frame(self.success_card.inner_frame, bg=self.colors.card_elevated)
        hdr.pack(fill=tk.X)

        tk.Label(hdr, text="✓ BUILD COMPLETE", font=("Segoe UI", 12, "bold"), fg=self.colors.success, bg=self.colors.card_elevated).pack(side=tk.LEFT)

        btn_box = tk.Frame(hdr, bg=self.colors.card_elevated)
        btn_box.pack(side=tk.RIGHT)

        tk.Button(
            btn_box,
            text="▶ Test EXE",
            font=("Segoe UI", 8, "bold"),
            fg="#FFFFFF",
            bg=self.colors.primary,
            activebackground=self.colors.primary_hover,
            bd=0,
            padx=10,
            pady=4,
            cursor="hand2",
            command=self._on_test_clicked
        ).pack(side=tk.LEFT, padx=4)

        tk.Button(
            btn_box,
            text="📁 Open Folder",
            font=("Segoe UI", 8, "bold"),
            fg=self.colors.text_primary,
            bg=self.colors.card_border,
            bd=0,
            padx=10,
            pady=4,
            cursor="hand2",
            command=self._on_open_clicked
        ).pack(side=tk.LEFT, padx=4)

        tk.Label(self.success_card.inner_frame, text=f"Generated Executable: {exe_path} ({size_str})", font=("Segoe UI", 9), fg=self.colors.text_primary, bg=self.colors.card_elevated).pack(anchor="w", pady=(4, 0))

    def start_building(self):
        self.btn_stop.config(state=tk.NORMAL)
        self.error_card.pack_forget()
        self.success_card.pack_forget()
        self.pipeline_widget.set_active_stage("Project")

    def show_success(self, result: BuildResult):
        self.btn_stop.config(state=tk.DISABLED)
        self.last_result = result
        self.pipeline_widget.set_active_stage("EXE")
        size_mb = f"{round(os.path.getsize(result.output_exe)/(1024*1024), 2)} MB" if result.output_exe and os.path.exists(result.output_exe) else "N/A"
        self._render_success_card_content(result.output_exe or "Executable", size_mb)
        self.success_card.pack(fill=tk.X, padx=25, pady=5, before=self.terminal.master)

    def show_failure(self, summary_msg: str):
        self.btn_stop.config(state=tk.DISABLED)
        self.pipeline_widget.set_active_stage("Builder", failed=True)
        self._render_error_card_content(summary_msg)
        self.error_card.pack(fill=tk.X, padx=25, pady=5, before=self.terminal.master)

    def _on_stop_clicked(self):
        if self.on_stop_build:
            self.on_stop_build()

    def _on_test_clicked(self):
        if self.on_test_exe:
            self.on_test_exe()

    def _on_open_clicked(self):
        if self.on_open_folder:
            self.on_open_folder()
