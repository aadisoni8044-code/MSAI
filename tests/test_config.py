"""
Tests for ConfigManager and Workspace State persistence.
"""

import os
from pathlib import Path
import pytest

from nvstudio.config import ConfigManager, DEFAULT_SETTINGS


def test_config_defaults(tmp_path):
    cm = ConfigManager()
    assert cm.get("auto_save") is True
    assert cm.get("preview_device") in ["mobile", "ipad", "laptop"]


def test_config_set_get(tmp_path):
    cm = ConfigManager()
    cm.set("theme", "light")
    assert cm.get("theme") == "light"

    cm.set("theme", "dark")
    assert cm.get("theme") == "dark"


def test_workspace_state_save_and_load(tmp_path):
    cm = ConfigManager()
    cm.save_workspace_state(
        project_path=str(tmp_path),
        open_files=["index.html", "style.css"],
        active_file="index.html",
        preview_device="ipad",
    )

    state = cm.load_workspace_state()
    assert state["project_path"] == str(tmp_path)
    assert state["open_files"] == ["index.html", "style.css"]
    assert state["active_file"] == "index.html"
    assert state["preview_device"] == "ipad"
