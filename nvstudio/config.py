import os
import json
from pathlib import Path

APP_NAME = "NV Studio"
CONFIG_DIR = Path.home() / ".nvstudio"
CONFIG_FILE = CONFIG_DIR / "config.json"
WORKSPACE_FILE = CONFIG_DIR / "workspace.json"

DEFAULT_CONFIG = {
    "theme": "Dark Mode",
    "permission_granted": False,
    "theme_chosen": False,
    "auto_save": True,
    "auto_save_interval": 1500,  # ms
    "font_family": "Consolas, 'Courier New', monospace",
    "font_size": 13,
    "tab_size": 4,
    "preview_device": "Laptop",
    "restore_workspace": True,
    "last_project_path": "",
    "word_wrap": False,
    "show_line_numbers": True
}

DARK_QSS = """
QMainWindow, QDialog {
    background-color: #121824;
    color: #e2e8f0;
}

QWidget {
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
    font-size: 13px;
    color: #e2e8f0;
}

/* Header & Toolbars */
#HeaderBar {
    background-color: #1a2234;
    border-bottom: 1px solid #2d3748;
    padding: 6px 12px;
}

#LogoLabel {
    font-weight: 800;
    font-size: 16px;
    color: #6366f1;
    letter-spacing: 0.5px;
}

#SubLogoLabel {
    font-size: 11px;
    color: #94a3b8;
    font-weight: 500;
}

/* Buttons */
QPushButton {
    background-color: #2a3447;
    color: #f1f5f9;
    border: 1px solid #3b4861;
    border-radius: 6px;
    padding: 6px 14px;
    font-weight: 600;
}

QPushButton:hover {
    background-color: #37445d;
    border-color: #6366f1;
}

QPushButton:pressed {
    background-color: #1f2737;
}

QPushButton#RunButton {
    background-color: #10b981;
    color: #ffffff;
    border: none;
    font-size: 13px;
    font-weight: 700;
    padding: 7px 18px;
    border-radius: 6px;
}

QPushButton#RunButton:hover {
    background-color: #059669;
}

QPushButton#RunButton:pressed {
    background-color: #047857;
}

QPushButton#DeviceBtn {
    background-color: #242f42;
    color: #94a3b8;
    border: 1px solid #334155;
    border-radius: 5px;
    padding: 4px 10px;
    font-size: 12px;
}

QPushButton#DeviceBtn:checked {
    background-color: #6366f1;
    color: #ffffff;
    border-color: #818cf8;
}

/* Tab Bar */
QTabWidget::pane {
    border: 1px solid #2d3748;
    background-color: #1a2234;
    border-radius: 6px;
}

QTabBar::tab {
    background-color: #182030;
    color: #94a3b8;
    border: 1px solid #273246;
    border-bottom: none;
    padding: 8px 16px;
    margin-right: 2px;
    border-top-left-radius: 6px;
    border-top-right-radius: 6px;
}

QTabBar::tab:selected {
    background-color: #1e293b;
    color: #38bdf8;
    font-weight: 600;
    border-top: 2px solid #38bdf8;
}

QTabBar::tab:hover:!selected {
    background-color: #222d42;
    color: #e2e8f0;
}

/* File Explorer */
QTreeView, QListView {
    background-color: #161d2b;
    color: #cbd5e1;
    border: 1px solid #273246;
    border-radius: 6px;
    outline: 0;
    padding: 4px;
}

QTreeView::item {
    padding: 4px;
    border-radius: 4px;
}

QTreeView::item:hover {
    background-color: #222d42;
}

QTreeView::item:selected {
    background-color: #312e81;
    color: #ffffff;
}

/* Text Editors */
QPlainTextEdit {
    background-color: #0f172a;
    color: #f8fafc;
    border: 1px solid #273246;
    border-radius: 6px;
    selection-background-color: #3730a3;
    selection-color: #ffffff;
}

/* Device Frames */
#PreviewContainer {
    background-color: #0f172a;
    border-radius: 8px;
    border: 1px solid #273246;
}

#MobileFrame {
    border: 12px solid #1e293b;
    border-radius: 28px;
    background-color: #000000;
}

#iPadFrame {
    border: 16px solid #1e293b;
    border-radius: 24px;
    background-color: #000000;
}

#LaptopFrame {
    border: 10px solid #1e293b;
    border-radius: 12px;
    background-color: #000000;
}

/* Status Bar */
QStatusBar {
    background-color: #161d2b;
    color: #94a3b8;
    border-top: 1px solid #273246;
}

/* Inputs & Combo */
QLineEdit, QComboBox, QSpinBox {
    background-color: #1e293b;
    color: #f1f5f9;
    border: 1px solid #334155;
    border-radius: 6px;
    padding: 6px 10px;
}

QLineEdit:focus, QComboBox:focus {
    border-color: #6366f1;
}

QCheckBox {
    color: #e2e8f0;
    spacing: 8px;
}

QCheckBox::indicator {
    width: 16px;
    height: 16px;
    border-radius: 4px;
    border: 1px solid #475569;
    background-color: #1e293b;
}

QCheckBox::indicator:checked {
    background-color: #6366f1;
    border-color: #818cf8;
}
"""

