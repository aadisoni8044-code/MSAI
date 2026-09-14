"""
NV Studio Dialogs
Includes First-Launch Theme Selection, First-Launch Storage Permission, and Settings Modal.
"""

import tkinter as tk
from typing import Callable, Optional
import customtkinter as ctk

from nvstudio.config import config
from nvstudio.ui.theme import get_theme


class FirstLaunchThemeDialog(ctk.CTkToplevel):
    """First-launch dialog prompting user: 'Choose your NV Studio theme'."""

    def __init__(self, parent: tk.Tk, on_select: Callable[[str], None]):
        super().__init__(parent)
        self.on_select = on_select

        self.title("Welcome to NV Studio")
        self.geometry("500x380")
        self.resizable(False, False)

        # Center dialog
        self.transient(parent)
        self.grab_set()

        theme = get_theme("dark")
        self.configure(fg_color=theme["bg_main"])

        # Header Label
        lbl_title = ctk.CTkLabel(
            self,
            text="Choose your NV Studio theme",
            font=ctk.CTkFont(size=20, weight="bold"),
            text_color=theme["fg_text"],
        )
        lbl_title.pack(pady=(32, 10))

        lbl_desc = ctk.CTkLabel(
            self,
            text="Select your preferred workspace aesthetic.\nYou can always change this later in Settings.",
            font=ctk.CTkFont(size=13),
            text_color=theme["fg_subtext"],
            justify="center",
        )
        lbl_desc.pack(pady=(0, 24))

        # Buttons Container
        btn_frame = ctk.CTkFrame(self, fg_color="transparent")
        btn_frame.pack(pady=10, padx=30, fill="x")

        # Dark Mode Button
        btn_dark = ctk.CTkButton(
            btn_frame,
            text="🌙  Dark Mode",
            font=ctk.CTkFont(size=14, weight="bold"),
            fg_color="#1e293b",
            hover_color="#334155",
            text_color="#f8fafc",
            border_width=2,
            border_color="#6366f1",
            height=54,
            command=lambda: self._select("dark"),
        )
        btn_dark.pack(side="left", expand=True, fill="x", padx=10)

        # White / Light Mode Button
        btn_light = ctk.CTkButton(
            btn_frame,
            text="☀️  White Mode",
            font=ctk.CTkFont(size=14, weight="bold"),
            fg_color="#f1f5f9",
            hover_color="#e2e8f0",
            text_color="#0f172a",
            border_width=2,
            border_color="#cbd5e1",
            height=54,
            command=lambda: self._select("light"),
        )
        btn_light.pack(side="right", expand=True, fill="x", padx=10)

        # Bottom info tag
        lbl_info = ctk.CTkLabel(
            self,
            text="NV Studio by Nvisov • Professional Web Code Editor",
            font=ctk.CTkFont(size=11),
            text_color=theme["fg_muted"],
        )
        lbl_info.pack(side="bottom", pady=20)

    def _select(self, theme_name: str) -> None:
        config.set("theme", theme_name)
        self.on_select(theme_name)
        self.destroy()


class FirstLaunchPermissionDialog(ctk.CTkToplevel):
    """First-launch dialog requesting project storage & workspace permission."""

    def __init__(self, parent: tk.Tk, on_grant: Callable[[], None]):
        super().__init__(parent)
        self.on_grant = on_grant

        self.title("Storage & Workspace Permission")
        self.geometry("480x340")
        self.resizable(False, False)

        self.transient(parent)
        self.grab_set()

        current_theme_name = config.get("theme", "dark")
        theme = get_theme(current_theme_name)
        self.configure(fg_color=theme["bg_main"])

        # Icon / Header
        lbl_title = ctk.CTkLabel(
            self,
            text="Workspace Storage Permission",
            font=ctk.CTkFont(size=19, weight="bold"),
            text_color=theme["fg_text"],
        )
        lbl_title.pack(pady=(28, 10))

        desc_text = (
            "NV Studio requires local storage access to:\n\n"
            "• Create and save HTML, CSS, & JavaScript files\n"
            "• Store workspace state for instant auto-restore\n"
            "• Auto-save your ongoing work while coding\n\n"
            "Your files remain 100% private and stored locally."
        )

        lbl_desc = ctk.CTkLabel(
            self,
            text=desc_text,
            font=ctk.CTkFont(size=12),
            text_color=theme["fg_subtext"],
            justify="left",
        )
        lbl_desc.pack(pady=(0, 20), padx=36)

        btn_grant = ctk.CTkButton(
            self,
            text="Grant Access & Continue",
            font=ctk.CTkFont(size=14, weight="bold"),
            fg_color=theme["accent"],
            hover_color=theme["accent_hover"],
            text_color=theme["accent_fg"],
            height=44,
            command=self._grant,
        )
        btn_grant.pack(padx=36, fill="x", pady=10)

    def _grant(self) -> None:
        config.set("storage_permission_granted", True)
        self.on_grant()
        self.destroy()


