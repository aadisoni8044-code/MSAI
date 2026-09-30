import os
import pytest
from exe_tow.core.logger import BuildLogger
from exe_tow.core.history import HistoryManager


def test_logger():
    logs = []
    logger = BuildLogger(callback=lambda line: logs.append(line))
    msg = logger.log("Testing log entry")

    assert "Testing log entry" in msg
    assert len(logs) == 1
    assert "Testing log entry" in logs[0]
    assert logger.get_text() == logs[0]


def test_history_manager(tmp_path):
    history_file = tmp_path / "data" / "history.json"
    history = HistoryManager(data_file=str(history_file))

    stats = history.get_statistics()
    assert stats["projects_count"] == 0
    assert stats["builds_count"] == 0

    history.add_or_update_project(
        project_path="/tmp/test_project",
        name="TestProject",
        main_file="main.py"
    )

    stats2 = history.get_statistics()
    assert stats2["projects_count"] == 1

    history.record_build(
        project_name="TestProject",
        project_path="/tmp/test_project",
        exe_name="TestProject.exe",
        exe_path="/tmp/test_project/dist/TestProject.exe",
        status="SUCCESS",
        size_mb=12.5,
        duration_sec=5.2
    )

    stats3 = history.get_statistics()
    assert stats3["builds_count"] == 1
    assert stats3["success_count"] == 1
    assert stats3["failed_count"] == 0
