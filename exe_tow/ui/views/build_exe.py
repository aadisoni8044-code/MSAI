import os
from PySide6.QtWidgets import (
    QWidget, QVBoxLayout, QHBoxLayout, QLabel, QLineEdit, QPushButton,
    QFrame, QGridLayout, QComboBox, QCheckBox, QFileDialog, QScrollArea
)
from PySide6.QtCore import Qt, Signal
from PySide6.QtGui import QFont, QCursor
from exe_tow.ui.components import CheckItem
from exe_tow.core.scanner import scan_project_folder

class BuildExeView(QWidget):
    start_build_requested = Signal(dict)

    def __init__(self, storage_mgr, parent=None):
        super().__init__(parent)
        self.storage_mgr = storage_mgr
        self.scan_data = {}

        # Scroll Area for clean overflow handling
        scroll = QScrollArea(self)
        scroll.setWidgetResizable(True)
        scroll.setStyleSheet("QScrollArea { border: none; background: transparent; }")

        content_widget = QWidget()
        scroll.setWidget(content_widget)

        main_layout = QVBoxLayout(self)
        main_layout.setContentsMargins(0, 0, 0, 0)
        main_layout.addWidget(scroll)

        layout = QVBoxLayout(content_widget)
        layout.setContentsMargins(28, 28, 28, 28)
        layout.setSpacing(20)

        # Page Title
        lbl_title = QLabel("Build Executable")
        lbl_title.setFont(QFont("Segoe UI", 18, QFont.Bold))
        lbl_title.setStyleSheet("color: #FFFFFF;")
        layout.addWidget(lbl_title)

        # 1. Project Folder Selection Card
        folder_card = QFrame()
        folder_card.setStyleSheet("""
            QFrame {
                background-color: #12141C;
                border: 1px solid #202433;
                border-radius: 10px;
                padding: 16px;
            }
        """)
        f_layout = QVBoxLayout(folder_card)
        f_layout.setSpacing(10)

        f_hdr = QLabel("Project Folder")
        f_hdr.setFont(QFont("Segoe UI", 11, QFont.Bold))
        f_hdr.setStyleSheet("color: #F8FAFC;")

        f_input_layout = QHBoxLayout()
        self.txt_folder = QLineEdit()
        self.txt_folder.setPlaceholderText("Select your Python project folder...")
        self.txt_folder.setReadOnly(True)
        self.txt_folder.setFixedHeight(40)

        btn_browse = QPushButton("📁 Browse")
        btn_browse.setFixedHeight(40)
        btn_browse.setCursor(QCursor(Qt.PointingHandCursor))
        btn_browse.setStyleSheet("""
            QPushButton {
                background-color: #1E2333;
                color: #FFFFFF;
                border: 1px solid #2B3147;
                border-radius: 6px;
                padding: 0 18px;
                font-weight: bold;
            }
            QPushButton:hover {
                background-color: #262C40;
                border-color: #3B82F6;
            }
        """)
        btn_browse.clicked.connect(self.browse_folder)

        f_input_layout.addWidget(self.txt_folder)
        f_input_layout.addWidget(btn_browse)

        f_layout.addWidget(f_hdr)
        f_layout.addLayout(f_input_layout)
        layout.addWidget(folder_card)

        # 2. Automated Detection Card
        self.scan_card = QFrame()
        self.scan_card.setStyleSheet("""
            QFrame {
                background-color: #12141C;
                border: 1px solid #202433;
                border-radius: 10px;
                padding: 16px;
            }
        """)
        scan_layout = QGridLayout(self.scan_card)
        scan_layout.setSpacing(12)

        self.chk_python = CheckItem("Python detected", False)
        self.chk_main = CheckItem("Main file detected", False)
        self.chk_files = CheckItem("Project files detected", False)
        self.chk_deps = CheckItem("Dependencies detected", False)

        scan_layout.addWidget(self.chk_python, 0, 0)
        scan_layout.addWidget(self.chk_main, 0, 1)
        scan_layout.addWidget(self.chk_files, 1, 0)
        scan_layout.addWidget(self.chk_deps, 1, 1)

        layout.addWidget(self.scan_card)

        # 3. Main File & Output Location Card
        entry_card = QFrame()
        entry_card.setStyleSheet("""
            QFrame {
                background-color: #12141C;
                border: 1px solid #202433;
                border-radius: 10px;
                padding: 16px;
            }
        """)
        e_layout = QVBoxLayout(entry_card)
        e_layout.setSpacing(14)

        # Main File Row
        main_hdr = QLabel("MAIN FILE")
        main_hdr.setFont(QFont("Segoe UI", 9, QFont.Bold))
        main_hdr.setStyleSheet("color: #94A3B8; letter-spacing: 0.5px;")

        main_row = QHBoxLayout()
        self.combo_main_file = QComboBox()
        self.combo_main_file.setFixedHeight(38)

        btn_change_main = QPushButton("Change")
        btn_change_main.setFixedHeight(38)
        btn_change_main.setCursor(QCursor(Qt.PointingHandCursor))
        btn_change_main.setStyleSheet("""
            QPushButton {
                background-color: #1A1D29;
                color: #94A3B8;
                border: 1px solid #232838;
                border-radius: 6px;
                padding: 0 16px;
            }
            QPushButton:hover {
                color: #F8FAFC;
                border-color: #3B82F6;
            }
        """)
        btn_change_main.clicked.connect(self.browse_main_file)

        main_row.addWidget(self.combo_main_file, stretch=1)
        main_row.addWidget(btn_change_main)

        # Output Location Row
        out_hdr = QLabel("OUTPUT LOCATION")
        out_hdr.setFont(QFont("Segoe UI", 9, QFont.Bold))
        out_hdr.setStyleSheet("color: #94A3B8; letter-spacing: 0.5px;")

        out_row = QHBoxLayout()
        self.txt_output_dir = QLineEdit()
        default_out = self.storage_mgr.get_settings().get("default_output_folder", "")
        self.txt_output_dir.setText(default_out)
        self.txt_output_dir.setFixedHeight(38)

        btn_out_browse = QPushButton("Browse")
        btn_out_browse.setFixedHeight(38)
        btn_out_browse.setCursor(QCursor(Qt.PointingHandCursor))
        btn_out_browse.setStyleSheet("""
            QPushButton {
                background-color: #1A1D29;
                color: #94A3B8;
                border: 1px solid #232838;
                border-radius: 6px;
                padding: 0 16px;
            }
            QPushButton:hover {
                color: #F8FAFC;
                border-color: #3B82F6;
            }
        """)
        btn_out_browse.clicked.connect(self.browse_output_folder)

        out_row.addWidget(self.txt_output_dir, stretch=1)
        out_row.addWidget(btn_out_browse)

        e_layout.addWidget(main_hdr)
        e_layout.addLayout(main_row)
        e_layout.addWidget(out_hdr)
        e_layout.addLayout(out_row)

        layout.addWidget(entry_card)

        # 4. Build Settings Grid
        settings_card = QFrame()
        settings_card.setStyleSheet("""
            QFrame {
                background-color: #12141C;
                border: 1px solid #202433;
                border-radius: 10px;
                padding: 16px;
            }
        """)
        s_layout = QVBoxLayout(settings_card)
        s_layout.setSpacing(12)

        s_title = QLabel("BUILD SETTINGS")
        s_title.setFont(QFont("Segoe UI", 9, QFont.Bold))
        s_title.setStyleSheet("color: #94A3B8; letter-spacing: 0.5px;")

        names_grid = QGridLayout()
        names_grid.setSpacing(12)

        lbl_app_name = QLabel("Application Name")
        lbl_app_name.setFont(QFont("Segoe UI", 9, QFont.Bold))
        lbl_app_name.setStyleSheet("color: #CBD5E1;")
        self.txt_app_name = QLineEdit()
        self.txt_app_name.setPlaceholderText("MyPythonApp")

        lbl_exe_name = QLabel("EXE Filename")
        lbl_exe_name.setFont(QFont("Segoe UI", 9, QFont.Bold))
        lbl_exe_name.setStyleSheet("color: #CBD5E1;")
        self.txt_exe_name = QLineEdit()
        self.txt_exe_name.setPlaceholderText("app.exe")

        names_grid.addWidget(lbl_app_name, 0, 0)
        names_grid.addWidget(self.txt_app_name, 1, 0)
        names_grid.addWidget(lbl_exe_name, 0, 1)
        names_grid.addWidget(self.txt_exe_name, 1, 1)

        toggles_grid = QGridLayout()
        toggles_grid.setSpacing(12)

        self.chk_onefile = QCheckBox("One-file build (standalone .exe)")
        self.chk_onefile.setChecked(True)

        self.chk_windowed = QCheckBox("Windowed / GUI mode (hide console window)")
        self.chk_windowed.setChecked(True)

        self.chk_assets = QCheckBox("Include project assets / resources")
        self.chk_assets.setChecked(True)

        self.chk_auto_deps = QCheckBox("Automatically detect dependencies")
        self.chk_auto_deps.setChecked(True)

        toggles_grid.addWidget(self.chk_onefile, 0, 0)
        toggles_grid.addWidget(self.chk_windowed, 0, 1)
        toggles_grid.addWidget(self.chk_assets, 1, 0)
        toggles_grid.addWidget(self.chk_auto_deps, 1, 1)

        s_layout.addWidget(s_title)
        s_layout.addLayout(names_grid)
        s_layout.addLayout(toggles_grid)

        layout.addWidget(settings_card)

        # 5. Primary Large BUILD EXE Button
        self.btn_build = QPushButton("🚀 BUILD EXE")
        self.btn_build.setFont(QFont("Segoe UI", 12, QFont.Bold))
        self.btn_build.setFixedHeight(50)
        self.btn_build.setCursor(QCursor(Qt.PointingHandCursor))
        self.btn_build.setStyleSheet("""
            QPushButton {
                background-color: #2563EB;
                color: #FFFFFF;
                border: none;
                border-radius: 8px;
            }
            QPushButton:hover {
                background-color: #1D4ED8;
            }
            QPushButton:disabled {
                background-color: #1E2333;
                color: #64748B;
            }
        """)
        self.btn_build.clicked.connect(self.trigger_build)

        layout.addWidget(self.btn_build)

    def set_project_folder(self, folder_path: str):
        if not folder_path:
            return
        self.txt_folder.setText(folder_path)
        self.scan_data = scan_project_folder(folder_path)

        # Update detection items
        self.chk_python.set_active(self.scan_data.get("has_python", False))
        self.chk_main.set_active(bool(self.scan_data.get("main_file")))
        self.chk_files.set_active(self.scan_data.get("total_files", 0) > 0)
        self.chk_deps.set_active(bool(self.scan_data.get("dependencies")))

        # Populate main file dropdown
        self.combo_main_file.clear()
        py_files = self.scan_data.get("python_files", [])
        if py_files:
            self.combo_main_file.addItems(py_files)
            main_f = self.scan_data.get("main_file")
            if main_f in py_files:
                self.combo_main_file.setCurrentText(main_f)

        # Pre-fill application name & exe filename
        proj_name = self.scan_data.get("project_name", "PythonApp")
        self.txt_app_name.setText(proj_name)
        self.txt_exe_name.setText(f"{proj_name}.exe")

    def browse_folder(self):
        folder = QFileDialog.getExistingDirectory(self, "Select Python Project Folder")
        if folder:
            self.set_project_folder(folder)

    def browse_main_file(self):
        folder = self.txt_folder.text()
        if not folder or not os.path.exists(folder):
            return
        file_path, _ = QFileDialog.getOpenFileName(self, "Select Main Python Entry File", folder, "Python Files (*.py)")
        if file_path:
            rel_path = os.path.relpath(file_path, folder)
            if rel_path not in [self.combo_main_file.itemText(i) for i in range(self.combo_main_file.count())]:
                self.combo_main_file.addItem(rel_path)
            self.combo_main_file.setCurrentText(rel_path)

    def browse_output_folder(self):
        folder = QFileDialog.getExistingDirectory(self, "Select Output Directory")
        if folder:
            self.txt_output_dir.setText(folder)

    def trigger_build(self):
        folder = self.txt_folder.text().strip()
        if not folder:
            return

        main_file = self.combo_main_file.currentText()
        app_name = self.txt_app_name.text().strip() or "PythonApp"
        exe_name = self.txt_exe_name.text().strip() or f"{app_name}.exe"
        if exe_name.endswith(".exe"):
            exe_name = exe_name[:-4]

        out_dir = self.txt_output_dir.text().strip() or str(os.path.expanduser("~/exe_tow_builds"))

        config = {
            "folder_path": folder,
            "project_name": app_name,
            "main_file": main_file,
            "exe_name": exe_name,
            "output_folder": out_dir,
            "one_file": self.chk_onefile.isChecked(),
            "windowed": self.chk_windowed.isChecked(),
            "include_assets": self.chk_assets.isChecked(),
            "auto_deps": self.chk_auto_deps.isChecked(),
            "dependencies": self.scan_data.get("dependencies", [])
        }

        self.start_build_requested.emit(config)
