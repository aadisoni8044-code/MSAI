"""Automated Unit and Integration Tests for NV Studio IDE"""
import os
import tempfile
from pathlib import Path
import pytest
from PyQt6.QtWidgets import QApplication

from nvstudio.core.config import ConfigManager
from nvstudio.core.workspace import WorkspaceManager
from nvstudio.ui.editor.code_editor import CodeEditor
from nvstudio.ui.editor.tab_widget import EditorTabWidget
from nvstudio.ui.sidebar.explorer import FileExplorerPanel
from nvstudio.ui.sidebar.search import SearchPanel
from nvstudio.ui.bottom_panel.terminal import TerminalWidget
from nvstudio.ui.main_window import MainWindow


@pytest.fixture(scope="session")
def qapp():
    """Session QApplication fixture."""
    app = QApplication.instance()
    if app is None:
        app = QApplication([])
    yield app


def test_config_manager(tmp_path):
    config = ConfigManager(config_dir=tmp_path)
    assert config.get("theme") == "NV Dark"
    config.set("editor.font_size", 18)
    assert config.get("editor.font_size") == 18

    # Test persistence
    config2 = ConfigManager(config_dir=tmp_path)
    assert config2.get("editor.font_size") == 18


def test_workspace_manager(tmp_path):
    ws = WorkspaceManager()
    assert ws.open_folder(str(tmp_path)) is True
    assert ws.get_root_path() == str(tmp_path.resolve())

    # Create file
    ok, fpath = ws.create_file(str(tmp_path), "test.txt")
    assert ok is True and Path(fpath).exists()

    # Rename
    ok, rpath = ws.rename_item(fpath, "renamed.txt")
    assert ok is True and Path(rpath).name == "renamed.txt"

    # Delete
    ok, _ = ws.delete_item(rpath)
    assert ok is True and not Path(rpath).exists()


def test_code_editor_functionality(qapp, tmp_path):
    editor = CodeEditor()
    editor.setPlainText("def hello():\n    return 'world'")
    assert "hello" in editor.toPlainText()

    # Find text
    found = editor.find_next("hello")
    assert found is True

    # Replace text
    editor.replace_text("hello", "greet")
    assert "def greet():" in editor.toPlainText()

    # Replace all without infinite loop when search pattern is inside replacement
    editor.setPlainText("foo bar foo baz foo")
    replaced_count = editor.replace_all_text("foo", "foobar")
    assert replaced_count == 3
    assert editor.toPlainText() == "foobar bar foobar baz foobar"


def test_tab_widget(qapp, tmp_path):
    tabs = EditorTabWidget()
    ed1 = tabs.new_file("print('file1')")
    assert tabs.count() == 1

    file2 = tmp_path / "test2.py"
    file2.write_text("print('file2')")
    ed2 = tabs.open_file(str(file2))
    assert tabs.count() == 2
    assert ed2.toPlainText() == "print('file2')"


def test_terminal_widget(qapp, tmp_path):
    term = TerminalWidget()
    term.cmd_input.setText("echo 'NV Studio Terminal Test'")
    term.execute_command()
    assert "NV Studio Terminal Test" in term.output.toPlainText()

    # Multiple sessions
    sess2 = term.new_terminal_session()
    assert term.tab_widget.count() == 2


def test_main_window_launch(qapp):
    win = MainWindow()
    win.show()
    assert win.isVisible()
    assert win.windowTitle().startswith("NV Studio")
    win.close()
