"""
Headless Unit tests for OpenMS UI Components
"""

import pytest
import tkinter as tk
from openms.ui.theme_manager import ThemeManager
from openms.ui.main_window import OpenMSIDE
from openms.config import THEMES


@pytest.fixture
def tk_root():
    root = tk.Tk()
    root.withdraw()
    yield root
    root.destroy()


def test_theme_manager():
    tm = ThemeManager("dark_plus")
    assert tm.active_theme_name == "dark_plus"
    assert tm.get("bg_main") == "#1e1e1e"

    notifications = []
    tm.register(lambda t: notifications.append(t["name"]))

    tm.set_theme("monokai")
    assert tm.active_theme_name == "monokai"
    assert len(notifications) == 1
    assert notifications[0] == "Monokai Pro"


def test_main_window_init(tk_root):
    app = OpenMSIDE(tk_root)
    assert app.root == tk_root
    assert app.theme_manager.active_theme_name == "dark_plus"
    assert app.editor_panel is not None
    assert app.terminal_panel is not None
    assert app.status_bar is not None


def test_main_window_code_execution(tk_root):
    app = OpenMSIDE(tk_root)
    app.editor_panel.set_active_code("a = box(80)\nmachine(a)")
    app.run_code()
    assert "Execution Finished Successfully" in app.status_bar.status_text


def test_ai_copilot_response(tk_root):
    app = OpenMSIDE(tk_root)
    reply = app.ai_panel.ai_respond("Tell me about box")
    assert "box" in reply
    assert "size" in reply.lower() or "box" in reply.lower()


def test_editor_tab_closing(tk_root):
    app = OpenMSIDE(tk_root)
    app.editor_panel.open_tab("tab2.game")
    assert len(app.editor_panel.tabs) == 2
    app.editor_panel.close_tab("tab2.game")
    assert len(app.editor_panel.tabs) == 1
