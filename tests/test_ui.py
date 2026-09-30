import sys
import pytest
from PySide6.QtWidgets import QApplication

# Ensure single QApplication per test session
@pytest.fixture(scope="session")
def qapp():
    app = QApplication.instance()
    if app is None:
        app = QApplication(sys.argv)
    yield app

def test_main_window_instantiation(qapp):
    from main import MainWindow
    window = MainWindow()
    assert window.windowTitle() == ""
    assert window.views["dashboard"] is not None
    assert window.views["build_exe"] is not None
    assert window.views["building"] is not None
    assert window.views["success"] is not None
    assert window.views["error"] is not None
    assert window.views["projects"] is not None
    assert window.views["history"] is not None
    assert window.views["settings"] is not None
    assert window.views["about"] is not None

def test_navigation_switch(qapp):
    from main import MainWindow
    window = MainWindow()
    window.sidebar.select_nav("build_exe")
    assert window.stack.currentWidget() == window.views["build_exe"]

    window.sidebar.select_nav("settings")
    assert window.stack.currentWidget() == window.views["settings"]
