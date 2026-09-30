import pytest
from exe_tow.core.history import HistoryManager
from exe_tow.ui.views.projects_view import ProjectsView
from exe_tow.ui.views.history_view import HistoryView


def test_projects_and_history_views(qtbot, tmp_path):
    history_file = tmp_path / "data" / "history.json"
    history = HistoryManager(data_file=str(history_file))

    # Add dummy history item
    history.add_or_update_project("/tmp/demo_proj", "DemoProj", "main.py")
    history.record_build("DemoProj", "/tmp/demo_proj", "DemoProj.exe", "/tmp/demo_proj/dist/DemoProj.exe", "SUCCESS", 15.0, 4.0)

    # Test ProjectsView
    proj_view = ProjectsView(history_manager=history)
    qtbot.addWidget(proj_view)
    proj_view.refresh_projects()

    # Test HistoryView
    hist_view = HistoryView(history_manager=history)
    qtbot.addWidget(hist_view)
    hist_view.refresh_history()

    assert hist_view.table.rowCount() == 1
    assert hist_view.table.item(0, 0).text() == "DemoProj"
