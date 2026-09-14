import sys
import tempfile
import pathlib
import pytest
from PyQt6.QtWidgets import QApplication

import tests.test_nvstudio as t

def test_all_nvstudio():
    app = QApplication.instance()
    if app is None:
        app = QApplication(sys.argv)
    with tempfile.TemporaryDirectory() as tmp_str:
        tmp = pathlib.Path(tmp_str)
        t.test_config_manager(tmp)
        t.test_workspace_manager(tmp)
        t.test_editor_and_workspace(app, tmp)
        t.test_file_explorer(app, tmp)
        t.test_live_preview_device(app)
        t.test_main_window_integration(app, tmp)
