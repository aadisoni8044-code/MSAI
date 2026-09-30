import os
import tempfile
import shutil
import pytest
from exe_tow.core.scanner import ProjectScanner

def test_scanner_non_existent_directory():
    scanner = ProjectScanner("/path/that/does/not/exist/12345")
    res = scanner.scan()
    assert res["valid"] is False
    assert len(res["checklist"]) > 0

def test_scanner_real_directory():
    temp_dir = tempfile.mkdtemp()
    try:
        # Create sample files
        with open(os.path.join(temp_dir, "app.py"), "w") as f:
            f.write("import os\nif __name__ == '__main__': print('hello')\n")

        with open(os.path.join(temp_dir, "requirements.txt"), "w") as f:
            f.write("requests==2.31.0\npillow>=10.0.0\n")

        os.makedirs(os.path.join(temp_dir, "assets"), exist_ok=True)
        with open(os.path.join(temp_dir, "assets", "logo.png"), "wb") as f:
            f.write(b"PNGDATA")

        scanner = ProjectScanner(temp_dir)
        res = scanner.scan()

        assert res["valid"] is True
        assert res["entry_file"] == "app.py"
        assert res["py_files_count"] == 1
        assert "requests" in res["dependencies"]
        assert "pillow" in res["dependencies"]
        assert len(res["asset_files"]) >= 1
    finally:
        shutil.rmtree(temp_dir)
