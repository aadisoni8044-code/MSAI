import os
import sys
from pathlib import Path

from PyQt6.QtWidgets import (
    QMainWindow, QWidget, QHBoxLayout, QVBoxLayout, QSplitter, QLabel,
    QPushButton, QStatusBar, QMessageBox, QFileDialog
)
from PyQt6.QtCore import Qt, QTimer
from PyQt6.QtGui import QKeySequence, QIcon, QShortcut, QTextDocument

from nvstudio.config import ConfigManager, APP_NAME
from nvstudio.workspace import WorkspaceManager
from nvstudio.ui.file_explorer import FileExplorerPanel
from nvstudio.ui.editor import TabbedEditorWorkspace
from nvstudio.ui.preview import LivePreviewPanel
from nvstudio.ui.dialogs import SettingsDialog, SearchReplaceBar, FirstLaunchConsentDialog, FirstLaunchThemeDialog


class MainWindow(QMainWindow):
    """NV Studio Main Application Window."""

    def __init__(self, config_manager=None, workspace_manager=None):
        super().__init__()
        self.config_manager = config_manager or ConfigManager()
        self.workspace_manager = workspace_manager or WorkspaceManager()
        self.workspace_manager.load()

        self.setWindowTitle(APP_NAME)
        self.resize(1400, 900)

        self._init_ui()
        self._apply_theme()
        self._setup_auto_save()
        self._restore_workspace()

    def _init_ui(self):
        central_widget = QWidget()
        self.setCentralWidget(central_widget)

        main_layout = QVBoxLayout(central_widget)
        main_layout.setContentsMargins(0, 0, 0, 0)
        main_layout.setSpacing(0)

        # Top Header Bar
        header_bar = QWidget()
        header_bar.setObjectName("HeaderBar")
        header_layout = QHBoxLayout(header_bar)
        header_layout.setContentsMargins(16, 8, 16, 8)

        logo_label = QLabel(APP_NAME)
        logo_label.setObjectName("LogoLabel")

        sub_logo = QLabel("Professional HTML, CSS & JavaScript Editor")
        sub_logo.setObjectName("SubLogoLabel")

        title_container = QVBoxLayout()
        title_container.setSpacing(0)
        title_container.addWidget(logo_label)
        title_container.addWidget(sub_logo)

        header_layout.addLayout(title_container)
        header_layout.addStretch()

        # Header Control Buttons
        self.btn_header_run = QPushButton("Run ▶")
        self.btn_header_run.setObjectName("RunButton")
        self.btn_header_run.clicked.connect(self.run_project)

        self.btn_save = QPushButton("Save")
        self.btn_save.clicked.connect(self.save_current)

        self.btn_save_as = QPushButton("Save As")
        self.btn_save_as.clicked.connect(self.save_as_current)

        self.btn_save_all = QPushButton("Save All")
        self.btn_save_all.clicked.connect(self.save_all)

        self.btn_find = QPushButton("Find & Replace")
        self.btn_find.clicked.connect(self.toggle_search_bar)

        self.btn_settings = QPushButton("⚙ Settings")
        self.btn_settings.clicked.connect(self.open_settings)

        header_layout.addWidget(self.btn_header_run)
        header_layout.addWidget(self.btn_save)
        header_layout.addWidget(self.btn_save_as)
        header_layout.addWidget(self.btn_save_all)
        header_layout.addWidget(self.btn_find)
        header_layout.addWidget(self.btn_settings)

        main_layout.addWidget(header_bar)

        # Search / Replace Bar
        self.search_bar = SearchReplaceBar()
        self.search_bar.find_next_requested.connect(self._find_next)
        self.search_bar.find_prev_requested.connect(self._find_prev)
        self.search_bar.replace_requested.connect(self._replace_one)
        self.search_bar.replace_all_requested.connect(self._replace_all)
        main_layout.addWidget(self.search_bar)

        # Main Splitter Area (Left File Explorer | Center Editor | Right Preview)
        self.splitter = QSplitter(Qt.Orientation.Horizontal)

        # File Explorer Panel
        self.file_explorer = FileExplorerPanel(
            project_dir=self.workspace_manager.get_project_dir()
        )
        self.file_explorer.file_selected.connect(self.open_file_in_editor)
        self.file_explorer.project_changed.connect(self._on_project_dir_changed)

        # Tabbed Editor Panel
        self.editor_workspace = TabbedEditorWorkspace()
        self.editor_workspace.file_saved.connect(self._on_file_saved)

        # Preview Panel
        self.preview_panel = LivePreviewPanel()
        self.preview_panel.btn_run.clicked.connect(self.run_project)
        self.preview_panel.device_changed.connect(self._on_preview_device_changed)

        # Set default device preference
        pref_device = self.config_manager.get("preview_device", "Laptop")
        self.preview_panel.set_device(pref_device)

        self.splitter.addWidget(self.file_explorer)
        self.splitter.addWidget(self.editor_workspace)
        self.splitter.addWidget(self.preview_panel)

        # Set initial layout widths
        self.splitter.setSizes([260, 600, 540])
        main_layout.addWidget(self.splitter)

        # Status Bar
        self.status_bar = QStatusBar()
        self.setStatusBar(self.status_bar)
        self.status_bar.showMessage("NV Studio Ready")

        # Shortcuts
        QShortcut(QKeySequence("Ctrl+S"), self, self.save_current)
        QShortcut(QKeySequence("Ctrl+Shift+S"), self, self.save_all)
        QShortcut(QKeySequence("Ctrl+R"), self, self.run_project)
        QShortcut(QKeySequence("Ctrl+F"), self, self.toggle_search_bar)

    def _apply_theme(self):
        qss = self.config_manager.get_qss()
        self.setStyleSheet(qss)

    def _setup_auto_save(self):
        self.auto_save_timer = QTimer(self)
        self.auto_save_timer.timeout.connect(self._auto_save_action)
        interval = self.config_manager.get("auto_save_interval", 1500)
        self.auto_save_timer.start(interval)

    def _auto_save_action(self):
        if self.config_manager.get("auto_save", True):
            self.save_all(quiet=True)

    def _restore_workspace(self):
        if not self.config_manager.get("restore_workspace", True):
            return

        open_files = self.workspace_manager.get_open_files()
        active_file = self.workspace_manager.state.get("active_file", "")

        for fp in open_files:
            if os.path.exists(fp):
                self.editor_workspace.open_file(fp)

        if active_file and os.path.exists(active_file):
            self.editor_workspace.open_file(active_file)

        self.run_project()

    def open_file_in_editor(self, filepath):
        self.editor_workspace.open_file(filepath)
        self._update_workspace_state()

    def run_project(self):
        self.save_all(quiet=True)
        project_dir = self.workspace_manager.get_project_dir()
        index_html = project_dir / "index.html"

        if index_html.exists():
            self.preview_panel.run_project(project_dir)
            self.status_bar.showMessage("Project executed in Live Preview", 3000)
        else:
            # Fallback to combining current open editors
            cur_editor = self.editor_workspace.current_editor()
            if cur_editor:
                self.preview_panel.run_raw_code(cur_editor.toPlainText())
                self.status_bar.showMessage("Current editor executed in Live Preview", 3000)

    def save_current(self):
        if self.editor_workspace.save_file():
            self.status_bar.showMessage("File saved", 2000)

    def save_as_current(self):
        editor = self.editor_workspace.current_editor()
        if not editor:
            return
        file_path, _ = QFileDialog.getSaveFileName(self, "Save File As", editor.filepath)
        if file_path:
            try:
                with open(file_path, "w", encoding="utf-8") as f:
                    f.write(editor.toPlainText())
                self.editor_workspace.open_file(file_path)
                self.status_bar.showMessage(f"Saved as {file_path}", 2000)
            except Exception as e:
                QMessageBox.critical(self, "Save As Error", f"Failed to save file: {e}")

    def save_all(self, quiet=False):
        self.editor_workspace.save_all()
        self._update_workspace_state()
        if not quiet:
            self.status_bar.showMessage("All files saved", 2000)

    def toggle_search_bar(self):
        if self.search_bar.isVisible():
            self.search_bar.hide()
        else:
            self.search_bar.show()
            self.search_bar.find_input.setFocus()

    def _find_next(self, text, match_case):
        editor = self.editor_workspace.current_editor()
        if editor and text:
            flags = QTextDocument.FindFlag(0)
            if match_case:
                flags |= QTextDocument.FindFlag.FindCaseSensitively
            if not editor.find(text, flags):
                # Wrap around to start
                editor.moveCursor(editor.textCursor().MoveOperation.Start)
                editor.find(text, flags)

    def _find_prev(self, text, match_case):
        editor = self.editor_workspace.current_editor()
        if editor and text:
            flags = QTextDocument.FindFlag.FindBackward
            if match_case:
                flags |= QTextDocument.FindFlag.FindCaseSensitively
            if not editor.find(text, flags):
                # Wrap around to end
                editor.moveCursor(editor.textCursor().MoveOperation.End)
                editor.find(text, flags)

    def _replace_one(self, find_text, replace_text, match_case):
        editor = self.editor_workspace.current_editor()
        if editor and find_text:
            cursor = editor.textCursor()
            if cursor.hasSelection() and cursor.selectedText() == find_text:
                cursor.insertText(replace_text)
            self._find_next(find_text, match_case)

    def _replace_all(self, find_text, replace_text, match_case):
        editor = self.editor_workspace.current_editor()
        if editor and find_text:
            text = editor.toPlainText()
            new_text = text.replace(find_text, replace_text)
            editor.setPlainText(new_text)

    def open_settings(self):
        dialog = SettingsDialog(self.config_manager, self)
        dialog.settings_changed.connect(self._on_settings_changed)
        dialog.exec()

    def _on_settings_changed(self, new_settings):
        self._apply_theme()
        if "preview_device" in new_settings:
            self.preview_panel.set_device(new_settings["preview_device"])
        self.status_bar.showMessage("Settings updated", 3000)

    def _on_preview_device_changed(self, device_name):
        self.config_manager.set("preview_device", device_name)

    def _on_project_dir_changed(self, new_dir):
        self.workspace_manager.set_project_dir(new_dir)

    def _on_file_saved(self, filepath):
        self._update_workspace_state()

    def _update_workspace_state(self):
        open_files = list(self.editor_workspace.open_editors.keys())
        cur_editor = self.editor_workspace.current_editor()
        active_file = cur_editor.filepath if cur_editor else ""
        self.workspace_manager.set_open_files(open_files, active_file)

    def closeEvent(self, event):
        self.save_all(quiet=True)
        self._update_workspace_state()
        super().closeEvent(event)
