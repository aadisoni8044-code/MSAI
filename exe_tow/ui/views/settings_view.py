"""
exe/tow - Settings View
Configures Python interpreter paths, compiler engine preferences, default output folders,
theme options, and build defaults.
"""

import os
import sys
from PySide6.QtCore import Qt
from PySide6.QtWidgets import (
    QWidget, QVBoxLayout, QHBoxLayout, QLabel, QPushButton, QFrame,
    QLineEdit, QComboBox, QCheckBox, QFileDialog, QMessageBox
)
from exe_tow.ui.theme import ThemeColors

class SettingsView(QWidget):
    """Settings view for configuring exe/tow preferences."""

    def __init__(self, settings_manager, parent=None):
        super().__init__(parent)
        self.settings = settings_manager

        layout = QVBoxLayout(self)
        layout.setContentsMargins(32, 28, 32, 28)
        layout.setSpacing(20)

        # Title
        header = QLabel("Application Settings")
        header.setObjectName("TitleLabel")
        layout.addWidget(header)

        # 1. Environment & Engine
        env_panel = QFrame()
        env_panel.setObjectName("CardPanel")
        env_layout = QVBoxLayout(env_panel)
        env_layout.setContentsMargins(20, 20, 20, 20)
        env_layout.setSpacing(14)

        sec1 = QLabel("ENVIRONMENT & BUILD TOOL")
        sec1.setStyleSheet(f"color: {ThemeColors.TEXT_MUTED}; font-size: 10px; font-weight: 700; letter-spacing: 1px;")
        env_layout.addWidget(sec1)

        # Python Interpreter
        lbl_py = QLabel("Python Interpreter Path")
        lbl_py.setObjectName("SectionTitle")
        env_layout.addWidget(lbl_py)

        py_row = QHBoxLayout()
        self.input_py = QLineEdit()
        self.input_py.setText(self.settings.get("python_interpreter", sys.executable))

        btn_browse_py = QPushButton("📁 Browse")
        btn_browse_py.setCursor(Qt.PointingHandCursor)
        btn_browse_py.clicked.connect(self._browse_python)

        py_row.addWidget(self.input_py)
        py_row.addWidget(btn_browse_py)
        env_layout.addLayout(py_row)

        # Build Engine Picker
        lbl_eng = QLabel("Build Tool Engine")
        lbl_eng.setObjectName("SectionTitle")
        env_layout.addWidget(lbl_eng)

        self.combo_engine = QComboBox()
        self.combo_engine.addItems(["PyInstaller", "Nuitka", "cx_Freeze"])
        self.combo_engine.setCurrentText(self.settings.get("build_engine", "PyInstaller"))
        env_layout.addWidget(self.combo_engine)

        layout.addWidget(env_panel)

        # 2. Defaults & Paths
        path_panel = QFrame()
        path_panel.setObjectName("CardPanel")
        path_layout = QVBoxLayout(path_panel)
        path_layout.setContentsMargins(20, 20, 20, 20)
        path_layout.setSpacing(14)

        sec2 = QLabel("DEFAULT OUTPUT & THEME")
        sec2.setStyleSheet(f"color: {ThemeColors.TEXT_MUTED}; font-size: 10px; font-weight: 700; letter-spacing: 1px;")
        path_layout.addWidget(sec2)

        lbl_out = QLabel("Default Output Directory")
        lbl_out.setObjectName("SectionTitle")
        path_layout.addWidget(lbl_out)

        out_row = QHBoxLayout()
        self.input_out = QLineEdit()
        self.input_out.setText(self.settings.get("default_output_folder", os.path.abspath("dist")))

        btn_browse_out = QPushButton("📁 Browse")
        btn_browse_out.setCursor(Qt.PointingHandCursor)
        btn_browse_out.clicked.connect(self._browse_out)

        out_row.addWidget(self.input_out)
        out_row.addWidget(btn_browse_out)
        path_layout.addLayout(out_row)

        # Theme
        lbl_theme = QLabel("Appearance Theme")
        lbl_theme.setObjectName("SectionTitle")
        path_layout.addWidget(lbl_theme)

        self.combo_theme = QComboBox()
        self.combo_theme.addItems(["Dark Charcoal", "Deep Black Modern", "Slate Minimal"])
        self.combo_theme.setCurrentText(self.settings.get("theme", "Dark Charcoal"))
        path_layout.addWidget(self.combo_theme)

        layout.addWidget(path_panel)

        # Save Button
        btn_save = QPushButton("💾 Save Preferences")
        btn_save.setObjectName("PrimaryButton")
        btn_save.setCursor(Qt.PointingHandCursor)
        btn_save.clicked.connect(self._save_settings)
        layout.addWidget(btn_save)

        layout.addStretch()

    def _browse_python(self):
        path, _ = QFileDialog.getOpenFileName(self, "Select Python Executable")
        if path:
            self.input_py.setText(path)

    def _browse_out(self):
        folder = QFileDialog.getExistingDirectory(self, "Select Default Output Directory")
        if folder:
            self.input_out.setText(folder)

    def _save_settings(self):
        self.settings.set("python_interpreter", self.input_py.text().strip())
        self.settings.set("build_engine", self.combo_engine.currentText())
        self.settings.set("default_output_folder", self.input_out.text().strip())
        self.settings.set("theme", self.combo_theme.currentText())

        QMessageBox.information(self, "Settings Saved", "Your preferences have been saved successfully.")
