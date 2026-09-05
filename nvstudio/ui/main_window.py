"""NV Studio Main IDE Window Assembly Component"""
import os
import sys
import subprocess
from pathlib import Path
from typing import Optional

from PyQt6.QtCore import Qt, QKeyCombination
from PyQt6.QtGui import QAction, QKeySequence, QShortcut
from PyQt6.QtWidgets import (
    QApplication, QFileDialog, QMainWindow, QMessageBox, QSplitter,
    QStackedWidget, QVBoxLayout, QWidget
)

from nvstudio.core.config import config_manager
from nvstudio.core.theme import get_theme_qss
from nvstudio.core.workspace import workspace_manager
from nvstudio.ui.activity_bar import ActivityBar
from nvstudio.ui.bottom_panel import BottomPanel
from nvstudio.ui.editor.tab_widget import EditorTabWidget
from nvstudio.ui.sidebar.explorer import FileExplorerPanel
from nvstudio.ui.sidebar.search import SearchPanel
from nvstudio.ui.sidebar.source_control import SourceControlPanel
from nvstudio.ui.sidebar.run_debug import RunDebugPanel
from nvstudio.ui.sidebar.extensions import ExtensionsPanel
from nvstudio.ui.sidebar.settings_panel import SettingsPanel
from nvstudio.ui.status_bar import StatusBar
from nvstudio.ui.title_bar import TitleBar


