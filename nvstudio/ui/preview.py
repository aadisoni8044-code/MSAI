import os
import tempfile
from pathlib import Path
from PyQt6.QtWidgets import (
    QWidget, QVBoxLayout, QHBoxLayout, QPushButton, QLabel, QButtonGroup,
    QStackedLayout, QFrame
)
from PyQt6.QtCore import Qt, pyqtSignal, QUrl, QSize
from PyQt6.QtWebEngineWidgets import QWebEngineView


# Device dimensions (width, height)
DEVICE_SIZES = {
    "Mobile": (375, 667),
    "iPad": (768, 1024),
    "Laptop": (1024, 680)
}


class LivePreviewPanel(QWidget):
    """Live Preview Panel supporting Mobile, iPad, and Laptop device views with instant Run execution."""

    device_changed = pyqtSignal(str)

    def __init__(self, parent=None):
        super().__init__(parent)
        self.current_device = "Laptop"
        self.temp_preview_file = None

        layout = QVBoxLayout(self)
        layout.setContentsMargins(8, 8, 8, 8)
        layout.setSpacing(8)

        # Header Control Bar
        control_bar = QHBoxLayout()
        control_bar.setContentsMargins(0, 0, 0, 0)

        preview_title = QLabel("LIVE PREVIEW")
        preview_title.setStyleSheet("font-weight: bold; color: #94a3b8; font-size: 11px; letter-spacing: 0.5px;")
        control_bar.addWidget(preview_title)

        control_bar.addStretch()

        # Device Selection Buttons
        self.device_group = QButtonGroup(self)
        self.device_group.setExclusive(True)

        self.btn_mobile = QPushButton("Mobile")
        self.btn_mobile.setObjectName("DeviceBtn")
        self.btn_mobile.setCheckable(True)

        self.btn_ipad = QPushButton("iPad")
        self.btn_ipad.setObjectName("DeviceBtn")
        self.btn_ipad.setCheckable(True)

        self.btn_laptop = QPushButton("Laptop")
        self.btn_laptop.setObjectName("DeviceBtn")
        self.btn_laptop.setCheckable(True)
        self.btn_laptop.setChecked(True)

        self.device_group.addButton(self.btn_mobile)
        self.device_group.addButton(self.btn_ipad)
        self.device_group.addButton(self.btn_laptop)

        self.btn_mobile.clicked.connect(lambda: self.set_device("Mobile"))
        self.btn_ipad.clicked.connect(lambda: self.set_device("iPad"))
        self.btn_laptop.clicked.connect(lambda: self.set_device("Laptop"))

        control_bar.addWidget(self.btn_mobile)
        control_bar.addWidget(self.btn_ipad)
        control_bar.addWidget(self.btn_laptop)

        # Prominent Run Button
        self.btn_run = QPushButton("Run ▶")
        self.btn_run.setObjectName("RunButton")
        self.btn_run.setToolTip("Execute HTML/CSS/JavaScript and update preview")
        control_bar.addWidget(self.btn_run)

        layout.addLayout(control_bar)

        # Preview Container Area
        self.container = QWidget()
        self.container.setObjectName("PreviewContainer")

        container_layout = QVBoxLayout(self.container)
        container_layout.setContentsMargins(12, 12, 12, 12)
        container_layout.setAlignment(Qt.AlignmentFlag.AlignCenter)

        # Device Frame
        self.device_frame = QFrame()
        self.device_frame.setObjectName("LaptopFrame")

        frame_layout = QVBoxLayout(self.device_frame)
        frame_layout.setContentsMargins(0, 0, 0, 0)

        # WebEngine View
        self.web_view = QWebEngineView()
        frame_layout.addWidget(self.web_view)

        container_layout.addWidget(self.device_frame)
        layout.addWidget(self.container)

        self.update_device_frame_size("Laptop")

    def set_device(self, device_name):
        if device_name not in DEVICE_SIZES:
            return

        self.current_device = device_name

        if device_name == "Mobile":
            self.btn_mobile.setChecked(True)
            self.device_frame.setObjectName("MobileFrame")
        elif device_name == "iPad":
            self.btn_ipad.setChecked(True)
            self.device_frame.setObjectName("iPadFrame")
        elif device_name == "Laptop":
            self.btn_laptop.setChecked(True)
            self.device_frame.setObjectName("LaptopFrame")

        # Re-apply QSS to update border styling
        self.device_frame.setStyle(self.device_frame.style())
        self.update_device_frame_size(device_name)
        self.device_changed.emit(device_name)

    def update_device_frame_size(self, device_name):
        width, height = DEVICE_SIZES.get(device_name, (1024, 680))
        self.device_frame.setFixedSize(width, height)

    def run_project(self, project_dir):
        """Execute project files in project_dir and render in QWebEngineView."""
        project_path = Path(project_dir)
        index_html = project_path / "index.html"

        if index_html.exists():
            url = QUrl.fromLocalFile(str(index_html.resolve()))
            try:
                self.web_view.setUrl(url)
                self.web_view.reload()
            except Exception as e:
                print(f"[LivePreviewPanel] Error setting web view URL: {e}")

    def run_raw_code(self, html_code, css_code="", js_code=""):
        """Run raw HTML, CSS, and JS strings together in preview."""
        full_html = f"""<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
    {css_code}
    </style>
</head>
<body>
    {html_code}
    <script>
    {js_code}
    </script>
</body>
</html>
"""
        if not self.temp_preview_file:
            self.temp_preview_file = tempfile.NamedTemporaryFile(suffix=".html", delete=False, mode="w", encoding="utf-8")

        with open(self.temp_preview_file.name, "w", encoding="utf-8") as f:
            f.write(full_html)

        url = QUrl.fromLocalFile(self.temp_preview_file.name)
        self.web_view.setUrl(url)
        self.web_view.reload()

    def closeEvent(self, event):
        if self.temp_preview_file and os.path.exists(self.temp_preview_file.name):
            try:
                os.remove(self.temp_preview_file.name)
            except Exception:
                pass
        super().closeEvent(event)
