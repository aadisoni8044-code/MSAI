"""
Horizontal and vertical split view editor container for PyCodeStudio.
"""

from PyQt6.QtCore import Qt, pyqtSignal
from PyQt6.QtWidgets import QSplitter, QVBoxLayout, QWidget

from editor.tab_manager import TabManager


class SplitViewContainer(QWidget):
    """Container holding single or dual side-by-side TabManager instances."""

    active_editor_changed = pyqtSignal(object)
    cursor_moved = pyqtSignal(int, int)

    def __init__(self, settings: dict = None, parent=None):
        super().__init__(parent)
        self.settings = settings or {}
        self.is_split: bool = False

        layout = QVBoxLayout(self)
        layout.setContentsMargins(0, 0, 0, 0)
        layout.setSpacing(0)

        self.splitter = QSplitter(Qt.Orientation.Horizontal)
        layout.addWidget(self.splitter)

        # Primary TabManager
        self.primary_tab_manager = TabManager(settings=self.settings, parent=self)
        self.primary_tab_manager.tab_changed_signal.connect(self._on_tab_changed)
        self.primary_tab_manager.cursor_moved_signal.connect(self._on_cursor_moved)
        self.splitter.addWidget(self.primary_tab_manager)

        # Secondary TabManager (created on demand for split view)
        self.secondary_tab_manager = None

    def toggle_split_view(self) -> None:
        """Toggles horizontal side-by-side split view."""
        if not self.is_split:
            self.secondary_tab_manager = TabManager(settings=self.settings, parent=self)
            self.secondary_tab_manager.tab_changed_signal.connect(self._on_tab_changed)
            self.secondary_tab_manager.cursor_moved_signal.connect(self._on_cursor_moved)
            self.splitter.addWidget(self.secondary_tab_manager)

            # Move active tab or open new document in split view
            active = self.primary_tab_manager.get_active_editor()
            if active and active.file_path:
                self.secondary_tab_manager.open_file(active.file_path)
            else:
                self.secondary_tab_manager.new_file("SplitView.py")

            self.is_split = True
            # Set equal sizes
            total_w = self.width()
            self.splitter.setSizes([total_w // 2, total_w // 2])
        else:
            if self.secondary_tab_manager:
                self.secondary_tab_manager.close_all_tabs()
                self.secondary_tab_manager.deleteLater()
                self.secondary_tab_manager = None
            self.is_split = False

    def get_active_tab_manager(self) -> TabManager:
        """Returns currently active or primary tab manager."""
        if self.secondary_tab_manager and self.secondary_tab_manager.hasFocus():
            return self.secondary_tab_manager
        return self.primary_tab_manager

    def get_active_editor(self):
        """Returns active editor from currently focused tab manager."""
        return self.get_active_tab_manager().get_active_editor()

    def update_settings(self, settings: dict) -> None:
        """Propagates settings to all tab managers."""
        self.settings = settings
        self.primary_tab_manager.update_settings(settings)
        if self.secondary_tab_manager:
            self.secondary_tab_manager.update_settings(settings)

    def _on_tab_changed(self, editor) -> None:
        """Forwards tab change signal."""
        self.active_editor_changed.emit(editor)

    def _on_cursor_moved(self, line: int, col: int) -> None:
        """Forwards cursor position signal."""
        self.cursor_moved.emit(line, col)
