import os
import tempfile
import shutil
import pytest
from exe_tow.core.storage import StorageManager

def test_storage_manager_initialization():
    temp_dir = tempfile.mkdtemp()
    try:
        sm = StorageManager(storage_dir=temp_dir)
        assert sm.settings is not None
        assert isinstance(sm.projects, list)
        assert isinstance(sm.history, list)
        assert os.path.exists(os.path.join(temp_dir, "data.json"))
    finally:
        shutil.rmtree(temp_dir)

def test_storage_add_and_get_stats():
    temp_dir = tempfile.mkdtemp()
    try:
        sm = StorageManager(storage_dir=temp_dir)
        sm.projects.clear()
        sm.history.clear()

        sm.add_project({
            "name": "TestApp",
            "path": "/tmp/testapp",
            "entry_file": "main.py",
            "status": "BUILT"
        })

        sm.add_history_record({
            "date": "2026-09-30 12:00",
            "project": "TestApp",
            "result": "SUCCESS"
        })

        stats = sm.get_stats()
        assert stats["projects_count"] == 1
        assert stats["success_count"] == 1
        assert stats["failed_count"] == 0
        assert stats["last_build"] == "2026-09-30 12:00"
    finally:
        shutil.rmtree(temp_dir)

def test_storage_update_settings():
    temp_dir = tempfile.mkdtemp()
    try:
        sm = StorageManager(storage_dir=temp_dir)
        sm.update_settings({"theme": "Cyberpunk Blue"})

        # Reload
        sm2 = StorageManager(storage_dir=temp_dir)
        assert sm2.settings.get("theme") == "Cyberpunk Blue"
    finally:
        shutil.rmtree(temp_dir)
