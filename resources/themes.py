"""
MSAI Studio - Theme and QSS Stylesheet Definitions
"""

DARK_THEME_COLORS = {
    "bg_dark": "#181824",
    "bg_medium": "#1e1e2e",
    "bg_light": "#2b2b3d",
    "bg_sidebar": "#181825",
    "bg_editor": "#1e1e2e",
    "fg_main": "#cdd6f4",
    "fg_muted": "#a6adc8",
    "accent": "#89b4fa",
    "accent_hover": "#b4befe",
    "accent_pressed": "#74c7ec",
    "border": "#313244",
    "line_number": "#585b70",
    "current_line": "#2a2b3d",
    "selection": "#45475a",
    "error": "#f38ba8",
    "warning": "#f9e2af",
    "success": "#a6e3a1",
    "keyword": "#cba6f7",
    "builtin": "#89b4fa",
    "string": "#a6e3a1",
    "number": "#fab387",
    "comment": "#6c7086",
    "function": "#89b4fa",
    "class": "#f9e2af",
    "decorator": "#f5c2e7",
}

LIGHT_THEME_COLORS = {
    "bg_dark": "#e6e9ef",
    "bg_medium": "#eff1f5",
    "bg_light": "#dce0e8",
    "bg_sidebar": "#e6e9ef",
    "bg_editor": "#eff1f5",
    "fg_main": "#4c4f69",
    "fg_muted": "#6c6f85",
    "accent": "#1e66f5",
    "accent_hover": "#7287fd",
    "accent_pressed": "#209fb5",
    "border": "#ccd0da",
    "line_number": "#9ca0b0",
    "current_line": "#e6e9ef",
    "selection": "#acb0be",
    "error": "#d20f39",
    "warning": "#df8e1d",
    "success": "#40a02b",
    "keyword": "#8839ef",
    "builtin": "#1e66f5",
    "string": "#40a02b",
    "number": "#fe640b",
    "comment": "#9ca0b0",
    "function": "#1e66f5",
    "class": "#df8e1d",
    "decorator": "#ea76cb",
}

def get_stylesheet(theme_name: str = "MSAI Dark") -> str:
    """Returns QSS stylesheet string for the chosen theme."""
    c = DARK_THEME_COLORS if theme_name == "MSAI Dark" else LIGHT_THEME_COLORS

    return f"""
    QMainWindow, QDialog {{
        background-color: {c['bg_dark']};
        color: {c['fg_main']};
    }}

    QWidget {{
        font-family: 'Segoe UI', -apple-system, BlinkMacSystemFont, 'Helvetica Neue', Arial, sans-serif;
        color: {c['fg_main']};
    }}

    /* Splitter */
    QSplitter::handle {{
        background-color: {c['border']};
    }}
    QSplitter::handle:horizontal {{
        width: 1px;
    }}
    QSplitter::handle:vertical {{
        height: 1px;
    }}

    /* Scrollbars */
    QScrollBar:vertical {{
        border: none;
        background: {c['bg_dark']};
        width: 10px;
        margin: 0px;
    }}
    QScrollBar::handle:vertical {{
        background: {c['border']};
        min-height: 20px;
        border-radius: 4px;
    }}
    QScrollBar::handle:vertical:hover {{
        background: {c['fg_muted']};
    }}
    QScrollBar::add-line:vertical, QScrollBar::sub-line:vertical {{
        height: 0px;
    }}

    QScrollBar:horizontal {{
        border: none;
        background: {c['bg_dark']};
        height: 10px;
        margin: 0px;
    }}
    QScrollBar::handle:horizontal {{
        background: {c['border']};
        min-width: 20px;
        border-radius: 4px;
    }}
    QScrollBar::handle:horizontal:hover {{
        background: {c['fg_muted']};
    }}
    QScrollBar::add-line:horizontal, QScrollBar::sub-line:horizontal {{
        width: 0px;
    }}

    /* Tab Widget */
    QTabWidget::pane {{
        border: 1px solid {c['border']};
        background: {c['bg_medium']};
    }}
    QTabBar::tab {{
        background: {c['bg_dark']};
        color: {c['fg_muted']};
        padding: 6px 14px;
        border: 1px solid {c['border']};
        border-bottom: none;
        margin-right: 2px;
        border-top-left-radius: 4px;
        border-top-right-radius: 4px;
    }}
    QTabBar::tab:selected {{
        background: {c['bg_medium']};
        color: {c['fg_main']};
        border-bottom: 2px solid {c['accent']};
    }}
    QTabBar::tab:hover:!selected {{
        background: {c['bg_light']};
    }}

    /* TreeView / ListView */
    QTreeView, QListView, QListWidget, QTreeWidget {{
        background-color: {c['bg_sidebar']};
        color: {c['fg_main']};
        border: none;
        outline: none;
    }}
    QTreeView::item:hover, QListView::item:hover {{
        background-color: {c['bg_light']};
    }}
    QTreeView::item:selected, QListView::item:selected {{
        background-color: {c['selection']};
        color: {c['fg_main']};
    }}

    /* Inputs & Buttons */
    QLineEdit, QTextEdit, QPlainTextEdit {{
        background-color: {c['bg_dark']};
        color: {c['fg_main']};
        border: 1px solid {c['border']};
        border-radius: 4px;
        padding: 4px 8px;
        selection-background-color: {c['selection']};
    }}
    QLineEdit:focus, QTextEdit:focus, QPlainTextEdit:focus {{
        border: 1px solid {c['accent']};
    }}

    QPushButton {{
        background-color: {c['bg_light']};
        color: {c['fg_main']};
        border: 1px solid {c['border']};
        border-radius: 4px;
        padding: 6px 12px;
        font-weight: 500;
    }}
    QPushButton:hover {{
        background-color: {c['accent']};
        color: #11111b;
    }}
    QPushButton:pressed {{
        background-color: {c['accent_pressed']};
    }}

    /* Tooltips */
    QToolTip {{
        background-color: {c['bg_light']};
        color: {c['fg_main']};
        border: 1px solid {c['border']};
        padding: 4px;
        border-radius: 3px;
    }}
    """
