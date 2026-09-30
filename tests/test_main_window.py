import pytest
from PySide6.QtWidgets import QApplication
from exe_tow.core.history import HistoryManager
from exe_tow.ui.main_window import MainWindow


def test_main_window_and_dashboard(qtbot, tmp_path):
    # Use isolated test history file
    hist_file = tmp_path / "data" / "history.json"
    win = MainWindow()
    win.history_manager = HistoryManager(data_file=str(hist_file))
    win.dashboard_view.history_manager = win.history_manager
    win.dashboard_view.refresh_stats()

    qtbot.addWidget(win)

    assert "exe/tow" in win.windowTitle()
    assert win.status_badge.text() == "● READY"

    # Check top bar and sidebar contain no Settings button
    for btn in win.findChildren(object, name="NavButton"):
        assert "Settings" not in btn.text()

    # Check Dashboard stats initialized
    dash = win.dashboard_view
    assert dash.projects_card.val_label.text() == "0"
    assert dash.builds_card.val_label.text() == "0"

    # Test navigation button clicking
    win.set_active_nav("dashboard")
    assert win.nav_btns["dashboard"].property("active") == "true"
