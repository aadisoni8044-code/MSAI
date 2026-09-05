"""NV Studio Interactive Settings Panel"""
from typing import List
from PyQt6.QtCore import pyqtSignal, Qt
from PyQt6.QtWidgets import (
    QCheckBox, QComboBox, QFormLayout, QGroupBox, QHBoxLayout, QLabel,
    QPushButton, QScrollArea, QSpinBox, QVBoxLayout, QWidget, QMessageBox
)

from nvstudio.core.config import config_manager


class SettingsPanel(QWidget):
    """Visual Settings Panel allowing modification of themes, editor settings, font, indentation, and shortcuts."""
    settings_updated = pyqtSignal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self.setObjectName("SettingsPanel")

        main_layout = QVBoxLayout(self)
        main_layout.setContentsMargins(0, 0, 0, 0)
        main_layout.setSpacing(0)

        # Header
        header = QLabel("SETTINGS")
        header.setObjectName("SidebarHeader")
        main_layout.addWidget(header)

        # Scrollable Area
        scroll = QScrollArea()
        scroll.setWidgetResizable(True)
        scroll.setStyleSheet("QScrollArea { border: none; }")

        scroll_content = QWidget()
        layout = QVBoxLayout(scroll_content)
        layout.setContentsMargins(10, 10, 10, 10)
        layout.setSpacing(12)

        # Editor Group
        editor_box = QGroupBox("Code Editor")
        editor_form = QFormLayout(editor_box)
        editor_form.setSpacing(8)

        # Font Family
        self.font_family_combo = QComboBox()
        self.font_family_combo.addItems([
            "Consolas, 'Courier New', monospace",
            "Fira Code, monospace",
            "Courier New, monospace",
            "Monospace"
        ])
        curr_ff = config_manager.get("editor.font_family", "Consolas, 'Courier New', monospace")
        idx = self.font_family_combo.findText(curr_ff)
        if idx != -1:
            self.font_family_combo.setCurrentIndex(idx)
        self.font_family_combo.currentTextChanged.connect(
            lambda v: config_manager.set("editor.font_family", v)
        )
        editor_form.addRow("Font Family:", self.font_family_combo)

        # Font Size
        self.font_size_spin = QSpinBox()
        self.font_size_spin.setRange(8, 36)
        self.font_size_spin.setValue(config_manager.get("editor.font_size", 13))
        self.font_size_spin.valueChanged.connect(
            lambda v: config_manager.set("editor.font_size", v)
        )
        editor_form.addRow("Font Size:", self.font_size_spin)

        # Tab Size
        self.tab_size_spin = QSpinBox()
        self.tab_size_spin.setRange(2, 8)
        self.tab_size_spin.setValue(config_manager.get("editor.tab_size", 4))
        self.tab_size_spin.valueChanged.connect(
            lambda v: config_manager.set("editor.tab_size", v)
        )
        editor_form.addRow("Tab Size:", self.tab_size_spin)

        # Word Wrap
        self.word_wrap_cb = QCheckBox("Enable Word Wrap")
        self.word_wrap_cb.setChecked(config_manager.get("editor.word_wrap", True))
        self.word_wrap_cb.toggled.connect(
            lambda v: config_manager.set("editor.word_wrap", v)
        )
        editor_form.addRow(self.word_wrap_cb)

        # Line Highlight
        self.highlight_line_cb = QCheckBox("Highlight Active Line")
        self.highlight_line_cb.setChecked(config_manager.get("editor.highlight_active_line", True))
        self.highlight_line_cb.toggled.connect(
            lambda v: config_manager.set("editor.highlight_active_line", v)
        )
        editor_form.addRow(self.highlight_line_cb)

        # Auto Close Brackets
        self.auto_close_cb = QCheckBox("Auto-close Brackets")
        self.auto_close_cb.setChecked(config_manager.get("editor.auto_close_brackets", True))
        self.auto_close_cb.toggled.connect(
            lambda v: config_manager.set("editor.auto_close_brackets", v)
        )
        editor_form.addRow(self.auto_close_cb)

        layout.addWidget(editor_box)

        # Theme Group
        theme_box = QGroupBox("Theme & Branding")
        theme_form = QFormLayout(theme_box)

        self.theme_combo = QComboBox()
        self.theme_combo.addItems(["NV Dark", "NV Deep Slate", "NV Midnight Blue"])
        self.theme_combo.currentTextChanged.connect(
            lambda v: config_manager.set("theme", v)
        )
        theme_form.addRow("Color Theme:", self.theme_combo)

        layout.addWidget(theme_box)

        # Keyboard Shortcuts cheat sheet
        shortcuts_box = QGroupBox("Keyboard Shortcuts")
        shortcuts_layout = QVBoxLayout(shortcuts_box)
        sc_info = (
            "• Ctrl+N : New File\n"
            "• Ctrl+O : Open Folder\n"
            "• Ctrl+S : Save File\n"
            "• Ctrl+Shift+S : Save As\n"
            "• Ctrl+F : Find in Editor\n"
            "• Ctrl+Shift+F : Search Workspace\n"
            "• Ctrl+` : Toggle Terminal\n"
            "• Ctrl+= / Ctrl+- : Zoom In/Out"
        )
        sc_lbl = QLabel(sc_info)
        sc_lbl.setStyleSheet("color: #94a3b8; font-size: 11px;")
        shortcuts_layout.addWidget(sc_lbl)

        layout.addWidget(shortcuts_box)
        layout.addStretch()

        scroll.setWidget(scroll_content)
        main_layout.addWidget(scroll)
