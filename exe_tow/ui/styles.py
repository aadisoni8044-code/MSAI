"""
exe/tow - Application Stylesheet (QSS)
Provides a dark, glass-morphism developer tool aesthetic with subtle borders and white accents.
"""

from exe_tow.ui.theme import ThemeColors

def get_application_stylesheet() -> str:
    return f"""
    QWidget {{
        background-color: {ThemeColors.BG_DARK};
        color: {ThemeColors.TEXT_PRIMARY};
        font-family: {ThemeColors.FONT_FAMILY};
        font-size: 13px;
        selection-background-color: {ThemeColors.BG_ACTIVE};
        selection-color: {ThemeColors.TEXT_PRIMARY};
    }}

    /* Main Window & Containers */
    QMainWindow {{
        background-color: {ThemeColors.BG_DARK};
    }}

    QFrame#TopBar {{
        background-color: {ThemeColors.BG_SURFACE};
        border-bottom: 1px solid {ThemeColors.BORDER_SUBTLE};
    }}

    QFrame#Sidebar {{
        background-color: {ThemeColors.BG_SURFACE};
        border-right: 1px solid {ThemeColors.BORDER_SUBTLE};
    }}

    QFrame#CardPanel {{
        background-color: {ThemeColors.BG_PANEL};
        border: 1px solid {ThemeColors.BORDER_SUBTLE};
        border-radius: {ThemeColors.RADIUS_CARD};
    }}

    QFrame#GlassPanel {{
        background-color: rgba(26, 29, 40, 0.7);
        border: 1px solid {ThemeColors.BORDER_LIGHT};
        border-radius: {ThemeColors.RADIUS_CARD};
    }}

    /* Typography Labels */
    QLabel {{
        color: {ThemeColors.TEXT_PRIMARY};
    }}

    QLabel#TitleLabel {{
        font-size: 22px;
        font-weight: 700;
        color: {ThemeColors.TEXT_PRIMARY};
        letter-spacing: -0.5px;
    }}

    QLabel#SubtitleLabel {{
        font-size: 14px;
        color: {ThemeColors.TEXT_SECONDARY};
    }}

    QLabel#SectionTitle {{
        font-size: 15px;
        font-weight: 600;
        color: {ThemeColors.TEXT_ACCENT};
        letter-spacing: -0.2px;
    }}

    /* Buttons */
    QPushButton {{
        background-color: {ThemeColors.BG_PANEL};
        color: {ThemeColors.TEXT_PRIMARY};
        border: 1px solid {ThemeColors.BORDER_SUBTLE};
        border-radius: {ThemeColors.RADIUS_BTN};
        padding: 8px 16px;
        font-weight: 500;
    }}

    QPushButton:hover {{
        background-color: {ThemeColors.BG_HOVER};
        border-color: {ThemeColors.BORDER_LIGHT};
    }}

    QPushButton:pressed {{
        background-color: {ThemeColors.BG_ACTIVE};
    }}

    QPushButton#PrimaryButton {{
        background-color: {ThemeColors.ACCENT_WHITE};
        color: #000000;
        border: 1px solid {ThemeColors.ACCENT_WHITE};
        font-weight: 700;
        font-size: 14px;
        padding: 12px 24px;
    }}

    QPushButton#PrimaryButton:hover {{
        background-color: {ThemeColors.ACCENT_GRAY};
        border-color: {ThemeColors.ACCENT_GRAY};
    }}

    QPushButton#PrimaryButton:pressed {{
        background-color: #94A3B8;
    }}

    QPushButton#SidebarNavButton {{
        background-color: transparent;
        color: {ThemeColors.TEXT_SECONDARY};
        border: none;
        border-radius: 6px;
        padding: 10px 14px;
        text-align: left;
        font-size: 13px;
        font-weight: 500;
    }}

    QPushButton#SidebarNavButton:hover {{
        background-color: {ThemeColors.BG_HOVER};
        color: {ThemeColors.TEXT_PRIMARY};
    }}

    QPushButton#SidebarNavButton[active="true"] {{
        background-color: {ThemeColors.BG_PANEL};
        color: {ThemeColors.ACCENT_WHITE};
        border-left: 3px solid {ThemeColors.ACCENT_WHITE};
        font-weight: 600;
    }}

    QPushButton#WindowControlBtn {{
        background-color: transparent;
        border: none;
        border-radius: 4px;
        color: {ThemeColors.TEXT_MUTED};
        font-size: 12px;
    }}

    QPushButton#WindowControlBtn:hover {{
        background-color: {ThemeColors.BG_HOVER};
        color: {ThemeColors.TEXT_PRIMARY};
    }}

    QPushButton#WindowControlBtnClose:hover {{
        background-color: {ThemeColors.STATUS_ERROR};
        color: #FFFFFF;
    }}

    /* Text Inputs */
    QLineEdit, QPlainTextEdit, QTextEdit {{
        background-color: {ThemeColors.BG_INPUT};
        border: 1px solid {ThemeColors.BORDER_SUBTLE};
        border-radius: {ThemeColors.RADIUS_BTN};
        color: {ThemeColors.TEXT_PRIMARY};
        padding: 8px 12px;
        font-size: 13px;
    }}

    QLineEdit:focus, QPlainTextEdit:focus {{
        border-color: {ThemeColors.BORDER_FOCUS};
    }}

    /* Checkboxes & Switches */
    QCheckBox {{
        color: {ThemeColors.TEXT_PRIMARY};
        spacing: 8px;
    }}

    QCheckBox::indicator {{
        width: 18px;
        height: 18px;
        border-radius: 4px;
        border: 1px solid {ThemeColors.BORDER_LIGHT};
        background-color: {ThemeColors.BG_INPUT};
    }}

    QCheckBox::indicator:checked {{
        background-color: {ThemeColors.ACCENT_WHITE};
        border-color: {ThemeColors.ACCENT_WHITE};
        image: none;
    }}

    /* Progress Bar */
    QProgressBar {{
        background-color: {ThemeColors.BG_INPUT};
        border: 1px solid {ThemeColors.BORDER_SUBTLE};
        border-radius: 6px;
        text-align: center;
        color: {ThemeColors.TEXT_PRIMARY};
        font-weight: 600;
        height: 12px;
    }}

    QProgressBar::chunk {{
        background-color: {ThemeColors.ACCENT_WHITE};
        border-radius: 5px;
    }}

    /* Tables */
    QTableWidget {{
        background-color: {ThemeColors.BG_SURFACE};
        border: 1px solid {ThemeColors.BORDER_SUBTLE};
        border-radius: {ThemeColors.RADIUS_CARD};
        gridline-color: {ThemeColors.BORDER_SUBTLE};
    }}

    QHeaderView::section {{
        background-color: {ThemeColors.BG_PANEL};
        color: {ThemeColors.TEXT_SECONDARY};
        padding: 8px;
        border: none;
        border-bottom: 1px solid {ThemeColors.BORDER_SUBTLE};
        font-weight: 600;
    }}

    /* Scrollbars */
    QScrollBar:vertical {{
        background: {ThemeColors.BG_DARK};
        width: 8px;
        margin: 0px;
    }}
    QScrollBar::handle:vertical {{
        background: {ThemeColors.BORDER_LIGHT};
        min-height: 20px;
        border-radius: 4px;
    }}
    QScrollBar::add-line:vertical, QScrollBar::sub-line:vertical {{
        height: 0px;
    }}
    """
