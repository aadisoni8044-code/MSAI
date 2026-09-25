"""Unit tests for ErrorAnalyzer, Database, PermissionManager, and Builders."""

import os
import tempfile
import pytest
from models.command_result import CommandResult
from models.project_info import ProjectInfo
from models.build_strategy import BuildStrategy, BuildAttempt
from models.settings import PermissionRequest, Settings
from app.error_analyzer.analyzer import ErrorAnalyzer
from database.build_history import BuildHistoryDB
from app.permission_manager.manager import PermissionManager
from builders import PyInstallerBuilder, NuitkaBuilder, cxFreezeBuilder


def test_error_analyzer():
    analyzer = ErrorAnalyzer()
    res = CommandResult(command=[], exit_code=1, stdout="", stderr="ModuleNotFoundError: No module named 'requests'", duration=1.0)
    analysis = analyzer.analyze(res, "PyInstaller")
    assert analysis["error_type"] == "MISSING_MODULE"
    assert analysis["missing_module"] == "requests"
    assert analysis["can_safe_fix"] is True
    assert analysis["suggested_fix"]["action"] == "INSTALL_PACKAGE"


def test_build_history_db():
    with tempfile.TemporaryDirectory() as tmpdir:
        db_file = os.path.join(tmpdir, "history.db")
        db = BuildHistoryDB(db_file)

        pinfo = ProjectInfo(project_path="/test/path", project_name="TestProj")
        db.save_project(pinfo)

        strat = BuildStrategy(builder_name="PyInstaller", mode="onefile")
        db.record_successful_strategy("/test/path", strat, "main.py")

        k_strat = db.get_successful_strategy("/test/path")
        assert k_strat is not None
        assert k_strat["builder_name"] == "PyInstaller"
        assert k_strat["mode"] == "onefile"


def test_permission_manager():
    perms = PermissionRequest(folder_access=True, execute_commands=True, install_packages=False)
    pm = PermissionManager(perms)
    assert pm.check_folder_access() is True
    assert pm.check_execute_commands() is True
    assert pm.check_install_packages() is False


def test_builder_command_generation():
    pinfo = ProjectInfo(
        project_path="/test/path",
        project_name="MyApp",
        selected_entry_point="app.py",
        is_onefile=True,
        is_gui=True
    )
    strat = BuildStrategy(builder_name="PyInstaller", mode="onefile", is_gui=True)

    pyi = PyInstallerBuilder()
    cmd = pyi.generate_command(pinfo, strat, "python3")
    assert "python3" in cmd
    assert "--onefile" in cmd
    assert "--noconsole" in cmd
    assert "MyApp" in cmd
