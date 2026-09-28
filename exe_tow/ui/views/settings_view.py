from PySide6.QtWidgets import (
    QWidget, QVBoxLayout, QHBoxLayout, QLabel, QLineEdit, QSpinBox,
    QPushButton, QCheckBox, QFrame, QFileDialog, QMessageBox, QComboBox
)
from PySide6.QtCore import Qt
from exe_tow.config.settings import Settings
from exe_tow.ui.theme import Theme

class SettingsView(QWidget):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.settings = Settings.load()

        layout = QVBoxLayout(self)
        layout.setContentsMargins(24, 24, 24, 24)
        layout.setSpacing(16)

        title = QLabel("Application Settings")
        title.setObjectName("heading")
        layout.addWidget(title)

        card = QFrame()
        card.setObjectName("card")
        c_layout = QVBoxLayout(card)
        c_layout.setContentsMargins(20, 20, 20, 20)
        c_layout.setSpacing(14)

        # 1. Custom Python Interpreter Path
        c_layout.addWidget(QLabel("Python Interpreter Path:"))
        py_row = QHBoxLayout()
        self.txt_py_path = QLineEdit(self.settings.python_path)
        self.txt_py_path.setPlaceholderText("Default system python...")
        py_row.addWidget(self.txt_py_path)

        btn_browse_py = QPushButton("Browse")
        btn_browse_py.clicked.connect(self._browse_python)
        py_row.addWidget(btn_browse_py)
        c_layout.addLayout(py_row)

        # 2. Default Output Directory
        c_layout.addWidget(QLabel("Default Output Directory:"))
        out_row = QHBoxLayout()
        self.txt_out_dir = QLineEdit(self.settings.default_output_folder)
        self.txt_out_dir.setPlaceholderText("Default ~/EXE-TOW/dist...")
        out_row.addWidget(self.txt_out_dir)

        btn_browse_out = QPushButton("Browse")
        btn_browse_out.clicked.connect(self._browse_out)
        out_row.addWidget(btn_browse_out)
        c_layout.addLayout(out_row)

        # 3. Maximum Retries & Timeout
        num_row = QHBoxLayout()

        v_retries = QVBoxLayout()
        v_retries.addWidget(QLabel("Maximum Retry Attempts:"))
        self.spin_retries = QSpinBox()
        self.spin_retries.setRange(1, 20)
        self.spin_retries.setValue(self.settings.max_retries)
        v_retries.addWidget(self.spin_retries)
        num_row.addLayout(v_retries)

        v_timeout = QVBoxLayout()
        v_timeout.addWidget(QLabel("Command Timeout (seconds):"))
        self.spin_timeout = QSpinBox()
        self.spin_timeout.setRange(30, 3600)
        self.spin_timeout.setValue(self.settings.command_timeout)
        v_timeout.addWidget(self.spin_timeout)
        num_row.addLayout(v_timeout)

        c_layout.addLayout(num_row)

        # 4. Mode Preference
        c_layout.addWidget(QLabel("Default Build Mode:"))
        self.combo_mode = QComboBox()
        self.combo_mode.addItems(["ONE FILE", "ONE DIRECTORY"])
        self.combo_mode.setCurrentText(self.settings.default_build_mode)
        c_layout.addWidget(self.combo_mode)

        # 5. Checkbox Automation Toggles
        self.chk_auto_install = QCheckBox("Automatic dependency installation (e.g., install PyInstaller if missing)")
        self.chk_auto_install.setChecked(self.settings.auto_install_dependencies)
        c_layout.addWidget(self.chk_auto_install)

        self.chk_auto_fallback = QCheckBox("Automatic command fallback execution on build failure")
        self.chk_auto_fallback.setChecked(self.settings.auto_fallback)
        c_layout.addWidget(self.chk_auto_fallback)

        self.chk_open_out = QCheckBox("Open output folder after successful compilation")
        self.chk_open_out.setChecked(self.settings.open_output_after_build)
        c_layout.addWidget(self.chk_open_out)

        c_layout.addSpacing(16)

        # Save Button
        btn_save = QPushButton("SAVE SETTINGS")
        btn_save.setObjectName("primary")
        btn_save.setFixedHeight(40)
        btn_save.clicked.connect(self._save_settings)
        c_layout.addWidget(btn_save)

        layout.addWidget(card)
        layout.addStretch()

    def _browse_python(self):
        f, _ = QFileDialog.getOpenFileName(self, "Select Python Executable", "", "Executables (*.exe python*);;All Files (*)")
        if f:
            self.txt_py_path.setText(f)

    def _browse_out(self):
        d = QFileDialog.getExistingDirectory(self, "Select Default Output Directory")
        if d:
            self.txt_out_dir.setText(d)

    def _save_settings(self):
        self.settings.python_path = self.txt_py_path.text().strip()
        self.settings.default_output_folder = self.txt_out_dir.text().strip()
        self.settings.max_retries = self.spin_retries.value()
        self.settings.command_timeout = self.spin_timeout.value()
        self.settings.default_build_mode = self.combo_mode.currentText()
        self.settings.auto_install_dependencies = self.chk_auto_install.isChecked()
        self.settings.auto_fallback = self.chk_auto_fallback.isChecked()
        self.settings.open_output_after_build = self.chk_open_out.isChecked()

        try:
            self.settings.save()
            QMessageBox.information(self, "Settings Saved", "Application settings saved successfully!")
        except Exception as e:
            QMessageBox.critical(self, "Error", f"Failed to save settings: {str(e)}")
