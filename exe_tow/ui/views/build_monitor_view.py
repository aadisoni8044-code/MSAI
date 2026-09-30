import os
import subprocess
from PySide6.QtWidgets import (
    QWidget, QVBoxLayout, QHBoxLayout, QLabel, QPushButton, QProgressBar, QFrame, QScrollArea, QStackedLayout
)
from PySide6.QtCore import Qt, Signal
from exe_tow.ui.components.pipeline_widget import PipelineWidget
from exe_tow.ui.components.terminal_panel import TerminalPanel
from exe_tow.ui.components.dialogs import LogViewerDialog

class BuildMonitorView(QWidget):
    """Real-time build monitor screen managing progress, pipeline steps, live terminal, and result views."""

    build_again_clicked = Signal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self.last_result = {}

        main_layout = QVBoxLayout(self)
        main_layout.setContentsMargins(20, 16, 20, 16)
        main_layout.setSpacing(14)

        # Header Title
        header_box = QHBoxLayout()
        header_box.setSpacing(10)

        title_layout = QVBoxLayout()
        title_layout.setSpacing(2)

        self.lbl_header = QLabel("BUILDING APPLICATION")
        self.lbl_header.setStyleSheet("font-size: 20px; font-weight: 800; color: #FFFFFF; letter-spacing: 1px;")

        self.lbl_sub_header = QLabel("MyPythonApp.exe")
        self.lbl_sub_header.setStyleSheet("font-size: 13px; font-weight: 700; color: #00FF66; font-family: Consolas, monospace;")

        title_layout.addWidget(self.lbl_header)
        title_layout.addWidget(self.lbl_sub_header)

        header_box.addLayout(title_layout)
        header_box.addStretch()

        main_layout.addLayout(header_box)

        # Stacked Container: 0 = Building State, 1 = Success State, 2 = Error State
        self.result_stack = QStackedLayout()

        # 0: ACTIVE BUILDING VIEW
        building_widget = QWidget()
        b_layout = QVBoxLayout(building_widget)
        b_layout.setContentsMargins(0, 0, 0, 0)
        b_layout.setSpacing(12)

        # Progress bar area
        progress_card = QFrame()
        progress_card.setStyleSheet("""
            QFrame {
                background-color: #12141A;
                border: 1px solid #1E222D;
                border-radius: 8px;
                padding: 14px;
            }
        """)
        p_card_layout = QVBoxLayout(progress_card)
        p_card_layout.setSpacing(8)

        op_header = QHBoxLayout()
        self.lbl_operation = QLabel("PACKAGING PROJECT...")
        self.lbl_operation.setStyleSheet("font-size: 12px; font-weight: 800; color: #00E5FF; letter-spacing: 1px;")

        self.lbl_percent = QLabel("0%")
        self.lbl_percent.setStyleSheet("font-size: 18px; font-weight: 900; color: #00FF66;")

        op_header.addWidget(self.lbl_operation)
        op_header.addStretch()
        op_header.addWidget(self.lbl_percent)
        p_card_layout.addLayout(op_header)

        self.progress_bar = QProgressBar()
        self.progress_bar.setRange(0, 100)
        self.progress_bar.setValue(0)
        self.progress_bar.setFixedHeight(12)
        self.progress_bar.setTextVisible(False)
        self.progress_bar.setStyleSheet("""
            QProgressBar {
                background-color: #0A0C10;
                border: 1px solid #1C202C;
                border-radius: 6px;
            }
            QProgressBar::chunk {
                background: qlineargradient(x1:0, y1:0, x2:1, y2:0, stop:0 #00FF66, stop:1 #00E5FF);
                border-radius: 5px;
            }
        """)
        p_card_layout.addWidget(self.progress_bar)

        b_layout.addWidget(progress_card)

        # Pipeline Steps Widget
        self.pipeline_widget = PipelineWidget()
        b_layout.addWidget(self.pipeline_widget)

        self.result_stack.addWidget(building_widget)

        # 1: SUCCESS VIEW
        success_widget = QWidget()
        s_layout = QVBoxLayout(success_widget)
        s_layout.setContentsMargins(0, 0, 0, 0)
        s_layout.setSpacing(12)

        s_card = QFrame()
        s_card.setStyleSheet("""
            QFrame {
                background-color: #0E1F16;
                border: 1px solid #00FF66;
                border-radius: 8px;
                padding: 18px;
            }
        """)
        sc_layout = QVBoxLayout(s_card)
        sc_layout.setSpacing(10)

        s_top = QHBoxLayout()
        s_mark = QLabel("✓")
        s_mark.setStyleSheet("font-size: 28px; font-weight: 900; color: #00FF66;")

        s_head = QVBoxLayout()
        s_lbl_title = QLabel("BUILD COMPLETE")
        s_lbl_title.setStyleSheet("font-size: 18px; font-weight: 900; color: #FFFFFF;")

        self.s_lbl_sub = QLabel("MyPythonApp.exe was successfully created.")
        self.s_lbl_sub.setStyleSheet("font-size: 13px; color: #00FF66;")

        s_head.addWidget(s_lbl_title)
        s_head.addWidget(self.s_lbl_sub)

        s_top.addWidget(s_mark)
        s_top.addLayout(s_head)
        s_top.addStretch()
        sc_layout.addLayout(s_top)

        # Details Grid
        details_grid = QHBoxLayout()
        details_grid.setSpacing(10)

        self.v_s_file = self._create_result_item("FILE", "MyPythonApp.exe", details_grid)
        self.v_s_size = self._create_result_item("SIZE", "42.8 MB", details_grid)
        self.v_s_loc = self._create_result_item("LOCATION", "C:\\dist", details_grid)
        self.v_s_time = self._create_result_item("BUILD TIME", "18.4 seconds", details_grid)

        sc_layout.addLayout(details_grid)

        # Action Buttons
        s_btn_layout = QHBoxLayout()
        s_btn_layout.setSpacing(10)

        btn_open_exe = QPushButton("OPEN EXE")
        btn_open_exe.setStyleSheet("""
            QPushButton {
                background-color: #00FF66;
                color: #090A0D;
                border: 1px solid #00FF66;
                border-radius: 6px;
                padding: 8px 18px;
                font-weight: 800;
            }
            QPushButton:hover { background-color: #33FF85; }
        """)
        btn_open_exe.clicked.connect(self.open_generated_exe)
        s_btn_layout.addWidget(btn_open_exe)

        btn_open_dir = QPushButton("OPEN FOLDER")
        btn_open_dir.setStyleSheet("""
            QPushButton {
                background-color: #1A1D26;
                color: #00E5FF;
                border: 1px solid #00E5FF;
                border-radius: 6px;
                padding: 8px 18px;
                font-weight: 800;
            }
            QPushButton:hover { background-color: #232836; }
        """)
        btn_open_dir.clicked.connect(self.open_output_folder)
        s_btn_layout.addWidget(btn_open_dir)

        btn_again = QPushButton("BUILD AGAIN")
        btn_again.setStyleSheet("""
            QPushButton {
                background-color: #1A1D26;
                color: #FFFFFF;
                border: 1px solid #2B3040;
                border-radius: 6px;
                padding: 8px 18px;
                font-weight: bold;
            }
            QPushButton:hover { background-color: #232836; }
        """)
        btn_again.clicked.connect(lambda: self.build_again_clicked.emit())
        s_btn_layout.addWidget(btn_again)

        s_btn_layout.addStretch()
        sc_layout.addLayout(s_btn_layout)

        s_layout.addWidget(s_card)
        self.result_stack.addWidget(success_widget)

        # 2: ERROR VIEW
        err_widget = QWidget()
        e_layout = QVBoxLayout(err_widget)
        e_layout.setContentsMargins(0, 0, 0, 0)
        e_layout.setSpacing(12)

        e_card = QFrame()
        e_card.setStyleSheet("""
            QFrame {
                background-color: #261215;
                border: 1px solid #FF4D4D;
                border-radius: 8px;
                padding: 18px;
            }
        """)
        ec_layout = QVBoxLayout(e_card)
        ec_layout.setSpacing(10)

        e_top = QHBoxLayout()
        e_mark = QLabel("✕")
        e_mark.setStyleSheet("font-size: 28px; font-weight: 900; color: #FF4D4D;")

        e_head = QVBoxLayout()
        e_lbl_title = QLabel("BUILD FAILED")
        e_lbl_title.setStyleSheet("font-size: 18px; font-weight: 900; color: #FFFFFF;")

        self.e_lbl_summary = QLabel("Unable to package the project because a required dependency could not be resolved.")
        self.e_lbl_summary.setStyleSheet("font-size: 13px; color: #FF4D4D;")

        e_head.addWidget(e_lbl_title)
        e_head.addWidget(self.e_lbl_summary)

        e_top.addWidget(e_mark)
        e_top.addLayout(e_head)
        e_top.addStretch()
        ec_layout.addLayout(e_top)

        # Error buttons
        e_btn_layout = QHBoxLayout()
        e_btn_layout.setSpacing(10)

        btn_view_log = QPushButton("VIEW LOG")
        btn_view_log.setStyleSheet("""
            QPushButton {
                background-color: #1A1D26;
                color: #00E5FF;
                border: 1px solid #00E5FF;
                border-radius: 6px;
                padding: 8px 18px;
                font-weight: bold;
            }
            QPushButton:hover { background-color: #232836; }
        """)
        btn_view_log.clicked.connect(self.view_full_log)
        e_btn_layout.addWidget(btn_view_log)

        btn_try_again = QPushButton("TRY AGAIN")
        btn_try_again.setStyleSheet("""
            QPushButton {
                background-color: #FF4D4D;
                color: #FFFFFF;
                border: 1px solid #FF4D4D;
                border-radius: 6px;
                padding: 8px 18px;
                font-weight: 800;
            }
            QPushButton:hover { background-color: #FF6666; }
        """)
        btn_try_again.clicked.connect(lambda: self.build_again_clicked.emit())
        e_btn_layout.addWidget(btn_try_again)

        e_btn_layout.addStretch()
        ec_layout.addLayout(e_btn_layout)

        e_layout.addWidget(e_card)
        self.result_stack.addWidget(err_widget)

        main_layout.addLayout(self.result_stack)

        # Live Terminal Panel (Always visible at bottom)
        self.terminal_panel = TerminalPanel()
        main_layout.addWidget(self.terminal_panel)

    def _create_result_item(self, label: str, val: str, parent_layout) -> QLabel:
        box = QVBoxLayout()
        box.setSpacing(2)

        lbl = QLabel(label)
        lbl.setStyleSheet("font-size: 10px; font-weight: 800; color: #8A8F9E;")

        v_lbl = QLabel(val)
        v_lbl.setStyleSheet("font-size: 12px; font-weight: 800; color: #00FF66; font-family: Consolas, monospace;")

        box.addWidget(lbl)
        box.addWidget(v_lbl)

        container = QFrame()
        container.setLayout(box)
        container.setStyleSheet("background-color: #0A0C10; border: 1px solid #1C202C; border-radius: 6px; padding: 6px;")
        parent_layout.addWidget(container)
        return v_lbl

    def prepare_for_build(self, app_name: str, exe_filename: str):
        self.lbl_header.setText("BUILDING APPLICATION")
        self.lbl_sub_header.setText(exe_filename)
        self.progress_bar.setValue(0)
        self.lbl_percent.setText("0%")
        self.lbl_operation.setText("INITIALIZING BUILD ENGINE...")
        self.pipeline_widget.reset_pipeline()
        self.terminal_panel.clear_logs()
        self.result_stack.setCurrentIndex(0)

    def update_progress(self, val: int):
        self.progress_bar.setValue(val)
        self.lbl_percent.setText(f"{val}%")

    def update_step(self, step_index: int, step_name: str):
        self.pipeline_widget.set_current_step(step_index)
        self.lbl_operation.setText(f"{step_name}...")

    def append_log_line(self, line: str):
        self.terminal_panel.append_log(line)

    def handle_build_finished(self, result: dict):
        self.last_result = result
        if result.get("result") == "SUCCESS":
            self.result_stack.setCurrentIndex(1)
            exe_name = result.get("exe_name", "MyPythonApp.exe")
            out_dir = result.get("output_dir", "")
            out_path = result.get("output_path", os.path.join(out_dir, exe_name))
            size_str = result.get("size_str", "42.8 MB")
            dur_str = f"{result.get('duration_sec', 18.4)} seconds"

            self.s_lbl_sub.setText(f"'{exe_name}' was successfully created.")
            self.v_s_file.setText(exe_name)
            self.v_s_size.setText(size_str)
            self.v_s_loc.setText(out_dir)
            self.v_s_time.setText(dur_str)
        else:
            self.result_stack.setCurrentIndex(2)
            err_msg = result.get("error", "An unexpected error occurred during PyInstaller execution.")
            self.e_lbl_summary.setText(err_msg)

    def open_generated_exe(self):
        out_path = self.last_result.get("output_path", "")
        if os.path.exists(out_path):
            try:
                if os.name == "nt":
                    os.startfile(out_path)
                else:
                    subprocess.Popen([out_path])
            except Exception as e:
                print(f"Error launching EXE: {e}")

    def open_output_folder(self):
        out_dir = self.last_result.get("output_dir", ".")
        if os.path.exists(out_dir):
            try:
                if os.name == "nt":
                    os.startfile(out_dir)
                else:
                    subprocess.Popen(["xdg-open", out_dir])
            except Exception as e:
                print(f"Error opening folder: {e}")

    def view_full_log(self):
        logs = self.last_result.get("logs", [self.terminal_panel.get_logs_text()])
        dlg = LogViewerDialog("Build Log Details", logs, self)
        dlg.exec()
