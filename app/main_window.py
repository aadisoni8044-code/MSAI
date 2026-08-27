"""
Main window application assembly for PyCodeStudio.
"""

from pathlib import Path
from typing import Optional

from PyQt6.QtCore import QSize, Qt
from PyQt6.QtGui import QAction, QDragEnterEvent, QDropEvent, QIcon, QKeySequence
from PyQt6.QtWidgets import (
    QApplication,
    QFileDialog,
    QHBoxLayout,
    QMainWindow,
    QMessageBox,
    QPushButton,
    QSplitter,
    QStackedWidget,
    QVBoxLayout,
    QWidget,
)

from app.command_palette import CommandPaletteDialog
from app.settings_dialog import SettingsDialog
from app.status_bar import AppStatusBar
from app.welcome_screen import WelcomeScreen
from editor.find_replace import FindReplacePanel
from editor.split_view import SplitViewContainer
from explorer.file_tree import FileExplorerTree
from plugins import PluginManager
from search.global_search import GlobalSearchPanel
from terminal.run_manager import RunManager
from terminal.terminal_widget import IntegratedTerminalWidget
from themes.theme_manager import ThemeManager
from utils.config_manager import ConfigManager
from utils.file_utils import get_language_from_filename
from utils.icon_loader import IconLoader
from utils.logger import logger


