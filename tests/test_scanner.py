import os
import pytest
from exe_tow.core.scanner import ProjectScanner
from exe_tow.core.detector import EntryFileDetector
from exe_tow.core.dependencies import DependencyParser


def test_scanner_and_detector_and_dependencies(tmp_path):
    # Create sample project structure
    project_dir = tmp_path / "sample_project"
    project_dir.mkdir()

    main_py = project_dir / "main.py"
    main_py.write_text("import requests\nif __name__ == '__main__':\n    print('Hello World')\n")

    app_py = project_dir / "app.py"
    app_py.write_text("import PySide6\ndef run(): pass\n")

    utils_py = project_dir / "utils.py"
    utils_py.write_text("def helper(): return 42\n")

    assets_dir = project_dir / "assets"
    assets_dir.mkdir()
    logo_file = assets_dir / "logo.png"
    logo_file.write_text("fake image bytes")

    req_file = project_dir / "requirements.txt"
    req_file.write_text("requests>=2.28.0\nPySide6==6.5.0\n")

    # 1. Test Scanner
    scanner = ProjectScanner(str(project_dir))
    scan_res = scanner.scan()

    assert scan_res["python_files_count"] == 3
    assert scan_res["asset_files_count"] == 1
    assert scan_res["config_files_count"] == 1
    assert "main.py" in scan_res["python_files"]

    # 2. Test Entry File Detector
    detector = EntryFileDetector(str(project_dir), scan_res["python_files"])
    det_res = detector.detect()

    assert det_res["selected_entry"] == "main.py"
    assert "app.py" in det_res["possible_entries"]

    # 3. Test Dependency Parser
    dep_parser = DependencyParser(str(project_dir), scan_res["python_files"])
    dep_res = dep_parser.parse()

    assert "requests" in dep_res["dependencies"]
    assert "PySide6" in dep_res["dependencies"]