class SettingsDialog(ctk.CTkToplevel):
    """Clean professional Settings panel for NV Studio."""

    def __init__(self, parent: tk.Tk, on_settings_changed: Callable[[], None]):
        super().__init__(parent)
        self.on_settings_changed = on_settings_changed

        self.title("NV Studio Settings")
        self.geometry("460x420")
        self.resizable(False, False)

        self.transient(parent)
        self.grab_set()

        self.current_theme_name = config.get("theme", "dark")
        theme = get_theme(self.current_theme_name)
        self.configure(fg_color=theme["bg_main"])

        # Title Header
        lbl_header = ctk.CTkLabel(
            self,
            text="Settings",
            font=ctk.CTkFont(size=20, weight="bold"),
            text_color=theme["fg_text"],
        )
        lbl_header.pack(pady=(20, 15), padx=20, anchor="w")

        # Container Frame
        container = ctk.CTkFrame(self, fg_color=theme["bg_panel"], corner_radius=10)
        container.pack(padx=20, pady=5, fill="both", expand=True)

        # 1. Theme Option
        f_theme = ctk.CTkFrame(container, fg_color="transparent")
        f_theme.pack(fill="x", padx=16, pady=12)
        lbl_t = ctk.CTkLabel(
            f_theme,
            text="Theme Mode",
            font=ctk.CTkFont(size=13, weight="bold"),
            text_color=theme["fg_text"],
        )
        lbl_t.pack(side="left")

        self.opt_theme = ctk.CTkOptionMenu(
            f_theme,
            values=["Dark Mode", "White Mode"],
            fg_color=theme["bg_input"],
            button_color=theme["accent"],
            text_color=theme["fg_text"],
            command=self._on_theme_change,
        )
        self.opt_theme.set("White Mode" if self.current_theme_name == "light" else "Dark Mode")
        self.opt_theme.pack(side="right")

        # 2. Auto Save Switch
        f_autosave = ctk.CTkFrame(container, fg_color="transparent")
        f_autosave.pack(fill="x", padx=16, pady=12)
        lbl_as = ctk.CTkLabel(
            f_autosave,
            text="Auto Save Code",
            font=ctk.CTkFont(size=13, weight="bold"),
            text_color=theme["fg_text"],
        )
        lbl_as.pack(side="left")

        self.sw_autosave = ctk.CTkSwitch(
            f_autosave,
            text="",
            progress_color=theme["accent"],
            command=self._on_autosave_toggle,
        )
        if config.get("auto_save", True):
            self.sw_autosave.select()
        else:
            self.sw_autosave.deselect()
        self.sw_autosave.pack(side="right")

        # 3. Default Preview Device
        f_device = ctk.CTkFrame(container, fg_color="transparent")
        f_device.pack(fill="x", padx=16, pady=12)
        lbl_dev = ctk.CTkLabel(
            f_device,
            text="Default Preview Device",
            font=ctk.CTkFont(size=13, weight="bold"),
            text_color=theme["fg_text"],
        )
        lbl_dev.pack(side="left")

        self.opt_device = ctk.CTkOptionMenu(
            f_device,
            values=["Mobile", "iPad", "Laptop"],
            fg_color=theme["bg_input"],
            button_color=theme["accent"],
            text_color=theme["fg_text"],
            command=self._on_device_change,
        )
        dev_val = config.get("preview_device", "laptop").capitalize()
        self.opt_device.set(dev_val)
        self.opt_device.pack(side="right")

        # 4. Restore Workspace Switch
        f_restore = ctk.CTkFrame(container, fg_color="transparent")
        f_restore.pack(fill="x", padx=16, pady=12)
        lbl_res = ctk.CTkLabel(
            f_restore,
            text="Restore Previous Workspace",
            font=ctk.CTkFont(size=13, weight="bold"),
            text_color=theme["fg_text"],
        )
        lbl_res.pack(side="left")

        self.sw_restore = ctk.CTkSwitch(
            f_restore,
            text="",
            progress_color=theme["accent"],
            command=self._on_restore_toggle,
        )
        if config.get("restore_workspace", True):
            self.sw_restore.select()
        else:
            self.sw_restore.deselect()
        self.sw_restore.pack(side="right")

        # Close / Save Button
        btn_close = ctk.CTkButton(
            self,
            text="Close",
            font=ctk.CTkFont(size=13, weight="bold"),
            fg_color=theme["accent"],
            hover_color=theme["accent_hover"],
            text_color=theme["accent_fg"],
            height=36,
            command=self.destroy,
        )
        btn_close.pack(pady=15, padx=20, fill="x")

    def _on_theme_change(self, value: str) -> None:
        new_theme = "light" if "White" in value else "dark"
        config.set("theme", new_theme)
        self.on_settings_changed()

    def _on_autosave_toggle(self) -> None:
        val = bool(self.sw_autosave.get())
        config.set("auto_save", val)
        self.on_settings_changed()

    def _on_device_change(self, value: str) -> None:
        config.set("preview_device", value.lower())
        self.on_settings_changed()

    def _on_restore_toggle(self) -> None:
        val = bool(self.sw_restore.get())
        config.set("restore_workspace", val)
        self.on_settings_changed()
