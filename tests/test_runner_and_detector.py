"""Unit tests for CommandRunner and OutputDetector."""

import os
import tempfile
import pytest
from app.command_runner.runner import CommandRunner
from app.output_detector.detector import OutputDetector


def test_command_runner_execution_and_safety():
    runner = CommandRunner()
    res = runner.run(["python3", "-c", "import sys; sys.stdout.write('out'); sys.stderr.write('err')"])
    assert res.exit_code == 0
    assert res.stdout == "out"
    assert res.stderr == "err"
    assert res.is_success is True

    unsafe_res = runner.run(["del /f /s /q c:\\\\"])
    assert unsafe_res.exit_code == -1
    assert "safety validation" in unsafe_res.stderr


def test_output_detector_detection_and_verification():
    with tempfile.TemporaryDirectory() as tmpdir:
        dist_dir = os.path.join(tmpdir, "dist")
        os.makedirs(dist_dir)
        exe_file = os.path.join(dist_dir, "myapp.exe")
        with open(exe_file, "wb") as f:
            f.write(b"MZ_EXECUTABLE_HEADER")

        detector = OutputDetector(tmpdir, "dist")
        detected = detector.detect_exe("myapp")
        assert detected == exe_file

        verif = detector.verify_exe(exe_file)
        assert verif["exists"] is True
        assert verif["is_valid"] is True
        assert verif["size_bytes"] > 0