class MainWindow(QMainWindow):
    """Main Window assembling title bar, activity bar, sidebars, editor tabs, bottom dock, and status bar."""

    def __init__(self):
        super().__init__()
        self.setWindowTitle("NV Studio")
        self.resize(config_manager.get("window.width", 1280), config_manager.get("window.height", 800))

        # Frameless window configuration
        self.setWindowFlags(Qt.WindowType.FramelessWindowHint)

        # Central Root Layout
        central_widget = QWidget(self)
        self.setCentralWidget(central_widget)
        root_layout = QVBoxLayout(central_widget)
        root_layout.setContentsMargins(0, 0, 0, 0)
        root_layout.setSpacing(0)

        # 1. Title Bar
        self.title_bar = TitleBar(main_window=self)
        self.title_bar.minimize_requested.connect(self.showMinimized)
        self.title_bar.maximize_requested.connect(self._toggle_maximize)
        self.title_bar.close_requested.connect(self.close)
        root_layout.addWidget(self.title_bar)

        # 2. Main Horizontal Body Splitter (Activity Bar + Sidebar Stack + Editor Area)
        self.body_splitter = QSplitter(Qt.Orientation.Horizontal)

        # Activity Bar
        self.activity_bar = ActivityBar()
        self.activity_bar.activity_changed.connect(self._on_activity_changed)
        self.body_splitter.addWidget(self.activity_bar)

        # Sidebar Stack Container
        self.sidebar_stack = QStackedWidget()
        self.sidebar_stack.setObjectName("SidebarContainer")

        self.explorer_panel = FileExplorerPanel()
        self.search_panel = SearchPanel()
        self.source_control_panel = SourceControlPanel()
        self.run_debug_panel = RunDebugPanel()
        self.extensions_panel = ExtensionsPanel()
        self.settings_panel = SettingsPanel()

        self.sidebar_stack.addWidget(self.explorer_panel)       # 0
        self.sidebar_stack.addWidget(self.search_panel)         # 1
        self.sidebar_stack.addWidget(self.source_control_panel) # 2
        self.sidebar_stack.addWidget(self.run_debug_panel)      # 3
        self.sidebar_stack.addWidget(self.extensions_panel)     # 4
        self.sidebar_stack.addWidget(self.settings_panel)       # 5

        self.body_splitter.addWidget(self.sidebar_stack)

        # Vertical Splitter (Editor Tabs + Bottom Dock)
        self.editor_bottom_splitter = QSplitter(Qt.Orientation.Vertical)

        # Editor Tabs
        self.editor_tabs = EditorTabWidget()
        self.editor_bottom_splitter.addWidget(self.editor_tabs)

        # Bottom Dock Panel
        self.bottom_panel = BottomPanel()
        self.editor_bottom_splitter.addWidget(self.bottom_panel)

        self.editor_bottom_splitter.setSizes([550, 200])

        self.body_splitter.addWidget(self.editor_bottom_splitter)
        self.body_splitter.setSizes([48, 260, 900])

        root_layout.addWidget(self.body_splitter)

        # 3. Status Bar
        self.status_bar = StatusBar()
        self.setStatusBar(self.status_bar)

        # Setup Menus & Shortcuts
        self._setup_menus()
        self._setup_shortcuts()
        self._connect_signals()

        # Apply Theme
        self.setStyleSheet(get_theme_qss())

        # Create starter default editor tab
        self.editor_tabs.new_file("# Welcome to NV Studio IDE\nprint('Hello, NV Studio!')\n")

    def _toggle_maximize(self) -> None:
        if self.isMaximized():
            self.showNormal()
        else:
            self.showMaximized()

    def _on_activity_changed(self, act_id: str) -> None:
        mapping = {
            "explorer": 0,
            "search": 1,
            "source_control": 2,
            "run_debug": 3,
            "extensions": 4,
            "settings": 5,
        }
        idx = mapping.get(act_id, 0)
        self.sidebar_stack.setCurrentIndex(idx)

    def _connect_signals(self) -> None:
        # File explorer item selected
        self.explorer_panel.file_selected.connect(self.editor_tabs.open_file)

        # Search match item selected
        self.search_panel.file_match_selected.connect(self._on_search_file_selected)

        # Source control item selected
        self.source_control_panel.file_selected.connect(self.editor_tabs.open_file)

        # Run/Debug script execution requested
        self.run_debug_panel.run_file_requested.connect(self._run_script_in_terminal)

        # Editor tab changed -> update active file in Run/Debug & Status bar
        self.editor_tabs.current_editor_changed.connect(self._on_current_editor_changed)
        self.editor_tabs.cursor_position_changed.connect(self.status_bar.set_cursor_position)

        # Workspace folder changed -> update title bar
        workspace_manager.folder_changed.connect(
            lambda folder: self.title_bar.set_title(f"NV Studio - {Path(folder).name}")
        )

        # Config theme changes
        config_manager.settings_changed.connect(self._on_config_changed)

    def _on_search_file_selected(self, filepath: str, line_num: int) -> None:
        editor = self.editor_tabs.open_file(filepath)
        if editor:
            block = editor.document().findBlockByNumber(max(0, line_num - 1))
            cursor = editor.textCursor()
            cursor.setPosition(block.position())
            editor.setTextCursor(cursor)
            editor.setFocus()

    def _on_current_editor_changed(self, editor) -> None:
        if editor:
            self.run_debug_panel.set_active_filepath(editor.filepath)
            title = f"NV Studio - {Path(editor.filepath).name}" if editor.filepath else "NV Studio - Untitled"
            self.title_bar.set_title(title)
        else:
            self.run_debug_panel.set_active_filepath(None)
            self.title_bar.set_title("NV Studio")

    def _run_script_in_terminal(self, filepath: str, args: str) -> None:
        self.bottom_panel.tab_widget.setCurrentWidget(self.bottom_panel.terminal)
        cmd = f"python3 \"{filepath}\" {args}".strip()
        self.bottom_panel.terminal.cmd_input.setText(cmd)
        self.bottom_panel.terminal.execute_command()

    def _on_config_changed(self, key_path: str, value) -> None:
        if key_path.startswith("editor."):
            for ed in self.editor_tabs.editors.values():
                ed.apply_editor_settings()

    def _setup_menus(self) -> None:
        mb = self.title_bar.menu_bar

        # File Menu
        file_menu = mb.addMenu("&File")

        act_new = QAction("New File", self)
        act_new.setShortcut("Ctrl+N")
        act_new.triggered.connect(lambda: self.editor_tabs.new_file())
        file_menu.addAction(act_new)

        act_open_folder = QAction("Open Folder...", self)
        act_open_folder.setShortcut("Ctrl+O")
        act_open_folder.triggered.connect(self._open_folder_dialog)
        file_menu.addAction(act_open_folder)

        file_menu.addSeparator()

        act_save = QAction("Save", self)
        act_save.setShortcut("Ctrl+S")
        act_save.triggered.connect(lambda: self.editor_tabs.save_current_file())
        file_menu.addAction(act_save)

        act_save_as = QAction("Save As...", self)
        act_save_as.setShortcut("Ctrl+Shift+S")
        act_save_as.triggered.connect(lambda: self.editor_tabs.save_current_file_as())
        file_menu.addAction(act_save_as)

        file_menu.addSeparator()

        act_exit = QAction("Exit", self)
        act_exit.setShortcut("Alt+F4")
        act_exit.triggered.connect(self.close)
        file_menu.addAction(act_exit)

        # Edit Menu
        edit_menu = mb.addMenu("&Edit")

        act_undo = QAction("Undo", self)
        act_undo.setShortcut("Ctrl+Z")
        act_undo.triggered.connect(lambda: self._active_editor_action("undo"))
        edit_menu.addAction(act_undo)

        act_redo = QAction("Redo", self)
        act_redo.setShortcut("Ctrl+Y")
        act_redo.triggered.connect(lambda: self._active_editor_action("redo"))
        edit_menu.addAction(act_redo)

        edit_menu.addSeparator()

        act_find = QAction("Find in Editor", self)
        act_find.setShortcut("Ctrl+F")
        act_find.triggered.connect(lambda: self._active_editor_action("show_search_bar"))
        edit_menu.addAction(act_find)

        # View Menu
        view_menu = mb.addMenu("&View")

        act_explorer = QAction("Explorer", self)
        act_explorer.setShortcut("Ctrl+Shift+E")
        act_explorer.triggered.connect(lambda: self.activity_bar.set_active_activity("explorer"))
        view_menu.addAction(act_explorer)

        act_search = QAction("Search Workspace", self)
        act_search.setShortcut("Ctrl+Shift+F")
        act_search.triggered.connect(lambda: self.activity_bar.set_active_activity("search"))
        view_menu.addAction(act_search)

        # Help Menu
        help_menu = mb.addMenu("&Help")

        act_about = QAction("About NV Studio", self)
        act_about.triggered.connect(self._show_about_dialog)
        help_menu.addAction(act_about)

    def _setup_shortcuts(self) -> None:
        # Toggle Find Overlay
        sc_find = QShortcut(QKeySequence("Ctrl+F"), self)
        sc_find.activated.connect(lambda: self._active_editor_action("show_search_bar"))

        # Zoom In / Out
        sc_zoom_in = QShortcut(QKeySequence("Ctrl+="), self)
        sc_zoom_in.activated.connect(lambda: self._active_editor_action("zoom_in"))

        sc_zoom_out = QShortcut(QKeySequence("Ctrl+-"), self)
        sc_zoom_out.activated.connect(lambda: self._active_editor_action("zoom_out"))

    def _active_editor_action(self, method_name: str) -> None:
        editor = self.editor_tabs.get_current_editor()
        if editor and hasattr(editor, method_name):
            getattr(editor, method_name)()

    def _open_folder_dialog(self) -> None:
        folder = QFileDialog.getExistingDirectory(self, "Open Workspace Folder")
        if folder:
            workspace_manager.open_folder(folder)

    def _show_about_dialog(self) -> None:
        QMessageBox.about(
            self,
            "About NV Studio",
            "<h3>NV Studio IDE</h3>"
            "<p>Version 1.0.0</p>"
            "<p>A professional Python-powered desktop Code Editor & IDE built with PyQt6.</p>"
        )

    def closeEvent(self, event) -> None:
        # Prompt unsaved changes for open tabs
        for i in reversed(range(self.editor_tabs.count())):
            if not self.editor_tabs.close_tab(i):
                event.ignore()
                return

        # Save window settings
        config_manager.set("window.width", self.width())
        config_manager.set("window.height", self.height())
        event.accept()