class MainWindow(QMainWindow):
    """Main QMainWindow class coordinating layouts, panels, menus, and application features."""

    def __init__(self):
        super().__init__()

        self.config_manager = ConfigManager()
        self.settings = self.config_manager.settings

        self.setWindowTitle("PyCodeStudio")
        self.resize(1280, 800)
        self.setAcceptDrops(True)

        # Apply initial theme
        ThemeManager.apply_theme(QApplication.instance(), self.settings.get("theme", "dark"))

        self._init_ui()
        self._init_menu_bar()
        self._init_shortcuts()

        # Plugin system initialization
        self.plugin_manager = PluginManager(main_window=self)
        self.plugin_manager.discover_and_load_plugins()

        self.run_manager = RunManager(terminal_widget=self.terminal_panel)

    def _init_ui(self) -> None:
        """Assembles native layout splitters, sidebar, tabs, and terminal."""
        central_widget = QWidget(self)
        self.setCentralWidget(central_widget)

        main_layout = QHBoxLayout(central_widget)
        main_layout.setContentsMargins(0, 0, 0, 0)
        main_layout.setSpacing(0)

        # Activity Bar (Leftmost icon strip)
        activity_bar = QWidget()
        activity_bar.setFixedWidth(48)
        activity_bar.setStyleSheet("background-color: #333333;")
        act_layout = QVBoxLayout(activity_bar)
        act_layout.setContentsMargins(4, 8, 4, 8)
        act_layout.setSpacing(12)

        btn_files = QPushButton()
        btn_files.setIcon(IconLoader.get_icon("folder"))
        btn_files.setToolTip("Explorer (Ctrl+Shift+E)")
        btn_files.setFlat(True)
        btn_files.clicked.connect(lambda: self._switch_sidebar_tab(0))

        btn_search = QPushButton()
        btn_search.setIcon(IconLoader.get_icon("search"))
        btn_search.setToolTip("Global Search (Ctrl+Shift+F)")
        btn_search.setFlat(True)
        btn_search.clicked.connect(lambda: self._switch_sidebar_tab(1))

        btn_run = QPushButton()
        btn_run.setIcon(IconLoader.get_icon("run"))
        btn_run.setToolTip("Run File (F5)")
        btn_run.setFlat(True)
        btn_run.clicked.connect(self.run_active_file)

        btn_settings = QPushButton()
        btn_settings.setIcon(IconLoader.get_icon("settings"))
        btn_settings.setToolTip("Settings")
        btn_settings.setFlat(True)
        btn_settings.clicked.connect(self.open_settings_dialog)

        act_layout.addWidget(btn_files)
        act_layout.addWidget(btn_search)
        act_layout.addWidget(btn_run)
        act_layout.addStretch()
        act_layout.addWidget(btn_settings)

        main_layout.addWidget(activity_bar)

        # Horizontal Splitter: [Sidebar Stack | Editor + Terminal Panel]
        self.h_splitter = QSplitter(Qt.Orientation.Horizontal)
        main_layout.addWidget(self.h_splitter)

        # Sidebar Stacked Widget
        self.sidebar_stack = QStackedWidget()
        self.sidebar_stack.setMinimumWidth(200)

        self.explorer_tree = FileExplorerTree(root_path=Path.cwd())
        self.explorer_tree.file_double_clicked.connect(self.open_file_path)

        self.search_panel = GlobalSearchPanel(root_path=Path.cwd())
        self.search_panel.file_selected.connect(self._on_search_file_selected)

        self.sidebar_stack.addWidget(self.explorer_tree)
        self.sidebar_stack.addWidget(self.search_panel)

        self.h_splitter.addWidget(self.sidebar_stack)

        # Vertical Splitter: [Main View (Welcome/Split View Editor) | Terminal]
        self.v_splitter = QSplitter(Qt.Orientation.Vertical)
        self.h_splitter.addWidget(self.v_splitter)

        # Upper Editor Area Widget
        editor_container = QWidget()
        editor_layout = QVBoxLayout(editor_container)
        editor_layout.setContentsMargins(0, 0, 0, 0)
        editor_layout.setSpacing(0)

        # Find / Replace Bar
        self.find_replace_bar = FindReplacePanel(self)
        self.find_replace_bar.hide()
        editor_layout.addWidget(self.find_replace_bar)

        # Editor Stack (Welcome Screen or SplitView Editor)
        self.editor_stack = QStackedWidget()

        self.welcome_screen = WelcomeScreen(
            recent_files=self.settings.get("recent_files", []),
            recent_folders=self.settings.get("recent_folders", [])
        )
        self.welcome_screen.open_file_requested.connect(self.open_file_dialog)
        self.welcome_screen.open_folder_requested.connect(self.open_folder_dialog)
        self.welcome_screen.new_file_requested.connect(self.new_file)
        self.welcome_screen.recent_file_clicked.connect(self.open_file_path)
        self.welcome_screen.recent_folder_clicked.connect(self.open_folder_path)
        self.welcome_screen.toggle_theme_requested.connect(self.toggle_theme)

        self.split_view = SplitViewContainer(settings=self.settings)
        self.split_view.active_editor_changed.connect(self._on_active_editor_changed)
        self.split_view.cursor_moved.connect(self._on_cursor_moved)

        self.editor_stack.addWidget(self.welcome_screen)
        self.editor_stack.addWidget(self.split_view)

        editor_layout.addWidget(self.editor_stack)
        self.v_splitter.addWidget(editor_container)

        # Embedded Terminal Panel
        self.terminal_panel = IntegratedTerminalWidget(working_dir=Path.cwd())
        self.v_splitter.addWidget(self.terminal_panel)

        # Set initial splitter proportions
        self.h_splitter.setSizes([260, 1020])
        self.v_splitter.setSizes([600, 200])

        # Status Bar
        self.status_bar = AppStatusBar(self)
        self.setStatusBar(self.status_bar)

    def _init_menu_bar(self) -> None:
        """Initializes native menu bar items."""
        menu_bar = self.menuBar()

        # File Menu
        file_menu = menu_bar.addMenu("&File")

        act_new = QAction("&New File", self)
        act_new.setShortcut(QKeySequence("Ctrl+N"))
        act_new.triggered.connect(self.new_file)

        act_open_f = QAction("&Open File...", self)
        act_open_f.setShortcut(QKeySequence("Ctrl+O"))
        act_open_f.triggered.connect(self.open_file_dialog)

        act_open_dir = QAction("Open &Folder...", self)
        act_open_dir.setShortcut(QKeySequence("Ctrl+K"))
        act_open_dir.triggered.connect(self.open_folder_dialog)

        act_save = QAction("&Save", self)
        act_save.setShortcut(QKeySequence("Ctrl+S"))
        act_save.triggered.connect(self.save_current_file)

        act_close_tab = QAction("&Close Tab", self)
        act_close_tab.setShortcut(QKeySequence("Ctrl+W"))
        act_close_tab.triggered.connect(self.close_current_tab)

        act_exit = QAction("E&xit", self)
        act_exit.setShortcut(QKeySequence("Alt+F4"))
        act_exit.triggered.connect(self.close)

        file_menu.addAction(act_new)
        file_menu.addAction(act_open_f)
        file_menu.addAction(act_open_dir)
        file_menu.addSeparator()
        file_menu.addAction(act_save)
        file_menu.addAction(act_close_tab)
        file_menu.addSeparator()
        file_menu.addAction(act_exit)

        # Edit Menu
        edit_menu = menu_bar.addMenu("&Edit")

        act_find = QAction("&Find", self)
        act_find.setShortcut(QKeySequence("Ctrl+F"))
        act_find.triggered.connect(self.show_find_replace)

        act_find_files = QAction("Find in &Files", self)
        act_find_files.setShortcut(QKeySequence("Ctrl+Shift+F"))
        act_find_files.triggered.connect(lambda: self._switch_sidebar_tab(1))

        edit_menu.addAction(act_find)
        edit_menu.addAction(act_find_files)

        # View Menu
        view_menu = menu_bar.addMenu("&View")

        act_palette = QAction("Command &Palette...", self)
        act_palette.setShortcut(QKeySequence("Ctrl+Shift+P"))
        act_palette.triggered.connect(self.open_command_palette)

        act_toggle_side = QAction("Toggle &Sidebar", self)
        act_toggle_side.setShortcut(QKeySequence("Ctrl+B"))
        act_toggle_side.triggered.connect(self.toggle_sidebar)

        act_toggle_term = QAction("Toggle &Terminal", self)
        act_toggle_term.setShortcut(QKeySequence("Ctrl+`"))
        act_toggle_term.triggered.connect(self.toggle_terminal)

        act_split = QAction("&Split Editor Right", self)
        act_split.triggered.connect(self.split_view.toggle_split_view)

        view_menu.addAction(act_palette)
        view_menu.addSeparator()
        view_menu.addAction(act_toggle_side)
        view_menu.addAction(act_toggle_term)
        view_menu.addAction(act_split)

        # Run / Terminal Menu
        run_menu = menu_bar.addMenu("&Run")
        act_run = QAction("&Run Active File", self)
        act_run.setShortcut(QKeySequence("F5"))
        act_run.triggered.connect(self.run_active_file)
        run_menu.addAction(act_run)

        # Help Menu
        help_menu = menu_bar.addMenu("&Help")
        act_about = QAction("&About PyCodeStudio", self)
        act_about.triggered.connect(self.show_about_dialog)
        help_menu.addAction(act_about)

    def _init_shortcuts(self) -> None:
        """Initializes global action shortcuts."""
        pass

    def _switch_sidebar_tab(self, index: int) -> None:
        """Switches sidebar stack between explorer tree and search."""
        self.sidebar_stack.setCurrentIndex(index)
        self.sidebar_stack.show()

    def toggle_sidebar(self) -> None:
        """Toggles sidebar visibility."""
        if self.sidebar_stack.isVisible():
            self.sidebar_stack.hide()
        else:
            self.sidebar_stack.show()

    def toggle_terminal(self) -> None:
        """Toggles bottom terminal panel visibility."""
        if self.terminal_panel.isVisible():
            self.terminal_panel.hide()
        else:
            self.terminal_panel.show()

    def toggle_theme(self) -> None:
        """Toggles between Dark and Light color themes."""
        current = self.settings.get("theme", "dark")
        new_theme = "light" if current == "dark" else "dark"
        self.settings["theme"] = new_theme
        self.config_manager.set("theme", new_theme)
        ThemeManager.apply_theme(QApplication.instance(), new_theme)

    def new_file(self) -> None:
        """Opens new untitled editor tab."""
        self.editor_stack.setCurrentWidget(self.split_view)
        tab_mgr = self.split_view.get_active_tab_manager()
        tab_mgr.new_file()

    def open_file_dialog(self) -> None:
        """Shows system open file dialog."""
        file_path, _ = QFileDialog.getOpenFileName(self, "Open File", str(Path.home()))
        if file_path:
            self.open_file_path(Path(file_path))

    def open_folder_dialog(self) -> None:
        """Shows system open folder dialog."""
        folder_path = QFileDialog.getExistingDirectory(self, "Open Folder", str(Path.home()))
        if folder_path:
            self.open_folder_path(Path(folder_path))

    def open_file_path(self, path: Path) -> None:
        """Opens specified file path in active tab manager."""
        if not path.exists():
            return
        self.editor_stack.setCurrentWidget(self.split_view)
        tab_mgr = self.split_view.get_active_tab_manager()
        editor = tab_mgr.open_file(path)
        self.config_manager.add_recent_file(str(path.resolve()))
        self.welcome_screen.populate_recents(
            self.settings.get("recent_files", []),
            self.settings.get("recent_folders", [])
        )
        if editor:
            self.find_replace_bar.set_editor(editor)

    def open_folder_path(self, path: Path) -> None:
        """Sets active root directory in File Explorer and Terminal."""
        if not path.exists():
            return
        self.explorer_tree.set_root_directory(path)
        self.search_panel.set_root_directory(path)
        self.terminal_panel.set_working_directory(path)
        self.config_manager.add_recent_folder(str(path.resolve()))
        self.welcome_screen.populate_recents(
            self.settings.get("recent_files", []),
            self.settings.get("recent_folders", [])
        )

    def save_current_file(self) -> None:
        """Saves current file or prompts save-as if new."""
        active_editor = self.split_view.get_active_editor()
        if active_editor:
            if active_editor.file_path:
                active_editor.save_file()
            else:
                file_path, _ = QFileDialog.getSaveFileName(self, "Save File", str(Path.home()))
                if file_path:
                    p = Path(file_path)
                    active_editor.save_file(p)

    def close_current_tab(self) -> None:
        """Closes active tab."""
        tab_mgr = self.split_view.get_active_tab_manager()
        curr_idx = tab_mgr.currentIndex()
        if curr_idx != -1:
            tab_mgr.close_tab(curr_idx)

        if tab_mgr.count() == 0:
            self.editor_stack.setCurrentWidget(self.welcome_screen)

    def show_find_replace(self) -> None:
        """Shows Find and Replace panel."""
        active_editor = self.split_view.get_active_editor()
        if active_editor:
            self.find_replace_bar.set_editor(active_editor)
            self.find_replace_bar.show_and_focus()

    def run_active_file(self) -> None:
        """Executes currently open file via run manager."""
        active_editor = self.split_view.get_active_editor()
        if active_editor:
            if active_editor.is_modified or not active_editor.file_path:
                self.save_current_file()

            if active_editor.file_path:
                self.terminal_panel.show()
                self.run_manager.run_file(active_editor.file_path)

    def open_command_palette(self) -> None:
        """Launches Command Palette dialog."""
        commands = [
            ("New File", self.new_file),
            ("Open File", self.open_file_dialog),
            ("Open Folder", self.open_folder_dialog),
            ("Save File", self.save_current_file),
            ("Run File", self.run_active_file),
            ("Toggle Sidebar", self.toggle_sidebar),
            ("Toggle Terminal", self.toggle_terminal),
            ("Switch Theme", self.toggle_theme),
            ("Open Settings", self.open_settings_dialog),
        ]
        dialog = CommandPaletteDialog(commands, self)
        dialog.exec()

    def open_settings_dialog(self) -> None:
        """Launches Preferences dialog."""
        dialog = SettingsDialog(self.settings, self)
        if dialog.exec() == SettingsDialog.DialogCode.Accepted:
            new_settings = dialog.get_settings()
            self.settings = new_settings
            self.config_manager.save_settings(new_settings)
            ThemeManager.apply_theme(QApplication.instance(), new_settings.get("theme", "dark"))
            self.split_view.update_settings(new_settings)

    def show_about_dialog(self) -> None:
        """Displays About PyCodeStudio message box."""
        QMessageBox.about(
            self,
            "About PyCodeStudio",
            "<h3>PyCodeStudio v1.0.0</h3>"
            "<p>A lightweight, VS Code–inspired cross-platform IDE built in Python with PyQt6 and QScintilla.</p>"
        )

    def _on_active_editor_changed(self, editor) -> None:
        """Updates status bar when active editor tab changes."""
        if editor:
            self.find_replace_bar.set_editor(editor)
            lang = editor.language or get_language_from_filename(editor.file_path.name if editor.file_path else "")
            enc = editor.file_encoding
            self.status_bar.update_file_info(language=lang, encoding=enc)

    def _on_cursor_moved(self, line: int, col: int) -> None:
        """Updates status bar line:col display."""
        self.status_bar.update_cursor_position(line, col)

    def _on_search_file_selected(self, path: Path, line_number: int) -> None:
        """Opens file from global search and jumps to line number."""
        self.open_file_path(path)
        active_editor = self.split_view.get_active_editor()
        if active_editor:
            active_editor.setCursorPosition(max(0, line_number - 1), 0)

    # Drag and Drop handlers
    def dragEnterEvent(self, event: QDragEnterEvent) -> None:
        if event.mimeData().hasUrls():
            event.acceptProposedAction()

    def dropEvent(self, event: QDropEvent) -> None:
        for url in event.mimeData().urls():
            path = Path(url.toLocalFile())
            if path.is_file():
                self.open_file_path(path)
            elif path.is_dir():
                self.open_folder_path(path)
