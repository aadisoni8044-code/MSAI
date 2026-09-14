"""
NV Studio Main Window Application
Integrates Explorer sidebar, Editor tabbed panel, Live Preview panel, Status Bar, and Settings modal.
Includes automatic workspace state saving and restoration.
"""

import sys
import os
import tkinter as tk
from pathlib import Path
from typing import Optional
import customtkinter as ctk

from nvstudio.config import config
from nvstudio.server import LocalServer
from nvstudio.ui.dialogs import (
    FirstLaunchPermissionDialog,
    FirstLaunchThemeDialog,
    SettingsDialog,
)
from nvstudio.ui.editor import CodeEditorPanel
from nvstudio.ui.explorer import FileExplorer
from nvstudio.ui.preview import LivePreviewPanel
from nvstudio.ui.theme import get_theme
from nvstudio.workspace import WorkspaceManager


class NVStudioApp(ctk.CTk):
    """Main Desktop Application Window for NV Studio."""

    def __init__(self, test_launch: bool = False):
        super().__init__()

        self.test_launch = test_launch
        self.title("NV Studio")
        self.geometry("1280x800")
        self.minsize(900, 600)

        # Initialize Workspace & Local Web Server
        initial_path = config.get("last_workspace_path")
        self.workspace = WorkspaceManager(initial_path)
        self.server = LocalServer(self.workspace.root_path)
        self.server.start()

        # Theme Initialization
        self.current_theme_name = config.get("theme") or "dark"
        ctk.set_appearance_mode("dark" if self.current_theme_name == "dark" else "light")
        self.theme = get_theme(self.current_theme_name)

        # Build Main UI Components
        self._create_header_bar()
        self._create_workspace_panes()
        self._create_status_bar()

        # Check First Launch Dialogs
        self._check_first_launch_flow()

        # Restore Previous Workspace State
        self.after(200, self._restore_workspace_state)

        # Auto Save Loop
        self._schedule_auto_save()

        # Bind Window Closing Event
        self.protocol("WM_DELETE_WINDOW", self.on_closing)

        if self.test_launch:
            self.after(500, self.destroy)

    def _create_header_bar(self) -> None:
        """Top Application Brand & Toolbar Header."""
        self.header_frame = ctk.CTkFrame(
            self, fg_color=self.theme["bg_main"], corner_radius=0, height=48
        )
        self.header_frame.pack(fill="x", side="top")

        # Brand Logo Title
        self.lbl_logo = ctk.CTkLabel(
            self.header_frame,
            text="NV STUDIO",
            font=ctk.CTkFont(size=16, weight="bold"),
            text_color=self.theme["accent"],
        )
        self.lbl_logo.pack(side="left", padx=16, pady=10)

        self.lbl_project_name = ctk.CTkLabel(
            self.header_frame,
            text=f"• {self.workspace.root_path.name}",
            font=ctk.CTkFont(size=12),
            text_color=self.theme["fg_subtext"],
        )
        self.lbl_project_name.pack(side="left", padx=4, pady=10)

        # Right Action Buttons (Settings, Theme Switcher)
        self.btn_settings = ctk.CTkButton(
            self.header_frame,
            text="⚙️ Settings",
            font=ctk.CTkFont(size=12),
            fg_color=self.theme["bg_input"],
            hover_color=self.theme["border"],
            text_color=self.theme["fg_text"],
            width=90,
            height=30,
            command=self.open_settings_dialog,
        )
        self.btn_settings.pack(side="right", padx=16, pady=9)

    def _create_workspace_panes(self) -> None:
        """Creates 3-pane Layout: Explorer (Left), Editor (Center), Preview (Right)."""
        self.main_container = ctk.CTkFrame(
            self, fg_color=self.theme["bg_main"], corner_radius=0
        )
        self.main_container.pack(fill="both", expand=True, side="top")

        # 1. Left Explorer Sidebar (Width ~230px)
        self.explorer = FileExplorer(
            self.main_container,
            workspace=self.workspace,
            theme_name=self.current_theme_name,
            on_file_select=self._on_file_selected,
            on_folder_change=self._on_folder_changed,
        )
        self.explorer.pack(side="left", fill="y", padx=(0, 1))

        # 2. Right Preview Panel (Width ~450px) - Packed right so center editor expands
        self.preview = LivePreviewPanel(
            self.main_container,
            theme_name=self.current_theme_name,
            on_run_clicked=self.run_project,
        )
        self.preview.pack(side="right", fill="both", expand=False, padx=(1, 0))

        # 3. Center Code Editor Panel
        self.editor = CodeEditorPanel(
            self.main_container,
            theme_name=self.current_theme_name,
            on_content_saved=self._on_code_saved,
            on_run_requested=self.run_project,
        )
        self.editor.pack(side="left", fill="both", expand=True)

    def _create_status_bar(self) -> None:
        """Bottom Application Status Bar."""
        self.status_bar = ctk.CTkFrame(
            self, fg_color=self.theme["bg_sidebar"], corner_radius=0, height=24
        )
        self.status_bar.pack(fill="x", side="bottom")

        self.lbl_status = ctk.CTkLabel(
            self.status_bar,
            text="Ready • Auto Save Enabled",
            font=ctk.CTkFont(size=11),
            text_color=self.theme["fg_subtext"],
        )
        self.lbl_status.pack(side="left", padx=12, pady=2)

        self.lbl_version = ctk.CTkLabel(
            self.status_bar,
            text="NV Studio v1.0.0",
            font=ctk.CTkFont(size=11),
            text_color=self.theme["fg_muted"],
        )
        self.lbl_version.pack(side="right", padx=12, pady=2)

    def _check_first_launch_flow(self) -> None:
        """Shows Theme dialog and Permission dialog on first launch."""
        if config.get("theme") is None:
            FirstLaunchThemeDialog(self, on_select=self._on_first_launch_theme_selected)
        elif not config.get("storage_permission_granted", False):
            FirstLaunchPermissionDialog(self, on_grant=lambda: None)

    def _on_first_launch_theme_selected(self, chosen_theme: str) -> None:
        self.apply_theme(chosen_theme)
        if not config.get("storage_permission_granted", False):
            FirstLaunchPermissionDialog(self, on_grant=lambda: None)

    def apply_theme(self, theme_name: str) -> None:
        """Applies theme throughout all UI components."""
        self.current_theme_name = theme_name
        config.set("theme", theme_name)
        ctk.set_appearance_mode("dark" if theme_name == "dark" else "light")

        self.theme = get_theme(theme_name)
        self.configure(fg_color=self.theme["bg_main"])
        self.header_frame.configure(fg_color=self.theme["bg_main"])
        self.lbl_logo.configure(text_color=self.theme["accent"])
        self.lbl_project_name.configure(text_color=self.theme["fg_subtext"])
        self.btn_settings.configure(
            fg_color=self.theme["bg_input"], text_color=self.theme["fg_text"]
        )

        self.explorer.set_theme(theme_name)
        self.editor.set_theme(theme_name)
        self.preview.set_theme(theme_name)

        self.status_bar.configure(fg_color=self.theme["bg_sidebar"])
        self.lbl_status.configure(text_color=self.theme["fg_subtext"])
        self.lbl_version.configure(text_color=self.theme["fg_muted"])

    def open_settings_dialog(self) -> None:
        SettingsDialog(self, on_settings_changed=self._on_settings_changed)

    def _on_settings_changed(self) -> None:
        new_theme = config.get("theme", "dark")
        if new_theme != self.current_theme_name:
            self.apply_theme(new_theme)

        device = config.get("preview_device", "laptop")
        self.preview.set_device(device)

    def _on_file_selected(self, rel_path: str) -> None:
        """Opens file in editor when clicked in treeview."""
        content = self.workspace.read_file(rel_path)
        self.editor.open_tab(rel_path, content)
        self.lbl_status.configure(text=f"Opened: {rel_path}")

    def _on_folder_changed(self, new_folder: str) -> None:
        """Handles opening a new workspace folder."""
        self.lbl_project_name.configure(text=f"• {self.workspace.root_path.name}")
        self.server.update_directory(self.workspace.root_path)

        # Open index.html by default
        if Path(new_folder, "index.html").exists():
            self._on_file_selected("index.html")

        self.run_project()

    def _on_code_saved(self, rel_path: str, content: str) -> None:
        """Saves edited content to disk."""
        self.workspace.save_file(rel_path, content)
        self.lbl_status.configure(text=f"Saved: {rel_path}")

    def run_project(self) -> None:
        """Executes current HTML, CSS, and JS workspace project and loads in live preview."""
        # Ensure all open tabs are saved first
        for rel_path, tab_view in self.editor.tabs.items():
            self.workspace.save_file(rel_path, tab_view.get_content())

        url = self.server.get_url("index.html")
        self.preview.load_url(url)
        self.lbl_status.configure(text="▶ Website Executed in Live Preview")

    def _restore_workspace_state(self) -> None:
        """Restores open files, active tab, device preference, and workspace path."""
        if not config.get("restore_workspace", True):
            self._on_file_selected("index.html")
            return

        state = config.workspace_state
        open_files = state.get("open_files", [])
        active_file = state.get("active_file")
        device = state.get("preview_device", "laptop")

        self.preview.set_device(device)

        if open_files:
            for rel_p in open_files:
                if (self.workspace.root_path / rel_p).exists():
                    cnt = self.workspace.read_file(rel_p)
                    self.editor.open_tab(rel_p, cnt)

        if active_file and (self.workspace.root_path / active_file).exists():
            self.editor.switch_to_tab(active_file)
        elif not self.editor.tabs:
            self._on_file_selected("index.html")

        # Initial live preview load
        self.run_project()

    def _schedule_auto_save(self) -> None:
        """Periodically saves open editor files and session state."""
        if config.get("auto_save", True):
            for rel_path, tab in self.editor.tabs.items():
                content = tab.get_content()
                self.workspace.save_file(rel_path, content)

            # Persist workspace session state
            config.save_workspace_state(
                project_path=str(self.workspace.root_path),
                open_files=list(self.editor.tabs.keys()),
                active_file=self.editor.active_tab_key,
                preview_device=self.preview.current_device,
            )

        # Run every 3 seconds
        self.after(3000, self._schedule_auto_save)

    def on_closing(self) -> None:
        """Saves state and shuts down local server gracefully before exit."""
        try:
            # Final save
            for rel_path, tab in self.editor.tabs.items():
                self.workspace.save_file(rel_path, tab.get_content())

            config.save_workspace_state(
                project_path=str(self.workspace.root_path),
                open_files=list(self.editor.tabs.keys()),
                active_file=self.editor.active_tab_key,
                preview_device=self.preview.current_device,
            )
            self.server.stop()
        except Exception as e:
            print(f"[NVStudioApp] Exit save note: {e}")
        finally:
            self.destroy()
