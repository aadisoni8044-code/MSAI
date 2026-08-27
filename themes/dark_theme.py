"""
VS Code Dark+ inspired QSS theme stylesheet for PyCodeStudio.
"""

DARK_THEME_QSS = """
QMainWindow {
    background-color: #1e1e1e;
    color: #d4d4d4;
}

QWidget {
    background-color: #1e1e1e;
    color: #d4d4d4;
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    font-size: 13px;
}

QMenuBar {
    background-color: #3c3c3c;
    color: #cccccc;
    border-bottom: 1px solid #252526;
}

QMenuBar::item {
    background-color: transparent;
    padding: 4px 10px;
}

QMenuBar::item:selected {
    background-color: #505050;
    color: #ffffff;
}

QMenu {
    background-color: #252526;
    color: #cccccc;
    border: 1px solid #454545;
}

QMenu::item {
    padding: 6px 24px 6px 12px;
}

QMenu::item:selected {
    background-color: #04395e;
    color: #ffffff;
}

QSplitter::handle {
    background-color: #2d2d2d;
}

QSplitter::handle:hover {
    background-color: #007acc;
}

QTabWidget::pane {
    border: none;
    background-color: #1e1e1e;
}

QTabBar::tab {
    background-color: #2d2d2d;
    color: #969696;
    padding: 8px 16px;
    border-right: 1px solid #252526;
    min-width: 100px;
}

QTabBar::tab:selected {
    background-color: #1e1e1e;
    color: #ffffff;
    border-top: 2px solid #007acc;
}

QTabBar::tab:hover:!selected {
    background-color: #2a2d2e;
    color: #cccccc;
}

QTreeView {
    background-color: #252526;
    color: #cccccc;
    border: none;
    outline: none;
}

QTreeView::item {
    padding: 4px;
}

QTreeView::item:hover {
    background-color: #2a2d2e;
}

QTreeView::item:selected {
    background-color: #37373d;
    color: #ffffff;
}

QLineEdit, QTextEdit, QPlainTextEdit {
    background-color: #3c3c3c;
    color: #cccccc;
    border: 1px solid #3c3c3c;
    border-radius: 2px;
    padding: 4px;
    selection-background-color: #264f78;
}

QLineEdit:focus, QTextEdit:focus {
    border: 1px solid #007acc;
}

QPushButton {
    background-color: #0e639c;
    color: #ffffff;
    border: none;
    border-radius: 2px;
    padding: 6px 14px;
    font-weight: bold;
}

QPushButton:hover {
    background-color: #1177bb;
}

QPushButton:pressed {
    background-color: #094771;
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
    background: #1e1e1e;
    width: 12px;
    margin: 0px;
}

QScrollBar::handle:vertical {
    background: #424242;
    min-height: 20px;
}

QScrollBar::handle:vertical:hover {
    background: #4f4f4f;
}

QScrollBar::add-line:vertical, QScrollBar::sub-line:vertical {
    height: 0px;
}

QScrollBar:horizontal {
    background: #1e1e1e;
    height: 12px;
    margin: 0px;
}

QScrollBar::handle:horizontal {
    background: #424242;
    min-width: 20px;
}

QScrollBar::handle:horizontal:hover {
    background: #4f4f4f;
}

QScrollBar::add-line:horizontal, QScrollBar::sub-line:horizontal {
    width: 0px;
}
"""
