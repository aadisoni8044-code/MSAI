"""Unit tests for ProjectScanner."""

import os
import tempfile
import pytest
from app.project_scanner.scanner import ProjectScanner


def test_scanner_detects_files_and_entry_point():
    with tempfile.TemporaryDirectory() as tmpdir:
        main_py = os.path.join(tmpdir, "main.py")
        req_txt = os.path.join(tmpdir, "requirements.txt")
        asset_png = os.path.join(tmpdir, "icon.png")

        with open(main_py, "w", encoding="utf-8") as f:
            f.write("import os\nimport sys\nprint('Hello')\n")

        with open(req_txt, "w", encoding="utf-8") as f:
            f.write("pyinstaller\n")

        with open(asset_png, "wb") as f:
            f.write(b"PNG_HEADER")

        scanner = ProjectScanner(tmpdir)
        info = scanner.scan()

        assert info.project_name == os.path.basename(tmpdir)
        assert "main.py" in info.python_files
        assert "requirements.txt" in info.config_files
        assert "main.py" in info.entry_point_candidates
        assert info.selected_entry_point == "main.py"
        assert "os" in info.imported_modules
        assert "sys" in info.imported_modules
        assert "icon.png" in info.detected_assets