WHITE_QSS = """
QMainWindow, QDialog {
    background-color: #f8fafc;
    color: #0f172a;
}

QWidget {
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
    font-size: 13px;
    color: #0f172a;
}

/* Header & Toolbars */
#HeaderBar {
    background-color: #ffffff;
    border-bottom: 1px solid #e2e8f0;
    padding: 6px 12px;
}

#LogoLabel {
    font-weight: 800;
    font-size: 16px;
    color: #4f46e5;
    letter-spacing: 0.5px;
}

#SubLogoLabel {
    font-size: 11px;
    color: #64748b;
    font-weight: 500;
}

/* Buttons */
QPushButton {
    background-color: #f1f5f9;
    color: #1e293b;
    border: 1px solid #cbd5e1;
    border-radius: 6px;
    padding: 6px 14px;
    font-weight: 600;
}

QPushButton:hover {
    background-color: #e2e8f0;
    border-color: #4f46e5;
}

QPushButton:pressed {
    background-color: #cbd5e1;
}

QPushButton#RunButton {
    background-color: #10b981;
    color: #ffffff;
    border: none;
    font-size: 13px;
    font-weight: 700;
    padding: 7px 18px;
    border-radius: 6px;
}

QPushButton#RunButton:hover {
    background-color: #059669;
}

QPushButton#RunButton:pressed {
    background-color: #047857;
}

QPushButton#DeviceBtn {
    background-color: #f8fafc;
    color: #64748b;
    border: 1px solid #cbd5e1;
    border-radius: 5px;
    padding: 4px 10px;
    font-size: 12px;
}

QPushButton#DeviceBtn:checked {
    background-color: #4f46e5;
    color: #ffffff;
    border-color: #4f46e5;
}

/* Tab Bar */
QTabWidget::pane {
    border: 1px solid #e2e8f0;
    background-color: #ffffff;
    border-radius: 6px;
}

QTabBar::tab {
    background-color: #f1f5f9;
    color: #64748b;
    border: 1px solid #e2e8f0;
    border-bottom: none;
    padding: 8px 16px;
    margin-right: 2px;
    border-top-left-radius: 6px;
    border-top-right-radius: 6px;
}

QTabBar::tab:selected {
    background-color: #ffffff;
    color: #0284c7;
    font-weight: 600;
    border-top: 2px solid #0284c7;
}

QTabBar::tab:hover:!selected {
    background-color: #e2e8f0;
    color: #0f172a;
}

/* File Explorer */
QTreeView, QListView {
    background-color: #ffffff;
    color: #1e293b;
    border: 1px solid #e2e8f0;
    border-radius: 6px;
    outline: 0;
    padding: 4px;
}

QTreeView::item {
    padding: 4px;
    border-radius: 4px;
}

QTreeView::item:hover {
    background-color: #f1f5f9;
}

QTreeView::item:selected {
    background-color: #e0e7ff;
    color: #3730a3;
}

/* Text Editors */
QPlainTextEdit {
    background-color: #ffffff;
    color: #0f172a;
    border: 1px solid #cbd5e1;
    border-radius: 6px;
    selection-background-color: #c7d2fe;
    selection-color: #1e1b4b;
}

/* Device Frames */
#PreviewContainer {
    background-color: #f1f5f9;
    border-radius: 8px;
    border: 1px solid #e2e8f0;
}

#MobileFrame {
    border: 12px solid #334155;
    border-radius: 28px;
    background-color: #ffffff;
}

#iPadFrame {
    border: 16px solid #334155;
    border-radius: 24px;
    background-color: #ffffff;
}

#LaptopFrame {
    border: 10px solid #334155;
    border-radius: 12px;
    background-color: #ffffff;
}

/* Status Bar */
QStatusBar {
    background-color: #ffffff;
    color: #64748b;
    border-top: 1px solid #e2e8f0;
}

/* Inputs & Combo */
QLineEdit, QComboBox, QSpinBox {
    background-color: #ffffff;
    color: #0f172a;
    border: 1px solid #cbd5e1;
    border-radius: 6px;
    padding: 6px 10px;
}

QLineEdit:focus, QComboBox:focus {
    border-color: #4f46e5;
}

QCheckBox {
    color: #0f172a;
    spacing: 8px;
}

QCheckBox::indicator {
    width: 16px;
    height: 16px;
    border-radius: 4px;
    border: 1px solid #cbd5e1;
    background-color: #ffffff;
}

QCheckBox::indicator:checked {
    background-color: #4f46e5;
    border-color: #4f46e5;
}
"""


class ConfigManager:
    """Manages NV Studio persistent settings."""

    def __init__(self, config_path=CONFIG_FILE):
        self.config_path = Path(config_path)
        self.data = dict(DEFAULT_CONFIG)
        self.load()

    def load(self):
        if self.config_path.exists():
            try:
                with open(self.config_path, "r", encoding="utf-8") as f:
                    loaded = json.load(f)
                    self.data.update(loaded)
            except Exception as e:
                print(f"[ConfigManager] Error loading config: {e}")
        else:
            self.save()

    def save(self):
        try:
            self.config_path.parent.mkdir(parents=True, exist_ok=True)
            with open(self.config_path, "w", encoding="utf-8") as f:
                json.dump(self.data, f, indent=2)
        except Exception as e:
            print(f"[ConfigManager] Error saving config: {e}")

    def get(self, key, default=None):
        return self.data.get(key, default)

    def set(self, key, value):
        self.data[key] = value
        self.save()

    def get_qss(self):
        theme = self.get("theme", "Dark Mode")
        if theme == "White Mode":
            return WHITE_QSS
        return DARK_QSS
