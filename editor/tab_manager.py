"""
Multi-tab editor management for PyCodeStudio.
"""

from pathlib import Path
from typing import List, Optional

from PyQt6.QtCore import Qt, pyqtSignal
from PyQt6.QtWidgets import QMenu, QMessageBox, QTabBar, QTabWidget

from editor.editor_widget import EditorWidget
from utils.logger import logger


class TabManager(QTabWidget):
    """Tab widget managing multiple EditorWidget instances."""

    tab_changed_signal = pyqtSignal(object)  # Optional[EditorWidget]
    cursor_moved_signal = pyqtSignal(int, int)  # line, col

    def __init__(self, settings: dict = None, parent=None):
        super().__init__(parent)
        self.settings = settings or {}

        self.setTabsClosable(True)
        self.setMovable(True)
        self.setDocumentMode(True)

        self.tabCloseRequested.connect(self.close_tab)
        self.currentChanged.connect(self._on_current_tab_changed)

        # Custom context menu on tab bar
        self.tabBar().setContextMenuPolicy(Qt.ContextMenuPolicy.CustomContextMenu)
        self.tabBar().customContextMenuRequested.connect(self._show_tab_context_menu)

    def get_active_editor(self) -> Optional[EditorWidget]:
        """Returns currently active EditorWidget."""
        widget = self.currentWidget()
        if isinstance(widget, EditorWidget):
            return widget
        return None

    def open_file(self, path: Path) -> EditorWidget:
        """Opens a file in a new tab or selects existing tab if already open."""
        # Check if already open
        for i in range(self.count()):
            editor = self.widget(i)
            if isinstance(editor, EditorWidget) and editor.file_path and editor.file_path.resolve() == path.resolve():
                self.setCurrentIndex(i)
                return editor

        # Create new editor tab
        editor = EditorWidget(file_path=path, settings=self.settings, parent=self)
        editor.text_changed_signal.connect(lambda: self._update_tab_title(editor))
        editor.cursor_position_changed_signal.connect(self._on_cursor_moved)

        index = self.addTab(editor, path.name)
        self.setTabToolTip(index, str(path.resolve()))
        self.setCurrentIndex(index)
        return editor

    def new_file(self, default_name: str = "Untitled.py") -> EditorWidget:
        """Creates a new untitled document tab."""
        editor = EditorWidget(file_path=None, settings=self.settings, parent=self)
        editor.text_changed_signal.connect(lambda: self._update_tab_title(editor))
        editor.cursor_position_changed_signal.connect(self._on_cursor_moved)

        index = self.addTab(editor, default_name + " *")
        self.setCurrentIndex(index)
        return editor

    def close_tab(self, index: int) -> bool:
        """Closes tab at index after prompting if unsaved changes exist."""
        editor = self.widget(index)
        if isinstance(editor, EditorWidget) and editor.is_modified:
            file_name = editor.file_path.name if editor.file_path else "Untitled"
            reply = QMessageBox.question(
                self,
                "Save Changes?",
                f"Do you want to save changes to '{file_name}' before closing?",
                QMessageBox.StandardButton.Save |
                QMessageBox.StandardButton.Discard |
                QMessageBox.StandardButton.Cancel,
                QMessageBox.StandardButton.Save
            )

            if reply == QMessageBox.StandardButton.Save:
                if not editor.save_file():
                    return False
            elif reply == QMessageBox.StandardButton.Cancel:
                return False

        self.removeTab(index)
        return True

    def close_other_tabs(self, index: int) -> None:
        """Closes all tabs except index."""
        for i in range(self.count() - 1, -1, -1):
            if i != index:
                self.close_tab(i)

    def close_all_tabs(self) -> None:
        """Closes all open tabs."""
        for i in range(self.count() - 1, -1, -1):
            if not self.close_tab(i):
                break

    def save_current_file(self) -> bool:
        """Saves current active file."""
        editor = self.get_active_editor()
        if editor:
            if editor.file_path:
                return editor.save_file()
            else:
                return False
        return False

    def _update_tab_title(self, editor: EditorWidget) -> None:
        """Updates tab title with modified indicator asterisk."""
        index = self.indexOf(editor)
        if index != -1:
            name = editor.file_path.name if editor.file_path else "Untitled"
            if editor.is_modified:
                self.setTabText(index, f"{name} *")
            else:
                self.setTabText(index, name)

    def _on_current_tab_changed(self, index: int) -> None:
        """Signal handler for active tab switch."""
        editor = self.get_active_editor()
        self.tab_changed_signal.emit(editor)

    def _on_cursor_moved(self, line: int, col: int) -> None:
        """Forwards editor cursor movement to parent status bar."""
        self.cursor_moved_signal.emit(line, col)

    def _show_tab_context_menu(self, pos) -> None:
        """Displays context menu on tab bar."""
        index = self.tabBar().tabAt(pos)
        if index == -1:
            return

        menu = QMenu(self)
        close_act = menu.addAction("Close")
        close_others_act = menu.addAction("Close Others")
        close_all_act = menu.addAction("Close All")

        action = menu.exec(self.tabBar().mapToGlobal(pos))
        if action == close_act:
            self.close_tab(index)
        elif action == close_others_act:
            self.close_other_tabs(index)
        elif action == close_all_act:
            self.close_all_tabs()

    def update_settings(self, settings: dict) -> None:
        """Propagates updated settings to all open editor tabs."""
        self.settings = settings
        for i in range(self.count()):
            editor = self.widget(i)
            if isinstance(editor, EditorWidget):
                editor.update_settings(settings)
