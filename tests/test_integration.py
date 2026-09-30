import pytest
from PySide6.QtWidgets import QApplication
from exe_tow.main import ExeTowApp


def test_full_app_integration(qtbot, tmp_path):
    app_win = ExeTowApp()
    qtbot.addWidget(app_win)

    # 1. Verify view stack initialized with 4 views (Dashboard, Build, Projects, History)
    assert app_win.view_stack.count() == 4

    # 2. Test navigation switching across views
    app_win.set_active_nav("dashboard")
    assert app_win.view_stack.currentIndex() == 0

    app_win.set_active_nav("build")
    assert app_win.view_stack.currentIndex() == 1

    app_win.set_active_nav("projects")
    assert app_win.view_stack.currentIndex() == 2

    app_win.set_active_nav("history")
    assert app_win.view_stack.currentIndex() == 3

    # 3. Test project open trigger from projects view
    demo_dir = tmp_path / "integration_proj"
    demo_dir.mkdir()
    (demo_dir / "app.py").write_text("print('Integration')")

    app_win._on_open_project(str(demo_dir))
    assert app_win.view_stack.currentIndex() == 1 # Navigated to build
    assert app_win.build_view.path_input.text() == str(demo_dir)
