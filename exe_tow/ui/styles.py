"""
Dark Hacker / Modern Developer Workstation Style Sheet for exe/tow.
"""

DARK_STYLESHEET = """
/* Global Window & Base Styles */
QWidget {
    background-color: #090A0D;
    color: #FFFFFF;
    font-family: 'Segoe UI', 'SF Pro Text', -apple-system, BlinkMacSystemFont, sans-serif;
    font-size: 13px;
    selection-background-color: #00FF66;
    selection-color: #090A0D;
    outline: none;
}

/* Scrollbars */
QScrollBar:vertical {
    border: none;
    background: #0D0F14;
    width: 8px;
    margin: 0px 0px 0px 0px;
    border-radius: 4px;
}
QScrollBar::handle:vertical {
    background: #2A2E3D;
    min-height: 20px;
    border-radius: 4px;
}
QScrollBar::handle:vertical:hover {
    background: #00FF66;
}
QScrollBar::add-line:vertical, QScrollBar::sub-line:vertical {
    height: 0px;
}
QScrollBar::add-page:vertical, QScrollBar::sub-page:vertical {
    background: none;
}

QScrollBar:horizontal {
    border: none;
    background: #0D0F14;
    height: 8px;
    margin: 0px;
    border-radius: 4px;
}
QScrollBar::handle:horizontal {
    background: #2A2E3D;
    min-width: 20px;
    border-radius: 4px;
}
QScrollBar::handle:horizontal:hover {
    background: #00FF66;
}
QScrollBar::add-line:horizontal, QScrollBar::sub-line:horizontal {
    width: 0px;
}

/* Frame Cards & Panels */
QFrame.panelCard {
    background-color: #12141A;
    border: 1px solid #1E222D;
    border-radius: 8px;
}
QFrame.panelCardHighlighted {
    background-color: #151820;
    border: 1px solid #00FF66;
    border-radius: 8px;
}
QFrame.heroCard {
    background: qlineargradient(x1:0, y1:0, x2:1, y2:1, stop:0 #13161F, stop:1 #0F1219);
    border: 1px solid #1E2433;
    border-radius: 10px;
}

/* Headings & Labels */
QLabel.h1 {
    font-size: 22px;
    font-weight: 800;
    color: #FFFFFF;
    letter-spacing: 1px;
}
QLabel.h2 {
    font-size: 16px;
    font-weight: 700;
    color: #FFFFFF;
    letter-spacing: 0.5px;
}
QLabel.h3 {
    font-size: 14px;
    font-weight: 600;
    color: #00FF66;
}
QLabel.subtitle {
    font-size: 12px;
    color: #8A8F9E;
}
QLabel.badgeGreen {
    background-color: #0B2B1B;
    color: #00FF66;
    border: 1px solid #00FF66;
    border-radius: 4px;
    padding: 2px 8px;
    font-size: 11px;
    font-weight: 700;
}
QLabel.badgeCyan {
    background-color: #0A2733;
    color: #00E5FF;
    border: 1px solid #00E5FF;
    border-radius: 4px;
    padding: 2px 8px;
    font-size: 11px;
    font-weight: 700;
}
QLabel.badgeAmber {
    background-color: #2E220A;
    color: #FFB300;
    border: 1px solid #FFB300;
    border-radius: 4px;
    padding: 2px 8px;
    font-size: 11px;
    font-weight: 700;
}
QLabel.badgeRed {
    background-color: #2E1215;
    color: #FF4D4D;
    border: 1px solid #FF4D4D;
    border-radius: 4px;
    padding: 2px 8px;
    font-size: 11px;
    font-weight: 700;
}

/* Buttons */
QPushButton {
    background-color: #1A1D26;
    color: #FFFFFF;
    border: 1px solid #2B3040;
    border-radius: 6px;
    padding: 8px 16px;
    font-weight: 600;
}
QPushButton:hover {
    background-color: #232836;
    border-color: #00FF66;
    color: #00FF66;
}
QPushButton:pressed {
    background-color: #12141A;
}

QPushButton.btnPrimary {
    background-color: #00FF66;
    color: #090A0D;
    border: 1px solid #00FF66;
    font-weight: 800;
    letter-spacing: 0.5px;
}
QPushButton.btnPrimary:hover {
    background-color: #33FF85;
    border-color: #33FF85;
    color: #090A0D;
}
QPushButton.btnPrimary:pressed {
    background-color: #00CC52;
}

QPushButton.btnSecondary {
    background-color: #1E222D;
    color: #00E5FF;
    border: 1px solid #00E5FF;
}
QPushButton.btnSecondary:hover {
    background-color: #252B3A;
    color: #66F0FF;
}

QPushButton.btnDanger {
    background-color: #2A1417;
    color: #FF4D4D;
    border: 1px solid #FF4D4D;
}
QPushButton.btnDanger:hover {
    background-color: #3B1B1F;
}

/* LineEdits & ComboBoxes */
QLineEdit, QComboBox, QSpinBox {
    background-color: #0E1015;
    color: #FFFFFF;
    border: 1px solid #232733;
    border-radius: 6px;
    padding: 8px 12px;
    font-size: 13px;
}
QLineEdit:focus, QComboBox:focus {
    border: 1px solid #00FF66;
}
QComboBox::drop-down {
    border: none;
    width: 24px;
}
QComboBox QAbstractItemView {
    background-color: #12141A;
    color: #FFFFFF;
    border: 1px solid #232733;
    selection-background-color: #00FF66;
    selection-color: #090A0D;
}

/* CheckBox & RadioButton */
QCheckBox, QRadioButton {
    color: #E2E8F0;
    spacing: 8px;
    font-size: 13px;
}
QCheckBox::indicator, QRadioButton::indicator {
    width: 16px;
    height: 16px;
    background-color: #0E1015;
    border: 1px solid #2E3445;
    border-radius: 3px;
}
QRadioButton::indicator {
    border-radius: 8px;
}
QCheckBox::indicator:checked {
    background-color: #00FF66;
    border-color: #00FF66;
    image: url("data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='%23090A0D' stroke-width='3' stroke-linecap='round' stroke-linejoin='round'><polyline points='20 6 9 17 4 12'></polyline></svg>");
}
QRadioButton::indicator:checked {
    background-color: #00FF66;
    border-color: #00FF66;
}

/* Progress Bar */
QProgressBar {
    background-color: #0E1015;
    border: 1px solid #232733;
    border-radius: 6px;
    text-align: center;
    color: #FFFFFF;
    font-weight: 700;
}
QProgressBar::chunk {
    background: qlineargradient(x1:0, y1:0, x2:1, y2:0, stop:0 #00FF66, stop:1 #00E5FF);
    border-radius: 5px;
}

/* Table View */
QTableWidget {
    background-color: #0E1015;
    border: 1px solid #1E222D;
    gridline-color: #1A1D28;
    color: #FFFFFF;
    border-radius: 6px;
}
QHeaderView::section {
    background-color: #141720;
    color: #8A8F9E;
    padding: 8px;
    border: none;
    border-bottom: 1px solid #232733;
    font-weight: 700;
    font-size: 11px;
    text-transform: uppercase;
}
QTableWidget::item {
    padding: 8px;
    border-bottom: 1px solid #141720;
}
QTableWidget::item:selected {
    background-color: #182B21;
    color: #00FF66;
}

/* Monospace Terminal */
QTextEdit.terminalText {
    background-color: #060709;
    color: #00FF66;
    font-family: 'JetBrains Mono', 'Cascadia Code', 'Consolas', 'Courier New', monospace;
    font-size: 12px;
    border: 1px solid #1A1D26;
    border-radius: 6px;
    padding: 10px;
    line-height: 1.4;
}
"""
