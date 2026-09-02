"""
MSAI Studio - Status Bar Component
"""
import os
import sys
from PyQt6.QtWidgets import QStatusBar, QLabel, QPushButton, QHBoxLayout, QWidget, QMenu
from PyQt6.QtCore import pyqtSignal
from core.interpreter_manager import InterpreterManager

class StatusBar(QStatusBar):
    """
    Bottom Status Bar displaying file information, line/column cursor positions,
    tab size, encoding, Git branch name, error/warning counters, and Python interpreter selector.
    """
    interpreter_selected = pyqtSignal(str)

    def __init__(self, parent=None):
        super().__init__(parent)
        self.setStyleSheet("""
            QStatusBar {
                background-color: #11111b;
                color: #a6adc8;
                border-top: 1px solid #313244;
                font-size: 11px;
            }
            QLabel, QPushButton {
                color: #a6adc8;
                font-size: 11px;
                padding: 2px 6px;
                background: transparent;
                border: none;
            }
            QPushButton:hover {
                background-color: #313244;
                color: #cdd6f4;
            }
        """)

        # Left Widgets
        self.git_btn = QPushButton("🌿 main")
        self.git_btn.setToolTip("Active Git Branch")

        self.error_btn = QPushButton("🚫 0  ⚠️ 0")
        self.error_btn.setToolTip("Problems & Warnings")

        # Right Widgets
        self.file_info_label = QLabel("Untitled.py")
        self.cursor_label = QLabel("Ln 1, Col 1")
        self.spaces_label = QLabel("Spaces: 4")
        self.encoding_label = QLabel("UTF-8")
        self.lang_label = QLabel("Python")
        self.interpreter_btn = QPushButton(f"🐍 Python ({sys.executable})")
        self.interpreter_btn.setToolTip("Select Python Interpreter")
        self.interpreter_btn.clicked.connect(self._show_interpreter_menu)

        self.addWidget(self.git_btn)
        self.addWidget(self.error_btn)

        self.addPermanentWidget(self.file_info_label)
        self.addPermanentWidget(self.cursor_label)
        self.addPermanentWidget(self.spaces_label)
        self.addPermanentWidget(self.encoding_label)
        self.addPermanentWidget(self.lang_label)
        self.addPermanentWidget(self.interpreter_btn)

    def set_file_info(self, file_path: str):
        if file_path:
            self.file_info_label.setText(os.path.basename(file_path))
        else:
            self.file_info_label.setText("No File Opened")

    def set_cursor_pos(self, line: int, col: int):
        self.cursor_label.setText(f"Ln {line}, Col {col}")

    def set_git_branch(self, branch: str):
        self.git_btn.setText(f"🌿 {branch}")

    def set_interpreter_label(self, label: str):
        self.interpreter_btn.setText(f"🐍 {label}")

    def _show_interpreter_menu(self):
        menu = QMenu(self)
        interpreters = InterpreterManager.get_system_interpreters()

        for item in interpreters:
            path = item["path"]
            label = item["label"]
            action = menu.addAction(label)
            action.triggered.connect(lambda _, p=path: self.interpreter_selected.emit(p))

        menu.exec(self.interpreter_btn.mapToGlobal(self.interpreter_btn.rect().bottomLeft()))
