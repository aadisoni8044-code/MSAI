"""
MSAI Studio - Settings View Component
"""
from PyQt6.QtWidgets import (
    QWidget, QVBoxLayout, QHBoxLayout, QLabel, QComboBox, QSpinBox,
    QCheckBox, QLineEdit, QPushButton, QFormLayout, QGroupBox, QScrollArea
)
from PyQt6.QtCore import pyqtSignal
from config import ConfigManager

class SettingsView(QWidget):
    """
    Settings interface allowing configuration of themes, font size, font family,
    editor word wrap, tab size, line numbers, and Python interpreter path.
    """
    settings_changed = pyqtSignal(dict)

    def __init__(self, config_manager: ConfigManager, parent=None):
        super().__init__(parent)
        self.config_manager = config_manager

        main_layout = QVBoxLayout(self)
        main_layout.setContentsMargins(12, 12, 12, 12)

        title = QLabel("SETTINGS")
        title.setStyleSheet("font-size: 14px; font-weight: bold; color: #89b4fa;")
        main_layout.addWidget(title)

        scroll = QScrollArea()
        scroll.setWidgetResizable(True)
        container = QWidget()
        form_layout = QFormLayout(container)
        form_layout.setSpacing(12)

        # 1. Theme
        self.combo_theme = QComboBox()
        self.combo_theme.addItems(["MSAI Dark", "MSAI Light"])
        self.combo_theme.setCurrentText(self.config_manager.get("theme", "MSAI Dark"))
        form_layout.addRow("Color Theme:", self.combo_theme)

        # 2. Font Size
        self.spin_font_size = QSpinBox()
        self.spin_font_size.setRange(8, 32)
        self.spin_font_size.setValue(self.config_manager.get("font_size", 13))
        form_layout.addRow("Editor Font Size:", self.spin_font_size)

        # 3. Tab Size
        self.spin_tab_size = QSpinBox()
        self.spin_tab_size.setRange(2, 8)
        self.spin_tab_size.setValue(self.config_manager.get("tab_size", 4))
        form_layout.addRow("Tab Size:", self.spin_tab_size)

        # 4. Word Wrap
        self.check_word_wrap = QCheckBox("Enable Word Wrap")
        self.check_word_wrap.setChecked(self.config_manager.get("word_wrap", False))
        form_layout.addRow("Word Wrap:", self.check_word_wrap)

        # 5. Line Numbers
        self.check_line_numbers = QCheckBox("Show Line Numbers")
        self.check_line_numbers.setChecked(self.config_manager.get("line_numbers", True))
        form_layout.addRow("Line Numbers:", self.check_line_numbers)

        # 6. Python Interpreter Path
        self.input_interpreter = QLineEdit(self.config_manager.get("python_interpreter", ""))
        form_layout.addRow("Python Interpreter Path:", self.input_interpreter)

        # 7. AI API Key
        self.input_api_key = QLineEdit(self.config_manager.get("ai_api_key", ""))
        self.input_api_key.setEchoMode(QLineEdit.EchoMode.Password)
        form_layout.addRow("AI API Key (Gemini):", self.input_api_key)

        scroll.setWidget(container)
        main_layout.addWidget(scroll)

        # Save Settings Button
        self.btn_save = QPushButton("Save Settings")
        self.btn_save.setStyleSheet("background-color: #89b4fa; color: #11111b; font-weight: bold; padding: 8px;")
        self.btn_save.clicked.connect(self._save_settings)
        main_layout.addWidget(self.btn_save)

    def _save_settings(self):
        new_settings = {
            "theme": self.combo_theme.currentText(),
            "font_size": self.spin_font_size.value(),
            "tab_size": self.spin_tab_size.value(),
            "word_wrap": self.check_word_wrap.isChecked(),
            "line_numbers": self.check_line_numbers.isChecked(),
            "python_interpreter": self.input_interpreter.text().strip(),
            "ai_api_key": self.input_api_key.text().strip()
        }

        for k, v in new_settings.items():
            self.config_manager.set(k, v)

        self.settings_changed.emit(new_settings)
