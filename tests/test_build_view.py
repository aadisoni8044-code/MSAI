import pytest
from PySide6.QtWidgets import QApplication
from exe_tow.core.history import HistoryManager
from exe_tow.ui.views.build_view import BuildView


def test_build_view(qtbot, tmp_path):
    history_file = tmp_path / "data" / "history.json"
    history = HistoryManager(data_file=str(history_file))

    bv = BuildView(history_manager=history)
    qtbot.addWidget(bv)

    assert bv.stack.currentIndex() == 0
    assert bv.header_title.text() == "BUILD EXE"

    # Setup dummy project folder
    proj_dir = tmp_path / "my_py_app"
    proj_dir.mkdir()
    (proj_dir / "main.py").write_text("print('test')")

    bv.set_project_path(str(proj_dir))
    assert bv.entry_combo.currentText() == "main.py"
    assert "✓ Folder found" in bv.folder_status_label.text()

    # Test step status update
    bv._on_step_changed(1, "SCANNING", "completed")
    assert "Complete" in bv.step_widgets[0].status_label.text()
