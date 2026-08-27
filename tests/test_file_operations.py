"""
Unit tests for file operations and utilities in PyCodeStudio.
"""

import tempfile
from pathlib import Path

from explorer.file_operations import FileOperations
from utils.config_manager import ConfigManager
from utils.file_utils import get_language_from_filename, read_file_content, write_file_content


def test_language_detection():
    """Tests extension to programming language mapping."""
    assert get_language_from_filename("script.py") == "python"
    assert get_language_from_filename("app.js") == "javascript"
    assert get_language_from_filename("index.html") == "html"
    assert get_language_from_filename("style.css") == "css"
    assert get_language_from_filename("data.json") == "json"
    assert get_language_from_filename("README.md") == "markdown"
    assert get_language_from_filename("main.cpp") == "cpp"
    assert get_language_from_filename("App.java") == "java"
    assert get_language_from_filename("unknown.xyz") == "text"


def test_file_read_write():
    """Tests file content reading and writing."""
    with tempfile.TemporaryDirectory() as tmp_dir:
        file_path = Path(tmp_dir) / "test_file.txt"
        test_content = "Hello PyCodeStudio\nLine 2"

        assert write_file_content(file_path, test_content)
        read_back, encoding = read_file_content(file_path)

        assert read_back == test_content
        assert encoding in ("utf-8", "utf-8-sig")


def test_file_operations_create_rename_delete():
    """Tests creating, renaming, duplicating, and deleting files and folders."""
    with tempfile.TemporaryDirectory() as tmp_dir:
        base_path = Path(tmp_dir)

        # Create File
        new_file = FileOperations.create_file(base_path, "test.py")
        assert new_file is not None
        assert new_file.exists()

        # Duplicate File
        copy_file = FileOperations.duplicate_file(new_file)
        assert copy_file is not None
        assert copy_file.exists()
        assert "copy" in copy_file.name

        # Rename File
        renamed_file = FileOperations.rename_item(new_file, "renamed.py")
        assert renamed_file is not None
        assert renamed_file.exists()
        assert not new_file.exists()

        # Create Folder
        new_folder = FileOperations.create_folder(base_path, "subfolder")
        assert new_folder is not None
        assert new_folder.is_dir()

        # Delete items
        assert FileOperations.delete_item(renamed_file)
        assert not renamed_file.exists()

        assert FileOperations.delete_item(new_folder)
        assert not new_folder.exists()


def test_config_manager():
    """Tests ConfigManager settings loading, saving, and recent history updates."""
    with tempfile.TemporaryDirectory() as tmp_dir:
        config_mgr = ConfigManager()
        config_mgr.config_dir = Path(tmp_dir)
        config_mgr.settings_file = config_mgr.config_dir / "settings.json"
        config_mgr.keybindings_file = config_mgr.config_dir / "keybindings.json"

        # Check default value
        assert config_mgr.get("font_size") == 13

        # Modify and save
        config_mgr.set("font_size", 16)
        assert config_mgr.get("font_size") == 16

        # Reload
        reloaded = config_mgr.load_settings()
        assert reloaded.get("font_size") == 16

        # Recent files
        config_mgr.add_recent_file("/path/to/file.py")
        assert "/path/to/file.py" in config_mgr.get("recent_files")
