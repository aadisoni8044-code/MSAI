"""NV Studio Extensions Catalog & Management Sidebar Panel"""
from typing import List, Dict
from PyQt6.QtCore import pyqtSignal, Qt
from PyQt6.QtWidgets import (
    QHBoxLayout, QLabel, QListWidget, QListWidgetItem,
    QPushButton, QVBoxLayout, QWidget, QMessageBox, QTabWidget
)

EXTENSIONS_DATA = [
    {
        "id": "python-tools",
        "name": "Python Language Server & Auto-PEP8",
        "author": "NV Studio Core",
        "version": "1.2.0",
        "desc": "Enhanced Python code analysis, linting, and PEP-8 auto-formatting.",
        "installed": True,
        "enabled": True
    },
    {
        "id": "theme-cyberpunk",
        "name": "NV Neon Cyberpunk Theme",
        "author": "NV Design",
        "version": "1.0.4",
        "desc": "High-contrast dark theme with vibrant neon highlights.",
        "installed": False,
        "enabled": False
    },
    {
        "id": "git-lens",
        "name": "Git Visual Annotations",
        "author": "NV Devs",
        "version": "2.1.0",
        "desc": "Inline git blame, history timeline, and visual branch graph.",
        "installed": True,
        "enabled": True
    },
    {
        "id": "markdown-preview",
        "name": "Markdown Live Previewer",
        "author": "Community",
        "version": "0.9.1",
        "desc": "Side-by-side rendered HTML view for Markdown documents.",
        "installed": False,
        "enabled": False
    },
    {
        "id": "rainbow-brackets",
        "name": "Rainbow Color Brackets",
        "author": "NV Studio Extensions",
        "version": "1.5.0",
        "desc": "Nested parenthesis and bracket matching colorizer.",
        "installed": True,
        "enabled": True
    }
]


class ExtensionsPanel(QWidget):
    """Sidebar extension catalog list and installation manager."""

    def __init__(self, parent=None):
        super().__init__(parent)
        self.setObjectName("ExtensionsPanel")

        layout = QVBoxLayout(self)
        layout.setContentsMargins(0, 0, 0, 0)
        layout.setSpacing(8)

        # Header
        header = QLabel("EXTENSIONS")
        header.setObjectName("SidebarHeader")
        layout.addWidget(header)

        # Tab widget (Installed / Available)
        self.tab_widget = QTabWidget()

        self.installed_list = QListWidget()
        self.available_list = QListWidget()

        self.tab_widget.addTab(self.installed_list, "Installed")
        self.tab_widget.addTab(self.available_list, "Marketplace")

        layout.addWidget(self.tab_widget)

        self._populate_extensions()

    def _populate_extensions(self) -> None:
        self.installed_list.clear()
        self.available_list.clear()

        for ext in EXTENSIONS_DATA:
            item_widget = QWidget()
            w_layout = QVBoxLayout(item_widget)
            w_layout.setContentsMargins(6, 6, 6, 6)
            w_layout.setSpacing(2)

            name_lbl = QLabel(f"<b>{ext['name']}</b> v{ext['version']}")
            name_lbl.setStyleSheet("color: #f1f5f9; font-size: 12px;")

            author_lbl = QLabel(f"By {ext['author']}")
            author_lbl.setStyleSheet("color: #64748b; font-size: 10px;")

            desc_lbl = QLabel(ext['desc'])
            desc_lbl.setWordWrap(True)
            desc_lbl.setStyleSheet("color: #cbd5e1; font-size: 11px;")

            w_layout.addWidget(name_lbl)
            w_layout.addWidget(author_lbl)
            w_layout.addWidget(desc_lbl)

            btn_row = QHBoxLayout()
            btn_row.addStretch()

            if ext['installed']:
                status_btn = QPushButton("Disable" if ext['enabled'] else "Enable")
                status_btn.setFixedSize(65, 24)
                status_btn.clicked.connect(lambda checked, e=ext: self._toggle_extension(e))
                btn_row.addWidget(status_btn)

                item = QListWidgetItem(self.installed_list)
                item.setSizeHint(item_widget.sizeHint())
                self.installed_list.addItem(item)
                self.installed_list.setItemWidget(item, item_widget)
            else:
                install_btn = QPushButton("Install")
                install_btn.setFixedSize(65, 24)
                install_btn.setStyleSheet("background-color: #2563eb; color: #ffffff;")
                install_btn.clicked.connect(lambda checked, e=ext: self._install_extension(e))
                btn_row.addWidget(install_btn)

                item = QListWidgetItem(self.available_list)
                item.setSizeHint(item_widget.sizeHint())
                self.available_list.addItem(item)
                self.available_list.setItemWidget(item, item_widget)

            w_layout.addLayout(btn_row)

    def _toggle_extension(self, ext: dict) -> None:
        ext['enabled'] = not ext['enabled']
        self._populate_extensions()

    def _install_extension(self, ext: dict) -> None:
        ext['installed'] = True
        ext['enabled'] = True
        QMessageBox.information(self, "Extension Installed", f"Successfully installed '{ext['name']}'!")
        self._populate_extensions()
