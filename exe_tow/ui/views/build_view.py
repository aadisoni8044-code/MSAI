import os
from PySide6.QtWidgets import (
    QWidget, QVBoxLayout, QHBoxLayout, QLabel, QPushButton, QLineEdit, QCheckBox, QRadioButton, QFrame, QFileDialog, QScrollArea, QButtonGroup
)
from PySide6.QtCore import Qt, Signal

class BuildView(QWidget):
    """Build Configuration View for adjusting output parameters, application name, and PyInstaller build options."""

    start_build_clicked = Signal(dict) # Emits build configuration dict

    def __init__(self, parent=None):
        super().__init__(parent)
        self.project_data = {}

        scroll = QScrollArea(self)
        scroll.setWidgetResizable(True)
        scroll.setStyleSheet("QScrollArea { border: none; background: transparent; }")

        content_widget = QWidget()
        layout = QVBoxLayout(content_widget)
        layout.setContentsMargins(24, 20, 24, 20)
        layout.setSpacing(18)

        # Large Title
        title_lbl = QLabel("BUILD EXE")
        title_lbl.setStyleSheet("font-size: 22px; font-weight: 800; color: #FFFFFF; letter-spacing: 1px;")
        layout.addWidget(title_lbl)

        # Project Summary Card
        summary_card = QFrame()
        summary_card.setStyleSheet("""
            QFrame {
                background-color: #12141A;
                border: 1px solid #1E222D;
                border-radius: 8px;
                padding: 16px;
            }
        """)
        summary_layout = QVBoxLayout(summary_card)
        summary_layout.setSpacing(10)

        summary_title = QLabel("PROJECT SUMMARY")
        summary_title.setStyleSheet("font-size: 11px; font-weight: 800; color: #8A8F9E; letter-spacing: 1px;")
        summary_layout.addWidget(summary_title)

        grid_layout = QHBoxLayout()
        grid_layout.setSpacing(12)

        self.val_proj = self._create_info_item("PROJECT", "MyPythonApp", grid_layout)
        self.val_entry = self._create_info_item("ENTRY FILE", "main.py", grid_layout)
        self.val_files = self._create_info_item("FILES", "27", grid_layout)
        self.val_deps = self._create_info_item("DEPENDENCIES", "8", grid_layout)
        self.val_assets = self._create_info_item("ASSETS", "14", grid_layout)

        summary_layout.addLayout(grid_layout)
        layout.addWidget(summary_card)

        # BUILD CONFIGURATION Section
        config_card = QFrame()
        config_card.setStyleSheet("""
            QFrame {
                background-color: #12141A;
                border: 1px solid #1E222D;
                border-radius: 8px;
                padding: 16px;
            }
        """)
        config_layout = QVBoxLayout(config_card)
        config_layout.setSpacing(12)

        config_title = QLabel("BUILD CONFIGURATION")
        config_title.setStyleSheet("font-size: 12px; font-weight: 800; color: #00FF66; letter-spacing: 1px;")
        config_layout.addWidget(config_title)

        # Application Name
        app_name_layout = QVBoxLayout()
        app_name_layout.setSpacing(4)
        lbl_app_name = QLabel("Application Name")
        lbl_app_name.setStyleSheet("font-size: 12px; color: #C5C9D6; font-weight: 600;")
        self.txt_app_name = QLineEdit("MyPythonApp")
        self.txt_app_name.textChanged.connect(self._on_app_name_changed)
        app_name_layout.addWidget(lbl_app_name)
        app_name_layout.addWidget(self.txt_app_name)
        config_layout.addLayout(app_name_layout)

        # EXE Filename
        exe_name_layout = QVBoxLayout()
        exe_name_layout.setSpacing(4)
        lbl_exe_name = QLabel("EXE Filename")
        lbl_exe_name.setStyleSheet("font-size: 12px; color: #C5C9D6; font-weight: 600;")
        self.txt_exe_filename = QLineEdit("MyPythonApp.exe")
        exe_name_layout.addWidget(lbl_exe_name)
        exe_name_layout.addWidget(self.txt_exe_filename)
        config_layout.addLayout(exe_name_layout)

        # Output Directory
        out_dir_layout = QVBoxLayout()
        out_dir_layout.setSpacing(4)
        lbl_out_dir = QLabel("Output Directory")
        lbl_out_dir.setStyleSheet("font-size: 12px; color: #C5C9D6; font-weight: 600;")

        out_bar = QHBoxLayout()
        out_bar.setSpacing(8)
        self.txt_out_dir = QLineEdit(os.path.abspath("dist"))
        browse_btn = QPushButton("BROWSE")
        browse_btn.setStyleSheet("""
            QPushButton {
                background-color: #1A1D26;
                color: #00E5FF;
                border: 1px solid #00E5FF;
                border-radius: 6px;
                padding: 8px 16px;
                font-weight: bold;
            }
            QPushButton:hover {
                background-color: #232836;
            }
        """)
        browse_btn.clicked.connect(self.browse_output_dir)
        out_bar.addWidget(self.txt_out_dir)
        out_bar.addWidget(browse_btn)

        out_dir_layout.addWidget(lbl_out_dir)
        out_dir_layout.addLayout(out_bar)
        config_layout.addLayout(out_dir_layout)

        layout.addWidget(config_card)

        # BUILD OPTIONS Section
        options_card = QFrame()
        options_card.setStyleSheet("""
            QFrame {
                background-color: #12141A;
                border: 1px solid #1E222D;
                border-radius: 8px;
                padding: 16px;
            }
        """)
        options_layout = QVBoxLayout(options_card)
        options_layout.setSpacing(12)

        options_title = QLabel("BUILD OPTIONS")
        options_title.setStyleSheet("font-size: 12px; font-weight: 800; color: #00FF66; letter-spacing: 1px;")
        options_layout.addWidget(options_title)

        # Checkboxes
        self.cb_onefile = QCheckBox("One-file EXE (Package everything into a single .exe)")
        self.cb_onefile.setChecked(True)

        self.cb_assets = QCheckBox("Include project assets")
        self.cb_assets.setChecked(True)

        self.cb_deps = QCheckBox("Automatically detect dependencies")
        self.cb_deps.setChecked(True)

        options_layout.addWidget(self.cb_onefile)
        options_layout.addWidget(self.cb_assets)
        options_layout.addWidget(self.cb_deps)

        # Divider
        div = QFrame()
        div.setFrameShape(QFrame.HLine)
        div.setStyleSheet("color: #1E222D; background: #1E222D; border: none; height: 1px;")
        options_layout.addWidget(div)

        # Window Mode Radio Group
        self.radio_group = QButtonGroup(self)
        self.radio_windowed = QRadioButton("Windowed Application (Hide CLI console window)")
        self.radio_windowed.setChecked(True)

        self.radio_console = QRadioButton("Console Application (Show CLI terminal window)")

        self.radio_group.addButton(self.radio_windowed)
        self.radio_group.addButton(self.radio_console)

        options_layout.addWidget(self.radio_windowed)
        options_layout.addWidget(self.radio_console)

        layout.addWidget(options_card)

        # Primary Action Button
        btn_build = QPushButton("> BUILD EXE")
        btn_build.setProperty("class", "btnPrimary")
        btn_build.setStyleSheet("""
            QPushButton {
                background-color: #00FF66;
                color: #090A0D;
                border: 1px solid #00FF66;
                border-radius: 6px;
                padding: 12px 24px;
                font-weight: 900;
                font-size: 15px;
                letter-spacing: 1px;
            }
            QPushButton:hover {
                background-color: #33FF85;
            }
        """)
        btn_build.clicked.connect(self.on_start_build)
        layout.addWidget(btn_build)

        layout.addStretch()

        scroll.setWidget(content_widget)

        main_layout = QVBoxLayout(self)
        main_layout.setContentsMargins(0, 0, 0, 0)
        main_layout.addWidget(scroll)

    def _create_info_item(self, label: str, val: str, parent_layout) -> QLabel:
        box = QVBoxLayout()
        box.setSpacing(2)

        lbl = QLabel(label)
        lbl.setStyleSheet("font-size: 10px; font-weight: 800; color: #8A8F9E;")

        v_lbl = QLabel(val)
        v_lbl.setStyleSheet("font-size: 14px; font-weight: 800; color: #00FF66; font-family: Consolas, monospace;")

        box.addWidget(lbl)
        box.addWidget(v_lbl)

        container = QFrame()
        container.setLayout(box)
        container.setStyleSheet("background-color: #0A0C10; border: 1px solid #1C202C; border-radius: 6px; padding: 6px;")
        parent_layout.addWidget(container)
        return v_lbl

    def load_project_data(self, scan_data: dict):
        self.project_data = scan_data
        proj_name = scan_data.get("project_name", "MyPythonApp")
        entry_file = scan_data.get("entry_file", "main.py")
        files_cnt = str(scan_data.get("py_files_count", 27))
        dep_cnt = str(scan_data.get("dep_count", 8))
        asset_cnt = str(scan_data.get("asset_files_count", 14))

        self.val_proj.setText(proj_name)
        self.val_entry.setText(entry_file)
        self.val_files.setText(files_cnt)
        self.val_deps.setText(dep_cnt)
        self.val_assets.setText(asset_cnt)

        self.txt_app_name.setText(proj_name)
        self.txt_exe_filename.setText(f"{proj_name}.exe")

        proj_path = scan_data.get("path", ".")
        self.txt_out_dir.setText(os.path.join(proj_path, "dist"))

    def _on_app_name_changed(self, text: str):
        if text:
            self.txt_exe_filename.setText(f"{text}.exe")

    def browse_output_dir(self):
        dir_path = QFileDialog.getExistingDirectory(self, "Select Output Directory", self.txt_out_dir.text())
        if dir_path:
            self.txt_out_dir.setText(dir_path)

    def on_start_build(self):
        config = {
            "project_dir": self.project_data.get("path", "."),
            "entry_file": self.project_data.get("entry_file", "main.py"),
            "app_name": self.txt_app_name.text() or "MyPythonApp",
            "exe_filename": self.txt_exe_filename.text() or "MyPythonApp.exe",
            "output_dir": self.txt_out_dir.text() or os.path.abspath("dist"),
            "one_file": self.cb_onefile.isChecked(),
            "include_assets": self.cb_assets.isChecked(),
            "auto_dependencies": self.cb_deps.isChecked(),
            "windowed_mode": self.radio_windowed.isChecked(),
            "asset_files": self.project_data.get("asset_files", [])
        }
        self.start_build_clicked.emit(config)
