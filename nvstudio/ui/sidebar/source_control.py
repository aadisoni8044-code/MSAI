"""NV Studio Source Control (Git) Sidebar Panel"""
import os
import subprocess
from pathlib import Path
from typing import List, Tuple
from PyQt6.QtCore import pyqtSignal, Qt
from PyQt6.QtWidgets import (
    QHBoxLayout, QLabel, QLineEdit, QListWidget, QListWidgetItem,
    QPushButton, QVBoxLayout, QWidget, QMessageBox, QTextEdit
)

from nvstudio.core.workspace import workspace_manager


class SourceControlPanel(QWidget):
    """Source Control Sidebar Panel with Git status inspection, stage/unstage, and commit actions."""
    file_selected = pyqtSignal(str)

    def __init__(self, parent=None):
        super().__init__(parent)
        self.setObjectName("SourceControlPanel")

        layout = QVBoxLayout(self)
        layout.setContentsMargins(0, 0, 0, 0)
        layout.setSpacing(8)

        # Header
        header = QLabel("SOURCE CONTROL: GIT")
        header.setObjectName("SidebarHeader")
        layout.addWidget(header)

        container = QWidget()
        c_layout = QVBoxLayout(container)
        c_layout.setContentsMargins(8, 0, 8, 0)
        c_layout.setSpacing(6)

        # Commit Message Box
        self.commit_msg_input = QTextEdit()
        self.commit_msg_input.setPlaceholderText("Message (Ctrl+Enter to commit)")
        self.commit_msg_input.setMaximumHeight(70)
        c_layout.addWidget(self.commit_msg_input)

        # Action Buttons
        btn_layout = QHBoxLayout()
        self.commit_btn = QPushButton("Commit Changes")
        self.commit_btn.clicked.connect(self.git_commit)

        self.refresh_btn = QPushButton("🔄")
        self.refresh_btn.setToolTip("Refresh Git Status")
        self.refresh_btn.clicked.connect(self.refresh_status)

        btn_layout.addWidget(self.commit_btn)
        btn_layout.addWidget(self.refresh_btn)
        c_layout.addLayout(btn_layout)

        # Branch Status Label
        self.branch_label = QLabel("Branch: unknown")
        self.branch_label.setStyleSheet("color: #4f80ff; font-weight: 600; font-size: 11px;")
        c_layout.addWidget(self.branch_label)

        layout.addWidget(container)

        # Changes Label
        changes_header = QLabel("  CHANGED FILES")
        changes_header.setStyleSheet("color: #94a3b8; font-size: 11px; font-weight: 600;")
        layout.addWidget(changes_header)

        # Changes List
        self.changes_list = QListWidget()
        self.changes_list.itemDoubleClicked.connect(self._on_item_double_clicked)
        layout.addWidget(self.changes_list)

        # Connect workspace manager
        workspace_manager.folder_changed.connect(lambda: self.refresh_status())

    def run_git_cmd(self, args: List[str]) -> Tuple[int, str, str]:
        root = workspace_manager.get_root_path()
        if not root:
            return -1, "", "No workspace folder open"
        try:
            res = subprocess.run(
                ["git"] + args,
                cwd=root,
                capture_output=True,
                text=True,
                timeout=10
            )
            return res.returncode, res.stdout, res.stderr
        except Exception as e:
            return -1, "", str(e)

    def refresh_status(self) -> None:
        self.changes_list.clear()
        root = workspace_manager.get_root_path()
        if not root:
            self.branch_label.setText("No folder open")
            return

        # Check git repo
        code, branch_out, _ = self.run_git_cmd(["rev-parse", "--abbrev-ref", "HEAD"])
        if code != 0:
            self.branch_label.setText("Not a Git repository")
            return

        self.branch_label.setText(f"Branch: {branch_out.strip()}")

        # Get git status porcelain
        code, status_out, _ = self.run_git_cmd(["status", "--porcelain"])
        if code == 0 and status_out:
            lines = status_out.strip().split("\n")
            for line in lines:
                if len(line) >= 3:
                    st = line[:2]
                    file_p = line[3:].strip()
                    item_str = f"[{st.strip()}] {file_p}"
                    item = QListWidgetItem(item_str)
                    full_path = os.path.join(root, file_p)
                    item.setData(Qt.ItemDataRole.UserRole, full_path)
                    self.changes_list.addItem(item)
        elif code == 0:
            item = QListWidgetItem("No modified files")
            item.setFlags(Qt.ItemFlag.NoItemFlags)
            self.changes_list.addItem(item)

    def _on_item_double_clicked(self, item: QListWidgetItem) -> None:
        path = item.data(Qt.ItemDataRole.UserRole)
        if path and os.path.exists(path):
            self.file_selected.emit(path)

    def git_commit(self) -> None:
        msg = self.commit_msg_input.toPlainText().strip()
        if not msg:
            QMessageBox.warning(self, "Commit Failed", "Please enter a commit message.")
            return

        # Git add all modified files
        code, _, err = self.run_git_cmd(["add", "-A"])
        if code != 0:
            QMessageBox.critical(self, "Git Add Failed", err)
            return

        code, out, err = self.run_git_cmd(["commit", "-m", msg])
        if code == 0:
            QMessageBox.information(self, "Commit Successful", f"Git commit completed:\n{out}")
            self.commit_msg_input.clear()
            self.refresh_status()
        else:
            QMessageBox.warning(self, "Commit Failed", f"Could not commit:\n{err or out}")
