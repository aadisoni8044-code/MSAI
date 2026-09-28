"""
exe/tow - Build EXE Workflow View
Handles project selection, main file auto-detection with manual override, output path,
toggleable build options, start build execution, live build console/progress,
success completion view, and clean error diagnosis panel.
"""

import os
import subprocess
from PySide6.QtCore import Qt, Signal, QTimer
from PySide6.QtWidgets import (
    QWidget, QVBoxLayout, QHBoxLayout, QLabel, QPushButton, QFrame,
    QLineEdit, QCheckBox, QProgressBar, QTextEdit, QFileDialog,
    QStackedWidget, QComboBox, QMessageBox
)
from exe_tow.ui.theme import ThemeColors
from exe_tow.core.detector import ProjectDetector
from exe_tow.core.builder import BuildWorker

class BuildView(QWidget):
    """Compiler interface for configuring and executing exe/tow builds."""

    sig_build_finished = Signal(dict)

    def __init__(self, settings_manager, history_manager, parent=None):
        super().__init__(parent)
        self.settings = settings_manager
        self.history = history_manager
        self.build_worker = None
        self.current_build_result = None

        layout = QVBoxLayout(self)
        layout.setContentsMargins(32, 28, 32, 28)
        layout.setSpacing(16)

        # Main Stacked Layout (0: Config & Build, 1: Progress, 2: Success, 3: Error)
        self.stack = QStackedWidget()
        layout.addWidget(self.stack)

        # Page 0: Configuration Screen
        self.config_page = self._build_config_page()
        self.stack.addWidget(self.config_page)

        # Page 1: Progress Console Screen
        self.progress_page = self._build_progress_page()
        self.stack.addWidget(self.progress_page)

        # Page 2: Success Screen
        self.success_page = self._build_success_page()
        self.stack.addWidget(self.success_page)

        # Page 3: Error Handling Screen
        self.error_page = self._build_error_page()
        self.stack.addWidget(self.error_page)

        # Show initial configuration
        self.stack.setCurrentIndex(0)

    # -------------------------------------------------------------------------
    # PAGE 0: CONFIGURATION & BUILD OPTIONS
    # -------------------------------------------------------------------------
    def _build_config_page(self) -> QWidget:
        page = QWidget()
        layout = QVBoxLayout(page)
        layout.setContentsMargins(0, 0, 0, 0)
        layout.setSpacing(20)

        # Title Header
        header = QLabel("Build EXE Package")
        header.setObjectName("TitleLabel")
        layout.addWidget(header)

        # 1. Project Selection Panel
        proj_panel = QFrame()
        proj_panel.setObjectName("CardPanel")
        proj_layout = QVBoxLayout(proj_panel)
        proj_layout.setContentsMargins(20, 20, 20, 20)
        proj_layout.setSpacing(14)

        panel_title = QLabel("PROJECT SELECTION")
        panel_title.setStyleSheet(f"color: {ThemeColors.TEXT_MUTED}; font-size: 10px; font-weight: 700; letter-spacing: 1px;")
        proj_layout.addWidget(panel_title)

        # Project Folder Field
        lbl_folder = QLabel("Project Folder")
        lbl_folder.setObjectName("SectionTitle")
        proj_layout.addWidget(lbl_folder)

        folder_row = QHBoxLayout()
        self.input_folder = QLineEdit()
        self.input_folder.setPlaceholderText("Select your Python project folder...")
        self.input_folder.textChanged.connect(self._on_project_folder_changed)

        btn_browse_folder = QPushButton("📁 Browse")
        btn_browse_folder.setCursor(Qt.PointingHandCursor)
        btn_browse_folder.clicked.connect(self._browse_project_folder)

        folder_row.addWidget(self.input_folder)
        folder_row.addWidget(btn_browse_folder)
        proj_layout.addLayout(folder_row)

        # Main Python File Row
        lbl_main = QLabel("Main Python File")
        lbl_main.setObjectName("SectionTitle")
        proj_layout.addWidget(lbl_main)

        main_row = QHBoxLayout()
        self.combo_main = QComboBox()
        self.combo_main.setEditable(True)
        self.combo_main.setStyleSheet(f"""
            QComboBox {{
                background-color: {ThemeColors.BG_INPUT};
                border: 1px solid {ThemeColors.BORDER_SUBTLE};
                border-radius: 6px;
                color: {ThemeColors.TEXT_PRIMARY};
                padding: 8px 12px;
            }}
            QComboBox::drop-down {{
                border: none;
            }}
        """)

        self.lbl_detected = QLabel("Automatically detected")
        self.lbl_detected.setStyleSheet(f"color: {ThemeColors.STATUS_SUCCESS}; font-size: 11px; font-weight: 600;")

        btn_browse_main = QPushButton("📄 Select File")
        btn_browse_main.setCursor(Qt.PointingHandCursor)
        btn_browse_main.clicked.connect(self._browse_main_file)

        main_row.addWidget(self.combo_main, stretch=1)
        main_row.addWidget(self.lbl_detected)
        main_row.addWidget(btn_browse_main)
        proj_layout.addLayout(main_row)

        # Output Folder Row
        lbl_out = QLabel("Output Folder")
        lbl_out.setObjectName("SectionTitle")
        proj_layout.addWidget(lbl_out)

        out_row = QHBoxLayout()
        self.input_output = QLineEdit()
        self.input_output.setText(self.settings.get("default_output_folder", os.path.abspath("dist")))

        btn_browse_out = QPushButton("📁 Browse")
        btn_browse_out.setCursor(Qt.PointingHandCursor)
        btn_browse_out.clicked.connect(self._browse_output_folder)

        out_row.addWidget(self.input_output)
        out_row.addWidget(btn_browse_out)
        proj_layout.addLayout(out_row)

        layout.addWidget(proj_panel)

        # 2. Build Options Panel
        opts_panel = QFrame()
        opts_panel.setObjectName("CardPanel")
        opts_layout = QVBoxLayout(opts_panel)
        opts_layout.setContentsMargins(20, 20, 20, 20)
        opts_layout.setSpacing(14)

        opts_title = QLabel("BUILD OPTIONS")
        opts_title.setStyleSheet(f"color: {ThemeColors.TEXT_MUTED}; font-size: 10px; font-weight: 700; letter-spacing: 1px;")
        opts_layout.addWidget(opts_title)

        opts_grid = QHBoxLayout()
        opts_grid.setSpacing(24)

        col1 = QVBoxLayout()
        self.cb_onefile = QCheckBox("One-file EXE")
        self.cb_onefile.setChecked(self.settings.get("one_file_default", True))
        self.cb_windowed = QCheckBox("Windowed application (GUI)")
        self.cb_windowed.setChecked(self.settings.get("windowed_default", True))
        self.cb_console = QCheckBox("Console application")
        self.cb_console.setChecked(self.settings.get("console_default", False))

        # Mutually exclusive GUI vs Console logic
        self.cb_windowed.toggled.connect(lambda chk: self.cb_console.setChecked(not chk) if chk else None)
        self.cb_console.toggled.connect(lambda chk: self.cb_windowed.setChecked(not chk) if chk else None)

        col1.addWidget(self.cb_onefile)
        col1.addWidget(self.cb_windowed)
        col1.addWidget(self.cb_console)

        col2 = QVBoxLayout()
        self.cb_files = QCheckBox("Include project files")
        self.cb_files.setChecked(self.settings.get("include_files_default", True))
        self.cb_deps = QCheckBox("Include dependencies")
        self.cb_deps.setChecked(self.settings.get("include_dependencies_default", True))
        self.cb_opt = QCheckBox("Optimize build")
        self.cb_opt.setChecked(self.settings.get("optimize_default", True))
        self.cb_clean = QCheckBox("Clean previous build")
        self.cb_clean.setChecked(self.settings.get("clean_default", True))

        col2.addWidget(self.cb_files)
        col2.addWidget(self.cb_deps)
        col2.addWidget(self.cb_opt)
        col2.addWidget(self.cb_clean)

        opts_grid.addLayout(col1)
        opts_grid.addLayout(col2)
        opts_layout.addLayout(opts_grid)

        layout.addWidget(opts_panel)

        # 3. Main Action Button
        self.btn_start_build = QPushButton("⚡ START BUILD")
        self.btn_start_build.setObjectName("PrimaryButton")
        self.btn_start_build.setCursor(Qt.PointingHandCursor)
        self.btn_start_build.clicked.connect(self._start_build)
        layout.addWidget(self.btn_start_build)

        layout.addStretch()
        return page

    # -------------------------------------------------------------------------
    # PAGE 1: BUILD PROGRESS & LOG CONSOLE
    # -------------------------------------------------------------------------
    def _build_progress_page(self) -> QWidget:
        page = QWidget()
        layout = QVBoxLayout(page)
        layout.setContentsMargins(0, 0, 0, 0)
        layout.setSpacing(20)

        header = QLabel("Packaging Application...")
        header.setObjectName("TitleLabel")
        layout.addWidget(header)

        # Progress Card
        card = QFrame()
        card.setObjectName("CardPanel")
        card_layout = QVBoxLayout(card)
        card_layout.setContentsMargins(20, 20, 20, 20)
        card_layout.setSpacing(14)

        self.lbl_operation = QLabel("→ Initializing build engine...")
        self.lbl_operation.setObjectName("SectionTitle")

        self.progress_bar = QProgressBar()
        self.progress_bar.setRange(0, 100)
        self.progress_bar.setValue(0)

        self.lbl_pct = QLabel("0%")
        self.lbl_pct.setStyleSheet(f"color: {ThemeColors.TEXT_MUTED}; font-size: 12px; font-weight: 600;")

        card_layout.addWidget(self.lbl_operation)
        card_layout.addWidget(self.progress_bar)
        card_layout.addWidget(self.lbl_pct)

        # Steps Checklist Panel
        steps_box = QFrame()
        steps_box.setStyleSheet(f"background-color: {ThemeColors.BG_INPUT}; border-radius: 8px; padding: 12px;")
        steps_layout = QVBoxLayout(steps_box)
        steps_layout.setSpacing(6)

        self.step_labels = {}
        step_items = [
            "Python detected",
            "Project folder loaded",
            "Main file detected",
            "Dependencies analyzed",
            "Build environment prepared",
            "Packaging application...",
            "Creating EXE...",
            "Build completed"
        ]
        for item in step_items:
            lbl = QLabel(f"⚪ {item}")
            lbl.setStyleSheet(f"color: {ThemeColors.TEXT_MUTED}; font-size: 12px;")
            self.step_labels[item] = lbl
            steps_layout.addWidget(lbl)

        card_layout.addWidget(steps_box)

        # Live Console Output
        console_lbl = QLabel("Build Log")
        console_lbl.setStyleSheet(f"color: {ThemeColors.TEXT_MUTED}; font-size: 10px; font-weight: 700;")
        card_layout.addWidget(console_lbl)

        self.log_console = QTextEdit()
        self.log_console.setReadOnly(True)
        self.log_console.setStyleSheet(f"""
            QTextEdit {{
                background-color: #050608;
                border: 1px solid {ThemeColors.BORDER_SUBTLE};
                font-family: {ThemeColors.FONT_MONO};
                font-size: 12px;
                color: #00FF66;
            }}
        """)
        card_layout.addWidget(self.log_console)

        layout.addWidget(card)
        return page

    # -------------------------------------------------------------------------
    # PAGE 2: SUCCESS SCREEN
    # -------------------------------------------------------------------------
    def _build_success_page(self) -> QWidget:
        page = QWidget()
        layout = QVBoxLayout(page)
        layout.setContentsMargins(0, 0, 0, 0)
        layout.setSpacing(20)

        card = QFrame()
        card.setObjectName("GlassPanel")
        card_layout = QVBoxLayout(card)
        card_layout.setContentsMargins(32, 32, 32, 32)
        card_layout.setSpacing(16)

        icon_lbl = QLabel("✓ BUILD COMPLETE")
        icon_lbl.setStyleSheet(f"color: {ThemeColors.STATUS_SUCCESS}; font-size: 24px; font-weight: 800;")
        card_layout.addWidget(icon_lbl)

        sub_lbl = QLabel("Your EXE is ready.")
        sub_lbl.setObjectName("SubtitleLabel")
        card_layout.addWidget(sub_lbl)

        self.lbl_success_details = QLabel()
        self.lbl_success_details.setStyleSheet(f"color: {ThemeColors.TEXT_SECONDARY}; font-size: 13px;")
        card_layout.addWidget(self.lbl_success_details)

        card_layout.addSpacing(16)

        btn_row = QHBoxLayout()
        btn_row.setSpacing(12)

        self.btn_open_exe = QPushButton("🚀 Open EXE")
        self.btn_open_exe.setObjectName("PrimaryButton")
        self.btn_open_exe.setCursor(Qt.PointingHandCursor)
        self.btn_open_exe.clicked.connect(self._on_open_exe)

        self.btn_open_folder = QPushButton("📁 Open Folder")
        self.btn_open_folder.setCursor(Qt.PointingHandCursor)
        self.btn_open_folder.clicked.connect(self._on_open_folder)

        self.btn_build_again = QPushButton("🔄 Build Again")
        self.btn_build_again.setCursor(Qt.PointingHandCursor)
        self.btn_build_again.clicked.connect(lambda: self.stack.setCurrentIndex(0))

        btn_row.addWidget(self.btn_open_exe)
        btn_row.addWidget(self.btn_open_folder)
        btn_row.addWidget(self.btn_build_again)
        card_layout.addLayout(btn_row)

        layout.addWidget(card)
        layout.addStretch()
        return page

    # -------------------------------------------------------------------------
    # PAGE 3: ERROR HANDLING
    # -------------------------------------------------------------------------
    def _build_error_page(self) -> QWidget:
        page = QWidget()
        layout = QVBoxLayout(page)
        layout.setContentsMargins(0, 0, 0, 0)
        layout.setSpacing(20)

        card = QFrame()
        card.setObjectName("GlassPanel")
        card_layout = QVBoxLayout(card)
        card_layout.setContentsMargins(32, 32, 32, 32)
        card_layout.setSpacing(16)

        title = QLabel("✕ Build Failed")
        title.setStyleSheet(f"color: {ThemeColors.STATUS_ERROR}; font-size: 22px; font-weight: 800;")
        card_layout.addWidget(title)

        self.lbl_err_title = QLabel("Clear Explanation:")
        self.lbl_err_title.setObjectName("SectionTitle")
        card_layout.addWidget(self.lbl_err_title)

        self.lbl_err_explanation = QLabel()
        self.lbl_err_explanation.setWordWrap(True)
        self.lbl_err_explanation.setStyleSheet(f"color: {ThemeColors.TEXT_PRIMARY}; font-size: 13px;")
        card_layout.addWidget(self.lbl_err_explanation)

        sol_header = QLabel("Possible Solution:")
        sol_header.setObjectName("SectionTitle")
        card_layout.addWidget(sol_header)

        self.lbl_err_solution = QLabel()
        self.lbl_err_solution.setWordWrap(True)
        self.lbl_err_solution.setStyleSheet(f"color: {ThemeColors.STATUS_WARNING}; font-size: 13px;")
        card_layout.addWidget(self.lbl_err_solution)

        card_layout.addSpacing(12)

        btn_row = QHBoxLayout()
        btn_row.setSpacing(12)

        btn_log = QPushButton("📜 View Detailed Log")
        btn_log.setCursor(Qt.PointingHandCursor)
        btn_log.clicked.connect(lambda: self.stack.setCurrentIndex(1))

        btn_retry = QPushButton("🔄 Retry Build")
        btn_retry.setObjectName("PrimaryButton")
        btn_retry.setCursor(Qt.PointingHandCursor)
        btn_retry.clicked.connect(lambda: self.stack.setCurrentIndex(0))

        btn_row.addWidget(btn_log)
        btn_row.addWidget(btn_retry)
        card_layout.addLayout(btn_row)

        layout.addWidget(card)
        layout.addStretch()
        return page

    # -------------------------------------------------------------------------
    # LOGIC & EVENT HANDLERS
    # -------------------------------------------------------------------------
    def set_project_folder(self, folder_path: str):
        self.input_folder.setText(folder_path)

    def _browse_project_folder(self):
        folder = QFileDialog.getExistingDirectory(self, "Select Python Project Folder")
        if folder:
            self.input_folder.setText(folder)

    def _browse_main_file(self):
        folder = self.input_folder.text().strip()
        start_dir = folder if os.path.exists(folder) else ""
        file_path, _ = QFileDialog.getOpenFileName(self, "Select Main Python File", start_dir, "Python Files (*.py)")
        if file_path:
            rel = os.path.relpath(file_path, folder) if folder and file_path.startswith(folder) else file_path
            self.combo_main.setEditText(rel)

    def _browse_output_folder(self):
        folder = QFileDialog.getExistingDirectory(self, "Select Output Folder")
        if folder:
            self.input_output.setText(folder)

    def _on_project_folder_changed(self, folder_path: str):
        if not folder_path or not os.path.exists(folder_path):
            self.lbl_detected.setText("Folder not found")
            self.lbl_detected.setStyleSheet(f"color: {ThemeColors.TEXT_MUTED}; font-size: 11px;")
            self.combo_main.clear()
            return

        # Auto-detect main file
        details = ProjectDetector.inspect_directory(folder_path)
        self.combo_main.clear()

        candidates = details.get("main_file_candidates", [])
        main_file = details.get("main_file")

        for c in candidates:
            self.combo_main.addItem(c)

        if main_file:
            self.combo_main.setCurrentText(main_file)
            self.lbl_detected.setText("✓ Automatically detected")
            self.lbl_detected.setStyleSheet(f"color: {ThemeColors.STATUS_SUCCESS}; font-size: 11px; font-weight: 600;")
        else:
            self.lbl_detected.setText("Manual selection required")
            self.lbl_detected.setStyleSheet(f"color: {ThemeColors.STATUS_WARNING}; font-size: 11px; font-weight: 600;")

    def _start_build(self):
        folder = self.input_folder.text().strip()
        main_file = self.combo_main.currentText().strip()
        out_folder = self.input_output.text().strip() or os.path.abspath("dist")

        if not folder:
            QMessageBox.warning(self, "Missing Project Folder", "Please select a Python project folder first.")
            return

        if not main_file:
            QMessageBox.warning(self, "Missing Main File", "Please select or specify the main Python script.")
            return

        # Save to recent projects
        self.settings.add_recent_project(folder)

        # Reset steps display
        for item, lbl in self.step_labels.items():
            lbl.setText(f"⚪ {item}")
            lbl.setStyleSheet(f"color: {ThemeColors.TEXT_MUTED}; font-size: 12px;")

        self.log_console.clear()
        self.progress_bar.setValue(0)
        self.lbl_pct.setText("0%")
        self.lbl_operation.setText("→ Initializing build environment...")

        # Switch to progress page
        self.stack.setCurrentIndex(1)

        config = {
            "project_folder": folder,
            "main_file": main_file,
            "output_folder": out_folder,
            "one_file": self.cb_onefile.isChecked(),
            "windowed": self.cb_windowed.isChecked(),
            "console": self.cb_console.isChecked(),
            "include_files": self.cb_files.isChecked(),
            "include_deps": self.cb_deps.isChecked(),
            "optimize": self.cb_opt.isChecked(),
            "clean": self.cb_clean.isChecked()
        }

        self.build_worker = BuildWorker(config)
        self.build_worker.sig_log.connect(self._on_log)
        self.build_worker.sig_step.connect(self._on_step)
        self.build_worker.sig_progress.connect(self._on_progress)
        self.build_worker.sig_finished.connect(self._on_build_success)
        self.build_worker.sig_failed.connect(self._on_build_failed)
        self.build_worker.start()

    def _on_log(self, text: str):
        self.log_console.append(text)

    def _on_step(self, step_text: str, completed: bool):
        if step_text in self.step_labels:
            if completed:
                self.step_labels[step_text].setText(f"✓ {step_text}")
                self.step_labels[step_text].setStyleSheet(f"color: {ThemeColors.STATUS_SUCCESS}; font-size: 12px; font-weight: 600;")

    def _on_progress(self, pct: int, op_name: str):
        self.progress_bar.setValue(pct)
        self.lbl_pct.setText(f"{pct}% completed")
        self.lbl_operation.setText(f"→ {op_name}")

    def _on_build_success(self, summary: dict):
        self.current_build_result = summary

        # Log history record
        self.history.add_record(summary)

        # Update success screen details
        exe_path = summary.get("output_exe", "")
        time_sec = summary.get("build_time_seconds", 0)
        self.lbl_success_details.setText(
            f"Executable location: {exe_path}\n"
            f"Build time: {time_sec}s\n"
            f"Target file: {summary.get('main_file')}"
        )

        # Emit finished signal
        self.sig_build_finished.emit(summary)

        # Delay 0.5s for clean UX transition
        QTimer.singleShot(500, lambda: self.stack.setCurrentIndex(2))

    def _on_build_failed(self, error_dict: dict):
        self.history.add_record(error_dict)

        self.lbl_err_title.setText(error_dict.get("title", "Build Failed"))
        self.lbl_err_explanation.setText(error_dict.get("explanation", "An unexpected build error occurred."))
        self.lbl_err_solution.setText(error_dict.get("solution", "Verify file paths and check dependency configurations."))

        QTimer.singleShot(500, lambda: self.stack.setCurrentIndex(3))

    def _on_open_exe(self):
        if self.current_build_result and "output_exe" in self.current_build_result:
            exe_path = self.current_build_result["output_exe"]
            if os.path.exists(exe_path):
                if os.name == "nt":
                    os.startfile(exe_path)
                else:
                    subprocess.Popen([exe_path])

    def _on_open_folder(self):
        if self.current_build_result and "output_folder" in self.current_build_result:
            folder = self.current_build_result["output_folder"]
            if os.path.exists(folder):
                if os.name == "nt":
                    os.startfile(folder)
                elif os.uname().sysname == "Darwin":
                    subprocess.Popen(["open", folder])
                else:
                    subprocess.Popen(["xdg-open", folder])
