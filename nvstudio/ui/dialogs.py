from PyQt6.QtWidgets import (
    QDialog, QVBoxLayout, QHBoxLayout, QLabel, QPushButton, QRadioButton,
    QButtonGroup, QCheckBox, QComboBox, QSpinBox, QFormLayout, QGroupBox,
    QLineEdit, QDialogButtonBox, QWidget
)
from PyQt6.QtCore import Qt, pyqtSignal


class FirstLaunchConsentDialog(QDialog):
    """Permission/consent screen shown on first launch."""

    def __init__(self, parent=None):
        super().__init__(parent)
        self.setWindowTitle("NV Studio - Permission Request")
        self.setFixedSize(480, 260)
        self.setModal(True)
        self.setWindowFlags(self.windowFlags() & ~Qt.WindowType.WindowContextHelpButtonHint)

        layout = QVBoxLayout(self)
        layout.setContentsMargins(24, 24, 24, 24)
        layout.setSpacing(16)

        title = QLabel("Welcome to NV Studio 🚀")
        title.setStyleSheet("font-size: 18px; font-weight: bold; color: #6366f1;")
        layout.addWidget(title)

        desc = QLabel(
            "NV Studio requires permission to save and restore your website "
            "projects, settings, and workspace preferences locally on your system.\n\n"
            "This consent is requested once and allows NV Studio to keep your code "
            "safe across sessions."
        )
        desc.setWordWrap(True)
        desc.setStyleSheet("color: #cbd5e1; line-height: 1.4;")
        layout.addWidget(desc)

        btn_layout = QHBoxLayout()
        btn_layout.addStretch()

        self.accept_btn = QPushButton("Grant Permission & Continue")
        self.accept_btn.setStyleSheet("""
            QPushButton {
                background-color: #6366f1;
                color: #ffffff;
                font-weight: bold;
                padding: 8px 18px;
                border-radius: 6px;
            }
            QPushButton:hover {
                background-color: #4f46e5;
            }
        """)
        self.accept_btn.clicked.connect(self.accept)
        btn_layout.addWidget(self.accept_btn)

        layout.addLayout(btn_layout)


class FirstLaunchThemeDialog(QDialog):
    """First launch theme choice dialog: Choose your NV Studio theme."""

    def __init__(self, parent=None):
        super().__init__(parent)
        self.setWindowTitle("NV Studio - Choose Your Theme")
        self.setFixedSize(460, 280)
        self.setModal(True)
        self.setWindowFlags(self.windowFlags() & ~Qt.WindowType.WindowContextHelpButtonHint)

        self.selected_theme = "Dark Mode"

        layout = QVBoxLayout(self)
        layout.setContentsMargins(24, 24, 24, 24)
        layout.setSpacing(16)

        title = QLabel("Choose your NV Studio theme")
        title.setStyleSheet("font-size: 18px; font-weight: bold; color: #6366f1;")
        layout.addWidget(title)

        sub = QLabel("Select your preferred interface look. You can change this later in Settings.")
        sub.setWordWrap(True)
        sub.setStyleSheet("color: #94a3b8;")
        layout.addWidget(sub)

        self.bg_group = QButtonGroup(self)

        self.dark_radio = QRadioButton("Dark Mode - Professional dark developer interface")
        self.dark_radio.setChecked(True)
        self.dark_radio.setStyleSheet("font-weight: 600; font-size: 13px; padding: 6px;")

        self.white_radio = QRadioButton("White Mode - Clean light interface with high contrast")
        self.white_radio.setStyleSheet("font-weight: 600; font-size: 13px; padding: 6px;")

        self.bg_group.addButton(self.dark_radio, 1)
        self.bg_group.addButton(self.white_radio, 2)

        layout.addWidget(self.dark_radio)
        layout.addWidget(self.white_radio)

        btn_layout = QHBoxLayout()
        btn_layout.addStretch()

        confirm_btn = QPushButton("Start NV Studio")
        confirm_btn.setStyleSheet("""
            QPushButton {
                background-color: #10b981;
                color: #ffffff;
                font-weight: bold;
                padding: 8px 20px;
                border-radius: 6px;
            }
            QPushButton:hover {
                background-color: #059669;
            }
        """)
        confirm_btn.clicked.connect(self._on_confirm)
        btn_layout.addWidget(confirm_btn)

        layout.addLayout(btn_layout)

    def _on_confirm(self):
        if self.white_radio.isChecked():
            self.selected_theme = "White Mode"
        else:
            self.selected_theme = "Dark Mode"
        self.accept()


