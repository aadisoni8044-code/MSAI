"""
exe/tow - Home Dashboard View
Welcome section, three quick action cards (Select Project, Detect Files, Build EXE),
and recent projects showcase.
"""

from PySide6.QtCore import Signal, Qt
from PySide6.QtWidgets import (
    QWidget, QVBoxLayout, QHBoxLayout, QLabel, QPushButton, QFrame,
    QGridLayout, QFileDialog, QListWidget, QListWidgetItem
)
from exe_tow.ui.theme import ThemeColors

class HomeView(QWidget):
    """Home dashboard screen for exe/tow."""

    sig_navigate = Signal(str)  # Navigates to view key e.g. 'build', 'projects'
    sig_project_selected = Signal(str)  # Folder path

    def __init__(self, settings_manager, parent=None):
        super().__init__(parent)
        self.settings = settings_manager

        layout = QVBoxLayout(self)
        layout.setContentsMargins(32, 28, 32, 28)
        layout.setSpacing(24)

        # Welcome Hero Section
        hero_panel = QFrame()
        hero_panel.setObjectName("GlassPanel")
        hero_layout = QVBoxLayout(hero_panel)
        hero_layout.setContentsMargins(28, 28, 28, 28)
        hero_layout.setSpacing(8)

        welcome_badge = QLabel("EXE/TOW DEVELOPER TOOLKIT")
        welcome_badge.setStyleSheet(f"color: {ThemeColors.TEXT_MUTED}; font-size: 11px; font-weight: 700; letter-spacing: 1.5px;")
        hero_layout.addWidget(welcome_badge)

        hero_title = QLabel("Build Python Apps into EXE")
        hero_title.setObjectName("TitleLabel")
        hero_layout.addWidget(hero_title)

        hero_sub = QLabel("Select your project and let exe/tow handle the build.")
        hero_sub.setObjectName("SubtitleLabel")
        hero_layout.addWidget(hero_sub)

        layout.addWidget(hero_panel)

        # Three Quick Action Cards Grid
        cards_grid = QGridLayout()
        cards_grid.setHorizontalSpacing(16)
        cards_grid.setVerticalSpacing(16)

        # Card 1: Select Project
        c1 = self._create_card(
            icon="📁",
            title="Select Project",
            desc="Choose your Python application root directory to begin.",
            btn_text="Browse Folder",
            on_click=self._on_browse_project
        )
        cards_grid.addWidget(c1, 0, 0)

        # Card 2: Detect Files
        c2 = self._create_card(
            icon="🔍",
            title="Detect Files",
            desc="Auto-scan entry point, requirements.txt, and venv.",
            btn_text="Explore Projects",
            on_click=lambda: self.sig_navigate.emit("projects")
        )
        cards_grid.addWidget(c2, 0, 1)

        # Card 3: Build EXE
        c3 = self._create_card(
            icon="🚀",
            title="Build EXE",
            desc="Configure build options and package into executable.",
            btn_text="Open Compiler",
            on_click=lambda: self.sig_navigate.emit("build")
        )
        cards_grid.addWidget(c3, 0, 2)

        layout.addLayout(cards_grid)

        # Recent Projects Panel
        recent_panel = QFrame()
        recent_panel.setObjectName("CardPanel")
        recent_layout = QVBoxLayout(recent_panel)
        recent_layout.setContentsMargins(20, 20, 20, 20)
        recent_layout.setSpacing(12)

        rec_header = QLabel("Recent Projects")
        rec_header.setObjectName("SectionTitle")
        recent_layout.addWidget(rec_header)

        self.recent_list = QListWidget()
        self.recent_list.setStyleSheet(f"""
            QListWidget {{
                background-color: {ThemeColors.BG_INPUT};
                border: 1px solid {ThemeColors.BORDER_SUBTLE};
                border-radius: 8px;
                padding: 4px;
            }}
            QListWidget::item {{
                color: {ThemeColors.TEXT_PRIMARY};
                padding: 10px;
                border-radius: 6px;
                margin-bottom: 2px;
            }}
            QListWidget::item:hover {{
                background-color: {ThemeColors.BG_HOVER};
            }}
            QListWidget::item:selected {{
                background-color: {ThemeColors.BG_ACTIVE};
            }}
        """)
        self.recent_list.itemDoubleClicked.connect(self._on_recent_double_clicked)
        recent_layout.addWidget(self.recent_list)

        layout.addWidget(recent_panel)

        self.refresh_recent_projects()

    def _create_card(self, icon: str, title: str, desc: str, btn_text: str, on_click) -> QFrame:
        card = QFrame()
        card.setObjectName("CardPanel")
        card_layout = QVBoxLayout(card)
        card_layout.setContentsMargins(20, 20, 20, 20)
        card_layout.setSpacing(10)

        header_row = QHBoxLayout()
        icon_lbl = QLabel(icon)
        icon_lbl.setStyleSheet("font-size: 22px;")
        t_lbl = QLabel(title)
        t_lbl.setObjectName("SectionTitle")

        header_row.addWidget(icon_lbl)
        header_row.addWidget(t_lbl)
        header_row.addStretch()

        card_layout.addLayout(header_row)

        d_lbl = QLabel(desc)
        d_lbl.setStyleSheet(f"color: {ThemeColors.TEXT_SECONDARY}; font-size: 12px;")
        d_lbl.setWordWrap(True)
        card_layout.addWidget(d_lbl)

        card_layout.addStretch()

        btn = QPushButton(btn_text)
        btn.setCursor(Qt.PointingHandCursor)
        btn.clicked.connect(on_click)
        card_layout.addWidget(btn)

        return card

    def _on_browse_project(self):
        folder = QFileDialog.getExistingDirectory(self, "Select Python Project Folder")
        if folder:
            self.settings.add_recent_project(folder)
            self.refresh_recent_projects()
            self.sig_project_selected.emit(folder)
            self.sig_navigate.emit("build")

    def _on_recent_double_clicked(self, item: QListWidgetItem):
        folder = item.data(Qt.UserRole)
        if folder:
            self.sig_project_selected.emit(folder)
            self.sig_navigate.emit("build")

    def refresh_recent_projects(self):
        self.recent_list.clear()
        recents = self.settings.get("recent_projects", [])
        if not recents:
            item = QListWidgetItem("No recent projects found. Click 'Browse Folder' above to choose a project.")
            item.setFlags(Qt.NoItemFlags)
            self.recent_list.addItem(item)
        else:
            for path in recents:
                item = QListWidgetItem(f"📁 {path}")
                item.setData(Qt.UserRole, path)
                self.recent_list.addItem(item)
