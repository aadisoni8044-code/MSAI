class Theme:
    # Color Palette - Dark Modern Developer Theme
    BG_DARK = "#0D0F12"          # Very dark charcoal background
    SURFACE_DARK = "#161B22"     # Card surface background
    SURFACE_HOVER = "#21262D"    # Hover surface
    SURFACE_BORDER = "#30363D"   # Border lines

    TEXT_PRIMARY = "#F0F6FC"     # White / light light gray
    TEXT_SECONDARY = "#8B949E"   # Light gray secondary text
    TEXT_MUTED = "#6E7681"       # Muted gray text

    ACCENT_PRIMARY = "#4F46E5"   # Modern Indigo Accent
    ACCENT_HOVER = "#6366F1"     # Accent hover
    ACCENT_LIGHT = "#EEF2FF"     # Light accent tint

    STATUS_SUCCESS = "#238636"    # Green
    STATUS_SUCCESS_BG = "#0E2A1B" # Dark green tint
    STATUS_FAILED = "#DA3633"     # Red
    STATUS_FAILED_BG = "#381214"  # Dark red tint
    STATUS_WARNING = "#D29922"    # Yellow / Orange

    TERMINAL_BG = "#090C10"      # True black / deep terminal bg
    TERMINAL_TEXT = "#7EE787"    # Matrix green terminal font

    # Global Qt StyleSheet
    STYLE_SHEET = f"""
    QMainWindow {{
        background-color: {BG_DARK};
    }}
    QWidget {{
        color: {TEXT_PRIMARY};
        font-family: "Segoe UI", -apple-system, BlinkMacSystemFont, Roboto, sans-serif;
        font-size: 13px;
    }}
    QFrame#card {{
        background-color: {SURFACE_DARK};
        border: 1px solid {SURFACE_BORDER};
        border-radius: 8px;
    }}
    QLabel {{
        color: {TEXT_PRIMARY};
    }}
    QLabel#secondary {{
        color: {TEXT_SECONDARY};
    }}
    QLabel#heading {{
        font-size: 18px;
        font-weight: bold;
        color: {TEXT_PRIMARY};
    }}
    QPushButton {{
        background-color: {SURFACE_HOVER};
        color: {TEXT_PRIMARY};
        border: 1px solid {SURFACE_BORDER};
        border-radius: 6px;
        padding: 8px 16px;
        font-weight: 500;
    }}
    QPushButton:hover {{
        background-color: {SURFACE_BORDER};
        border-color: {TEXT_SECONDARY};
    }}
    QPushButton:pressed {{
        background-color: {BG_DARK};
    }}
    QPushButton#primary {{
        background-color: {ACCENT_PRIMARY};
        color: #FFFFFF;
        border: none;
        font-weight: bold;
        padding: 10px 20px;
    }}
    QPushButton#primary:hover {{
        background-color: {ACCENT_HOVER};
    }}
    QPushButton#stop {{
        background-color: {STATUS_FAILED};
        color: #FFFFFF;
        border: none;
        font-weight: bold;
    }}
    QLineEdit, QComboBox, QSpinBox {{
        background-color: {TERMINAL_BG};
        color: {TEXT_PRIMARY};
        border: 1px solid {SURFACE_BORDER};
        border-radius: 6px;
        padding: 8px;
        selection-background-color: {ACCENT_PRIMARY};
    }}
    QLineEdit:focus, QComboBox:focus, QSpinBox:focus {{
        border: 1px solid {ACCENT_PRIMARY};
    }}
    QTableWidget {{
        background-color: {SURFACE_DARK};
        border: 1px solid {SURFACE_BORDER};
        gridline-color: {SURFACE_BORDER};
        border-radius: 6px;
    }}
    QHeaderView::section {{
        background-color: {BG_DARK};
        color: {TEXT_SECONDARY};
        padding: 8px;
        border: 1px solid {SURFACE_BORDER};
        font-weight: bold;
    }}
    QTextEdit, QPlainTextEdit {{
        background-color: {TERMINAL_BG};
        color: {TERMINAL_TEXT};
        border: 1px solid {SURFACE_BORDER};
        border-radius: 6px;
        font-family: "Cascadia Code", "Consolas", "Courier New", monospace;
        font-size: 12px;
    }}
    QScrollBar:vertical {{
        border: none;
        background: {BG_DARK};
        width: 10px;
        border-radius: 5px;
    }}
    QScrollBar::handle:vertical {{
        background: {SURFACE_BORDER};
        border-radius: 5px;
    }}
    QScrollBar::handle:vertical:hover {{
        background: {TEXT_SECONDARY};
    }}
    QCheckBox {{
        spacing: 8px;
        color: {TEXT_PRIMARY};
    }}
    QCheckBox::indicator {{
        width: 18px;
        height: 18px;
        border-radius: 4px;
        border: 1px solid {SURFACE_BORDER};
        background-color: {TERMINAL_BG};
    }}
    QCheckBox::indicator:checked {{
        background-color: {ACCENT_PRIMARY};
        border-color: {ACCENT_PRIMARY};
    }}
    """
