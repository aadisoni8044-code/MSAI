import os
import tempfile
import shutil
import pytest
from PySide6.QtWidgets import QApplication
from exe_tow.core.storage import StorageManager
from exe_tow.ui.titlebar import TitleBar
from exe_tow.ui.sidebar import Sidebar
from exe_tow.ui.views.dashboard_view import DashboardView
from exe_tow.ui.views.scanner_view import ScannerView
from exe_tow.ui.views.build_view import BuildView
from exe_tow.ui.views.build_monitor_view import BuildMonitorView
from exe_tow.ui.views.projects_view import ProjectsView
from exe_tow.ui.views.history_view import HistoryView
from exe_tow.ui.views.settings_view import SettingsView
from exe_tow.ui.views.about_view import AboutView
from exe_tow.ui.main_window import MainWindow

@pytest.fixture(scope="module")
def qapp():
    app = QApplication.instance()
    if app is None:
        app = QApplication([])
    return app

def test_titlebar_and_sidebar(qapp):
    tb = TitleBar()
    assert tb.logo_label is not None

    sb = Sidebar()
    assert sb.button_group is not None
    assert len(sb.nav_buttons) == 6

def test_all_views_creation(qapp):
    temp_dir = tempfile.mkdtemp()
    try:
        sm = StorageManager(storage_dir=temp_dir)
        dv = DashboardView(sm)
        sv = ScannerView()
        bv = BuildView()
        bmv = BuildMonitorView()
        pv = ProjectsView(sm)
        hv = HistoryView(sm)
        set_v = SettingsView(sm)
        av = AboutView()

        assert dv is not None
        assert sv is not None
        assert bv is not None
        assert bmv is not None
        assert pv is not None
        assert hv is not None
        assert set_v is not None
        assert av is not None
    finally:
        shutil.rmtree(temp_dir)

def test_main_window_routing(qapp):
    temp_dir = tempfile.mkdtemp()
    try:
        window = MainWindow()

        # Test page navigation
        pages = ["dashboard", "scanner", "build", "monitor", "projects", "history", "settings", "about"]
        for p in pages:
            window.navigate_to(p)
            idx, _ = window.views_map[p]
            assert window.stacked_widget.currentIndex() == idx
    finally:
        shutil.rmtree(temp_dir)

def test_scanner_view_directory_scan(qapp):
    temp_dir = tempfile.mkdtemp()
    try:
        with open(os.path.join(temp_dir, "main.py"), "w") as f:
            f.write("print('test')\n")

        sv = ScannerView()
        sv.scan_directory(temp_dir)
        assert sv.scan_result["valid"] is True
        assert sv.scan_result["entry_file"] == "main.py"
    finally:
        shutil.rmtree(temp_dir)
