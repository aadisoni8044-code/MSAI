import os
from PySide6.QtWidgets import (
    QWidget, QVBoxLayout, QHBoxLayout, QLabel, QLineEdit, QPushButton,
    QFrame, QGridLayout, QComboBox, QFileDialog, QScrollArea
)
from PySide6.QtCore import Qt, Signal
from PySide6.QtGui import QFont, QPixmap, QCursor

class SettingsView(QWidget):
    settings_updated = Signal()

    def __init__(self, storage_mgr, parent=None):
        super().__init__(parent)
        self.storage_mgr = storage_mgr

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

        # Title
        lbl_title = QLabel("Settings")
        lbl_title.setFont(QFont("Segoe UI", 18, QFont.Bold))
        lbl_title.setStyleSheet("color: #FFFFFF;")
        layout.addWidget(lbl_title)

        settings = self.storage_mgr.get_settings()

        # Settings Form Card
        card = QFrame()
        card.setStyleSheet("""
            QFrame {
                background-color: #12141C;
                border: 1px solid #202433;
                border-radius: 10px;
                padding: 20px;
            }
        """)
        c_layout = QGridLayout(card)
        c_layout.setSpacing(16)

        # 1. Python Interpreter
        lbl_py = QLabel("Python Interpreter Path")
        lbl_py.setFont(QFont("Segoe UI", 10, QFont.Bold))
        lbl_py.setStyleSheet("color: #CBD5E1;")

        self.txt_python_path = QLineEdit()
        self.txt_python_path.setText(settings.get("python_interpreter", "python"))
        self.txt_python_path.setFixedHeight(38)

        # 2. Default Output Folder
        lbl_out = QLabel("Default Output Folder")
        lbl_out.setFont(QFont("Segoe UI", 10, QFont.Bold))
        lbl_out.setStyleSheet("color: #CBD5E1;")

        out_row = QHBoxLayout()
        self.txt_out_folder = QLineEdit()
        self.txt_out_folder.setText(settings.get("default_output_folder", ""))
        self.txt_out_folder.setFixedHeight(38)

        btn_out_browse = QPushButton("Browse")
        btn_out_browse.setFixedHeight(38)
        btn_out_browse.setCursor(QCursor(Qt.PointingHandCursor))
        btn_out_browse.setStyleSheet("""
            QPushButton {
                background-color: #1E2333;
                color: #FFFFFF;
                border: 1px solid #2B3147;
                border-radius: 6px;
                padding: 0 16px;
            }
            QPushButton:hover {
                border-color: #3B82F6;
            }
        """)
        btn_out_browse.clicked.connect(self.browse_out_dir)

        out_row.addWidget(self.txt_out_folder, stretch=1)
        out_row.addWidget(btn_out_browse)

        # 3. Build Engine Settings
        lbl_engine = QLabel("Build Engine")
        lbl_engine.setFont(QFont("Segoe UI", 10, QFont.Bold))
        lbl_engine.setStyleSheet("color: #CBD5E1;")

        self.combo_engine = QComboBox()
        self.combo_engine.setFixedHeight(38)
        self.combo_engine.addItems(["PyInstaller (Default)", "Nuitka", "cx_Freeze"])

        # 4. Theme
        lbl_theme = QLabel("Interface Theme")
        lbl_theme.setFont(QFont("Segoe UI", 10, QFont.Bold))
        lbl_theme.setStyleSheet("color: #CBD5E1;")

        self.combo_theme = QComboBox()
        self.combo_theme.setFixedHeight(38)
        self.combo_theme.addItems(["Dark (System Native)", "Deep Black / Charcoal"])

        # 5. Log Level
        lbl_log = QLabel("Log Settings")
        lbl_log.setFont(QFont("Segoe UI", 10, QFont.Bold))
        lbl_log.setStyleSheet("color: #CBD5E1;")

        self.combo_log = QComboBox()
        self.combo_log.setFixedHeight(38)
        self.combo_log.addItems(["DEBUG (Verbose)", "INFO (Standard)", "WARN (Errors only)"])

        c_layout.addWidget(lbl_py, 0, 0)
        c_layout.addWidget(self.txt_python_path, 1, 0)
        c_layout.addWidget(lbl_out, 2, 0)
        c_layout.addLayout(out_row, 3, 0)
        c_layout.addWidget(lbl_engine, 4, 0)
        c_layout.addWidget(self.combo_engine, 5, 0)
        c_layout.addWidget(lbl_theme, 6, 0)
        c_layout.addWidget(self.combo_theme, 7, 0)
        c_layout.addWidget(lbl_log, 8, 0)
        c_layout.addWidget(self.combo_log, 9, 0)

        layout.addWidget(card)

        # Save Button
        btn_save = QPushButton("💾 Save Preferences")
        btn_save.setFixedHeight(44)
        btn_save.setFont(QFont("Segoe UI", 10, QFont.Bold))
        btn_save.setCursor(QCursor(Qt.PointingHandCursor))
        btn_save.setStyleSheet("""
            QPushButton {
                background-color: #2563EB;
                color: #FFFFFF;
                border: none;
                border-radius: 8px;
                padding: 0 24px;
            }
            QPushButton:hover {
                background-color: #1D4ED8;
            }
        """)
        btn_save.clicked.connect(self.save_settings)

        layout.addWidget(btn_save)
        layout.addStretch()

    def browse_out_dir(self):
        folder = QFileDialog.getExistingDirectory(self, "Select Default Output Directory")
        if folder:
            self.txt_out_folder.setText(folder)

    def save_settings(self):
        new_settings = {
            "python_interpreter": self.txt_python_path.text().strip() or "python",
            "default_output_folder": self.txt_out_folder.text().strip(),
            "theme": self.combo_theme.currentText(),
            "log_level": self.combo_log.currentText()
        }
        self.storage_mgr.update_settings(new_settings)
        self.settings_updated.emit()


