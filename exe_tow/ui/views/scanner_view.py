import os
from PySide6.QtWidgets import (
    QWidget, QVBoxLayout, QHBoxLayout, QLabel, QPushButton, QFrame, QFileDialog, QProgressBar, QScrollArea
)
from PySide6.QtCore import Qt, Signal
from exe_tow.core.scanner import ProjectScanner

class ScannerView(QWidget):
    """Project Scanner view displaying folder scan checklist and Main Entry Point selector panel."""

    proceed_to_build_clicked = Signal(dict) # Emits scan result dict

    def __init__(self, parent=None):
        super().__init__(parent)
        self.scan_result = {}

        scroll = QScrollArea(self)
        scroll.setWidgetResizable(True)
        scroll.setStyleSheet("QScrollArea { border: none; background: transparent; }")

        content_widget = QWidget()
        layout = QVBoxLayout(content_widget)
        layout.setContentsMargins(24, 20, 24, 20)
        layout.setSpacing(18)

        # Header Title
        header_layout = QVBoxLayout()
        header_layout.setSpacing(2)

        title_lbl = QLabel("PROJECT SCANNER")
        title_lbl.setStyleSheet("font-size: 22px; font-weight: 800; color: #FFFFFF; letter-spacing: 1px;")

        self.path_lbl = QLabel("Path: None selected")
        self.path_lbl.setStyleSheet("font-size: 12px; color: #00E5FF; font-family: Consolas, monospace;")

        header_layout.addWidget(title_lbl)
        header_layout.addWidget(self.path_lbl)
        layout.addLayout(header_layout)

        # Progress bar animation container
        self.progress_bar = QProgressBar()
        self.progress_bar.setRange(0, 100)
        self.progress_bar.setValue(100)
        self.progress_bar.setFixedHeight(6)
        self.progress_bar.setTextVisible(False)
        self.progress_bar.setStyleSheet("""
            QProgressBar {
                background-color: #12141A;
                border: none;
                border-radius: 3px;
            }
            QProgressBar::chunk {
                background-color: #00FF66;
                border-radius: 3px;
            }
        """)
        layout.addWidget(self.progress_bar)

        # Detection Results Checklist Card
        checklist_card = QFrame()
        checklist_card.setStyleSheet("""
            QFrame {
                background-color: #12141A;
                border: 1px solid #1E222D;
                border-radius: 8px;
                padding: 16px;
            }
        """)
        checklist_layout = QVBoxLayout(checklist_card)
        checklist_layout.setSpacing(10)

        checklist_title = QLabel("DETECTION RESULTS")
        checklist_title.setStyleSheet("font-size: 12px; font-weight: 800; color: #00FF66; letter-spacing: 1px;")
        checklist_layout.addWidget(checklist_title)

        self.items_layout = QVBoxLayout()
        self.items_layout.setSpacing(8)
        checklist_layout.addLayout(self.items_layout)

        layout.addWidget(checklist_card)

        # Entry Point Dedicated Panel
        entry_card = QFrame()
        entry_card.setStyleSheet("""
            QFrame {
                background-color: #0E151E;
                border: 1px solid #00E5FF;
                border-radius: 8px;
                padding: 16px;
            }
        """)
        entry_layout = QVBoxLayout(entry_card)
        entry_layout.setSpacing(10)

        entry_title = QLabel("ENTRY POINT")
        entry_title.setStyleSheet("font-size: 12px; font-weight: 800; color: #00E5FF; letter-spacing: 1px;")
        entry_layout.addWidget(entry_title)

        # Entry file details
        grid_layout = QHBoxLayout()
        grid_layout.setSpacing(16)

        left_info = QVBoxLayout()
        left_info.setSpacing(4)

        lbl_entry_title = QLabel("Detected main file:")
        lbl_entry_title.setStyleSheet("font-size: 11px; color: #8A8F9E; font-weight: 600;")

        self.val_entry_file = QLabel("main.py")
        self.val_entry_file.setStyleSheet("font-size: 16px; font-weight: 800; color: #FFFFFF; font-family: Consolas, monospace;")

        left_info.addWidget(lbl_entry_title)
        left_info.addWidget(self.val_entry_file)

        right_info = QVBoxLayout()
        right_info.setSpacing(4)

        lbl_loc_title = QLabel("Location:")
        lbl_loc_title.setStyleSheet("font-size: 11px; color: #8A8F9E; font-weight: 600;")

        self.val_entry_loc = QLabel("C:\\Projects\\MyPythonApp\\main.py")
        self.val_entry_loc.setStyleSheet("font-size: 12px; color: #00E5FF; font-family: Consolas, monospace;")

        right_info.addWidget(lbl_loc_title)
        right_info.addWidget(self.val_entry_loc)

        status_box = QVBoxLayout()
        status_box.setSpacing(4)
        lbl_stat_title = QLabel("Status:")
        lbl_stat_title.setStyleSheet("font-size: 11px; color: #8A8F9E; font-weight: 600;")
        self.val_status = QLabel("● READY")
        self.val_status.setStyleSheet("font-size: 12px; font-weight: 800; color: #00FF66;")

        status_box.addWidget(lbl_stat_title)
        status_box.addWidget(self.val_status)

        grid_layout.addLayout(left_info, stretch=2)
        grid_layout.addLayout(right_info, stretch=3)
        grid_layout.addLayout(status_box, stretch=1)

        entry_layout.addLayout(grid_layout)

        # Entry buttons
        ebtn_layout = QHBoxLayout()
        ebtn_layout.setSpacing(10)

        change_btn = QPushButton("CHANGE")
        change_btn.setStyleSheet("""
            QPushButton {
                background-color: #1A1D26;
                color: #FFFFFF;
                border: 1px solid #2B3040;
                border-radius: 6px;
                padding: 6px 16px;
                font-weight: bold;
            }
            QPushButton:hover {
                background-color: #232836;
                border-color: #00E5FF;
                color: #00E5FF;
            }
        """)
        change_btn.clicked.connect(self.change_entry_file)
        ebtn_layout.addWidget(change_btn)

        auto_btn = QPushButton("AUTO DETECT")
        auto_btn.setStyleSheet("""
            QPushButton {
                background-color: #1A1D26;
                color: #00FF66;
                border: 1px solid #00FF66;
                border-radius: 6px;
                padding: 6px 16px;
                font-weight: bold;
            }
            QPushButton:hover {
                background-color: #00FF66;
                color: #090A0D;
            }
        """)
        auto_btn.clicked.connect(self.auto_detect_entry_file)
        ebtn_layout.addWidget(auto_btn)

        ebtn_layout.addStretch()
        entry_layout.addLayout(ebtn_layout)

        layout.addWidget(entry_card)

        # Primary Proceed Action Button
        btn_proceed = QPushButton("PROCEED TO BUILD CONFIGURATION >")
        btn_proceed.setStyleSheet("""
            QPushButton {
                background-color: #00FF66;
                color: #090A0D;
                border: 1px solid #00FF66;
                border-radius: 6px;
                padding: 12px 24px;
                font-weight: 800;
                font-size: 14px;
                letter-spacing: 0.5px;
            }
            QPushButton:hover {
                background-color: #33FF85;
            }
        """)
        btn_proceed.clicked.connect(self.on_proceed)
        layout.addWidget(btn_proceed)

        layout.addStretch()

        scroll.setWidget(content_widget)

        main_layout = QVBoxLayout(self)
        main_layout.setContentsMargins(0, 0, 0, 0)
        main_layout.addWidget(scroll)

    def scan_directory(self, folder_path: str):
        """Scans folder and updates checklist and entry point panel."""
        self.path_lbl.setText(f"Path: {folder_path}")
        scanner = ProjectScanner(folder_path)
        self.scan_result = scanner.scan()

        # Update checklist UI items
        while self.items_layout.count():
            child = self.items_layout.takeAt(0)
            if child.widget():
                child.widget().deleteLater()

        for item in self.scan_result.get("checklist", []):
            row = QHBoxLayout()
            row.setSpacing(10)

            status = item.get("status", "OK")
            if status == "OK":
                mark = "✓"
                color = "#00FF66"
            elif status == "WARNING":
                mark = "!"
                color = "#FFB300"
            else:
                mark = "✕"
                color = "#FF4D4D"

            mark_lbl = QLabel(mark)
            mark_lbl.setStyleSheet(f"font-size: 14px; font-weight: 900; color: {color}; font-family: Consolas, monospace;")
            mark_lbl.setFixedWidth(20)

            text_lbl = QLabel(item.get("label", ""))
            text_lbl.setStyleSheet("font-size: 13px; color: #FFFFFF; font-weight: 600;")

            row.addWidget(mark_lbl)
            row.addWidget(text_lbl)
            row.addStretch()

            container = QWidget()
            container.setLayout(row)
            self.items_layout.addWidget(container)

        # Update entry point panel
        entry_file = self.scan_result.get("entry_file", "main.py")
        full_loc = os.path.join(self.scan_result.get("path", ""), entry_file)
        self.val_entry_file.setText(os.path.basename(entry_file))
        self.val_entry_loc.setText(full_loc)
        self.val_status.setText("● READY" if self.scan_result.get("valid") else "! WARNING")

    def change_entry_file(self):
        project_dir = self.scan_result.get("path", ".")
        file_path, _ = QFileDialog.getOpenFileName(self, "Select Main Python File", project_dir, "Python Files (*.py)")
        if file_path:
            rel_file = os.path.relpath(file_path, project_dir)
            self.scan_result["entry_file"] = rel_file
            self.val_entry_file.setText(os.path.basename(rel_file))
            self.val_entry_loc.setText(file_path)

    def auto_detect_entry_file(self):
        folder_path = self.scan_result.get("path", ".")
        if folder_path:
            self.scan_directory(folder_path)

    def on_proceed(self):
        self.proceed_to_build_clicked.emit(self.scan_result)
