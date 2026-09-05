"""NV Studio Theme and Styling Engine"""

NV_DARK_QSS = """
/* Global Window Base */
QMainWindow, QDialog {
    background-color: #10141d;
    color: #c5cddb;
    font-family: 'Segoe UI', system-ui, -apple-system, sans-serif;
    font-size: 13px;
}

QWidget {
    background-color: transparent;
    color: #c5cddb;
    font-family: 'Segoe UI', system-ui, -apple-system, sans-serif;
}

/* Custom Title Bar */
#TitleBar {
    background-color: #0b0e14;
    border-bottom: 1px solid #1a202c;
    min-height: 38px;
    max-height: 38px;
}

#TitleLogoLabel {
    color: #4f80ff;
    font-weight: bold;
    font-size: 14px;
    padding-left: 10px;
    padding-right: 10px;
}

#TitleTextLabel {
    color: #8c97ad;
    font-size: 12px;
}

#TitleBar QToolButton {
    background: transparent;
    border: none;
    color: #8c97ad;
    padding: 6px 10px;
    font-size: 12px;
}

#TitleBar QToolButton:hover {
    background-color: #1e2636;
    color: #ffffff;
}

#TitleBar #CloseButton:hover {
    background-color: #e53e3e;
    color: #ffffff;
}

/* Activity Bar (Left Vertical Toolbar) */
#ActivityBar {
    background-color: #0b0e14;
    border-right: 1px solid #1a202c;
    min-width: 48px;
    max-width: 48px;
}

#ActivityBar QPushButton {
    background-color: transparent;
    border: none;
    border-left: 2px solid transparent;
    color: #64748b;
    padding: 10px 0px;
    font-size: 16px;
    margin: 2px 0px;
}

#ActivityBar QPushButton:hover {
    color: #cbd5e1;
    background-color: #141a24;
}

#ActivityBar QPushButton[active="true"] {
    color: #4f80ff;
    border-left: 2px solid #4f80ff;
    background-color: #161c28;
}

/* Sidebar Containers */
#SidebarContainer {
    background-color: #141923;
    border-right: 1px solid #1e2636;
}

#SidebarHeader {
    background-color: #10141d;
    border-bottom: 1px solid #1e2636;
    padding: 8px 12px;
    font-weight: 600;
    font-size: 11px;
    text-transform: uppercase;
    color: #94a3b8;
    letter-spacing: 0.5px;
}

/* Tree Views / File Explorer */
QTreeView, QListView {
    background-color: #141923;
    border: none;
    color: #cbd5e1;
    outline: none;
    font-size: 13px;
}

QTreeView::item {
    padding: 4px 6px;
    border-radius: 3px;
    margin: 1px 4px;
}

QTreeView::item:hover {
    background-color: #1e2738;
    color: #f1f5f9;
}

QTreeView::item:selected {
    background-color: #25334d;
    color: #ffffff;
}

QTreeView::branch {
    background: transparent;
}

/* Editor Tabs */
#EditorTabWidget QTabBar::tab {
    background-color: #0f131c;
    color: #64748b;
    border: none;
    border-right: 1px solid #181f2c;
    border-top: 2px solid transparent;
    padding: 8px 16px;
    min-width: 90px;
    font-size: 12px;
}

#EditorTabWidget QTabBar::tab:hover {
    background-color: #161c27;
    color: #cbd5e1;
}

#EditorTabWidget QTabBar::tab:selected {
    background-color: #141923;
    color: #f8fafc;
    border-top: 2px solid #4f80ff;
}

#EditorTabWidget QTabBar::close-button {
    image: none;
    subcontrol-position: right;
    margin-left: 6px;
}

#EditorTabWidget QTabBar::close-button:hover {
    background-color: #2d3748;
    border-radius: 2px;
}

/* Code Editor Window */
#CodeEditor {
    background-color: #141923;
    color: #e2e8f0;
    border: none;
    font-family: 'Consolas', 'Courier New', monospace;
    selection-background-color: #263859;
    selection-color: #ffffff;
}

#LineNumberMargin {
    background-color: #10141d;
    color: #475569;
    border-right: 1px solid #1e2636;
    font-family: 'Consolas', 'Courier New', monospace;
}

/* Bottom Panel Dock */
#BottomPanel {
    background-color: #10141d;
    border-top: 1px solid #1e2636;
}

#BottomPanel QTabBar::tab {
    background-color: transparent;
    color: #64748b;
    padding: 6px 14px;
    font-size: 12px;
    font-weight: 500;
    border: none;
    border-bottom: 2px solid transparent;
}

#BottomPanel QTabBar::tab:hover {
    color: #cbd5e1;
}

#BottomPanel QTabBar::tab:selected {
    color: #4f80ff;
    border-bottom: 2px solid #4f80ff;
}

/* Status Bar */
QStatusBar {
    background-color: #0b0e14;
    color: #94a3b8;
    border-top: 1px solid #1a202c;
    min-height: 24px;
    max-height: 24px;
    font-size: 11px;
}

QStatusBar QLabel {
    color: #94a3b8;
    padding: 0 8px;
}

/* Input Fields & Buttons */
QLineEdit, QTextEdit, QPlainTextEdit {
    background-color: #0f131c;
    border: 1px solid #232d3f;
    border-radius: 4px;
    color: #f1f5f9;
    padding: 5px 8px;
    selection-background-color: #3b82f6;
}

QLineEdit:focus, QTextEdit:focus, QPlainTextEdit:focus {
    border: 1px solid #4f80ff;
}

QPushButton {
    background-color: #2563eb;
    color: #ffffff;
    border: none;
    border-radius: 4px;
    padding: 6px 14px;
    font-weight: 500;
}

QPushButton:hover {
    background-color: #3b82f6;
}

QPushButton:pressed {
    background-color: #1d4ed8;
}

QPushButton:disabled {
    background-color: #1e293b;
    color: #475569;
}

/* Combo Box & Spin Box */
QComboBox, QSpinBox {
    background-color: #0f131c;
    border: 1px solid #232d3f;
    border-radius: 4px;
    color: #f1f5f9;
    padding: 4px 8px;
}

QComboBox::drop-down {
    border: none;
}

QComboBox QAbstractItemView {
    background-color: #141923;
    border: 1px solid #232d3f;
    selection-background-color: #25334d;
    color: #f1f5f9;
}

/* Scrollbars */
QScrollBar:vertical {
    background-color: #10141d;
    width: 10px;
    margin: 0px;
}

QScrollBar::handle:vertical {
    background-color: #242d3d;
    min-height: 20px;
    border-radius: 4px;
    margin: 2px;
}

QScrollBar::handle:vertical:hover {
    background-color: #3b485e;
}

QScrollBar::add-line:vertical, QScrollBar::sub-line:vertical {
    height: 0px;
}

QScrollBar:horizontal {
    background-color: #10141d;
    height: 10px;
    margin: 0px;
}

QScrollBar::handle:horizontal {
    background-color: #242d3d;
    min-width: 20px;
    border-radius: 4px;
    margin: 2px;
}

QScrollBar::handle:horizontal:hover {
    background-color: #3b485e;
}

QScrollBar::add-line:horizontal, QScrollBar::sub-line:horizontal {
    width: 0px;
}

/* Splitter Handle */
QSplitter::handle {
    background-color: #1e2636;
}

QSplitter::handle:hover {
    background-color: #4f80ff;
}

/* Tooltips */
QToolTip {
    background-color: #1e2636;
    color: #f8fafc;
    border: 1px solid #334155;
    padding: 4px 8px;
    border-radius: 4px;
}
"""


def get_theme_qss(theme_name: str = "NV Dark") -> str:
    """Return the QSS stylesheet string for the requested theme."""
    return NV_DARK_QSS
