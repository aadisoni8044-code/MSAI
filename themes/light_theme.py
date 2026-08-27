"""
VS Code Light+ inspired QSS theme stylesheet for PyCodeStudio.
"""

LIGHT_THEME_QSS = """
QMainWindow {
    background-color: #ffffff;
    color: #000000;
}

QWidget {
    background-color: #ffffff;
    color: #333333;
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    font-size: 13px;
}

QMenuBar {
    background-color: #dddddd;
    color: #333333;
    border-bottom: 1px solid #cccccc;
}

QMenuBar::item {
    background-color: transparent;
    padding: 4px 10px;
}

QMenuBar::item:selected {
    background-color: #c8c8c8;
    color: #000000;
}

QMenu {
    background-color: #f3f3f3;
    color: #333333;
    border: 1px solid #cccccc;
}

QMenu::item {
    padding: 6px 24px 6px 12px;
}

QMenu::item:selected {
    background-color: #0060c0;
    color: #ffffff;
}

QSplitter::handle {
    background-color: #e5e5e5;
}

QSplitter::handle:hover {
    background-color: #007acc;
}

QTabWidget::pane {
    border: none;
    background-color: #ffffff;
}

QTabBar::tab {
    background-color: #ececec;
    color: #616161;
    padding: 8px 16px;
    border-right: 1px solid #e5e5e5;
    min-width: 100px;
}

QTabBar::tab:selected {
    background-color: #ffffff;
    color: #333333;
    border-top: 2px solid #007acc;
}

QTabBar::tab:hover:!selected {
    background-color: #f3f3f3;
    color: #333333;
}

QTreeView {
    background-color: #f3f3f3;
    color: #333333;
    border: none;
    outline: none;
}

QTreeView::item {
    padding: 4px;
}

QTreeView::item:hover {
    background-color: #e8e8e8;
}

QTreeView::item:selected {
    background-color: #0060c0;
    color: #ffffff;
}

QLineEdit, QTextEdit, QPlainTextEdit {
    background-color: #ffffff;
    color: #333333;
    border: 1px solid #cecece;
    border-radius: 2px;
    padding: 4px;
    selection-background-color: #a6d2ff;
}

QLineEdit:focus, QTextEdit:focus {
    border: 1px solid #007acc;
}

QPushButton {
    background-color: #007acc;
    color: #ffffff;
    border: none;
    border-radius: 2px;
    padding: 6px 14px;
    font-weight: bold;
}

QPushButton:hover {
    background-color: #0062a3;
}

QPushButton:pressed {
    background-color: #004c7e;
}

QStatusBar {
    background-color: #007acc;
    color: #ffffff;
    font-size: 12px;
}

QStatusBar::item {
    border: none;
}

QScrollBar:vertical {
    background: #f3f3f3;
    width: 12px;
    margin: 0px;
}

QScrollBar::handle:vertical {
    background: #c2c2c2;
    min-height: 20px;
}

QScrollBar::handle:vertical:hover {
    background: #a6a6a6;
}

QScrollBar::add-line:vertical, QScrollBar::sub-line:vertical {
    height: 0px;
}

QScrollBar:horizontal {
    background: #f3f3f3;
    height: 12px;
    margin: 0px;
}

QScrollBar::handle:horizontal {
    background: #c2c2c2;
    min-width: 20px;
}

QScrollBar::handle:horizontal:hover {
    background: #a6a6a6;
}

QScrollBar::add-line:horizontal, QScrollBar::sub-line:horizontal {
    width: 0px;
}
"""
