"""
Settings & Preferences dialog for PyCodeStudio.
"""

from typing import Any, Dict

from PyQt6.QtWidgets import (
    QCheckBox,
    QComboBox,
    QDialog,
    QFormLayout,
    QHBoxLayout,
    QLabel,
    QPushButton,
    QSpinBox,
    QVBoxLayout,
)


class SettingsDialog(QDialog):
    """Graphical dialog allowing user to configure application preferences."""

    def __init__(self, current_settings: Dict[str, Any], parent=None):
        super().__init__(parent)
        self.settings = dict(current_settings)

        self.setWindowTitle("Settings")
        self.setMinimumWidth(440)

        layout = QVBoxLayout(self)

        form = QFormLayout()
        form.setSpacing(12)

        # Theme
        self.combo_theme = QComboBox()
        self.combo_theme.addItems(["Dark", "Light"])
        theme_val = "Light" if self.settings.get("theme") == "light" else "Dark"
        self.combo_theme.setCurrentText(theme_val)

        # Font Family
        self.combo_font = QComboBox()
        self.combo_font.addItems(["Consolas", "Courier New", "Fira Code", "JetBrains Mono", "Monaco"])
        self.combo_font.setCurrentText(str(self.settings.get("font_family", "Consolas")))

        # Font Size
        self.spin_font_size = QSpinBox()
        self.spin_font_size.setRange(8, 36)
        self.spin_font_size.setValue(int(self.settings.get("font_size", 13)))

        # Tab Size
        self.spin_tab_size = QSpinBox()
        self.spin_tab_size.setRange(1, 8)
        self.spin_tab_size.setValue(int(self.settings.get("tab_size", 4)))

        # Word Wrap
        self.check_word_wrap = QCheckBox("Enable Word Wrap")
        self.check_word_wrap.setChecked(bool(self.settings.get("word_wrap", False)))

        # Auto Save
        self.check_auto_save = QCheckBox("Enable Auto Save")
        self.check_auto_save.setChecked(bool(self.settings.get("auto_save", False)))

        # Auto Save Delay
        self.spin_auto_save_delay = QSpinBox()
        self.spin_auto_save_delay.setRange(1, 60)
        self.spin_auto_save_delay.setSuffix(" sec")
        self.spin_auto_save_delay.setValue(int(self.settings.get("auto_save_delay", 5)))

        form.addRow(QLabel("Color Theme:"), self.combo_theme)
        form.addRow(QLabel("Font Family:"), self.combo_font)
        form.addRow(QLabel("Font Size:"), self.spin_font_size)
        form.addRow(QLabel("Tab Size:"), self.spin_tab_size)
        form.addRow(QLabel("Word Wrap:"), self.check_word_wrap)
        form.addRow(QLabel("Auto Save:"), self.check_auto_save)
        form.addRow(QLabel("Auto Save Delay:"), self.spin_auto_save_delay)

        layout.addLayout(form)

        # Dialog buttons
        btn_box = QHBoxLayout()
        btn_save = QPushButton("Save Settings")
        btn_save.clicked.connect(self._on_save)

        btn_cancel = QPushButton("Cancel")
        btn_cancel.clicked.connect(self.reject)

        btn_box.addStretch()
        btn_box.addWidget(btn_cancel)
        btn_box.addWidget(btn_save)

        layout.addLayout(btn_box)

    def _on_save(self) -> None:
        """Collects form inputs and accepts dialog."""
        self.settings["theme"] = self.combo_theme.currentText().lower()
        self.settings["font_family"] = self.combo_font.currentText()
        self.settings["font_size"] = self.spin_font_size.value()
        self.settings["tab_size"] = self.spin_tab_size.value()
        self.settings["word_wrap"] = self.check_word_wrap.isChecked()
        self.settings["auto_save"] = self.check_auto_save.isChecked()
        self.settings["auto_save_delay"] = self.spin_auto_save_delay.value()

        self.accept()

    def get_settings(self) -> Dict[str, Any]:
        """Returns updated settings dictionary."""
        return self.settings
