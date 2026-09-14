"""
Unit tests for OpenMS UI Components
"""

import pytest
import tkinter as tk
from openms.ui.theme_manager import ThemeManager
from openms.ui.highlighter import OpenMSHighlighter
from openms.ui.ai_copilot import AICopilot
from openms.config import THEMES


class TestOpenMSUI:

    def test_theme_manager_switch(self):
        tm = ThemeManager("VS Code Dark")
        assert tm.active_theme_name == "VS Code Dark"
        assert tm.theme["bg_main"] == "#1e1e1e"

        received = []
        tm.subscribe(lambda t: received.append(t["name"]))

        tm.set_theme("Monokai")
        assert tm.active_theme_name == "Monokai"
        assert received == ["Monokai"]

    def test_ai_copilot_responses(self):
        copilot = AICopilot.__new__(AICopilot)

        reply_box = copilot.respond("How do I create a box?")
        assert "box(" in reply_box

        reply_2d = copilot.respond("Tell me about boody_2D")
        assert "2D" in reply_2d or "boody_2D" in reply_2d

        reply_list = copilot.respond("list functions")
        assert "built-in functions" in reply_list

    def test_highlighter_regex_patterns(self):
        m_kw = OpenMSHighlighter.KEYWORD_PATTERN.search("if (x > 0):")
        assert m_kw is not None and m_kw.group(0) == "if"

        m_fn = OpenMSHighlighter.COREFUNC_PATTERN.search("boody_2D(game)")
        assert m_fn is not None and m_fn.group(0) == "boody_2D"

        m_num = OpenMSHighlighter.NUMBER_PATTERN.search("size = 125.5")
        assert m_num is not None and m_num.group(0) == "125.5"

        m_str = OpenMSHighlighter.STRING_PATTERN.search('title = "OpenMS App"')
        assert m_str is not None and m_str.group(0) == '"OpenMS App"'
