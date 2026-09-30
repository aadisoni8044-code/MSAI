import os
import sys
from PySide6.QtWidgets import (
    QMainWindow, QWidget, QHBoxLayout, QVBoxLayout, QFrame, QLabel,
    QPushButton, QStackedWidget, QApplication
)
from PySide6.QtCore import Qt, QPoint, Signal
from PySide6.QtGui import QIcon, QPixmap

from exe_tow.ui.styles import STYLESHEET
from exe_tow.core.history import HistoryManager
from exe_tow.ui.views.dashboard_view import DashboardView


class MainWindow(QMainWindow):
    """
    Main Application Window for exe/tow.
    Features dark hacker/developer UI, custom title bar with logo,
    build status badge, minimize/maximize/close buttons (NO Settings button),
    and left navigation sidebar.
    """

    def __init__(self, parent=None):
        super().__init__(parent)
        self.setWindowTitle("exe/tow - Python EXE Builder")
        self.setMinimumSize(1280, 720)
        self.resize(1280, 760)

        # Frameless window setup for modern custom title bar
        self.setWindowFlags(Qt.FramelessWindowHint | Qt.WindowSystemMenuHint | Qt.WindowMinMaxButtonsHint)
        self.setAttribute(Qt.WA_TranslucentBackground, False)

        # Persistence
        self.history_manager = HistoryManager()

        # Dragging variables for custom title bar
        self._is_dragging = False
        self._drag_position = QPoint()

        # Build UI
        self._init_ui()
        self.setStyleSheet(STYLESHEET)

    def _init_ui(self):
        self.central_widget = QWidget(self)
        self.central_widget.setObjectName("CentralWidget")
        self.setCentralWidget(self.central_widget)

        main_layout = QVBoxLayout(self.central_widget)
        main_layout.setContentsMargins(0, 0, 0, 0)
        main_layout.setSpacing(0)

        # 1. TOP BAR
        self.top_bar = self._create_top_bar()
        main_layout.addWidget(self.top_bar)

        # 2. BODY (Sidebar + Stacked Content)
        body_widget = QWidget(self)
        body_layout = QHBoxLayout(body_widget)
        body_layout.setContentsMargins(0, 0, 0, 0)
        body_layout.setSpacing(0)

        self.view_stack = QStackedWidget(self)
        self.sidebar = self._create_sidebar()

        body_layout.addWidget(self.sidebar)
        body_layout.addWidget(self.view_stack, stretch=1)

        main_layout.addWidget(body_widget, stretch=1)

        # 3. INITIALIZE VIEWS
        self.dashboard_view = DashboardView(self.history_manager, self)
        self.view_stack.addWidget(self.dashboard_view) # Index 0

        # Connect Dashboard signals
        self.dashboard_view.create_exe_requested.connect(lambda: self.set_active_nav("build"))
        self.dashboard_view.open_project_requested.connect(lambda: self.set_active_nav("build"))

        # Set initial active navigation
        self.set_active_nav("dashboard")

    def _create_top_bar(self) -> QFrame:
        top_frame = QFrame(self)
        top_frame.setObjectName("TopBarFrame")

        layout = QHBoxLayout(top_frame)
        layout.setContentsMargins(16, 0, 16, 0)
        layout.setSpacing(12)

        # Logo
        logo_label = QLabel(self)
        base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        logo_path = os.path.join(base_dir, "assets", "logo.png")

        if os.path.exists(logo_path):
            pixmap = QPixmap(logo_path)
            if not pixmap.isNull():
                logo_label.setPixmap(pixmap.scaled(32, 32, Qt.KeepAspectRatio, Qt.SmoothTransformation))
        else:
            logo_label.setText("[exe/tow]")
            logo_label.setStyleSheet("color: #FFFFFF; font-weight: bold;")

        # Brand Titles
        title_box = QVBoxLayout()
        title_box.setSpacing(0)
        title_box.setAlignment(Qt.AlignVCenter)

        title_lbl = QLabel("EXE/TOW", self)
        title_lbl.setObjectName("BrandTitle")

        subtitle_lbl = QLabel("Python EXE Builder", self)
        subtitle_lbl.setObjectName("BrandSubtitle")

        title_box.addWidget(title_lbl)
        title_box.addWidget(subtitle_lbl)

        # Status Badge
        self.status_badge = QLabel("● READY", self)
        self.status_badge.setObjectName("StatusBadgeReady")

        # Window Controls
        min_btn = QPushButton("─", self)
        min_btn.setObjectName("WindowControlBtn")
        min_btn.clicked.connect(self.showMinimized)

        self.max_btn = QPushButton("□", self)
        self.max_btn.setObjectName("WindowControlBtn")
        self.max_btn.clicked.connect(self._toggle_maximize)

        close_btn = QPushButton("✕", self)
        close_btn.setObjectName("WindowControlCloseBtn")
        close_btn.clicked.connect(self.close)

        # Assemble Top Bar
        layout.addWidget(logo_label)
        layout.addLayout(title_box)
        layout.addSpacing(20)
        layout.addWidget(self.status_badge)
        layout.addStretch()
        layout.addWidget(min_btn)
        layout.addWidget(self.max_btn)
        layout.addWidget(close_btn)

        return top_frame

    def _create_sidebar(self) -> QFrame:
        sidebar_frame = QFrame(self)
        sidebar_frame.setObjectName("SidebarFrame")
        sidebar_frame.setFixedWidth(220)

        layout = QVBoxLayout(sidebar_frame)
        layout.setContentsMargins(0, 16, 0, 16)
        layout.setSpacing(4)

        self.nav_btns = {}

        nav_items = [
            ("dashboard", "⌂ Dashboard", 0),
            ("build", "⚡ Build EXE", 1),
            ("projects", "▣ Projects", 2),
            ("history", "▤ Build History", 3),
        ]

        for nav_key, label_text, index in nav_items:
            btn = QPushButton(f"  {label_text}", self)
            btn.setObjectName("NavButton")
            btn.setCursor(Qt.PointingHandCursor)
            btn.setProperty("active", "false")
            btn.clicked.connect(lambda checked=False, k=nav_key: self.set_active_nav(k))
            self.nav_btns[nav_key] = btn
            layout.addWidget(btn)

        layout.addStretch()

        return sidebar_frame

    def set_active_nav(self, key: str):
        for k, btn in self.nav_btns.items():
            if k == key:
                btn.setProperty("active", "true")
            else:
                btn.setProperty("active", "false")
            btn.style().unpolish(btn)
            btn.style().polish(btn)

        # Switch view stack index
        key_index_map = {"dashboard": 0, "build": 1, "projects": 2, "history": 3}
        if key in key_index_map and hasattr(self, 'view_stack') and self.view_stack.count() > key_index_map[key]:
            self.view_stack.setCurrentIndex(key_index_map[key])

    def set_status_badge(self, status: str):
        if status == "BUILDING":
            self.status_badge.setText("● BUILDING")
            self.status_badge.setObjectName("StatusBadgeBuilding")
        else:
            self.status_badge.setText("● READY")
            self.status_badge.setObjectName("StatusBadgeReady")

        self.status_badge.style().unpolish(self.status_badge)
        self.status_badge.style().polish(self.status_badge)

    def _toggle_maximize(self):
        if self.isMaximized():
            self.showNormal()
            self.max_btn.setText("□")
        else:
            self.showMaximized()
            self.max_btn.setText("❐")

    # Mouse events for window dragging
    def mousePressEvent(self, event):
        if event.button() == Qt.LeftButton and event.position().y() <= 54:
            self._is_dragging = True
            self._drag_position = event.globalPosition().toPoint() - self.frameGeometry().topLeft()
            event.accept()

    def mouseMoveEvent(self, event):
        if self._is_dragging and event.buttons() & Qt.LeftButton:
            self.move(event.globalPosition().toPoint() - self._drag_position)
            event.accept()

    def mouseReleaseEvent(self, event):
        self._is_dragging = False
