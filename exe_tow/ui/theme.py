DARK_THEME_QSS = """
/* Global Styles */
QWidget {
    background-color: #090A0D;
    color: #F8FAFC;
    font-family: 'Segoe UI', 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
    font-size: 13px;
    selection-background-color: #2563EB;
    selection-color: #FFFFFF;
}

/* Scrollbars */
QScrollBar:vertical {
    border: none;
    background: #090A0D;
    width: 8px;
    margin: 0px;
    border-radius: 4px;
}
QScrollBar::handle:vertical {
    background: #272A38;
    min-height: 20px;
    border-radius: 4px;
}
QScrollBar::handle:vertical:hover {
    background: #3B82F6;
}
QScrollBar::add-line:vertical, QScrollBar::sub-line:vertical {
    height: 0px;
}

QScrollBar:horizontal {
    border: none;
    background: #090A0D;
    height: 8px;
    margin: 0px;
    border-radius: 4px;
}
QScrollBar::handle:horizontal {
    background: #272A38;
    min-width: 20px;
    border-radius: 4px;
}
QScrollBar::handle:horizontal:hover {
    background: #3B82F6;
}
QScrollBar::add-line:horizontal, QScrollBar::sub-line:horizontal {
    width: 0px;
}

/* Input Fields */
QLineEdit, QPlainTextEdit, QTextEdit {
    background-color: #12141C;
    border: 1px solid #232736;
    border-radius: 6px;
    padding: 8px 12px;
    color: #F8FAFC;
    font-size: 13px;
}
QLineEdit:focus, QPlainTextEdit:focus, QTextEdit:focus {
    border: 1px solid #3B82F6;
    background-color: #161924;
}

/* Combo Box */
QComboBox {
    background-color: #12141C;
    border: 1px solid #232736;
    border-radius: 6px;
    padding: 8px 12px;
    color: #F8FAFC;
}
QComboBox:hover {
    border: 1px solid #3B82F6;
}
QComboBox::drop-down {
    subcontrol-origin: padding;
    subcontrol-position: top right;
    width: 20px;
    border-left-width: 0px;
}
QComboBox QAbstractItemView {
    background-color: #12141C;
    border: 1px solid #232736;
    selection-background-color: #2563EB;
    color: #F8FAFC;
}

/* Checkboxes & Switches */
QCheckBox {
    spacing: 8px;
    color: #E2E8F0;
    font-size: 13px;
}
QCheckBox::indicator {
    width: 18px;
    height: 18px;
    border-radius: 4px;
    border: 1px solid #2E3345;
    background-color: #12141C;
}
QCheckBox::indicator:hover {
    border-color: #3B82F6;
}
QCheckBox::indicator:checked {
    background-color: #2563EB;
    border-color: #2563EB;
    image: url(none);
}

/* Progress Bar */
QProgressBar {
    border: none;
    background-color: #12141C;
    border-radius: 6px;
    height: 10px;
    text-align: center;
}
QProgressBar::chunk {
    background-color: #3B82F6;
    border-radius: 6px;
}

/* Group Boxes / Panels */
QFrame.card {
    background-color: #12141C;
    border: 1px solid #202433;
    border-radius: 10px;
}
QFrame.card-hover:hover {
    border: 1px solid #3B82F6;
}

/* Table View */
QTableWidget, QTableView {
    background-color: #12141C;
    border: 1px solid #202433;
    border-radius: 8px;
    gridline-color: #1E2230;
    color: #F8FAFC;
}
QHeaderView::section {
    background-color: #181B26;
    color: #94A3B8;
    padding: 8px;
    border: none;
    font-weight: 600;
    font-size: 12px;
}
"""

COLOR_PALETTE = {
    "bg_main": "#090A0D",
    "bg_card": "#12141C",
    "bg_card_alt": "#181B26",
    "border": "#202433",
    "border_focus": "#3B82F6",
    "accent": "#2563EB",
    "accent_hover": "#1D4ED8",
    "text_primary": "#F8FAFC",
    "text_secondary": "#94A3B8",
    "text_muted": "#64748B",
    "success": "#10B981",
    "warning": "#F59E0B",
    "error": "#EF4444"
}
