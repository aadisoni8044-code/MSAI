"""
MSAI Studio - Source Control View Component
"""
from PyQt6.QtWidgets import (
    QWidget, QVBoxLayout, QHBoxLayout, QLabel, QListWidget, QListWidgetItem,
    QPushButton, QLineEdit, QComboBox, QMessageBox
)
from PyQt6.QtCore import pyqtSignal, Qt
from git.git_manager import GitManager

class GitView(QWidget):
    """
    Git source control view displaying staged/unstaged changes,
    commit message input, stage/unstage controls, and branch selector.
    """
    file_selected = pyqtSignal(str)

    def __init__(self, parent=None):
        super().__init__(parent)
        self.git_manager = GitManager()

        layout = QVBoxLayout(self)
        layout.setContentsMargins(8, 8, 8, 8)

        title = QLabel("SOURCE CONTROL")
        title.setStyleSheet("font-size: 11px; font-weight: bold; color: #a6adc8;")
        layout.addWidget(title)

        # Branch selector
        branch_layout = QHBoxLayout()
        branch_layout.addWidget(QLabel("Branch:"))
        self.combo_branch = QComboBox()
        self.combo_branch.setMinimumWidth(120)
        branch_layout.addWidget(self.combo_branch)
        self.btn_git_refresh = QPushButton("🔄")
        self.btn_git_refresh.setFixedWidth(28)
        self.btn_git_refresh.clicked.connect(self.refresh_status)
        branch_layout.addWidget(self.btn_git_refresh)
        layout.addLayout(branch_layout)

        # Commit message input and Commit button
        self.input_commit_msg = QLineEdit()
        self.input_commit_msg.setPlaceholderText("Message (Ctrl+Enter to commit)")
        self.btn_commit = QPushButton("Commit")
        self.btn_commit.setStyleSheet("background-color: #89b4fa; color: #11111b; font-weight: bold;")
        self.btn_commit.clicked.connect(self._commit_changes)

        layout.addWidget(self.input_commit_msg)
        layout.addWidget(self.btn_commit)

        # Changes List
        layout.addWidget(QLabel("<b>Changes</b>"))
        self.list_changes = QListWidget()
        self.list_changes.itemDoubleClicked.connect(self._on_item_double_clicked)
        layout.addWidget(self.list_changes)

    def set_repo_path(self, path: str):
        self.git_manager.set_repo_path(path)
        self.refresh_status()

    def refresh_status(self):
        self.list_changes.clear()
        self.combo_branch.clear()

        if not self.git_manager.is_git_repo():
            self.list_changes.addItem("Not a git repository")
            return

        # Branches
        branches = self.git_manager.get_branches()
        self.combo_branch.addItems(branches)
        curr_branch = self.git_manager.get_current_branch()
        self.combo_branch.setCurrentText(curr_branch)

        # Status
        status_dict = self.git_manager.get_status()

        # Staged
        for item in status_dict["staged"]:
            lw_item = QListWidgetItem(f"✅ {item['file']} ({item['status']})")
            lw_item.setData(Qt.ItemDataRole.UserRole, item['file'])
            self.list_changes.addItem(lw_item)

        # Unstaged / Untracked
        for item in status_dict["unstaged"]:
            lw_item = QListWidgetItem(f"✏️ {item['file']} ({item['status']})")
            lw_item.setData(Qt.ItemDataRole.UserRole, item['file'])
            self.list_changes.addItem(lw_item)

    def _commit_changes(self):
        msg = self.input_commit_msg.text().strip()
        if not msg:
            QMessageBox.warning(self, "Warning", "Please enter a commit message.")
            return

        ok, out = self.git_manager.commit(msg)
        if ok:
            self.input_commit_msg.clear()
            self.refresh_status()
            QMessageBox.information(self, "Git Commit", "Commit successful!")
        else:
            QMessageBox.critical(self, "Git Commit Error", out)

    def _on_item_double_clicked(self, item):
        file_path = item.data(Qt.ItemDataRole.UserRole)
        if file_path:
            self.file_selected.emit(file_path)
