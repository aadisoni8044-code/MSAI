import os
import sys
from PySide6.QtWidgets import (
    QWidget, QVBoxLayout, QHBoxLayout, QLabel, QPushButton, QLineEdit, QCheckBox, QComboBox, QFrame, QFileDialog, QScrollArea
)
from PySide6.QtCore import Qt

class SettingsView(QWidget):
    """Settings Configuration View managing interpreter paths, default build options, and visual theme."""

    def __init__(self, storage_manager, parent=None):
        super().__init__(parent)
        self.storage = storage_manager

        scroll = QScrollArea(self)
        scroll.setWidgetResizable(True)
        scroll.setStyleSheet("QScrollArea { border: none; background: transparent; }")

        content_widget = QWidget()
        layout = QVBoxLayout(content_widget)
        layout.setContentsMargins(24, 20, 24, 20)
        layout.setSpacing(18)

        # Title
        title_lbl = QLabel("SETTINGS")
        title_lbl.setStyleSheet("font-size: 22px; font-weight: 800; color: #FFFFFF; letter-spacing: 1px;")
        layout.addWidget(title_lbl)

        # 1. PYTHON INTERPRETER SECTION
        py_card = self._create_section_card("PYTHON INTERPRETER", layout)
        py_layout = py_card.layout()

        lbl_py_path = QLabel("Python Executable Path")
        lbl_py_path.setStyleSheet("font-size: 12px; color: #C5C9D6; font-weight: 600;")
        py_layout.addWidget(lbl_py_path)

        py_bar = QHBoxLayout()
        py_bar.setSpacing(8)
        self.txt_py_path = QLineEdit(self.storage.settings.get("python_interpreter", sys.executable))
        btn_py_browse = QPushButton("BROWSE")
        btn_py_browse.setStyleSheet(self._btn_style_cyan())
        btn_py_browse.clicked.connect(self.browse_python_exe)

        btn_py_auto = QPushButton("AUTO DETECT")
        btn_py_auto.setStyleSheet(self._btn_style_green())
        btn_py_auto.clicked.connect(self.auto_detect_python)

        py_bar.addWidget(self.txt_py_path, stretch=3)
        py_bar.addWidget(btn_py_browse)
        py_bar.addWidget(btn_py_auto)
        py_layout.addLayout(py_bar)

        py_ver_str = f"Python {sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro} Detected"
        lbl_ver = QLabel(f"● Status: {py_ver_str}")
        lbl_ver.setStyleSheet("font-size: 11px; color: #00FF66; font-weight: bold;")
        py_layout.addWidget(lbl_ver)

        # 2. BUILD ENGINE SECTION
        eng_card = self._create_section_card("BUILD ENGINE", layout)
        eng_layout = eng_card.layout()

        lbl_eng = QLabel("Build Engine Backend")
        lbl_eng.setStyleSheet("font-size: 12px; color: #C5C9D6; font-weight: 600;")
        eng_layout.addWidget(lbl_eng)

        self.combo_engine = QComboBox()
        self.combo_engine.addItems(["PyInstaller (Automatic)", "PyInstaller (Custom Spec)", "Nuitka (Experimental)"])
        eng_layout.addWidget(self.combo_engine)

        lbl_out = QLabel("Default Output Directory")
        lbl_out.setStyleSheet("font-size: 12px; color: #C5C9D6; font-weight: 600;")
        eng_layout.addWidget(lbl_out)

        out_bar = QHBoxLayout()
        self.txt_default_out = QLineEdit(self.storage.settings.get("default_output_dir", os.path.abspath("dist")))
        btn_out_browse = QPushButton("BROWSE")
        btn_out_browse.setStyleSheet(self._btn_style_cyan())
        btn_out_browse.clicked.connect(self.browse_output_dir)
        out_bar.addWidget(self.txt_default_out, stretch=3)
        out_bar.addWidget(btn_out_browse)
        eng_layout.addLayout(out_bar)

        # 3. BUILD DEFAULTS SECTION
        defaults_card = self._create_section_card("BUILD DEFAULTS", layout)
        def_layout = defaults_card.layout()

        self.cb_onefile = QCheckBox("One-file EXE (Default)")
        self.cb_onefile.setChecked(self.storage.settings.get("one_file", True))

        self.cb_deps = QCheckBox("Auto dependency detection (Default)")
        self.cb_deps.setChecked(self.storage.settings.get("auto_dependencies", True))

        self.cb_assets = QCheckBox("Include project assets (Default)")
        self.cb_assets.setChecked(self.storage.settings.get("include_assets", True))

        def_layout.addWidget(self.cb_onefile)
        def_layout.addWidget(self.cb_deps)
        def_layout.addWidget(self.cb_assets)

        # 4. APPEARANCE SECTION
        app_card = self._create_section_card("APPEARANCE", layout)
        app_layout = app_card.layout()

        lbl_theme = QLabel("Theme")
        lbl_theme.setStyleSheet("font-size: 12px; color: #C5C9D6; font-weight: 600;")
        app_layout.addWidget(lbl_theme)

        combo_theme = QComboBox()
        combo_theme.addItems(["Dark Hacker (Terminal Green)", "Cyberpunk Blue", "Stealth Charcoal"])
        app_layout.addWidget(combo_theme)

        lbl_font = QLabel("Terminal Font")
        lbl_font.setStyleSheet("font-size: 12px; color: #C5C9D6; font-weight: 600;")
        app_layout.addWidget(lbl_font)

        combo_font = QComboBox()
        combo_font.addItems(["JetBrains Mono / Consolas", "Cascadia Code", "Courier New"])
        app_layout.addWidget(combo_font)

        self.cb_anim = QCheckBox("Enable UI Micro-Animations")
        self.cb_anim.setChecked(self.storage.settings.get("animations_enabled", True))
        app_layout.addWidget(self.cb_anim)

        # Save Button
        btn_save = QPushButton("SAVE SETTINGS")
        btn_save.setStyleSheet("""
            QPushButton {
                background-color: #00FF66;
                color: #090A0D;
                border: 1px solid #00FF66;
                border-radius: 6px;
                padding: 12px 24px;
                font-weight: 900;
                font-size: 14px;
            }
            QPushButton:hover { background-color: #33FF85; }
        """)
        btn_save.clicked.connect(self.save_settings)
        layout.addWidget(btn_save)

        layout.addStretch()

        scroll.setWidget(content_widget)

        main_layout = QVBoxLayout(self)
        main_layout.setContentsMargins(0, 0, 0, 0)
        main_layout.addWidget(scroll)

    def _create_section_card(self, title: str, parent_layout) -> QFrame:
        card = QFrame()
        card.setStyleSheet("""
            QFrame {
                background-color: #12141A;
                border: 1px solid #1E222D;
                border-radius: 8px;
                padding: 16px;
            }
        """)
        c_layout = QVBoxLayout(card)
        c_layout.setSpacing(10)

        t_lbl = QLabel(title)
        t_lbl.setStyleSheet("font-size: 12px; font-weight: 800; color: #00FF66; letter-spacing: 1px;")
        c_layout.addWidget(t_lbl)

        parent_layout.addWidget(card)
        return card

    def _btn_style_cyan(self) -> str:
        return """
            QPushButton {
                background-color: #1A1D26;
                color: #00E5FF;
                border: 1px solid #00E5FF;
                border-radius: 6px;
                padding: 8px 14px;
                font-weight: bold;
            }
            QPushButton:hover { background-color: #232836; }
        """

    def _btn_style_green(self) -> str:
        return """
            QPushButton {
                background-color: #1A1D26;
                color: #00FF66;
                border: 1px solid #00FF66;
                border-radius: 6px;
                padding: 8px 14px;
                font-weight: bold;
            }
            QPushButton:hover { background-color: #00FF66; color: #090A0D; }
        """

    def browse_python_exe(self):
        f, _ = QFileDialog.getOpenFileName(self, "Select Python Executable", "", "Executables (*.exe python*)")
        if f:
            self.txt_py_path.setText(f)

    def auto_detect_python(self):
        self.txt_py_path.setText(sys.executable)

    def browse_output_dir(self):
        d = QFileDialog.getExistingDirectory(self, "Select Default Output Directory", self.txt_default_out.text())
        if d:
            self.txt_default_out.setText(d)

    def save_settings(self):
        new_s = {
            "python_interpreter": self.txt_py_path.text(),
            "default_output_dir": self.txt_default_out.text(),
            "one_file": self.cb_onefile.isChecked(),
            "auto_dependencies": self.cb_deps.isChecked(),
            "include_assets": self.cb_assets.isChecked(),
            "animations_enabled": self.cb_anim.isChecked()
        }
        self.storage.update_settings(new_s)
