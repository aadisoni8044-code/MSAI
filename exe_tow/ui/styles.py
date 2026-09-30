"""
Dark, futuristic hacker/developer-tool theme styles for exe/tow.
Color Palette:
- Background Dark: #090A0D
- Surface Dark: #12151C
- Surface Panel: #181C26
- Text Primary: #FFFFFF
- Text Muted: #8A92A6
- Neon Accent / Terminal Green: #00FF66
- Neon Glow / Hover Green: #00CC55
- Dark Green Highlight: #0D2B1D
- Border Dark: #1E2638
- Border Neon: #00FF66
- Error Red: #FF4D4D
"""

STYLESHEET = """
QMainWindow, QWidget#CentralWidget {
    background-color: #090A0D;
    color: #FFFFFF;
    font-family: 'Segoe UI', -apple-system, BlinkMacSystemFont, Roboto, sans-serif;
    font-size: 13px;
}

QWidget {
    color: #FFFFFF;
}

/* ScrollBars */
QScrollBar:vertical {
    background: #090A0D;
    width: 8px;
    margin: 0px;
}
QScrollBar::handle:vertical {
    background: #1E2638;
    min-height: 20px;
    border-radius: 4px;
}
QScrollBar::handle:vertical:hover {
    background: #00FF66;
}
QScrollBar::add-line:vertical, QScrollBar::sub-line:vertical {
    height: 0px;
}

QScrollBar:horizontal {
    background: #090A0D;
    height: 8px;
    margin: 0px;
}
QScrollBar::handle:horizontal {
    background: #1E2638;
    min-width: 20px;
    border-radius: 4px;
}
QScrollBar::handle:horizontal:hover {
    background: #00FF66;
}
QScrollBar::add-line:horizontal, QScrollBar::sub-line:horizontal {
    width: 0px;
}

/* Sidebar Navigation */
QFrame#SidebarFrame {
    background-color: #0D0F14;
    border-right: 1px solid #1E2638;
}

QPushButton#NavButton {
    background-color: transparent;
    color: #8A92A6;
    border: none;
    border-left: 3px solid transparent;
    padding: 12px 18px;
    text-align: left;
    font-size: 14px;
    font-weight: 500;
}

QPushButton#NavButton:hover {
    background-color: #12151C;
    color: #FFFFFF;
}

QPushButton#NavButton[active="true"] {
    background-color: #121C18;
    color: #00FF66;
    border-left: 3px solid #00FF66;
    font-weight: bold;
}

/* Top Bar Header */
QFrame#TopBarFrame {
    background-color: #0D0F14;
    border-bottom: 1px solid #1E2638;
    min-height: 54px;
    max-height: 54px;
}

QLabel#BrandTitle {
    font-size: 16px;
    font-weight: bold;
    color: #FFFFFF;
    letter-spacing: 1px;
}

QLabel#BrandSubtitle {
    font-size: 11px;
    color: #00FF66;
    font-family: 'Consolas', 'Courier New', monospace;
}

QLabel#StatusBadgeReady {
    color: #00FF66;
    font-size: 12px;
    font-weight: bold;
    font-family: 'Consolas', 'Courier New', monospace;
    background-color: #0D2B1D;
    border: 1px solid #00FF66;
    border-radius: 12px;
    padding: 4px 12px;
}

QLabel#StatusBadgeBuilding {
    color: #FFB703;
    font-size: 12px;
    font-weight: bold;
    font-family: 'Consolas', 'Courier New', monospace;
    background-color: #2B230D;
    border: 1px solid #FFB703;
    border-radius: 12px;
    padding: 4px 12px;
}

/* Window Control Buttons */
QPushButton#WindowControlBtn {
    background-color: transparent;
    color: #8A92A6;
    border: none;
    font-size: 14px;
    font-weight: bold;
    min-width: 36px;
    min-height: 30px;
}

QPushButton#WindowControlBtn:hover {
    background-color: #1E2638;
    color: #FFFFFF;
}

QPushButton#WindowControlCloseBtn:hover {
    background-color: #FF4D4D;
    color: #FFFFFF;
}

/* Primary Neon Button */
QPushButton#NeonPrimaryBtn {
    background-color: #00FF66;
    color: #090A0D;
    border: 1px solid #00FF66;
    border-radius: 6px;
    padding: 10px 22px;
    font-size: 13px;
    font-weight: bold;
    letter-spacing: 0.5px;
}

QPushButton#NeonPrimaryBtn:hover {
    background-color: #00CC55;
    border-color: #00CC55;
    box-shadow: 0 0 10px rgba(0, 255, 102, 0.4);
}

QPushButton#NeonPrimaryBtn:disabled {
    background-color: #1E2638;
    color: #555E70;
    border-color: #1E2638;
}

/* Secondary Button */
QPushButton#SecondaryBtn {
    background-color: #12151C;
    color: #FFFFFF;
    border: 1px solid #1E2638;
    border-radius: 6px;
    padding: 10px 22px;
    font-size: 13px;
    font-weight: bold;
}

QPushButton#SecondaryBtn:hover {
    background-color: #181C26;
    border-color: #00FF66;
    color: #00FF66;
}

/* Cards & Containers */
QFrame#HackerCard {
    background-color: #12151C;
    border: 1px solid #1E2638;
    border-radius: 8px;
}

QFrame#HackerCard:hover {
    border: 1px solid #2B364D;
}

/* Stat Box */
QFrame#StatCard {
    background-color: #12151C;
    border: 1px solid #1E2638;
    border-radius: 8px;
    padding: 16px;
}

QLabel#StatValue {
    font-size: 28px;
    font-weight: bold;
    color: #00FF66;
    font-family: 'Consolas', 'Courier New', monospace;
}

QLabel#StatLabel {
    font-size: 11px;
    font-weight: bold;
    color: #8A92A6;
    letter-spacing: 1px;
}

/* Form Inputs */
QLineEdit, QComboBox {
    background-color: #090A0D;
    color: #FFFFFF;
    border: 1px solid #1E2638;
    border-radius: 6px;
    padding: 8px 12px;
    font-size: 13px;
    selection-background-color: #00FF66;
    selection-color: #090A0D;
}

QLineEdit:focus, QComboBox:focus {
    border: 1px solid #00FF66;
}

QCheckBox {
    color: #FFFFFF;
    spacing: 8px;
    font-size: 13px;
}

QCheckBox::indicator {
    width: 18px;
    height: 18px;
    border: 1px solid #1E2638;
    border-radius: 4px;
    background-color: #090A0D;
}

QCheckBox::indicator:checked {
    background-color: #00FF66;
    border: 1px solid #00FF66;
    image: url("data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='%23090A0D' stroke-width='4' stroke-linecap='round' stroke-linejoin='round'><polyline points='20 6 9 17 4 12'></polyline></svg>");
}

/* Monospace Terminal Panel */
QTextEdit#TerminalText {
    background-color: #06070A;
    color: #00FF66;
    border: 1px solid #1E2638;
    border-radius: 6px;
    font-family: 'Consolas', 'Cascadia Code', 'Courier New', monospace;
    font-size: 12px;
    padding: 10px;
    line-height: 1.4;
}

/* Tables */
QTableWidget {
    background-color: #12151C;
    color: #FFFFFF;
    gridline-color: #1E2638;
    border: 1px solid #1E2638;
    border-radius: 8px;
}

QHeaderView::section {
    background-color: #0D0F14;
    color: #8A92A6;
    padding: 10px;
    border: none;
    border-bottom: 1px solid #1E2638;
    font-weight: bold;
    font-size: 12px;
    letter-spacing: 0.5px;
}

QTableWidget::item {
    padding: 10px;
    border-bottom: 1px solid #161A24;
}

QTableWidget::item:selected {
    background-color: #182220;
    color: #00FF66;
}
"""
