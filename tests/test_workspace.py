"""
Tests for WorkspaceManager file system operations.
"""

from pathlib import Path
import pytest

from nvstudio.workspace import WorkspaceManager


def test_workspace_manager_initialization(tmp_path):
    wm = WorkspaceManager(str(tmp_path))
    assert wm.root_path == tmp_path
    assert (tmp_path / "index.html").exists()
    assert (tmp_path / "style.css").exists()
    assert (tmp_path / "script.js").exists()


def test_workspace_list_and_read_files(tmp_path):
    wm = WorkspaceManager(str(tmp_path))
    files = [str(f) for f in wm.list_files()]
    assert "index.html" in files
    assert "style.css" in files
    assert "script.js" in files

    content = wm.read_file("index.html")
    assert "<!DOCTYPE html>" in content


def test_workspace_file_crud_operations(tmp_path):
    wm = WorkspaceManager(str(tmp_path))

    # Create
    created = wm.create_file("app.js", "console.log('test');")
    assert created is True
    assert (tmp_path / "app.js").exists()

    # Read
    content = wm.read_file("app.js")
    assert content == "console.log('test');"

    # Save / Update
    wm.save_file("app.js", "console.log('updated');")
    assert wm.read_file("app.js") == "console.log('updated');"

    # Rename
    renamed = wm.rename_file("app.js", "main.js")
    assert renamed is True
    assert not (tmp_path / "app.js").exists()
    assert (tmp_path / "main.js").exists()

    # Delete
    deleted = wm.delete_file("main.js")
    assert deleted is True
    assert not (tmp_path / "main.js").exists()
