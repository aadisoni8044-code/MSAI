import os
from PySide6.QtWidgets import (
    QWidget, QVBoxLayout, QHBoxLayout, QLabel, QPushButton, QLineEdit,
    QComboBox, QRadioButton, QButtonGroup, QCheckBox, QFileDialog, QStackedWidget, QFrame
)
from PySide6.QtCore import Qt, QTimer, Signal

from exe_tow.ui.components.custom_widgets import (
    HackerCard, TerminalLogPanel, PipelineStepWidget, CustomProgressBar
)
from exe_tow.core.scanner import ProjectScanner
from exe_tow.core.detector import EntryFileDetector
from exe_tow.core.dependencies import DependencyParser
from exe_tow.core.builder import BuilderThread
from exe_tow.core.history import HistoryManager


class BuildView(QWidget):
    """
    Main Build EXE screen with 3 sub-states:
    0: Setup Screen (Browse folder, Scan stats, Entry chooser, Build options, [⚡ BUILD EXE])
    1: Active Build Screen (Progress bar, 6-step pipeline, contained terminal log panel)
    2: Result Screen (Success / Error screens with action buttons)
    """

    build_status_changed = Signal(str) # "READY" or "BUILDING"
    project_changed = Signal()

    def __init__(self, history_manager: HistoryManager, parent=None):
        super().__init__(parent)
        self.history_manager = history_manager

        self.project_path = ""
        self.scan_result = {}
        self.entry_result = {}
        self.dep_result = {}
        self.builder_thread = None

        main_layout = QVBoxLayout(self)
        main_layout.setContentsMargins(32, 24, 32, 24)
        main_layout.setSpacing(16)

        # Header
        header_box = QVBoxLayout()
        header_box.setSpacing(4)

        self.header_title = QLabel("BUILD EXE", self)
        self.header_title.setStyleSheet("font-size: 24px; font-weight: bold; color: #FFFFFF;")

        self.header_subtitle = QLabel("Select a Python project and create a Windows executable.", self)
        self.header_subtitle.setStyleSheet("font-size: 13px; color: #8A92A6;")

        header_box.addWidget(self.header_title)
        header_box.addWidget(self.header_subtitle)
        main_layout.addLayout(header_box)

        # Stacked Sub-Screens
        self.stack = QStackedWidget(self)

        self.setup_screen = self._create_setup_screen()
        self.building_screen = self._create_building_screen()
        self.result_screen = self._create_result_screen()

        self.stack.addWidget(self.setup_screen)     # Index 0
        self.stack.addWidget(self.building_screen)  # Index 1
        self.stack.addWidget(self.result_screen)    # Index 2

        main_layout.addWidget(self.stack, stretch=1)

    # -------------------------------------------------------------------------
    # SUB-SCREEN 0: SETUP
    # -------------------------------------------------------------------------
    def _create_setup_screen(self) -> QWidget:
        widget = QWidget(self)
        layout = QVBoxLayout(widget)
        layout.setContentsMargins(0, 0, 0, 0)
        layout.setSpacing(16)

        # Folder Selection Card
        folder_card = HackerCard(widget)
        folder_layout = QVBoxLayout(folder_card)
        folder_layout.setContentsMargins(18, 16, 18, 16)
        folder_layout.setSpacing(12)

        folder_title = QLabel("PROJECT FOLDER", widget)
        folder_title.setStyleSheet("font-size: 12px; font-weight: bold; color: #8A92A6; letter-spacing: 0.5px;")

        input_row = QHBoxLayout()
        input_row.setSpacing(10)

        self.path_input = QLineEdit(widget)
        self.path_input.setPlaceholderText("C:\\Users\\User\\Desktop\\MyProject")
        self.path_input.textChanged.connect(self._on_path_changed)

        browse_btn = QPushButton("BROWSE", widget)
        browse_btn.setObjectName("SecondaryBtn")
        browse_btn.setCursor(Qt.PointingHandCursor)
        browse_btn.setMinimumHeight(36)
        browse_btn.clicked.connect(self._browse_folder)

        input_row.addWidget(self.path_input, stretch=1)
        input_row.addWidget(browse_btn)

        self.folder_status_label = QLabel("", widget)
        self.folder_status_label.setStyleSheet("font-family: 'Consolas', monospace; color: #00FF66; font-size: 12px;")

        folder_layout.addWidget(folder_title)
        folder_layout.addLayout(input_row)
        folder_layout.addWidget(self.folder_status_label)

        layout.addWidget(folder_card)

        # Scanning Details & Entry Chooser Card
        self.details_card = HackerCard(widget)
        details_layout = QVBoxLayout(self.details_card)
        details_layout.setContentsMargins(18, 16, 18, 16)
        details_layout.setSpacing(12)

        self.scan_status_title = QLabel("> PROJECT DETAILS", widget)
        self.scan_status_title.setStyleSheet("font-family: 'Consolas', monospace; font-weight: bold; color: #00FF66; font-size: 13px;")

        self.scan_info_label = QLabel("No project folder loaded yet. Select a folder above to scan.", widget)
        self.scan_info_label.setStyleSheet("font-family: 'Consolas', monospace; color: #8A92A6; font-size: 12px; line-height: 1.5;")

        # Entry File Dropdown Row
        entry_row = QHBoxLayout()
        entry_row.setSpacing(10)

        entry_lbl = QLabel("MAIN ENTRY FILE:", widget)
        entry_lbl.setStyleSheet("font-size: 12px; font-weight: bold; color: #FFFFFF;")

        self.entry_combo = QComboBox(widget)
        self.entry_combo.setMinimumHeight(32)

        entry_row.addWidget(entry_lbl)
        entry_row.addWidget(self.entry_combo, stretch=1)

        details_layout.addWidget(self.scan_status_title)
        details_layout.addWidget(self.scan_info_label)
        details_layout.addLayout(entry_row)

        layout.addWidget(self.details_card)

        # Build Options Card
        options_card = HackerCard(widget)
        options_layout = QVBoxLayout(options_card)
        options_layout.setContentsMargins(18, 16, 18, 16)
        options_layout.setSpacing(14)

        opt_title = QLabel("BUILD OPTIONS", widget)
        opt_title.setStyleSheet("font-size: 12px; font-weight: bold; color: #8A92A6; letter-spacing: 0.5px;")

        # App Name & EXE Name
        name_row = QHBoxLayout()
        name_row.setSpacing(16)

        app_name_box = QVBoxLayout()
        app_name_lbl = QLabel("Application Name:", widget)
        app_name_lbl.setStyleSheet("color: #FFFFFF; font-size: 12px;")
        self.app_name_input = QLineEdit("My Application", widget)
        self.app_name_input.textChanged.connect(self._auto_update_exe_name)
        app_name_box.addWidget(app_name_lbl)
        app_name_box.addWidget(self.app_name_input)

        exe_name_box = QVBoxLayout()
        exe_name_lbl = QLabel("EXE File Name:", widget)
        exe_name_lbl.setStyleSheet("color: #FFFFFF; font-size: 12px;")
        self.exe_name_input = QLineEdit("MyApplication.exe", widget)
        exe_name_box.addWidget(exe_name_lbl)
        exe_name_box.addWidget(self.exe_name_input)

        name_row.addLayout(app_name_box, stretch=1)
        name_row.addLayout(exe_name_box, stretch=1)

        # Radio Group Options
        radios_row = QHBoxLayout()
        radios_row.setSpacing(24)

        # Build Type
        build_type_lbl = QLabel("Build Type:", widget)
        build_type_lbl.setStyleSheet("font-weight: bold; color: #FFFFFF;")
        self.radio_onefile = QRadioButton("One File", widget)
        self.radio_onefile.setChecked(True)
        self.radio_folder = QRadioButton("Folder", widget)

        type_group = QButtonGroup(widget)
        type_group.addButton(self.radio_onefile)
        type_group.addButton(self.radio_folder)

        type_layout = QHBoxLayout()
        type_layout.addWidget(build_type_lbl)
        type_layout.addWidget(self.radio_onefile)
        type_layout.addWidget(self.radio_folder)

        # Window Mode
        window_mode_lbl = QLabel("Window Mode:", widget)
        window_mode_lbl.setStyleSheet("font-weight: bold; color: #FFFFFF;")
        self.radio_windowed = QRadioButton("Windowed", widget)
        self.radio_windowed.setChecked(True)
        self.radio_console = QRadioButton("Console", widget)

        mode_group = QButtonGroup(widget)
        mode_group.addButton(self.radio_windowed)
        mode_group.addButton(self.radio_console)

        mode_layout = QHBoxLayout()
        mode_layout.addWidget(window_mode_lbl)
        mode_layout.addWidget(self.radio_windowed)
        mode_layout.addWidget(self.radio_console)

        radios_row.addLayout(type_layout)
        radios_row.addSpacing(20)
        radios_row.addLayout(mode_layout)
        radios_row.addStretch()

        # Checkboxes
        check_row = QHBoxLayout()
        check_row.setSpacing(20)

        self.check_assets = QCheckBox("Include Assets", widget)
        self.check_assets.setChecked(True)

        self.check_deps = QCheckBox("Automatically Detect Dependencies", widget)
        self.check_deps.setChecked(True)

        check_row.addWidget(self.check_assets)
        check_row.addWidget(self.check_deps)
        check_row.addStretch()

        options_layout.addWidget(opt_title)
        options_layout.addLayout(name_row)
        options_layout.addLayout(radios_row)
        options_layout.addLayout(check_row)

        layout.addWidget(options_card)

        # BUILD EXE BUTTON
        self.start_build_btn = QPushButton("⚡ BUILD EXE", widget)
        self.start_build_btn.setObjectName("NeonPrimaryBtn")
        self.start_build_btn.setCursor(Qt.PointingHandCursor)
        self.start_build_btn.setMinimumHeight(48)
        self.start_build_btn.clicked.connect(self._start_build)

        layout.addWidget(self.start_build_btn)
        layout.addStretch()

        return widget

    def _auto_update_exe_name(self, text: str):
        clean = "".join(c for c in text if c.isalnum() or c in ("_", "-")).strip()
        if not clean:
            clean = "MyApplication"
        self.exe_name_input.setText(f"{clean}.exe")

    def _browse_folder(self):
        folder = QFileDialog.getExistingDirectory(self, "Select Python Project Folder")
        if folder:
            self.set_project_path(folder)

    def set_project_path(self, folder_path: str):
        self.path_input.setText(folder_path)

    def _on_path_changed(self, text: str):
        self.project_path = text.strip()
        if os.path.exists(self.project_path) and os.path.isdir(self.project_path):
            self.folder_status_label.setText("✓ Folder found   ✓ Python project detected")
            self.scan_project()
        else:
            self.folder_status_label.setText("")
            self.scan_info_label.setText("No valid project folder selected.")
            self.entry_combo.clear()

    def scan_project(self):
        if not self.project_path or not os.path.exists(self.project_path):
            return

        try:
            scanner = ProjectScanner(self.project_path)
            self.scan_result = scanner.scan()

            detector = EntryFileDetector(self.project_path, self.scan_result["python_files"])
            self.entry_result = detector.detect()

            parser = DependencyParser(self.project_path, self.scan_result["python_files"])
            self.dep_result = parser.parse()

            # Set default App Name from folder
            proj_name = self.scan_result["project_name"]
            self.app_name_input.setText(proj_name)

            # Populate details text
            info_text = (
                f"Python Version : {self.scan_result['python_version']}\n"
                f"Entry File     : {self.entry_result['selected_entry'] or 'None'}\n"
                f"Python Files   : {self.scan_result['python_files_count']}\n"
                f"Asset Files    : {self.scan_result['asset_files_count']}\n"
                f"Dependencies   : {self.dep_result['count']}"
            )
            self.scan_info_label.setText(info_text)

            # Populate Entry Combo
            self.entry_combo.clear()
            possible = self.entry_result["possible_entries"]
            if not possible:
                possible = self.scan_result["python_files"]

            for entry in possible:
                self.entry_combo.addItem(entry)

            selected = self.entry_result["selected_entry"]
            if selected in possible:
                self.entry_combo.setCurrentText(selected)

            # Save to history
            self.history_manager.add_or_update_project(
                self.project_path,
                proj_name,
                selected,
                "READY"
            )
            self.project_changed.emit()

        except Exception as e:
            self.scan_info_label.setText(f"Scan error: {str(e)}")

    # -------------------------------------------------------------------------
    # SUB-SCREEN 1: BUILDING PROGRESS & PIPELINE
    # -------------------------------------------------------------------------
    def _create_building_screen(self) -> QWidget:
        widget = QWidget(self)
        layout = QVBoxLayout(widget)
        layout.setContentsMargins(0, 0, 0, 0)
        layout.setSpacing(14)

        # Active Build Header Card
        build_card = HackerCard(widget)
        build_layout = QVBoxLayout(build_card)
        build_layout.setContentsMargins(18, 14, 18, 14)
        build_layout.setSpacing(10)

        meta_row = QHBoxLayout()
        self.build_proj_label = QLabel("Project: MyProject", widget)
        self.build_proj_label.setStyleSheet("font-weight: bold; color: #FFFFFF;")

        self.build_entry_label = QLabel("Entry: main.py", widget)
        self.build_entry_label.setStyleSheet("color: #8A92A6;")

        self.build_pct_label = QLabel("0%", widget)
        self.build_pct_label.setStyleSheet("font-family: 'Consolas', monospace; font-weight: bold; color: #00FF66; font-size: 16px;")

        meta_row.addWidget(self.build_proj_label)
        meta_row.addSpacing(20)
        meta_row.addWidget(self.build_entry_label)
        meta_row.addStretch()
        meta_row.addWidget(self.build_pct_label)

        self.progress_bar = CustomProgressBar(widget)

        build_layout.addLayout(meta_row)
        build_layout.addWidget(self.progress_bar)

        layout.addWidget(build_card)

        # 6-Step Pipeline Column
        pipeline_box = QVBoxLayout()
        pipeline_box.setSpacing(6)

        self.step_widgets = [
            PipelineStepWidget("01", "SCANNING", widget),
            PipelineStepWidget("02", "DETECTING", widget),
            PipelineStepWidget("03", "DEPENDENCIES", widget),
            PipelineStepWidget("04", "PACKAGING", widget),
            PipelineStepWidget("05", "BUILDING EXE", widget),
            PipelineStepWidget("06", "FINALIZING", widget),
        ]

        for step_w in self.step_widgets:
            pipeline_box.addWidget(step_w)

        layout.addLayout(pipeline_box)

        # Contained Build Log Panel
        self.log_panel = TerminalLogPanel(widget)
        layout.addWidget(self.log_panel, stretch=1)

        return widget

    # -------------------------------------------------------------------------
    # SUB-SCREEN 2: SUCCESS / ERROR STATES
    # -------------------------------------------------------------------------
    def _create_result_screen(self) -> QWidget:
        widget = QWidget(self)
        self.result_layout = QVBoxLayout(widget)
        self.result_layout.setContentsMargins(0, 0, 0, 0)
        self.result_layout.setSpacing(16)
        return widget

    def _show_success_screen(self, result_dict: dict):
        # Clear layout
        while self.result_layout.count():
            child = self.result_layout.takeAt(0)
            if child.widget():
                child.widget().deleteLater()

        card = HackerCard(self)
        card_layout = QVBoxLayout(card)
        card_layout.setContentsMargins(32, 28, 32, 28)
        card_layout.setSpacing(16)

        icon_lbl = QLabel("✓", self)
        icon_lbl.setStyleSheet("font-size: 48px; color: #00FF66; font-weight: bold;")
        icon_lbl.setAlignment(Qt.AlignCenter)

        title_lbl = QLabel("BUILD COMPLETE", self)
        title_lbl.setStyleSheet("font-size: 24px; font-weight: bold; color: #FFFFFF;")
        title_lbl.setAlignment(Qt.AlignCenter)

        sub_lbl = QLabel("Your Python project was successfully converted into an EXE.", self)
        sub_lbl.setStyleSheet("font-size: 13px; color: #8A92A6;")
        sub_lbl.setAlignment(Qt.AlignCenter)

        # Details Box
        info_box = QFrame(self)
        info_box.setStyleSheet("background-color: #090A0D; border: 1px solid #1E2638; border-radius: 6px; padding: 16px;")
        info_box_layout = QVBoxLayout(info_box)
        info_box_layout.setSpacing(8)

        exe_path = result_dict.get("exe_path", "")
        out_dir = result_dict.get("output_dir", "")
        size_mb = result_dict.get("size_mb", 0.0)
        dur_sec = result_dict.get("duration_sec", 0.0)

        app_info = QLabel(f"Application : {result_dict.get('exe_name', 'MyApplication.exe')}", self)
        loc_info = QLabel(f"Location    : {out_dir}", self)
        size_info = QLabel(f"Size        : {size_mb:.1f} MB", self)
        dur_info = QLabel(f"Build time  : {dur_sec:.1f} seconds", self)

        for l in (app_info, loc_info, size_info, dur_info):
            l.setStyleSheet("font-family: 'Consolas', monospace; color: #00FF66; font-size: 13px;")
            info_box_layout.addWidget(l)

        # Actions Row
        actions_row = QHBoxLayout()
        actions_row.setSpacing(14)
        actions_row.setAlignment(Qt.AlignCenter)

        open_exe_btn = QPushButton("OPEN EXE", self)
        open_exe_btn.setObjectName("NeonPrimaryBtn")
        open_exe_btn.setCursor(Qt.PointingHandCursor)
        open_exe_btn.clicked.connect(lambda: self._open_path(exe_path))

        open_folder_btn = QPushButton("OPEN OUTPUT FOLDER", self)
        open_folder_btn.setObjectName("SecondaryBtn")
        open_folder_btn.setCursor(Qt.PointingHandCursor)
        open_folder_btn.clicked.connect(lambda: self._open_path(out_dir))

        build_again_btn = QPushButton("BUILD AGAIN", self)
        build_again_btn.setObjectName("SecondaryBtn")
        build_again_btn.setCursor(Qt.PointingHandCursor)
        build_again_btn.clicked.connect(self._reset_to_setup)

        actions_row.addWidget(open_exe_btn)
        actions_row.addWidget(open_folder_btn)
        actions_row.addWidget(build_again_btn)

        card_layout.addWidget(icon_lbl)
        card_layout.addWidget(title_lbl)
        card_layout.addWidget(sub_lbl)
        card_layout.addWidget(info_box)
        card_layout.addSpacing(10)
        card_layout.addLayout(actions_row)

        self.result_layout.addWidget(card)
        self.stack.setCurrentIndex(2)

    def _show_error_screen(self, result_dict: dict):
        while self.result_layout.count():
            child = self.result_layout.takeAt(0)
            if child.widget():
                child.widget().deleteLater()

        card = HackerCard(self)
        card_layout = QVBoxLayout(card)
        card_layout.setContentsMargins(32, 28, 32, 28)
        card_layout.setSpacing(16)

        icon_lbl = QLabel("✕", self)
        icon_lbl.setStyleSheet("font-size: 48px; color: #FF4D4D; font-weight: bold;")
        icon_lbl.setAlignment(Qt.AlignCenter)

        title_lbl = QLabel("BUILD FAILED", self)
        title_lbl.setStyleSheet("font-size: 24px; font-weight: bold; color: #FFFFFF;")
        title_lbl.setAlignment(Qt.AlignCenter)

        err_msg = result_dict.get("error_message", "An unexpected error occurred during packaging.")
        err_lbl = QLabel(f"Error: {err_msg}", self)
        err_lbl.setStyleSheet("font-family: 'Consolas', monospace; font-size: 13px; color: #FF4D4D;")
        err_lbl.setAlignment(Qt.AlignCenter)
        err_lbl.setWordWrap(True)

        actions_row = QHBoxLayout()
        actions_row.setSpacing(14)
        actions_row.setAlignment(Qt.AlignCenter)

        view_log_btn = QPushButton("VIEW LOG", self)
        view_log_btn.setObjectName("SecondaryBtn")
        view_log_btn.setCursor(Qt.PointingHandCursor)
        view_log_btn.clicked.connect(lambda: self.stack.setCurrentIndex(1)) # Back to progress screen log

        try_again_btn = QPushButton("TRY AGAIN", self)
        try_again_btn.setObjectName("NeonPrimaryBtn")
        try_again_btn.setCursor(Qt.PointingHandCursor)
        try_again_btn.clicked.connect(self._reset_to_setup)

        actions_row.addWidget(view_log_btn)
        actions_row.addWidget(try_again_btn)

        card_layout.addWidget(icon_lbl)
        card_layout.addWidget(title_lbl)
        card_layout.addWidget(err_lbl)
        card_layout.addSpacing(10)
        card_layout.addLayout(actions_row)

        self.result_layout.addWidget(card)
        self.stack.setCurrentIndex(2)

    def _open_path(self, target_path: str):
        if not target_path or not os.path.exists(target_path):
            return
        if os.name == 'nt':
            os.startfile(target_path)
        elif os.uname().sysname == 'Darwin':
            import subprocess
            subprocess.Popen(["open", target_path])
        else:
            import subprocess
            subprocess.Popen(["xdg-open", target_path])

    def _reset_to_setup(self):
        self.stack.setCurrentIndex(0)
        self.build_status_changed.emit("READY")

    # -------------------------------------------------------------------------
    # BUILD EXECUTION CONTROLLER
    # -------------------------------------------------------------------------
    def _start_build(self):
        if not self.project_path or not os.path.exists(self.project_path):
            return

        entry_file = self.entry_combo.currentText() or "main.py"
        app_name = self.app_name_input.text().strip() or "My Application"
        exe_name = self.exe_name_input.text().strip() or "MyApplication.exe"

        # Prepare building screen
        self.build_proj_label.setText(f"Project: {os.path.basename(self.project_path)}")
        self.build_entry_label.setText(f"Entry: {entry_file}")
        self.build_pct_label.setText("0%")
        self.progress_bar.setValue(0)
        self.log_panel.clear_logs()

        for step_w in self.step_widgets:
            step_w.set_status("waiting")

        # Switch screen to active build
        self.stack.setCurrentIndex(1)
        self.build_status_changed.emit("BUILDING")

        # Create thread
        self.builder_thread = BuilderThread(
            project_path=self.project_path,
            entry_file=entry_file,
            app_name=app_name,
            exe_name=exe_name,
            one_file=self.radio_onefile.isChecked(),
            windowed=self.radio_windowed.isChecked(),
            include_assets=self.check_assets.isChecked(),
            auto_dependencies=self.check_deps.isChecked()
        )

        self.builder_thread.step_changed.connect(self._on_step_changed)
        self.builder_thread.progress_updated.connect(self._on_progress_updated)
        self.builder_thread.log_emitted.connect(self.log_panel.append_log)
        self.builder_thread.build_finished.connect(self._on_build_finished)

        self.builder_thread.start()

    def _on_step_changed(self, step_idx: int, step_name: str, status: str):
        if 1 <= step_idx <= 6:
            self.step_widgets[step_idx - 1].set_status(status)

    def _on_progress_updated(self, val: int):
        self.progress_bar.setValue(val)
        self.build_pct_label.setText(f"{val}%")

    def _on_build_finished(self, success: bool, result_dict: dict):
        self.build_status_changed.emit("READY")

        status_str = "SUCCESS" if success else "FAILED"
        self.history_manager.record_build(
            project_name=os.path.basename(self.project_path),
            project_path=self.project_path,
            exe_name=self.exe_name_input.text().strip() or "MyApplication.exe",
            exe_path=result_dict.get("exe_path", ""),
            status=status_str,
            size_mb=result_dict.get("size_mb", 0.0),
            duration_sec=result_dict.get("duration_sec", 0.0),
            error_message=result_dict.get("error_message", "")
        )
        self.project_changed.emit()

        if success:
            self._show_success_screen(result_dict)
        else:
            self._show_error_screen(result_dict)
