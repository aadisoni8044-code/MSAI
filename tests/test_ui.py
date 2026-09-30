import pytest
from PySide6.QtWidgets import QApplication
from exe_tow.ui.components.custom_widgets import StatCard, TerminalLogPanel, PipelineStepWidget


def test_custom_widgets(qtbot):
    # 1. Test StatCard
    stat_card = StatCard("BUILDS", "38")
    qtbot.addWidget(stat_card)
    assert stat_card.val_label.text() == "38"
    assert stat_card.title_label.text() == "BUILDS"
    stat_card.set_value("42")
    assert stat_card.val_label.text() == "42"

    # 2. Test TerminalLogPanel
    log_panel = TerminalLogPanel()
    qtbot.addWidget(log_panel)
    log_panel.append_log("[12:00:00] Initializing build...")
    assert "[12:00:00] Initializing build..." in log_panel.get_logs()
    log_panel.clear_logs()
    assert log_panel.get_logs() == ""

    # 3. Test PipelineStepWidget
    pipeline_step = PipelineStepWidget("01", "SCANNING")
    qtbot.addWidget(pipeline_step)
    assert "Waiting" in pipeline_step.status_label.text()
    pipeline_step.set_status("completed")
    assert "Complete" in pipeline_step.status_label.text()
