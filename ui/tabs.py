"""
MSAI Studio - Multi-Tab System
"""
import os
from PyQt6.QtWidgets import QTabWidget, QWidget, QVBoxLayout, QMessageBox
from PyQt6.QtCore import pyqtSignal
from ui.editor import CodeEditor
from core.file_manager import FileManager
from state import state

class TabSystem(QTabWidget):
    """
    Manages multiple open file editor tabs with active indicator, modified status,
    and save/close lifecycle.
    """
    tab_closed = pyqtSignal(str) # file_path

    def __init__(self, parent=None):
        super().__init__(parent)
        self.setTabsClosable(True)
        self.setMovable(True)
        self.tabCloseRequested.connect(self.close_tab_index)
        self.currentChanged.connect(self._on_tab_changed)

        self.editors = {} # file_path -> CodeEditor

    def open_file(self, file_path: str, content: str = None) -> CodeEditor:
        """Opens file in tab or switches to it if already open."""
        norm_path = os.path.abspath(file_path)

        if norm_path in self.editors:
            idx = self._find_tab_index(norm_path)
            if idx != -1:
                self.setCurrentIndex(idx)
                return self.editors[norm_path]

        if content is None:
            ok, content_or_err = FileManager.read_file(norm_path)
            if not ok:
                QMessageBox.warning(self, "Error Opening File", content_or_err)
                return None
            content = content_or_err

        editor = CodeEditor()
        editor.file_path = norm_path
        editor.setPlainText(content)

        editor.file_modified.connect(lambda mod: self._set_tab_modified(norm_path, mod))

        filename = os.path.basename(norm_path)
        idx = self.addTab(editor, filename)
        self.setCurrentIndex(idx)

        self.editors[norm_path] = editor
        state.file_opened.emit(norm_path)
        return editor

    def save_current_file(self) -> bool:
        """Saves currently active tab editor content to file."""
        editor = self.currentWidget()
        if not editor or not isinstance(editor, CodeEditor) or not editor.file_path:
            return False

        content = editor.toPlainText()
        ok, msg = FileManager.write_file(editor.file_path, content)
        if ok:
            self._set_tab_modified(editor.file_path, False)
            state.file_saved.emit(editor.file_path)
            return True
        else:
            QMessageBox.critical(self, "Save Error", msg)
            return False

    def close_tab_index(self, index: int):
        """Closes tab at specified index with unsaved changes prompt."""
        widget = self.widget(index)
        if isinstance(widget, CodeEditor) and widget.file_path:
            path = widget.file_path
            # Check unsaved changes
            tab_title = self.tabText(index)
            if tab_title.endswith("●"):
                reply = QMessageBox.question(
                    self, "Unsaved Changes",
                    f"Do you want to save changes to '{os.path.basename(path)}'?",
                    QMessageBox.StandardButton.Save | QMessageBox.StandardButton.Discard | QMessageBox.StandardButton.Cancel
                )
                if reply == QMessageBox.StandardButton.Save:
                    if not self.save_current_file():
                        return
                elif reply == QMessageBox.StandardButton.Cancel:
                    return

            self.removeTab(index)
            if path in self.editors:
                del self.editors[path]
            state.file_closed.emit(path)
            self.tab_closed.emit(path)

    def get_current_editor(self) -> CodeEditor:
        widget = self.currentWidget()
        return widget if isinstance(widget, CodeEditor) else None

    def _find_tab_index(self, file_path: str) -> int:
        for i in range(self.count()):
            w = self.widget(i)
            if isinstance(w, CodeEditor) and w.file_path == file_path:
                return i
        return -1

    def _set_tab_modified(self, file_path: str, is_modified: bool):
        idx = self._find_tab_index(file_path)
        if idx != -1:
            base_name = os.path.basename(file_path)
            if is_modified:
                self.setTabText(idx, f"{base_name} ●")
            else:
                self.setTabText(idx, base_name)
            state.file_modified_changed.emit(file_path, is_modified)

    def _on_tab_changed(self, index: int):
        editor = self.get_current_editor()
        if editor and editor.file_path:
            state.active_editor_changed.emit(editor.file_path)
