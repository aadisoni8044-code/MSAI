import os
import pytest
from pathlib import Path

from exe_tow.core.scanner import scan_project_folder
from exe_tow.core.storage import StorageManager
from exe_tow.core.builder import BuildWorker

def test_scanner_with_dummy_folder(tmp_path):
    project_dir = tmp_path / "sample_project"
    project_dir.mkdir()

    main_py = project_dir / "main.py"
    main_py.write_text("if __name__ == '__main__':\n    print('Hello World')\n")

    req_txt = project_dir / "requirements.txt"
    req_txt.write_text("requests==2.31.0\npytest\n")

    assets_dir = project_dir / "assets"
    assets_dir.mkdir()
    (assets_dir / "logo.png").write_text("fake png content")

    scan = scan_project_folder(str(project_dir))

    assert scan["valid"] is True
    assert scan["project_name"] == "sample_project"
    assert scan["main_file"] == "main.py"
    assert "main.py" in scan["python_files"]
    assert "requests" in scan["dependencies"]
    assert "assets" in scan["asset_folders"]

def test_storage_manager(tmp_path):
    storage_file = tmp_path / "test_data.json"
    mgr = StorageManager(file_path=storage_file)

    settings = mgr.get_settings()
    assert settings["python_interpreter"] == "python"

    mgr.update_settings({"python_interpreter": "python3"})
    assert mgr.get_settings()["python_interpreter"] == "python3"

    mgr.add_or_update_project({
        "folder_path": "/tmp/test",
        "project_name": "TestProj",
        "main_file": "app.py"
    })
    projects = mgr.get_projects()
    assert len(projects) == 1
    assert projects[0]["project_name"] == "TestProj"

    mgr.add_history_entry({
        "project_name": "TestProj",
        "status": "Success",
        "exe_filename": "TestProj.exe"
    })
    stats = mgr.get_stats()
    assert stats["projects_built"] == 1
    assert stats["successful_builds"] == 1
    assert stats["recent_build"] == "TestProj"
    assert stats["build_status"] == "Success"

def test_builder_worker_fallback(tmp_path):
    proj_dir = tmp_path / "dummy_app"
    proj_dir.mkdir()
    (proj_dir / "app.py").write_text("print('test')")

    out_dir = tmp_path / "output"

    config = {
        "folder_path": str(proj_dir),
        "project_name": "dummy_app",
        "main_file": "app.py",
        "exe_name": "dummy_app",
        "output_folder": str(out_dir),
        "one_file": True,
        "windowed": True
    }

    worker = BuildWorker(config)
    success_results = []
    error_results = []

    worker.finished_success.connect(lambda s: success_results.append(s))
    worker.finished_error.connect(lambda e: error_results.append(e))

    worker.run()

    assert len(success_results) == 1 or len(error_results) == 1
    if success_results:
        summary = success_results[0]
        assert summary["project_name"] == "dummy_app"
        assert summary["status"] == "Success"
