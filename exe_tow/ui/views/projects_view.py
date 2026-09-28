import os
from pathlib import Path
from PySide6.QtWidgets import (
    QWidget, QVBoxLayout, QHBoxLayout, QLabel, QLineEdit, QPushButton, QFrame, QTextEdit, QFileDialog, QMessageBox
)
from PySide6.QtCore import Qt
from exe_tow.ui.theme import Theme
from exe_tow.core.project_analyzer import ProjectAnalyzer

class ProjectsView(QWidget):
    def __init__(self, parent=None):
        super().__init__(parent)

        layout = QVBoxLayout(self)
        layout.setContentsMargins(24, 24, 24, 24)
        layout.setSpacing(16)

        title = QLabel("Project Analyzer & Workspace")
        title.setObjectName("heading")
        layout.addWidget(title)

        # File Selection Card
        card = QFrame()
        card.setObjectName("card")
        c_layout = QHBoxLayout(card)

        self.txt_path = QLineEdit()
        self.txt_path.setPlaceholderText("Select or enter a Python project directory / file...")
        c_layout.addWidget(self.txt_path)

        btn_browse = QPushButton("Browse")
        btn_browse.clicked.connect(self._browse)
        c_layout.addWidget(btn_browse)

        btn_analyze = QPushButton("Analyze")
        btn_analyze.setObjectName("primary")
        btn_analyze.clicked.connect(self._analyze)
        c_layout.addWidget(btn_analyze)

        layout.addWidget(card)

        # Analysis Output Inspector
        self.output = QTextEdit()
        self.output.setReadOnly(True)
        self.output.setPlaceholderText("Detailed project analysis output will appear here...")
        layout.addWidget(self.output)

    def _browse(self):
        f, _ = QFileDialog.getOpenFileName(self, "Select Python File", "", "Python (*.py);;All Files (*)")
        if not f:
            f = QFileDialog.getExistingDirectory(self, "Select Project Folder")
        if f:
            self.txt_path.setText(f)
            self._analyze()

    def _analyze(self):
        path = self.txt_path.text().strip()
        if not path or not os.path.exists(path):
            QMessageBox.warning(self, "Warning", "Please select a valid file or directory.")
            return

        try:
            analyzer = ProjectAnalyzer(path)
            info = analyzer.analyze()

            res = []
            res.append(f"PROJECT NAME: {info.project_name}")
            res.append(f"PROJECT PATH: {info.project_path}")
            res.append(f"ENTRY FILE:   {info.entry_file}")
            res.append(f"TYPE:         {'Single File Script' if info.is_single_file else 'Directory Package'}")
            res.append(f"REQUIREMENTS: {'Found (' + str(info.requirements_path) + ')' if info.has_requirements else 'Not Detected'}")
            res.append(f"VIRTUAL ENV:  {'Found (' + str(info.venv_path) + ')' if info.has_venv else 'Not Detected'}")
            res.append("\n" + "="*50)
            res.append("DETECTED IMPORTS:")
            for imp in info.detected_imports:
                res.append(f" - {imp}")

            res.append("\n" + "="*50)
            res.append("DETECTED LOCAL ASSETS:")
            for asset in info.local_assets:
                res.append(f" - {asset}")

            self.output.setText("\n".join(res))
        except Exception as e:
            self.output.setText(f"Error during project analysis:\n{str(e)}")
