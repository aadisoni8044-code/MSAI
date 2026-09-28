from PySide6.QtWidgets import QWidget, QVBoxLayout, QHBoxLayout, QLabel, QFrame
from PySide6.QtCore import Qt
from exe_tow.ui.theme import Theme

class AttemptIndicator(QFrame):
    def __init__(self, attempt_num: int, command: str, status: str, parent=None):
        super().__init__(parent)
        self.setObjectName("card")
        layout = QHBoxLayout(self)
        layout.setContentsMargins(12, 8, 12, 8)

        # Attempt label
        lbl_num = QLabel(f"Attempt #{attempt_num}")
        lbl_num.setStyleSheet("font-weight: bold; font-size: 12px;")
        layout.addWidget(lbl_num)

        # Command preview
        cmd_short = command if len(command) < 60 else command[:57] + "..."
        lbl_cmd = QLabel(cmd_short)
        lbl_cmd.setStyleSheet(f"color: {Theme.TEXT_SECONDARY}; font-family: monospace; font-size: 11px;")
        layout.addWidget(lbl_cmd, stretch=1)

        # Status badge
        lbl_status = QLabel()
        if status == "SUCCESS":
            lbl_status.setText("✓ SUCCESS")
            lbl_status.setStyleSheet(f"color: #7EE787; font-weight: bold; background-color: {Theme.STATUS_SUCCESS_BG}; padding: 4px 8px; border-radius: 4px;")
        elif status == "FAILED":
            lbl_status.setText("❌ FAILED")
            lbl_status.setStyleSheet(f"color: #FF7B72; font-weight: bold; background-color: {Theme.STATUS_FAILED_BG}; padding: 4px 8px; border-radius: 4px;")
        else:
            lbl_status.setText("⏳ RUNNING")
            lbl_status.setStyleSheet(f"color: {Theme.STATUS_WARNING}; font-weight: bold; padding: 4px 8px;")

        layout.addWidget(lbl_status)
