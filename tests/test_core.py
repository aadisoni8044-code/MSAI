import os
import pytest
from pathlib import Path
from exe_tow.config.settings import Settings
from exe_tow.core.models import CommandExecution, CommandStatus, ErrorCategory
from exe_tow.core.environment_detector import EnvironmentDetector
from exe_tow.core.project_analyzer import ProjectAnalyzer
from exe_tow.core.command_runner import CommandRunner
from exe_tow.core.knowledge_db import KnowledgeDatabase
from exe_tow.core.history_manager import HistoryManager
from exe_tow.core.recovery_manager import RecoveryManager
from exe_tow.core.fallback_manager import FallbackManager
from exe_tow.core.engines.pyinstaller_engine import PyInstallerEngine
from exe_tow.core.build_engine import BuildEngine

def test_settings_load_save(tmp_path):
    cfg_file = tmp_path / "test_config.json"
    settings = Settings(max_retries=8, default_build_mode="ONE DIRECTORY")
    settings.save(cfg_file)

    assert cfg_file.exists()
    loaded = Settings.load(cfg_file)
    assert loaded.max_retries == 8
    assert loaded.default_build_mode == "ONE DIRECTORY"

def test_environment_detector():
    detector = EnvironmentDetector()
    env = detector.detect()
    assert env.python_executable != ""
    assert env.python_version != ""

def test_project_analyzer(tmp_path):
    py_file = tmp_path / "main.py"
    py_file.write_text("import sys\nimport os\nprint('hello')", encoding="utf-8")

    analyzer = ProjectAnalyzer(str(py_file))
    info = analyzer.analyze()

    assert info.is_single_file is True
    assert info.project_name == "main"
    assert "sys" in info.detected_imports
    assert "os" in info.detected_imports

def test_command_runner():
    runner = CommandRunner(timeout=10)
    exec_res = runner.run_command(
        command_list=["python3", "-c", "print('EXE_TOW_TEST_OK')"],
        reason="Unit Test Execution"
    )
    assert exec_res.status == CommandStatus.SUCCESS
    assert "EXE_TOW_TEST_OK" in exec_res.stdout
    assert exec_res.exit_code == 0

def test_knowledge_db(tmp_path):
    db_file = tmp_path / "knowledge.json"
    kdb = KnowledgeDatabase(db_path=db_file)
    kdb.record_attempt(
        command="python -m PyInstaller --onefile main.py",
        environment_info={"python_version": "3.12"},
        project_type="single_file",
        status="SUCCESS"
    )
    assert db_file.exists()
    pref = kdb.get_preferred_command("single_file")
    assert pref == "python -m PyInstaller --onefile main.py"

def test_recovery_manager():
    dummy_exec = CommandExecution(
        id="1",
        command_text="pyinstaller main.py",
        reason="test",
        stdout="",
        stderr="No module named PyInstaller"
    )
    cat = RecoveryManager.classify_error(dummy_exec)
    assert cat == ErrorCategory.PYINSTALLER_NOT_FOUND

    rec_cmd = RecoveryManager.get_recovery_command(cat, "python3", "pip")
    assert rec_cmd == ["pip", "install", "pyinstaller"]

def test_pyinstaller_engine():
    engine = PyInstallerEngine()
    dummy_project = ProjectAnalyzer.__new__(ProjectAnalyzer)
    from exe_tow.core.models import ProjectInfo, EnvironmentInfo

    p_info = ProjectInfo(
        project_path="/tmp", entry_file="/tmp/main.py", project_name="main",
        is_single_file=True, has_requirements=False, requirements_path=None,
        has_venv=False, venv_path=None
    )
    e_info = EnvironmentInfo(
        python_executable="python3", python_version="3.12", architecture="x86_64",
        pip_executable="pip", pip_installed=True, pyinstaller_installed=True
    )

    candidates = engine.build_command_candidates(p_info, e_info, "MyGame.exe", "/tmp/out", "ONE FILE")
    assert len(candidates) >= 2
    assert candidates[0][0] == "python3"
    assert candidates[0][1] == "-m"
    assert candidates[0][2] == "PyInstaller"
    # Verify exact name extraction without rstrip bug
    assert candidates[0][6] == "MyGame"
