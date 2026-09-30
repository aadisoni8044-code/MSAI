import os
import tempfile
import shutil
import pytest
from exe_tow.core.builder import BuildWorkerThread, PIPELINE_STEPS

def test_pipeline_steps_constant():
    assert len(PIPELINE_STEPS) == 7
    assert PIPELINE_STEPS[0] == "PROJECT SCANNED"
    assert PIPELINE_STEPS[6] == "COMPLETE"

def test_builder_thread_initialization():
    thread = BuildWorkerThread(
        project_dir=".",
        entry_file="main.py",
        app_name="TestApp",
        exe_filename="TestApp.exe",
        output_dir="dist"
    )
    assert thread.app_name == "TestApp"
    assert thread.exe_filename == "TestApp.exe"
    assert thread.one_file is True
