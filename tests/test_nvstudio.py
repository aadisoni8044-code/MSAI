import os
import pytest
from pathlib import Path
from PyQt6.QtWidgets import QApplication

from nvstudio.config import ConfigManager, DEFAULT_CONFIG
from nvstudio.workspace import WorkspaceManager
from nvstudio.ui.editor import CodeEditor, TabbedEditorWorkspace
from nvstudio.ui.file_explorer import FileExplorerPanel
from nvstudio.ui.preview import LivePreviewPanel
from nvstudio.ui.dialogs import SettingsDialog, SearchReplaceBar, FirstLaunchConsentDialog, FirstLaunchThemeDialog
from nvstudio.ui.main_window import MainWindow


@pytest.fixture(scope="session")
def qapp():
    app = QApplication.instance()
    if app is None:
        app = QApplication([])
    yield app


def test_config_manager(tmp_path):
    cfg_file = tmp_path / "config.json"
    cm = ConfigManager(config_path=cfg_file)
    assert cm.get("theme") == "Dark Mode"

    cm.set("theme", "White Mode")
    assert cm.get("theme") == "White Mode"

    # Reload from file
    cm2 = ConfigManager(config_path=cfg_file)
    assert cm2.get("theme") == "White Mode"


def test_workspace_manager(tmp_path):
    ws_file = tmp_path / "workspace.json"
    proj_dir = tmp_path / "my_project"
    wm = WorkspaceManager(workspace_path=ws_file)
    wm.set_project_dir(proj_dir)
    wm.load()

    assert proj_dir.exists()
    assert (proj_dir / "index.html").exists()
    assert (proj_dir / "style.css").exists()
    assert (proj_dir / "script.js").exists()


def test_editor_and_workspace(qapp, tmp_path):
    workspace = TabbedEditorWorkspace()
    test_file = tmp_path / "test.html"
    test_file.write_text("<h1>Hello World</h1>", encoding="utf-8")

    editor = workspace.open_file(str(test_file))
    assert editor is not None
    assert editor.toPlainText() == "<h1>Hello World</h1>"

    editor.setPlainText("<h1>Updated Title</h1>")
    assert editor.is_modified is True

    workspace.save_file(str(test_file))
    assert test_file.read_text(encoding="utf-8") == "<h1>Updated Title</h1>"
    assert editor.is_modified is False


def test_file_explorer(qapp, tmp_path):
    explorer = FileExplorerPanel(project_dir=tmp_path)
    assert explorer.project_dir == tmp_path

    # New file creation logic
    new_file = tmp_path / "app.js"
    new_file.touch()
    assert new_file.exists()


def test_live_preview_device(qapp):
    preview = LivePreviewPanel()
    assert preview.current_device == "Laptop"

    preview.set_device("Mobile")
    assert preview.current_device == "Mobile"

    preview.set_device("iPad")
    assert preview.current_device == "iPad"


def test_main_window_integration(qapp, tmp_path):
    cfg_file = tmp_path / "config.json"
    ws_file = tmp_path / "workspace.json"
    proj_dir = tmp_path / "test_proj"

    cm = ConfigManager(config_path=cfg_file)
    wm = WorkspaceManager(workspace_path=ws_file)
    wm.set_project_dir(proj_dir)
    wm.ensure_default_project()

    main_win = MainWindow(cm, wm)
    assert main_win.windowTitle() == "NV Studio"

    # Test settings update
    cm.set("theme", "White Mode")
    main_win._apply_theme()
    main_win.close()
