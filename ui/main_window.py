"""
MSAI Studio - Main Application Window
"""
import os
import sys
from PyQt6.QtWidgets import (
    QMainWindow, QWidget, QHBoxLayout, QVBoxLayout, QSplitter, QFileDialog, QMessageBox
)
from PyQt6.QtGui import QShortcut, QKeySequence, QIcon
from PyQt6.QtCore import Qt

from config import ConfigManager
from state import state
from core.project_manager import ProjectManager
from core.workspace import Workspace
from core.python_runner import PythonRunner
from core.file_manager import FileManager
from debug.debugger import Debugger
from ai.ai_assistant import AIAssistant
from ai.ai_provider import AIProvider

from ui.title_bar import TitleBar
from ui.activity_bar import ActivityBar
from ui.explorer import ExplorerView
from ui.tabs import TabSystem
from ui.terminal_panel import TerminalPanel
from ui.status_bar import StatusBar
from ui.settings_view import SettingsView
from ui.extensions_view import ExtensionsView
from ui.command_palette import CommandPalette
from ui.search_view import SearchView
from ui.git_view import GitView
from ui.debug_view import DebugView
from ui.ai_view import AIView
from resources.themes import get_stylesheet

class MainWindow(QMainWindow):
    """
    Main MSAI Studio Application Window assembling Title Bar, Activity Bar,
    Sidebar panels, Editor Tab System, Collapsible Terminal Panel, and Status Bar.
    """

    def __init__(self):
        super().__init__()
        self.setWindowTitle("MSAI Studio")
        self.resize(1280, 800)

        # Config & Managers
        self.config_manager = ConfigManager()
        self.project_manager = ProjectManager()
        self.workspace = Workspace(self.project_manager, self.config_manager)
        self.python_runner = PythonRunner(self)
        self.debugger = Debugger(self)

        # AI Assistant Setup
        api_key = self.config_manager.get("ai_api_key", os.environ.get("GOOGLE_API_KEY", ""))
        self.ai_provider = AIProvider(api_key=api_key)
        self.ai_assistant = AIAssistant(self.ai_provider)

        # Apply Theme QSS
        theme_name = self.config_manager.get("theme", "MSAI Dark")
        self.setStyleSheet(get_stylesheet(theme_name))

        # Build Main UI Structure
        self._init_ui()

        # Connect Menus & Signals
        self._setup_menus()
        self._setup_shortcuts()
        self._connect_signals()

    def _init_ui(self):
        central_widget = QWidget(self)
        self.setCentralWidget(central_widget)

        main_vbox = QVBoxLayout(central_widget)
        main_vbox.setContentsMargins(0, 0, 0, 0)
        main_vbox.setSpacing(0)

        # 1. Custom Title Bar
        self.title_bar = TitleBar(self)
        main_vbox.addWidget(self.title_bar)

        # 2. Main Horizontal Splitter Container
        self.main_hsplitter = QSplitter(Qt.Orientation.Horizontal)

        # Left Activity Bar
        self.activity_bar = ActivityBar(self)

        # Sidebar Views Widget Stack Container
        self.sidebar_container = QWidget(self)
        self.sidebar_layout = QVBoxLayout(self.sidebar_container)
        self.sidebar_layout.setContentsMargins(0, 0, 0, 0)
        self.sidebar_container.setFixedWidth(260)

        # Sidebar Views
        self.explorer_view = ExplorerView(self)
        self.search_view = SearchView(self)
        self.git_view = GitView(self)
        self.debug_view = DebugView(self.debugger, self)
        self.extensions_view = ExtensionsView(self)
        self.ai_view = AIView(self.ai_assistant, self)
        self.settings_view = SettingsView(self.config_manager, self)

        self.sidebar_views = [
            self.explorer_view,
            self.search_view,
            self.git_view,
            self.debug_view,
            self.extensions_view,
            self.ai_view,
            self.settings_view,
        ]

        for view in self.sidebar_views:
            self.sidebar_layout.addWidget(view)
            view.hide()

        # Show Explorer View by default
        self.explorer_view.show()

        # Center Area: Editor Tab System & Bottom Terminal Splitter
        self.center_vsplitter = QSplitter(Qt.Orientation.Vertical)

        self.tab_system = TabSystem(self)
        self.terminal_panel = TerminalPanel(self)

        self.center_vsplitter.addWidget(self.tab_system)
        self.center_vsplitter.addWidget(self.terminal_panel)
        self.center_vsplitter.setSizes([550, 200])

        # Add widgets to main horizontal splitter
        self.main_hsplitter.addWidget(self.activity_bar)
        self.main_hsplitter.addWidget(self.sidebar_container)
        self.main_hsplitter.addWidget(self.center_vsplitter)
        self.main_hsplitter.setSizes([50, 260, 970])

        main_vbox.addWidget(self.main_hsplitter)

        # 3. Status Bar
        self.status_bar = StatusBar(self)
        self.setStatusBar(self.status_bar)

    def _setup_menus(self):
        # File Menu
        file_m = self.title_bar.file_menu
        file_m.addAction("New File (Ctrl+N)", self.new_file)
        file_m.addAction("Open File (Ctrl+O)", self.open_file_dialog)
        file_m.addAction("Open Folder...", self.open_folder_dialog)
        file_m.addSeparator()
        file_m.addAction("Save (Ctrl+S)", self.save_file)
        file_m.addAction("Save As... (Ctrl+Shift+S)", self.save_file_as)
        file_m.addSeparator()
        file_m.addAction("Close Tab (Ctrl+W)", self.close_active_tab)
        file_m.addAction("Exit", self.close)

        # Edit Menu
        edit_m = self.title_bar.edit_menu
        edit_m.addAction("Find (Ctrl+F)", self.show_find)

        # View Menu
        view_m = self.title_bar.view_menu
        view_m.addAction("Toggle Sidebar (Ctrl+B)", self.toggle_sidebar)
        view_m.addAction("Toggle Terminal (Ctrl+`)", self.toggle_terminal)
        view_m.addAction("Command Palette (Ctrl+Shift+P)", self.show_command_palette)

        # Run Menu
        run_m = self.title_bar.run_menu
        run_m.addAction("Run Python File (Ctrl+F5)", self.run_current_file)
        run_m.addAction("Start Debugging (F5)", self.start_debugging)
        run_m.addAction("Stop Execution", self.stop_python_execution)

        # Terminal Menu
        term_m = self.title_bar.terminal_menu
        term_m.addAction("New Terminal", lambda: self.terminal_panel.tabs.setCurrentIndex(3))
        term_m.addAction("Clear Terminal", self.terminal_panel.clear_terminal)

        # Help Menu
        help_m = self.title_bar.help_menu
        help_m.addAction("About MSAI Studio", self.show_about)

    def _setup_shortcuts(self):
        QShortcut(QKeySequence("Ctrl+N"), self, self.new_file)
        QShortcut(QKeySequence("Ctrl+O"), self, self.open_file_dialog)
        QShortcut(QKeySequence("Ctrl+S"), self, self.save_file)
        QShortcut(QKeySequence("Ctrl+Shift+S"), self, self.save_file_as)
        QShortcut(QKeySequence("Ctrl+W"), self, self.close_active_tab)
        QShortcut(QKeySequence("Ctrl+Shift+P"), self, self.show_command_palette)
        QShortcut(QKeySequence("Ctrl+P"), self, self.show_quick_open)
        QShortcut(QKeySequence("F5"), self, self.start_debugging)
        QShortcut(QKeySequence("Ctrl+F5"), self, self.run_current_file)
        QShortcut(QKeySequence("Ctrl+`"), self, self.toggle_terminal)
        QShortcut(QKeySequence("Ctrl+B"), self, self.toggle_sidebar)

    def _connect_signals(self):
        # Window Controls
        self.title_bar.minimize_requested.connect(self.showMinimized)
        self.title_bar.maximize_requested.connect(
            lambda: self.showNormal() if self.isMaximized() else self.showMaximized()
        )
        self.title_bar.close_requested.connect(self.close)

        # Activity Bar Switching
        self.activity_bar.activity_changed.connect(self._switch_sidebar_tab)

        # Explorer signals
        self.explorer_view.file_selected.connect(self.open_file)
        self.explorer_view.open_folder_requested.connect(self.open_folder_dialog)

        # Search signals
        self.search_view.file_match_selected.connect(self._open_file_at_line)

        # Git signals
        self.git_view.file_selected.connect(self.open_file)

        # Debug signals
        self.debug_view.start_debug_requested.connect(self.start_debugging)
        self.debug_view.stop_debug_requested.connect(self.stop_python_execution)

        # Settings changed
        self.settings_view.settings_changed.connect(self._on_settings_changed)

        # Status Bar Interpreter selection
        self.status_bar.interpreter_selected.connect(self._on_interpreter_selected)

        # Python Runner signals
        self.python_runner.output_received.connect(self.terminal_panel.append_terminal_output)
        self.python_runner.error_received.connect(self.terminal_panel.append_terminal_output)

        # Global State Signals
        state.active_editor_changed.connect(self._on_active_editor_changed)

    def new_file(self):
        editor = self.tab_system.open_file("Untitled.py", "# New Python Script\n\ndef main():\n    print('Hello from MSAI Studio')\n\nif __name__ == '__main__':\n    main()\n")
        editor.file_path = None

    def open_file(self, file_path: str):
        if file_path and os.path.exists(file_path):
            self.tab_system.open_file(file_path)
            self.workspace.add_open_file(file_path)

    def open_file_dialog(self):
        file_path, _ = QFileDialog.getOpenFileName(
            self, "Open File", self.project_manager.current_project_path or "", "Python Files (*.py);;All Files (*)"
        )
        if file_path:
            self.open_file(file_path)

    def open_folder_dialog(self):
        folder_path = QFileDialog.getExistingDirectory(self, "Open Folder", os.getcwd())
        if folder_path:
            self.project_manager.open_project(folder_path)
            self.explorer_view.set_project_path(folder_path)
            self.search_view.set_project_path(folder_path)
            self.git_view.set_repo_path(folder_path)
            self.config_manager.add_recent_project(folder_path)

    def save_file(self):
        editor = self.tab_system.get_current_editor()
        if not editor:
            return
        if not editor.file_path:
            self.save_file_as()
        else:
            self.tab_system.save_current_file()

    def save_file_as(self):
        editor = self.tab_system.get_current_editor()
        if not editor:
            return
        file_path, _ = QFileDialog.getSaveFileName(
            self, "Save File As", self.project_manager.current_project_path or "", "Python Files (*.py);;All Files (*)"
        )
        if file_path:
            editor.file_path = file_path
            self.tab_system.save_current_file()
            self.tab_system.setTabText(self.tab_system.currentIndex(), os.path.basename(file_path))

    def close_active_tab(self):
        curr_idx = self.tab_system.currentIndex()
        if curr_idx != -1:
            self.tab_system.close_tab_index(curr_idx)

    def run_current_file(self):
        editor = self.tab_system.get_current_editor()
        if not editor or not editor.file_path:
            QMessageBox.warning(self, "Run Warning", "Please save the file before running.")
            return

        self.save_file()
        interpreter = self.config_manager.get("python_interpreter", sys.executable)
        self.terminal_panel.tabs.setCurrentIndex(3) # Switch to terminal
        self.python_runner.run_file(editor.file_path, interpreter_path=interpreter)

    def start_debugging(self):
        editor = self.tab_system.get_current_editor()
        if editor and editor.file_path:
            self.debugger.start_debugging(editor.file_path)
            self.debug_view.refresh_breakpoints()
            self.run_current_file()

    def stop_python_execution(self):
        self.python_runner.stop()
        self.debugger.stop_debugging()

    def toggle_sidebar(self):
        self.sidebar_container.setVisible(not self.sidebar_container.isVisible())

    def toggle_terminal(self):
        self.terminal_panel.setVisible(not self.terminal_panel.isVisible())

    def show_find(self):
        editor = self.tab_system.get_current_editor()
        if editor:
            editor.show_search_panel()

    def show_command_palette(self):
        commands = [
            "File: New File",
            "File: Open File",
            "File: Open Folder",
            "File: Save File",
            "Run: Run Python File",
            "Run: Start Debugging",
            "Run: Stop Execution",
            "View: Toggle Terminal",
            "View: Toggle Sidebar",
            "View: Open Settings",
        ]
        palette = CommandPalette(commands, self)
        palette.command_triggered.connect(self._handle_command_palette)
        palette.exec()

    def _handle_command_palette(self, cmd: str):
        if cmd == "File: New File":
            self.new_file()
        elif cmd == "File: Open File":
            self.open_file_dialog()
        elif cmd == "File: Open Folder":
            self.open_folder_dialog()
        elif cmd == "File: Save File":
            self.save_file()
        elif cmd == "Run: Run Python File":
            self.run_current_file()
        elif cmd == "Run: Start Debugging":
            self.start_debugging()
        elif cmd == "Run: Stop Execution":
            self.stop_python_execution()
        elif cmd == "View: Toggle Terminal":
            self.toggle_terminal()
        elif cmd == "View: Toggle Sidebar":
            self.toggle_sidebar()
        elif cmd == "View: Open Settings":
            self._switch_sidebar_tab(6)

    def show_quick_open(self):
        root_dir = self.project_manager.current_project_path or os.getcwd()
        files = self.project_manager.get_all_python_files()
        palette = CommandPalette(files, self)
        palette.command_triggered.connect(lambda f: self.open_file(os.path.join(root_dir, f)))
        palette.exec()

    def show_about(self):
        QMessageBox.about(
            self, "About MSAI Studio",
            "<b>MSAI Studio v1.0.0</b><br>"
            "Professional Dark-Mode Python Code Editor IDE.<br>"
            "Built with PyQt6 and Python 3.12."
        )

    def _switch_sidebar_tab(self, index: int):
        self.sidebar_container.show()
        for idx, view in enumerate(self.sidebar_views):
            if idx == index:
                view.show()
            else:
                view.hide()

    def _on_active_editor_changed(self, file_path: str):
        self.status_bar.set_file_info(file_path)
        editor = self.tab_system.get_current_editor()
        if editor:
            try:
                editor.cursor_position_changed.disconnect(self.status_bar.set_cursor_pos)
            except Exception:
                pass
            editor.cursor_position_changed.connect(self.status_bar.set_cursor_pos)

    def _open_file_at_line(self, file_path: str, line: int):
        editor = self.tab_system.open_file(file_path)
        if editor:
            cursor = editor.textCursor()
            cursor.setPosition(0)
            editor.setTextCursor(cursor)
            for _ in range(line - 1):
                editor.moveCursor(editor.textCursor().MoveOperation.Down)

    def _on_settings_changed(self, new_settings: dict):
        theme_name = new_settings.get("theme", "MSAI Dark")
        self.setStyleSheet(get_stylesheet(theme_name))
        api_key = new_settings.get("ai_api_key", "")
        self.ai_provider.set_api_key(api_key)

    def _on_interpreter_selected(self, path: str):
        self.config_manager.set("python_interpreter", path)
        self.status_bar.set_interpreter_label(f"Python ({path})")
