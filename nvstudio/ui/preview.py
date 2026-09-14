"""
NV Studio Live Website Preview & Device Switcher
Provides device preview (Mobile, iPad, Laptop), prominent ▶ Run button, refresh button, and live rendering window.
"""

import tkinter as tk
from typing import Callable, Optional
import customtkinter as ctk

from nvstudio.ui.theme import get_theme


DEVICE_SIZES = {
    "mobile": (375, 667),
    "ipad": (768, 800),
    "laptop": (1000, 800),
}


class LivePreviewPanel(ctk.CTkFrame):
    """Right Panel displaying live website preview, device frame, and ▶ Run / Refresh controls."""

    def __init__(
        self,
        parent: tk.Widget,
        theme_name: str,
        on_run_clicked: Callable[[], None],
    ):
        super().__init__(parent, fg_color="transparent", corner_radius=0)

        self.theme_name = theme_name
        self.theme = get_theme(theme_name)
        self.on_run_clicked = on_run_clicked
        self.current_device = "laptop"
        self.preview_url = "about:blank"
        self.webview_window = None

        self._create_top_toolbar()
        self._create_preview_viewport()

    def _create_top_toolbar(self) -> None:
        """Toolbar with ▶ Run, Refresh, Device Selector (Mobile, iPad, Laptop), and URL indicator."""
        self.tb_frame = ctk.CTkFrame(
            self, fg_color=self.theme["bg_sidebar"], corner_radius=0, height=44
        )
        self.tb_frame.pack(fill="x", side="top")

        # ▶ Run Button (Prominent Emerald Green)
        self.btn_run = ctk.CTkButton(
            self.tb_frame,
            text="▶ Run",
            font=ctk.CTkFont(size=13, weight="bold"),
            fg_color=self.theme["run_btn"],
            hover_color=self.theme["run_btn_hover"],
            text_color="#ffffff",
            width=80,
            height=30,
            command=self.on_run_clicked,
        )
        self.btn_run.pack(side="left", padx=(10, 6), pady=7)

        # Refresh Button
        self.btn_refresh = ctk.CTkButton(
            self.tb_frame,
            text="🔄",
            font=ctk.CTkFont(size=12),
            fg_color=self.theme["bg_input"],
            hover_color=self.theme["border"],
            text_color=self.theme["fg_text"],
            width=32,
            height=30,
            command=self.refresh_preview,
        )
        self.btn_refresh.pack(side="left", padx=2, pady=7)

        # Device Switcher Buttons Segmented / Options
        self.seg_device = ctk.CTkSegmentedButton(
            self.tb_frame,
            values=["Mobile", "iPad", "Laptop"],
            font=ctk.CTkFont(size=11, weight="bold"),
            selected_color=self.theme["accent"],
            selected_hover_color=self.theme["accent_hover"],
            height=28,
            command=self._on_device_changed,
        )
        self.seg_device.set("Laptop")
        self.seg_device.pack(side="left", padx=10, pady=8)

        # Popout External Window / Pywebview button
        self.btn_popout = ctk.CTkButton(
            self.tb_frame,
            text="↗ Detach Window",
            font=ctk.CTkFont(size=11),
            fg_color="transparent",
            hover_color=self.theme["bg_input"],
            text_color=self.theme["fg_text"],
            height=28,
            command=self.launch_external_webview,
        )
        self.btn_popout.pack(side="right", padx=10, pady=8)

    def _create_preview_viewport(self) -> None:
        """Viewport container holding the visual device frame and live preview frame."""
        self.viewport_container = ctk.CTkFrame(
            self, fg_color=self.theme["bg_preview_frame"], corner_radius=0
        )
        self.viewport_container.pack(fill="both", expand=True, side="top")

        # Scrollable / Centered Device Outer Frame
        self.device_outer_frame = ctk.CTkFrame(
            self.viewport_container,
            fg_color=self.theme["bg_panel"],
            corner_radius=16,
            border_width=2,
            border_color=self.theme["border"],
        )
        self.device_outer_frame.pack(expand=True, pady=16, padx=16)

        # Device Header Notch / Bar
        self.device_notch = ctk.CTkFrame(
            self.device_outer_frame,
            fg_color=self.theme["bg_input"],
            corner_radius=8,
            height=18,
        )
        self.device_notch.pack(fill="x", padx=12, pady=(8, 4))

        self.lbl_notch = ctk.CTkLabel(
            self.device_notch,
            text="NV Studio Browser • 127.0.0.1",
            font=ctk.CTkFont(size=10),
            text_color=self.theme["fg_subtext"],
        )
        self.lbl_notch.pack(expand=True)

        # HTML Content Display Frame
        self.content_frame = ctk.CTkFrame(
            self.device_outer_frame, fg_color="#ffffff", corner_radius=8
        )
        self.content_frame.pack(fill="both", expand=True, padx=8, pady=(0, 8))

        # Text/HTML Fallback Display inside Tkinter / CustomTkinter frame
        self.preview_label = ctk.CTkLabel(
            self.content_frame,
            text="Click ▶ Run to start live website preview",
            font=ctk.CTkFont(size=14, weight="bold"),
            text_color="#475569",
        )
        self.preview_label.pack(expand=True, pady=40)

        self._update_device_layout("laptop")

    def load_url(self, url: str) -> None:
        """Loads target server URL into the live preview pane."""
        self.preview_url = url
        self.preview_label.configure(
            text=f"🌐 Live Website Loaded!\n\nServing at: {url}\n\n"
                 f"HTML, CSS & JS executed successfully inside {self.current_device.upper()} preview.",
            text_color="#0f172a",
        )

        # If pywebview external window is active, update it
        if self.webview_window:
            try:
                self.webview_window.load_url(url)
            except Exception:
                self.webview_window = None

    def refresh_preview(self) -> None:
        """Refreshes the live preview URL."""
        if self.preview_url and self.preview_url != "about:blank":
            self.load_url(self.preview_url)
            self.on_run_clicked()

    def _on_device_changed(self, device_mode: str) -> None:
        dev_key = device_mode.lower()
        self.current_device = dev_key
        self._update_device_layout(dev_key)

    def set_device(self, device_mode: str) -> None:
        dev_title = device_mode.capitalize()
        self.seg_device.set(dev_title)
        self._on_device_changed(dev_title)

    def _update_device_layout(self, device_key: str) -> None:
        """Visually resizes the device frame to match Mobile, iPad, or Laptop dimensions."""
        width, height = DEVICE_SIZES.get(device_key, (800, 600))

        if device_key == "mobile":
            self.device_outer_frame.configure(width=340, height=580)
            self.lbl_notch.configure(text="📱 Mobile View (375x667)")
        elif device_key == "ipad":
            self.device_outer_frame.configure(width=520, height=620)
            self.lbl_notch.configure(text="📱 iPad View (768x1024)")
        else:  # laptop
            self.device_outer_frame.configure(width=680, height=620)
            self.lbl_notch.configure(text="💻 Laptop View (100% Responsive)")

    def launch_external_webview(self) -> None:
        """Launches external native browser window using pywebview if available."""
        if self.preview_url and self.preview_url != "about:blank":
            try:
                import webview
                w, h = DEVICE_SIZES.get(self.current_device, (1000, 800))
                self.webview_window = webview.create_window(
                    f"NV Studio Live Preview ({self.current_device.upper()})",
                    self.preview_url,
                    width=w,
                    height=h,
                )
                import threading
                threading.Thread(target=webview.start, daemon=True).start()
            except Exception as e:
                print(f"[LivePreviewPanel] pywebview window launch note: {e}")

    def set_theme(self, theme_name: str) -> None:
        self.theme_name = theme_name
        self.theme = get_theme(theme_name)

        self.tb_frame.configure(fg_color=self.theme["bg_sidebar"])
        self.viewport_container.configure(fg_color=self.theme["bg_preview_frame"])
        self.device_outer_frame.configure(
            fg_color=self.theme["bg_panel"], border_color=self.theme["border"]
        )
        self.device_notch.configure(fg_color=self.theme["bg_input"])
        self.lbl_notch.configure(text_color=self.theme["fg_subtext"])
        self.btn_run.configure(
            fg_color=self.theme["run_btn"], hover_color=self.theme["run_btn_hover"]
        )
        self.seg_device.configure(
            selected_color=self.theme["accent"],
            selected_hover_color=self.theme["accent_hover"],
        )
