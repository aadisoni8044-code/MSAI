"""
Tests for UI components initialization and theme switching.
"""

import pytest
from nvstudio.ui.theme import get_theme
from nvstudio.ui.main_window import NVStudioApp


def test_theme_color_palette():
    dark = get_theme("dark")
    light = get_theme("light")

    assert dark["name"] == "dark"
    assert light["name"] == "light"
    assert dark["bg_main"] != light["bg_main"]


def test_nvstudio_app_instantiation():
    app = NVStudioApp(test_launch=True)
    assert app.winfo_exists()
    assert app.current_theme_name in ["dark", "light"]
    app.destroy()
