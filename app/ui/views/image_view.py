"""Image to EXE UI View for Kora."""

import os
import tkinter as tk
from tkinter import filedialog, messagebox
from typing import Callable, Optional, Dict, Any
from models.build_strategy import BuildResult
from app.image_exporter.generator import ImageExeExporter
from app.ui.theme import ColorPalette, DARK_PALETTE
from app.ui.components import Card
from app.ui.terminal_view import TerminalView


class ImageView(tk.Frame):
    """Image -> EXE view allowing users to select an image and package it into a standalone Windows executable."""

    def __init__(
        self,
        parent,
        colors: ColorPalette = DARK_PALETTE,
        on_start_export: Optional[Callable[[str, str, str], None]] = None,
        on_test_exe: Optional[Callable[[str], None]] = None,
        on_open_folder: Optional[Callable[[str], None]] = None
    ):
        super().__init__(parent, bg=colors.bg_dark)
        self.colors = colors
        self.on_start_export = on_start_export
        self.on_test_exe = on_test_exe
        self.on_open_folder = on_open_folder

        self.exporter = ImageExeExporter()
        self.selected_image_path: Optional[str] = None
        self.image_metadata: Optional[Dict[str, Any]] = None
        self.last_result: Optional[BuildResult] = None

        self._build_ui()

    def _build_ui(self):
        # Header Title
        header = tk.Frame(self, bg=self.colors.bg_dark)
        header.pack(fill=tk.X, padx=25, pady=(20, 10))

        lbl_title = tk.Label(
            header,
            text="Image → EXE",
            font=("Segoe UI", 16, "bold"),
            fg=self.colors.text_primary,
            bg=self.colors.bg_dark
        )
        lbl_title.pack(anchor="w")

        lbl_sub = tk.Label(
            header,
            text="Turn an image into a standalone Windows executable with embedded resources.",
            font=("Segoe UI", 10),
            fg=self.colors.text_secondary,
            bg=self.colors.bg_dark
        )
        lbl_sub.pack(anchor="w", pady=(2, 0))

        # Selection & Config Card
        self.card_select = Card(self, colors=self.colors, padding=20)
        self.card_select.pack(fill=tk.X, padx=25, pady=10)

        grid = tk.Frame(self.card_select.inner_frame, bg=self.colors.card_bg)
        grid.pack(fill=tk.X)

        # Image Picker
        tk.Label(grid, text="Select Image:", font=("Segoe UI", 9, "bold"), fg=self.colors.text_primary, bg=self.colors.card_bg).grid(row=0, column=0, sticky="w", pady=8)

        btn_sel = tk.Button(
            grid,
            text="Select Image File",
            font=("Segoe UI", 9, "bold"),
            fg="#FFFFFF",
            bg=self.colors.primary,
            activebackground=self.colors.primary_hover,
            bd=0,
            padx=12,
            pady=6,
            cursor="hand2",
            command=self._on_select_image
        )
        btn_sel.grid(row=0, column=1, sticky="w", padx=10, pady=8)

        self.lbl_img_path = tk.Label(grid, text="No image selected", font=("Segoe UI", 9, "italic"), fg=self.colors.text_secondary, bg=self.colors.card_bg)
        self.lbl_img_path.grid(row=0, column=2, sticky="w", padx=10, pady=8)

        # Metadata Label
        self.lbl_meta = tk.Label(self.card_select.inner_frame, text="", font=("Segoe UI", 9, "bold"), fg=self.colors.success, bg=self.colors.card_bg)
        self.lbl_meta.pack(anchor="w", pady=(2, 10))

        # Output EXE Name Input
        tk.Label(grid, text="Output EXE Name:", font=("Segoe UI", 9, "bold"), fg=self.colors.text_primary, bg=self.colors.card_bg).grid(row=1, column=0, sticky="w", pady=8)
        self.entry_exe_name = tk.Entry(grid, bg=self.colors.input_bg, fg=self.colors.text_primary, insertbackground="#FFFFFF", bd=1, relief=tk.FLAT, font=("Segoe UI", 9), width=30)
        self.entry_exe_name.insert(0, "MyImage.exe")
        self.entry_exe_name.grid(row=1, column=1, columnspan=2, sticky="w", padx=10, pady=8)

        # Output Location
        tk.Label(grid, text="Output Folder:", font=("Segoe UI", 9, "bold"), fg=self.colors.text_primary, bg=self.colors.card_bg).grid(row=2, column=0, sticky="w", pady=8)
        self.entry_output_dir = tk.Entry(grid, bg=self.colors.input_bg, fg=self.colors.text_primary, insertbackground="#FFFFFF", bd=1, relief=tk.FLAT, font=("Segoe UI", 9), width=30)
        self.entry_output_dir.insert(0, os.path.abspath("dist"))
        self.entry_output_dir.grid(row=2, column=1, sticky="w", padx=10, pady=8)

        btn_browse = tk.Button(
            grid,
            text="Choose Folder",
            font=("Segoe UI", 8, "bold"),
            fg=self.colors.text_primary,
            bg=self.colors.card_border,
            bd=0,
            padx=10,
            pady=4,
            cursor="hand2",
            command=self._on_choose_folder
        )
        btn_browse.grid(row=2, column=2, sticky="w", padx=5, pady=8)

        # Action Button Area
        action_frame = tk.Frame(self, bg=self.colors.bg_dark)
        action_frame.pack(fill=tk.X, padx=25, pady=10)

        self.btn_create = tk.Button(
            action_frame,
            text="⚡  CREATE EXE",
            font=("Segoe UI", 12, "bold"),
            fg="#FFFFFF",
            bg=self.colors.primary,
            activebackground=self.colors.primary_hover,
            bd=0,
            padx=25,
            pady=10,
            cursor="hand2",
            state=tk.DISABLED,
            command=self._on_create_clicked
        )
        self.btn_create.pack(side=tk.LEFT)

        self.lbl_status = tk.Label(action_frame, text="● Ready", font=("Segoe UI", 10), fg=self.colors.text_secondary, bg=self.colors.bg_dark)
        self.lbl_status.pack(side=tk.LEFT, padx=20)

        # Terminal & Logs
        container = tk.Frame(self, bg=self.colors.bg_dark)
        container.pack(fill=tk.BOTH, expand=True, padx=25, pady=10)
        self.terminal = TerminalView(container)
        self.terminal.pack(fill=tk.BOTH, expand=True)

    def _on_select_image(self):
        file_path = filedialog.askopenfilename(
            title="Select Image File",
            filetypes=[("Image Files", "*.png *.jpg *.jpeg *.bmp *.gif *.webp"), ("All Files", "*.*")]
        )
        if not file_path:
            return

        val = self.exporter.validate_image_path(file_path)
        if not val["valid"]:
            messagebox.showerror("Invalid Image", val["error"])
            return

        self.selected_image_path = file_path
        self.image_metadata = val

        self.lbl_img_path.config(text=os.path.basename(file_path), fg=self.colors.text_primary, font=("Segoe UI", 9, "bold"))
        dim_str = f"{val['dimensions'][0]} × {val['dimensions'][1]}" if val['dimensions'] != (0, 0) else "N/A"
        self.lbl_meta.config(text=f"✓ Image selected: {val['filename']} ({dim_str}, {val['size_mb']} MB)")

        default_exe = os.path.splitext(val['filename'])[0] + ".exe"
        self.entry_exe_name.delete(0, tk.END)
        self.entry_exe_name.insert(0, default_exe)

        self.btn_create.config(state=tk.NORMAL)
        self.lbl_status.config(text="● Ready to create EXE", fg=self.colors.success)

    def _on_choose_folder(self):
        folder = filedialog.askdirectory(title="Select Output Directory")
        if folder:
            self.entry_output_dir.delete(0, tk.END)
            self.entry_output_dir.insert(0, os.path.abspath(folder))

    def _on_create_clicked(self):
        if not self.selected_image_path:
            return

        exe_name = self.entry_exe_name.get().strip() or "MyImage.exe"
        out_dir = self.entry_output_dir.get().strip() or os.path.abspath("dist")

        if self.on_start_export:
            self.on_start_export(self.selected_image_path, exe_name, out_dir)
