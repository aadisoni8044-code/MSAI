"""
Unit and Integration Tests for MSAI Studio
"""
import os
import sys
import pytest
from PyQt6.QtWidgets import QApplication

# Ensure QApplication instance for Qt GUI testing
@pytest.fixture(scope="session", autouse=True)
def qapp():
    app = QApplication.instance()
    if app is None:
        app = QApplication([])
    yield app

from config import ConfigManager
from core.file_manager import FileManager
from core.project_manager import ProjectManager
from core.search_engine import SearchEngine
from git.git_manager import GitManager
from debug.debugger import Debugger
from ai.ai_assistant import AIAssistant
from ui.main_window import MainWindow

def test_config_manager(tmp_path):
    cfg_file = tmp_path / "test_settings.json"
    cfg = ConfigManager(config_file=str(cfg_file))
    cfg.set("font_size", 16)
    assert cfg.get("font_size") == 16

def test_file_manager(tmp_path):
    test_file = tmp_path / "hello.py"
    ok, msg = FileManager.write_file(str(test_file), "print('test')")
    assert ok is True
    ok, content = FileManager.read_file(str(test_file))
    assert ok is True
    assert content == "print('test')"

def test_search_engine(tmp_path):
    test_file = tmp_path / "sample.py"
    FileManager.write_file(str(test_file), "def hello_world():\n    return 42\n")
    results = SearchEngine.search_in_directory(str(tmp_path), "hello_world")
    assert len(results) == 1
    assert results[0]["matches"][0]["line_number"] == 1

def test_main_window_startup(qapp):
    window = MainWindow()
    assert window.windowTitle() == "MSAI Studio"
    window.new_file()
    assert window.tab_system.count() == 1
    window.close()
