"""
Tests for LocalServer HTTP preview serving.
"""

import urllib.request
from pathlib import Path
import pytest

from nvstudio.server import LocalServer
from nvstudio.workspace import WorkspaceManager


def test_local_server_startup_and_response(tmp_path):
    wm = WorkspaceManager(str(tmp_path))
    server = LocalServer(wm.root_path)
    url = server.start()

    try:
        assert url.startswith("http://127.0.0.1:")
        with urllib.request.urlopen(url) as resp:
            assert resp.status == 200
            content = resp.read().decode("utf-8")
            assert "Welcome to NV Studio" in content
    finally:
        server.stop()
