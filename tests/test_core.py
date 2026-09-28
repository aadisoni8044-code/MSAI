"""
Unit tests for exe/tow core modules: SettingsManager, ProjectDetector, HistoryManager, and BuildWorker.
"""

import os
import tempfile
import pytest
from PySide6.QtWidgets import QApplication

from exe_tow.core.settings import SettingsManager
from exe_tow.core.detector import ProjectDetector
from exe_tow.core.history import HistoryManager
from exe_tow.core.builder import BuildWorker


def test_settings_manager():
    with tempfile.NamedTemporaryFile(suffix=".json", delete=False) as tmp:
        tmp_path = tmp.name

    try:
        sm = SettingsManager(tmp_path)
        assert sm.get("build_engine") == "PyInstaller"
        sm.set("theme", "Dark Charcoal")
        assert sm.get("theme") == "Dark Charcoal"

        sm.add_recent_project("/tmp/test_proj")
        assert "/tmp/test_proj" in sm.get("recent_projects")
    finally:
        if os.path.exists(tmp_path):
            os.remove(tmp_path)


def test_project_detector():
    with tempfile.TemporaryDirectory() as tmp_dir:
        main_py = os.path.join(tmp_dir, "main.py")
        req_txt = os.path.join(tmp_dir, "requirements.txt")

        with open(main_py, "w") as f:
            f.write("if __name__ == '__main__': print('hello')\n")

        with open(req_txt, "w") as f:
            f.write("PySide6>=6.0.0\nrequests==2.28.1\n")

        info = ProjectDetector.inspect_directory(tmp_dir)
        assert info["valid"] is True
        assert info["main_file"] == "main.py"
        assert "PySide6" in info["dependencies"]
        assert "requests" in info["dependencies"]


def test_history_manager():
    with tempfile.NamedTemporaryFile(suffix=".json", delete=False) as tmp:
        tmp_path = tmp.name

    try:
        hm = HistoryManager(tmp_path)
        hm.clear()
        assert len(hm.get_records()) == 0

        hm.add_record({
            "project_name": "SampleApp",
            "status": "SUCCESS",
            "output_exe": "/tmp/dist/SampleApp.exe"
        })
        records = hm.get_records()
        assert len(records) == 1
        assert records[0]["project_name"] == "SampleApp"
    finally:
        if os.path.exists(tmp_path):
            os.remove(tmp_path)


def test_build_worker_success():
    app = QApplication.instance() or QApplication([])

    with tempfile.TemporaryDirectory() as tmp_dir:
        main_py = os.path.join(tmp_dir, "app.py")
        with open(main_py, "w") as f:
            f.write("print('Hello from app')\n")

        out_dir = os.path.join(tmp_dir, "dist")

        config = {
            "project_folder": tmp_dir,
            "main_file": "app.py",
            "output_folder": out_dir,
            "one_file": True
        }

        results = {}

        def on_finished(res):
            results["res"] = res

        worker = BuildWorker(config)
        worker.sig_finished.connect(on_finished)
        worker.start()

        worker.wait(10000)
        app.processEvents()

        assert "res" in results
        assert results["res"]["status"] == "SUCCESS"
        assert os.path.exists(results["res"]["output_exe"])


def test_build_worker_error():
    app = QApplication.instance() or QApplication([])

    config = {
        "project_folder": "/non_existent_folder_xyz_123",
        "main_file": "app.py",
        "output_folder": "/tmp/dist"
    }

    errors = {}

    def on_failed(err):
        errors["err"] = err

    worker = BuildWorker(config)
    worker.sig_failed.connect(on_failed)
    worker.start()
    worker.wait(10000)
    app.processEvents()

    assert "err" in errors
    assert errors["err"]["status"] == "FAILED"
    assert "Invalid Project Folder" in errors["err"]["title"]