class SettingsDialog(QDialog):
    """Settings dialog for NV Studio preferences."""

    settings_changed = pyqtSignal(dict)

    def __init__(self, config_manager, parent=None):
        super().__init__(parent)
        self.config_manager = config_manager
        self.setWindowTitle("NV Studio Settings")
        self.setFixedSize(520, 420)
        self.setModal(True)

        layout = QVBoxLayout(self)
        layout.setContentsMargins(20, 20, 20, 20)
        layout.setSpacing(16)

        title = QLabel("NV Studio Settings")
        title.setStyleSheet("font-size: 18px; font-weight: bold; color: #6366f1;")
        layout.addWidget(title)

        form_layout = QFormLayout()
        form_layout.setSpacing(12)

        # Theme
        self.theme_combo = QComboBox()
        self.theme_combo.addItems(["Dark Mode", "White Mode"])
        self.theme_combo.setCurrentText(self.config_manager.get("theme", "Dark Mode"))
        form_layout.addRow("Interface Theme:", self.theme_combo)

        # Auto save
        self.autosave_check = QCheckBox("Enable Automatic Saving while working")
        self.autosave_check.setChecked(bool(self.config_manager.get("auto_save", True)))
        form_layout.addRow("Auto-Save:", self.autosave_check)

        # Editor Font Size
        self.font_size_spin = QSpinBox()
        self.font_size_spin.setRange(8, 36)
        self.font_size_spin.setValue(int(self.config_manager.get("font_size", 13)))
        form_layout.addRow("Editor Font Size:", self.font_size_spin)

        # Tab Size
        self.tab_size_spin = QSpinBox()
        self.tab_size_spin.setRange(2, 8)
        self.tab_size_spin.setValue(int(self.config_manager.get("tab_size", 4)))
        form_layout.addRow("Tab Indent Size:", self.tab_size_spin)

        # Default Preview Device
        self.device_combo = QComboBox()
        self.device_combo.addItems(["Mobile", "iPad", "Laptop"])
        self.device_combo.setCurrentText(self.config_manager.get("preview_device", "Laptop"))
        form_layout.addRow("Default Preview Device:", self.device_combo)

        # Restore Previous Workspace
        self.restore_check = QCheckBox("Restore previous workspace & open files on launch")
        self.restore_check.setChecked(bool(self.config_manager.get("restore_workspace", True)))
        form_layout.addRow("Restore Workspace:", self.restore_check)

        layout.addLayout(form_layout)
        layout.addStretch()

        # Action Buttons
        btn_box = QDialogButtonBox(QDialogButtonBox.StandardButton.Save | QDialogButtonBox.StandardButton.Cancel)
        btn_box.accepted.connect(self._on_save)
        btn_box.rejected.connect(self.reject)
        layout.addWidget(btn_box)

    def _on_save(self):
        new_settings = {
            "theme": self.theme_combo.currentText(),
            "auto_save": self.autosave_check.isChecked(),
            "font_size": self.font_size_spin.value(),
            "tab_size": self.tab_size_spin.value(),
            "preview_device": self.device_combo.currentText(),
            "restore_workspace": self.restore_check.isChecked()
        }

        for k, v in new_settings.items():
            self.config_manager.set(k, v)

        self.settings_changed.emit(new_settings)
        self.accept()


class SearchReplaceBar(QWidget):
    """Inline Search and Replace Widget for the Code Editor."""

    find_next_requested = pyqtSignal(str, bool)  # text, match_case
    find_prev_requested = pyqtSignal(str, bool)
    replace_requested = pyqtSignal(str, str, bool)  # find, replace, match_case
    replace_all_requested = pyqtSignal(str, str, bool)

    def __init__(self, parent=None):
        super().__init__(parent)
        layout = QHBoxLayout(self)
        layout.setContentsMargins(8, 4, 8, 4)
        layout.setSpacing(8)

        self.find_input = QLineEdit()
        self.find_input.setPlaceholderText("Find...")
        self.find_input.setClearButtonEnabled(True)

        self.replace_input = QLineEdit()
        self.replace_input.setPlaceholderText("Replace with...")
        self.replace_input.setClearButtonEnabled(True)

        self.case_check = QCheckBox("Match Case")

        self.next_btn = QPushButton("Next")
        self.next_btn.clicked.connect(
            lambda: self.find_next_requested.emit(self.find_input.text(), self.case_check.isChecked())
        )

        self.prev_btn = QPushButton("Prev")
        self.prev_btn.clicked.connect(
            lambda: self.find_prev_requested.emit(self.find_input.text(), self.case_check.isChecked())
        )

        self.replace_btn = QPushButton("Replace")
        self.replace_btn.clicked.connect(
            lambda: self.replace_requested.emit(self.find_input.text(), self.replace_input.text(), self.case_check.isChecked())
        )

        self.replace_all_btn = QPushButton("Replace All")
        self.replace_all_btn.clicked.connect(
            lambda: self.replace_all_requested.emit(self.find_input.text(), self.replace_input.text(), self.case_check.isChecked())
        )

        self.close_btn = QPushButton("✕")
        self.close_btn.setFixedWidth(28)
        self.close_btn.clicked.connect(self.hide)

        layout.addWidget(self.find_input)
        layout.addWidget(self.next_btn)
        layout.addWidget(self.prev_btn)
        layout.addWidget(self.replace_input)
        layout.addWidget(self.replace_btn)
        layout.addWidget(self.replace_all_btn)
        layout.addWidget(self.case_check)
        layout.addWidget(self.close_btn)

        self.hide()
