"""
Unit tests for editor widgets and components in PyCodeStudio.
"""

import sys
import tempfile
from pathlib import Path

import pytest
from PyQt6.QtWidgets import QApplication

from editor.editor_widget import EditorWidget
from editor.tab_manager import TabManager
from themes.theme_manager import ThemeManager

@pytest.fixture(scope="session")
def qapp():
    """Provides a singleton QApplication instance for PyQt tests."""
    app = QApplication.instance()
    if app is None:
        app = QApplication(sys.argv)
    yield app


def test_editor_widget_basic(qapp):
    """Tests basic EditorWidget operations."""
    editor = EditorWidget(settings={"font_size": 14, "tab_size": 4})
    editor.setText("def main():\n    print('Hello World')")

    assert "main()" in editor.text()
    assert editor.font_size == 14

    with tempfile.TemporaryDirectory() as tmp_dir:
        save_path = Path(tmp_dir) / "test_editor.py"
        assert editor.save_file(save_path)
        assert save_path.exists()

        new_editor = EditorWidget(settings={"font_size": 14})
        assert new_editor.load_file(save_path)
        assert "Hello World" in new_editor.text()
        assert new_editor.language == "python"


def test_tab_manager_open_and_close(qapp):
    """Tests TabManager opening, switching, and closing tabs."""
    tab_mgr = TabManager(settings={"font_size": 12})

    # Create new file
    editor1 = tab_mgr.new_file("Untitled-1.py")
    assert tab_mgr.count() == 1
    assert tab_mgr.get_active_editor() == editor1

    with tempfile.TemporaryDirectory() as tmp_dir:
        file2_path = Path(tmp_dir) / "file2.js"
        file2_path.write_text("console.log('test');", encoding="utf-8")

        editor2 = tab_mgr.open_file(file2_path)
        assert tab_mgr.count() == 2
        assert tab_mgr.get_active_editor() == editor2
        assert editor2.language == "javascript"

        # Close active tab
        tab_mgr.close_tab(1)
        assert tab_mgr.count() == 1


def test_theme_manager():
    """Tests ThemeManager dark/light identification."""
    assert ThemeManager.is_dark_theme("dark")
    assert not ThemeManager.is_dark_theme("light")
