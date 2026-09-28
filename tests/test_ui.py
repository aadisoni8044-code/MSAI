import os
import pytest
from PySide6.QtWidgets import QApplication
from exe_tow.ui.app_window import MainWindow

@pytest.fixture(scope="session")
def qapp():
    app = QApplication.instance()
    if app is None:
        app = QApplication([])
    yield app

def test_ui_initialization(qapp):
    window = MainWindow()
    assert window.windowTitle() == "EXE/TOW — Python to Windows EXE Builder"
    assert "dashboard" in window.views
    assert "build" in window.views
    assert "projects" in window.views
    assert "cmd_history" in window.views
    assert "build_history" in window.views
    assert "settings" in window.views

def test_view_switching(qapp):
    window = MainWindow()
    window._switch_view("build")
    assert window.stack.currentWidget() == window.views["build"]

    window._switch_view("settings")
    assert window.stack.currentWidget() == window.views["settings"]
