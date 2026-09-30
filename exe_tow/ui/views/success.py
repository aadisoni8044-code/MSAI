import os
import subprocess
from PySide6.QtWidgets import (
    QWidget, QVBoxLayout, QHBoxLayout, QLabel, QPushButton, QFrame, QGridLayout
)
from PySide6.QtCore import Qt, Signal
from PySide6.QtGui import QFont, QCursor

class SuccessView(QWidget):
    build_again_requested = Signal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self.summary = {}

        layout = QVBoxLayout(self)
        layout.setContentsMargins(28, 28, 28, 28)
        layout.setSpacing(24)

        # Success Banner
        banner = QFrame()
        banner.setStyleSheet("""
            QFrame {
                background-color: #0F2018;
                border: 1px solid #1B4D36;
                border-radius: 12px;
                padding: 24px;
            }
        """)
        b_layout = QVBoxLayout(banner)
        b_layout.setSpacing(10)

        lbl_check = QLabel("✓ EXE BUILD COMPLETE")
        lbl_check.setFont(QFont("Segoe UI", 20, QFont.Bold))
        lbl_check.setStyleSheet("color: #10B981;")

        lbl_sub = QLabel("Your application was successfully built.")
        lbl_sub.setFont(QFont("Segoe UI", 12, QFont.Medium))
        lbl_sub.setStyleSheet("color: #D1FAE5;")

        b_layout.addWidget(lbl_check)
        b_layout.addWidget(lbl_sub)

        layout.addWidget(banner)

        # Details Panel
        details_card = QFrame()
        details_card.setStyleSheet("""
            QFrame {
                background-color: #12141C;
                border: 1px solid #202433;
                border-radius: 10px;
                padding: 20px;
            }
        """)
        d_layout = QGridLayout(details_card)
        d_layout.setSpacing(16)

        lbl_f_title = QLabel("EXE Filename:")
        lbl_f_title.setFont(QFont("Segoe UI", 10, QFont.Bold))
        lbl_f_title.setStyleSheet("color: #94A3B8;")

        self.lbl_exe_file = QLabel("app.exe")
        self.lbl_exe_file.setFont(QFont("Segoe UI", 11, QFont.Bold))
        self.lbl_exe_file.setStyleSheet("color: #38BDF8;")

        lbl_loc_title = QLabel("Output Location:")
        lbl_loc_title.setFont(QFont("Segoe UI", 10, QFont.Bold))
        lbl_loc_title.setStyleSheet("color: #94A3B8;")

        self.lbl_output_loc = QLabel("/path/to/dist")
        self.lbl_output_loc.setFont(QFont("Segoe UI", 10))
        self.lbl_output_loc.setStyleSheet("color: #E2E8F0;")
        self.lbl_output_loc.setWordWrap(True)

        lbl_time_title = QLabel("Build Time:")
        lbl_time_title.setFont(QFont("Segoe UI", 10, QFont.Bold))
        lbl_time_title.setStyleSheet("color: #94A3B8;")

        self.lbl_build_time = QLabel("1.8s")
        self.lbl_build_time.setFont(QFont("Segoe UI", 10))
        self.lbl_build_time.setStyleSheet("color: #E2E8F0;")

        lbl_size_title = QLabel("File Size:")
        lbl_size_title.setFont(QFont("Segoe UI", 10, QFont.Bold))
        lbl_size_title.setStyleSheet("color: #94A3B8;")

        self.lbl_file_size = QLabel("12.4 MB")
        self.lbl_file_size.setFont(QFont("Segoe UI", 10))
        self.lbl_file_size.setStyleSheet("color: #E2E8F0;")

        d_layout.addWidget(lbl_f_title, 0, 0)
        d_layout.addWidget(self.lbl_exe_file, 0, 1)
        d_layout.addWidget(lbl_loc_title, 1, 0)
        d_layout.addWidget(self.lbl_output_loc, 1, 1)
        d_layout.addWidget(lbl_time_title, 2, 0)
        d_layout.addWidget(self.lbl_build_time, 2, 1)
        d_layout.addWidget(lbl_size_title, 3, 0)
        d_layout.addWidget(self.lbl_file_size, 3, 1)

        layout.addWidget(details_card)

        # Action Buttons Row
        actions_layout = QHBoxLayout()
        actions_layout.setSpacing(14)

        btn_open_exe = QPushButton("▶ Open EXE")
        btn_open_exe.setFixedHeight(44)
        btn_open_exe.setFont(QFont("Segoe UI", 10, QFont.Bold))
        btn_open_exe.setCursor(QCursor(Qt.PointingHandCursor))
        btn_open_exe.setStyleSheet("""
            QPushButton {
                background-color: #10B981;
                color: #FFFFFF;
                border: none;
                border-radius: 8px;
                padding: 0 20px;
            }
            QPushButton:hover {
                background-color: #059669;
            }
        """)
        btn_open_exe.clicked.connect(self.open_exe)

        btn_open_folder = QPushButton("📁 Open Folder")
        btn_open_folder.setFixedHeight(44)
        btn_open_folder.setFont(QFont("Segoe UI", 10, QFont.Medium))
        btn_open_folder.setCursor(QCursor(Qt.PointingHandCursor))
        btn_open_folder.setStyleSheet("""
            QPushButton {
                background-color: #1E2333;
                color: #FFFFFF;
                border: 1px solid #2B3147;
                border-radius: 8px;
                padding: 0 20px;
            }
            QPushButton:hover {
                background-color: #262C40;
                border-color: #3B82F6;
            }
        """)
        btn_open_folder.clicked.connect(self.open_folder)

        btn_build_again = QPushButton("🔄 Build Again")
        btn_build_again.setFixedHeight(44)
        btn_build_again.setFont(QFont("Segoe UI", 10, QFont.Medium))
        btn_build_again.setCursor(QCursor(Qt.PointingHandCursor))
        btn_build_again.setStyleSheet("""
            QPushButton {
                background-color: #1E2333;
                color: #FFFFFF;
                border: 1px solid #2B3147;
                border-radius: 8px;
                padding: 0 20px;
            }
            QPushButton:hover {
                background-color: #262C40;
                border-color: #3B82F6;
            }
        """)
        btn_build_again.clicked.connect(self.build_again_requested.emit)

        actions_layout.addWidget(btn_open_exe)
        actions_layout.addWidget(btn_open_folder)
        actions_layout.addWidget(btn_build_again)
        actions_layout.addStretch()

        layout.addLayout(actions_layout)
        layout.addStretch()

    def set_summary(self, summary: dict):
        self.summary = summary
        self.lbl_exe_file.setText(summary.get("exe_filename", "app.exe"))
        self.lbl_output_loc.setText(summary.get("output_location", ""))
        self.lbl_build_time.setText(summary.get("build_time", "0s"))
        self.lbl_file_size.setText(summary.get("file_size", "0 MB"))

    def open_exe(self):
        exe_path = self.summary.get("exe_path", "")
        if exe_path and os.path.exists(exe_path):
            try:
                if os.name == 'nt':
                    os.startfile(exe_path)
                else:
                    subprocess.Popen([exe_path])
            except Exception:
                pass

    def open_folder(self):
        folder = self.summary.get("output_location", "")
        if folder and os.path.exists(folder):
            try:
                if os.name == 'nt':
                    os.startfile(folder)
                elif os.name == 'posix':
                    subprocess.Popen(['xdg-open', folder])
            except Exception:
                pass
