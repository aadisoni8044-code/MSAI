"""NV Studio Editor Tab Container supporting multiple tabs, file saving, and dirty status indicators"""
import os
from pathlib import Path
from typing import Dict, Optional, Tuple
from PyQt6.QtCore import Qt, pyqtSignal
from PyQt6.QtGui import QIcon, QKeySequence, QShortcut
from PyQt6.QtWidgets import (
    QApplication, QFileDialog, QMessageBox, QTabWidget, QVBoxLayout, QWidget, QTabBar
)

from nvstudio.core.config import config_manager
from nvstudio.core.workspace import workspace_manager
from nvstudio.ui.editor.code_editor import CodeEditor


class EditorTabWidget(QTabWidget):
    """Tabbed workspace container managing open files, modification tracking, and document actions."""
    current_editor_changed = pyqtSignal(object)  # Emits active CodeEditor instance or None
    cursor_position_changed = pyqtSignal(int, int)  # (line, column)
    file_status_changed = pyqtSignal(str)          # File metadata/status string update

    def __init__(self, parent=None):
        super().__init__(parent)
        self.setObjectName("EditorTabWidget")
        self.setTabsClosable(True)
        self.setMovable(True)

        self.tabCloseRequested.connect(self.close_tab)
        self.currentChanged.connect(self._on_current_tab_changed)

        # Tab map: filepath -> CodeEditor
        self.editors: Dict[str, CodeEditor] = {}
        self.untitled_counter = 1

    def open_file(self, filepath: str) -> Optional[CodeEditor]:
        """Open a file in a tab, or switch to it if already open."""
        path = str(Path(filepath).resolve())

        # Check if already open
        if path in self.editors:
            editor = self.editors[path]
            index = self.indexOf(editor)
            self.setCurrentIndex(index)
            return editor

        if not os.path.exists(path):
            return None

        try:
            with open(path, "r", encoding="utf-8", errors="replace") as f:
                content = f.read()
        except Exception as e:
            QMessageBox.critical(self, "Error Opening File", f"Could not read file:\n{e}")
            return None

        editor = CodeEditor(filepath=path)
        editor.setPlainText(content)
        editor.document().setModified(False)

        file_name = Path(path).name
        index = self.addTab(editor, file_name)
        self.setTabToolTip(index, path)
        self.setCurrentIndex(index)

        self.editors[path] = editor
        self._connect_editor_signals(editor, path)

        # Add to config recent files
        recents = config_manager.get("workspace.recent_files", [])
        if path in recents:
            recents.remove(path)
        recents.insert(0, path)
        config_manager.set("workspace.recent_files", recents[:15])

        return editor

    def new_file(self, default_content: str = "") -> CodeEditor:
        """Create a new unsaved editor document tab."""
        title = f"Untitled-{self.untitled_counter}"
        self.untitled_counter += 1

        editor = CodeEditor(filepath=None)
        editor.setPlainText(default_content)
        editor.document().setModified(False)

        index = self.addTab(editor, title)
        self.setCurrentIndex(index)

        fake_path = f"__untitled__/{title}"
        self.editors[fake_path] = editor
        self._connect_editor_signals(editor, fake_path)

        return editor

    def save_current_file(self) -> bool:
        """Save active document."""
        editor = self.get_current_editor()
        if not editor:
            return False

        if editor.filepath and not editor.filepath.startswith("__untitled__"):
            return self._write_editor_to_disk(editor, editor.filepath)
        else:
            return self.save_current_file_as()

    def save_current_file_as(self) -> bool:
        """Save active document to a new file location."""
        editor = self.get_current_editor()
        if not editor:
            return False

        start_dir = workspace_manager.get_root_path() or os.path.expanduser("~")
        file_path, _ = QFileDialog.getSaveFileName(
            self, "Save File As", start_dir, "All Files (*);;Python (*.py);;Text (*.txt)"
        )
        if file_path:
            old_path = editor.filepath or ""
            if self._write_editor_to_disk(editor, file_path):
                if old_path in self.editors:
                    del self.editors[old_path]
                self.editors[file_path] = editor
                editor.set_filepath(file_path)
                index = self.indexOf(editor)
                self.setTabText(index, Path(file_path).name)
                self.setTabToolTip(index, file_path)
                return True
        return False

    def _write_editor_to_disk(self, editor: CodeEditor, filepath: str) -> bool:
        try:
            with open(filepath, "w", encoding="utf-8") as f:
                f.write(editor.toPlainText())
            editor.document().setModified(False)
            self._update_tab_dirty_status(editor)
            editor.file_saved.emit()
            return True
        except Exception as e:
            QMessageBox.critical(self, "Save Error", f"Could not save file:\n{e}")
            return False

    def close_tab(self, index: int) -> bool:
        """Prompt to save unsaved changes before closing tab."""
        editor = self.widget(index)
        if not isinstance(editor, CodeEditor):
            return True

        if editor.document().isModified():
            tab_name = self.tabText(index).rstrip(" •")
            reply = QMessageBox.question(
                self,
                "Unsaved Changes",
                f"Do you want to save the changes you made to {tab_name}?",
                QMessageBox.StandardButton.Save |
                QMessageBox.StandardButton.Discard |
                QMessageBox.StandardButton.Cancel,
                QMessageBox.StandardButton.Save
            )

            if reply == QMessageBox.StandardButton.Save:
                self.setCurrentIndex(index)
                if not self.save_current_file():
                    return False
            elif reply == QMessageBox.StandardButton.Cancel:
                return False

        # Find and remove from tracking dict
        for k, v in list(self.editors.items()):
            if v == editor:
                del self.editors[k]
                break

        self.removeTab(index)
        editor.deleteLater()
        return True

    def get_current_editor(self) -> Optional[CodeEditor]:
        curr = self.currentWidget()
        return curr if isinstance(curr, CodeEditor) else None

    def _connect_editor_signals(self, editor: CodeEditor, key: str) -> None:
        editor.document().modificationChanged.connect(
            lambda modified: self._update_tab_dirty_status(editor)
        )
        editor.cursor_position_changed.connect(self.cursor_position_changed.emit)

    def _update_tab_dirty_status(self, editor: CodeEditor) -> None:
        index = self.indexOf(editor)
        if index != -1:
            base_name = Path(editor.filepath).name if editor.filepath and not editor.filepath.startswith("__untitled__") else self.tabText(index).rstrip(" •")
            if editor.document().isModified():
                self.setTabText(index, f"{base_name} •")
            else:
                self.setTabText(index, base_name)

    def _on_current_tab_changed(self, index: int) -> None:
        editor = self.get_current_editor()
        self.current_editor_changed.emit(editor)
        if editor:
            cursor = editor.textCursor()
            self.cursor_position_changed.emit(cursor.blockNumber() + 1, cursor.positionInBlock() + 1)
            ext = Path(editor.filepath).suffix if editor.filepath else ""
            self.file_status_changed.emit(f"UTF-8 | {ext.upper() if ext else 'PLAIN TEXT'}")
