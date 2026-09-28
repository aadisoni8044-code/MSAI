"""
UI tests for exe/tow PySide6 views and MainWindow layout.
"""

import os
import tempfile
import pytest
from PySide6.QtCore import QCoreApplication
from PySide6.QtGui import QPixmap, QImage
from PySide6.QtWidgets import QApplication

from exe_tow.core.settings import SettingsManager
from exe_tow.core.history import HistoryManager
from exe_tow.ui.main_window import MainWindow
from exe_tow.ui.views.home_view import HomeView
from exe_tow.ui.views.build_view import BuildView


def test_main_window_instantiation():
    app = QApplication.instance() or QApplication([])
    with tempfile.TemporaryDirectory() as tmp_dir:
        s_file = os.path.join(tmp_dir, "s.json")
        h_file = os.path.join(tmp_dir, "h.json")

        sm = SettingsManager(s_file)
        hm = HistoryManager(h_file)

        mw = MainWindow(sm, hm, logo_path="assets/logo.png")
        assert mw.windowTitle() == "exe/tow - Desktop Python Compiler"
        assert mw.views_stack.count() == 6

        # Test view navigation
        for key in ["home", "build", "projects", "history", "settings", "about"]:
            mw.navigate_to_key(key)
            app.processEvents()
            assert mw.sidebar.current_key == key

        mw.close()
        mw.deleteLater()
        app.processEvents()


def test_build_view_flow():
    app = QApplication.instance() or QApplication([])
    with tempfile.TemporaryDirectory() as tmp_dir:
        f_set = os.path.join(tmp_dir, "s.json")
        f_hist = os.path.join(tmp_dir, "h.json")

        sm = SettingsManager(f_set)
        hm = HistoryManager(f_hist)

        bv = BuildView(sm, hm)
        bv.set_project_folder(tmp_dir)

        # Create dummy main.py
        app_py = os.path.join(tmp_dir, "main.py")
        with open(app_py, "w") as f:
            f.write("print('Hello world')\n")

        bv._on_project_folder_changed(tmp_dir)
        assert bv.combo_main.currentText() == "main.py"

        bv.close()
        bv.deleteLater()
        app.processEvents()


def test_render_snapshot():
    app = QApplication.instance() or QApplication([])
    with tempfile.TemporaryDirectory() as tmp_dir:
        s_file = os.path.join(tmp_dir, "s.json")
        h_file = os.path.join(tmp_dir, "h.json")

        sm = SettingsManager(s_file)
        hm = HistoryManager(h_file)

        mw = MainWindow(sm, hm, logo_path="assets/logo.png")
        mw.resize(1180, 780)
        mw.show()
        app.processEvents()

        # Render window to QPixmap
        pixmap = mw.grab()
        assert pixmap.width() > 0 and pixmap.height() > 0

        os.makedirs("snapshots", exist_ok=True)
        pixmap.save("snapshots/exe_tow_dashboard.png")
        assert os.path.exists("snapshots/exe_tow_dashboard.png")

        mw.close()
        mw.deleteLater()
        app.processEvents()