class AboutView(QWidget):
    def __init__(self, logo_path: str = "", parent=None):
        super().__init__(parent)

        layout = QVBoxLayout(self)
        layout.setContentsMargins(28, 28, 28, 28)
        layout.setSpacing(24)

        lbl_title = QLabel("About exe/tow")
        lbl_title.setFont(QFont("Segoe UI", 18, QFont.Bold))
        lbl_title.setStyleSheet("color: #FFFFFF;")
        layout.addWidget(lbl_title)

        card = QFrame()
        card.setStyleSheet("""
            QFrame {
                background-color: #12141C;
                border: 1px solid #202433;
                border-radius: 12px;
                padding: 28px;
            }
        """)
        c_layout = QVBoxLayout(card)
        c_layout.setSpacing(16)

        # Logo Display
        if logo_path and os.path.exists(logo_path):
            logo_lbl = QLabel()
            pixmap = QPixmap(logo_path)
            logo_lbl.setPixmap(pixmap.scaledToHeight(48, Qt.SmoothTransformation))
            c_layout.addWidget(logo_lbl)
        else:
            text_logo = QLabel("exe/tow")
            text_logo.setFont(QFont("Segoe UI", 28, QFont.Bold))
            text_logo.setStyleSheet("color: #FFFFFF;")
            c_layout.addWidget(text_logo)

        lbl_desc = QLabel(
            "exe/tow is a professional Python project-to-EXE desktop application builder designed "
            "to automatically detect main entry files, project assets, and python dependencies before "
            "packaging them into clean, standalone Windows executables."
        )
        lbl_desc.setFont(QFont("Segoe UI", 11))
        lbl_desc.setStyleSheet("color: #94A3B8; line-height: 1.5;")
        lbl_desc.setWordWrap(True)

        ver_label = QLabel("Version: 1.0.0 Pro Edition\nEngine: PyInstaller 6.x / Standard Distribution")
        ver_label.setFont(QFont("Segoe UI", 10, QFont.Medium))
        ver_label.setStyleSheet("color: #38BDF8;")

        c_layout.addWidget(lbl_desc)
        c_layout.addWidget(ver_label)

        layout.addWidget(card)
        layout.addStretch()
