import os
import subprocess
from pathlib import Path
from PySide6.QtWidgets import (
    QWidget, QVBoxLayout, QHBoxLayout, QLabel, QLineEdit, QComboBox,
    QPushButton, QFrame, QFileDialog, QMessageBox, QScrollArea
)
from PySide6.QtCore import Qt, Signal
from exe_tow.ui.theme import Theme
from exe_tow.ui.components.terminal import TerminalWidget
from exe_tow.ui.components.attempt_indicator import AttemptIndicator
from exe_tow.core.project_analyzer import ProjectAnalyzer
from exe_tow.core.environment_detector import EnvironmentDetector

class BuildView(QWidget):
    start_build_signal = Signal(dict)
    stop_build_signal = Signal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self.selected_project_path = ""
        self.created_exe_path = None

        layout = QHBoxLayout(self)
        layout.setContentsMargins(20, 20, 20, 20)
        layout.setSpacing(20)

        # LEFT PANE: Configuration Form
        left_pane = QFrame()
        left_pane.setObjectName("card")
        left_pane.setFixedWidth(420)
        left_layout = QVBoxLayout(left_pane)
        left_layout.setContentsMargins(20, 20, 20, 20)
        left_layout.setSpacing(14)

        lbl_title = QLabel("Build Configuration")
        lbl_title.setObjectName("heading")
        left_layout.addWidget(lbl_title)

        # 1. Project Selection
        left_layout.addWidget(QLabel("Python Project / File:"))
        proj_row = QHBoxLayout()
        self.txt_project = QLineEdit()
        self.txt_project.setPlaceholderText("Select .py file or project directory...")
        self.txt_project.textChanged.connect(self._on_project_path_changed)
        proj_row.addWidget(self.txt_project)

        self.btn_browse_proj = QPushButton("Browse")
        self.btn_browse_proj.clicked.connect(self._browse_project)
        proj_row.addWidget(self.btn_browse_proj)
        left_layout.addLayout(proj_row)

        self.lbl_proj_info = QLabel("No project selected.")
        self.lbl_proj_info.setObjectName("secondary")
        self.lbl_proj_info.setWordWrap(True)
        self.lbl_proj_info.setStyleSheet("font-size: 11px;")
        left_layout.addWidget(self.lbl_proj_info)

        # 2. EXE Name
        left_layout.addWidget(QLabel("EXE Name:"))
        self.txt_exe_name = QLineEdit()
        self.txt_exe_name.setPlaceholderText("e.g. MyApplication.exe")
        left_layout.addWidget(self.txt_exe_name)

        # 3. Output Folder
        left_layout.addWidget(QLabel("Output Folder:"))
        out_row = QHBoxLayout()
        self.txt_output_dir = QLineEdit()
        default_dist = str(Path.home() / "EXE-TOW" / "dist")
        self.txt_output_dir.setText(default_dist)
        out_row.addWidget(self.txt_output_dir)

        self.btn_browse_out = QPushButton("Browse")
        self.btn_browse_out.clicked.connect(self._browse_output_folder)
        out_row.addWidget(self.btn_browse_out)
        left_layout.addLayout(out_row)

        # 4. Build Mode
        left_layout.addWidget(QLabel("Build Mode:"))
        self.combo_mode = QComboBox()
        self.combo_mode.addItems(["ONE FILE", "ONE DIRECTORY"])
        left_layout.addWidget(self.combo_mode)

        # 5. Build Engine
        left_layout.addWidget(QLabel("Build Engine:"))
        self.combo_engine = QComboBox()
        self.combo_engine.addItems(["PyInstaller"])
        left_layout.addWidget(self.combo_engine)

        left_layout.addSpacing(10)

        # Main Action Button: BUILD EXE
        self.btn_build = QPushButton("BUILD EXE")
        self.btn_build.setObjectName("primary")
        self.btn_build.setFixedHeight(45)
        self.btn_build.setCursor(Qt.PointingHandCursor)
        self.btn_build.clicked.connect(self._on_build_click)
        left_layout.addWidget(self.btn_build)

        # STOP BUILD Button
        self.btn_stop = QPushButton("STOP BUILD")
        self.btn_stop.setObjectName("stop")
        self.btn_stop.setFixedHeight(35)
        self.btn_stop.setEnabled(False)
        self.btn_stop.clicked.connect(self._on_stop_click)
        left_layout.addWidget(self.btn_stop)

        # Successful Output Action Panel (Hidden by default)
        self.success_box = QFrame()
        self.success_box.setStyleSheet(f"background-color: {Theme.STATUS_SUCCESS_BG}; border: 1px solid {Theme.STATUS_SUCCESS}; border-radius: 6px;")
        succ_layout = QVBoxLayout(self.success_box)

        lbl_succ = QLabel("🎉 EXE CREATED SUCCESSFULLY")
        lbl_succ.setStyleSheet(f"color: {Theme.TERMINAL_TEXT}; font-weight: bold; font-size: 13px;")
        succ_layout.addWidget(lbl_succ)

        succ_btns = QHBoxLayout()
        self.btn_open_exe = QPushButton("OPEN EXE")
        self.btn_open_exe.clicked.connect(self._open_exe)
        succ_btns.addWidget(self.btn_open_exe)

        self.btn_open_folder = QPushButton("OPEN FOLDER")
        self.btn_open_folder.clicked.connect(self._open_folder)
        succ_btns.addWidget(self.btn_open_folder)

        succ_layout.addLayout(succ_btns)
        self.success_box.setVisible(False)
        left_layout.addWidget(self.success_box)

        left_layout.addStretch()
        layout.addWidget(left_pane)

        # RIGHT PANE: Build Status & Terminal Output
        right_pane = QWidget()
        right_layout = QVBoxLayout(right_pane)
        right_layout.setContentsMargins(0, 0, 0, 0)
        right_layout.setSpacing(12)

        # Build Status Header Card
        self.status_card = QFrame()
        self.status_card.setObjectName("card")
        sc_layout = QVBoxLayout(self.status_card)

        sc_hdr = QHBoxLayout()
        sc_hdr.addWidget(QLabel("BUILD STATUS:"))
        self.lbl_status_val = QLabel("READY")
        self.lbl_status_val.setStyleSheet("font-weight: bold; font-size: 14px; color: #8B949E;")
        sc_hdr.addWidget(self.lbl_status_val)
        sc_hdr.addStretch()
        sc_layout.addLayout(sc_hdr)

        # Scrollable Fallback Attempts Panel
        self.attempts_container = QWidget()
        self.attempts_layout = QVBoxLayout(self.attempts_container)
        self.attempts_layout.setContentsMargins(0, 0, 0, 0)
        self.attempts_layout.setSpacing(6)

        scroll_attempts = QScrollArea()
        scroll_attempts.setWidgetResizable(True)
        scroll_attempts.setFixedHeight(120)
        scroll_attempts.setStyleSheet("QScrollArea { border: none; background: transparent; }")
        scroll_attempts.setWidget(self.attempts_container)
        sc_layout.addWidget(scroll_attempts)

        right_layout.addWidget(self.status_card)

        # Terminal Panel
        self.terminal = TerminalWidget()
        right_layout.addWidget(self.terminal)

        layout.addWidget(right_pane, stretch=1)

    def _browse_project(self):
        filename, _ = QFileDialog.getOpenFileName(self, "Select Entry Python File", "", "Python Files (*.py);;All Files (*)")
        if not filename:
            filename = QFileDialog.getExistingDirectory(self, "Select Python Project Directory")
        if filename:
            self.txt_project.setText(filename)

    def _browse_output_folder(self):
        folder = QFileDialog.getExistingDirectory(self, "Select Output Directory")
        if folder:
            self.txt_output_dir.setText(folder)

    def _on_project_path_changed(self, text: str):
        self.selected_project_path = text.strip()
        if not self.selected_project_path or not os.path.exists(self.selected_project_path):
            self.lbl_proj_info.setText("Selected path does not exist.")
            return

        try:
            analyzer = ProjectAnalyzer(self.selected_project_path)
            p_info = analyzer.analyze()

            # Default EXE Name if empty
            if not self.txt_exe_name.text().strip():
                self.txt_exe_name.setText(f"{p_info.project_name}.exe")

            desc = f"Project: {p_info.project_name}\nEntry File: {Path(p_info.entry_file).name}\n"
            desc += f"Type: {'Single File' if p_info.is_single_file else 'Directory Project'}\n"
            desc += f"Requirements: {'Detected' if p_info.has_requirements else 'None'}"
            self.lbl_proj_info.setText(desc)
        except Exception as e:
            self.lbl_proj_info.setText(f"Analysis error: {str(e)}")

    def _on_build_click(self):
        proj_path = self.txt_project.text().strip()
        if not proj_path or not os.path.exists(proj_path):
            QMessageBox.critical(self, "Error", "Please select a valid Python project or .py file.")
            return

        exe_name = self.txt_exe_name.text().strip()
        if not exe_name:
            QMessageBox.critical(self, "Error", "Please enter an EXE name.")
            return

        out_dir = self.txt_output_dir.text().strip()
        if not out_dir:
            QMessageBox.critical(self, "Error", "Please select an output folder.")
            return

        build_config = {
            "project_path": proj_path,
            "exe_name": exe_name,
            "output_folder": out_dir,
            "build_mode": self.combo_mode.currentText(),
            "engine_name": self.combo_engine.currentText()
        }

        self.set_building_state(True)
        self.clear_attempt_indicators()
        self.success_box.setVisible(False)
        self.created_exe_path = None
        self.start_build_signal.emit(build_config)

    def _on_stop_click(self):
        self.stop_build_signal.emit()

    def set_building_state(self, is_building: bool):
        self.btn_build.setEnabled(not is_building)
        self.btn_stop.setEnabled(is_building)
        self.txt_project.setEnabled(not is_building)
        self.btn_browse_proj.setEnabled(not is_building)

    def update_status(self, status_msg: str):
        self.lbl_status_val.setText(status_msg)

    def add_attempt_indicator(self, attempt_num: int, command: str, status: str):
        indicator = AttemptIndicator(attempt_num, command, status, self.attempts_container)
        self.attempts_layout.addWidget(indicator)

    def clear_attempt_indicators(self):
        while self.attempts_layout.count():
            child = self.attempts_layout.takeAt(0)
            if child.widget():
                child.widget().deleteLater()

    def show_build_success(self, output_exe_path: str):
        self.created_exe_path = output_exe_path
        self.success_box.setVisible(True)

    def _open_exe(self):
        if self.created_exe_path and os.path.exists(self.created_exe_path):
            try:
                os.startfile(self.created_exe_path)
            except Exception:
                subprocess.Popen([self.created_exe_path])

    def _open_folder(self):
        out_folder = self.txt_output_dir.text().strip()
        if os.path.exists(out_folder):
            if os.name == 'nt':
                os.startfile(out_folder)
            else:
                subprocess.Popen(["xdg-open", out_folder])
