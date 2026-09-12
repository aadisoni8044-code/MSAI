import sys
import os
import re
from PySide6.QtCore import Qt, QRect, QSize, QTimer, QUrl
from PySide6.QtGui import (
    QColor, QFont, QFontMetrics, QPainter, QSyntaxHighlighter,
    QTextCharFormat, QDesktopServices, QIcon, QKeySequence, QAction
)
from PySide6.QtWidgets import (
    QApplication, QMainWindow, QWidget, QVBoxLayout, QHBoxLayout,
    QSplitter, QTabWidget, QPlainTextEdit, QTextEdit, QFrame, QLabel, QPushButton,
    QComboBox, QFileDialog, QDialog, QFormLayout, QSpinBox, QCheckBox,
    QDialogButtonBox, QMessageBox, QScrollArea, QSizePolicy
)
from PySide6.QtWebEngineWidgets import QWebEngineView

# -----------------------------------------------------------------------------
# DEFAULT ACCENT COLORS & THEMING
# -----------------------------------------------------------------------------
ACCENT_COLORS = {
    "Indigo": "#6366F1",
    "Emerald": "#10B981",
    "Purple": "#8B5CF6",
    "Rose": "#F43F5E",
    "Amber": "#F59E0B",
    "Cyan": "#06B6D4"
}

DEFAULT_ACCENT = "Indigo"
DEFAULT_ACCENT_HEX = ACCENT_COLORS[DEFAULT_ACCENT]

def generate_stylesheet(accent_hex=DEFAULT_ACCENT_HEX):
    return f"""
    QMainWindow {{
        background-color: #0F172A;
        color: #F8FAFC;
    }}
    QWidget {{
        font-family: 'Segoe UI', Inter, -apple-system, sans-serif;
        color: #E2E8F0;
    }}
    QSplitter::handle {{
        background-color: #1E293B;
        width: 3px;
        height: 3px;
    }}
    QSplitter::handle:hover {{
        background-color: {accent_hex};
    }}

    /* TOOLBAR & HEADER */
    #TopBar {{
        background-color: #1E293B;
        border-bottom: 1px solid #334155;
        padding: 6px 12px;
    }}
    #AppTitle {{
        font-weight: 700;
        font-size: 15px;
        color: #F8FAFC;
        letter-spacing: 0.5px;
    }}
    #Badge {{
        background-color: {accent_hex};
        color: #FFFFFF;
        font-size: 10px;
        font-weight: bold;
        padding: 2px 6px;
        border-radius: 4px;
    }}

    /* BUTTONS */
    QPushButton {{
        background-color: #334155;
        color: #F8FAFC;
        border: 1px solid #475569;
        border-radius: 6px;
        padding: 6px 14px;
        font-weight: 600;
        font-size: 12px;
    }}
    QPushButton:hover {{
        background-color: #475569;
        border-color: {accent_hex};
    }}
    QPushButton:pressed {{
        background-color: {accent_hex};
        color: #FFFFFF;
    }}
    QPushButton#PrimaryBtn {{
        background-color: {accent_hex};
        color: #FFFFFF;
        border: none;
    }}
    QPushButton#PrimaryBtn:hover {{
        background-color: {accent_hex}DD;
    }}

    /* COMBOBOX */
    QComboBox {{
        background-color: #334155;
        color: #F8FAFC;
        border: 1px solid #475569;
        border-radius: 6px;
        padding: 5px 10px;
        font-weight: 500;
        font-size: 12px;
    }}
    QComboBox:hover {{
        border-color: {accent_hex};
    }}
    QComboBox::drop-down {{
        subcontrol-origin: padding;
        subcontrol-position: top right;
        width: 20px;
        border-left-width: 0px;
    }}
    QComboBox QAbstractItemView {{
        background-color: #1E293B;
        color: #F8FAFC;
        selection-background-color: {accent_hex};
        border: 1px solid #334155;
        border-radius: 6px;
    }}

    /* TABS */
    QTabWidget::pane {{
        border: 1px solid #1E293B;
        background-color: #0F172A;
        border-radius: 0 0 8px 8px;
    }}
    QTabBar::tab {{
        background-color: #1E293B;
        color: #94A3B8;
        padding: 8px 18px;
        border-top-left-radius: 6px;
        border-top-right-radius: 6px;
        margin-right: 4px;
        font-weight: 600;
        font-size: 12px;
    }}
    QTabBar::tab:hover {{
        color: #F8FAFC;
        background-color: #334155;
    }}
    QTabBar::tab:selected {{
        background-color: #0F172A;
        color: {accent_hex};
        border-top: 2px solid {accent_hex};
    }}

    /* EDITOR */
    QPlainTextEdit {{
        background-color: #090D16;
        color: #E2E8F0;
        border: none;
        selection-background-color: #334155;
        selection-color: #F8FAFC;
    }}

    /* PREVIEW CONTAINER */
    #PreviewHeader {{
        background-color: #1E293B;
        border-bottom: 1px solid #334155;
        padding: 6px 12px;
    }}
    #PreviewDeviceFrame {{
        background-color: #0F172A;
        border-radius: 8px;
    }}

    /* FOOTER */
    #FooterBar {{
        background-color: #1E293B;
        border-top: 1px solid #334155;
        padding: 6px 16px;
    }}

    /* SCROLLBARS */
    QScrollBar:vertical {{
        background-color: #0F172A;
        width: 10px;
        margin: 0px;
    }}
    QScrollBar::handle:vertical {{
        background-color: #334155;
        min-height: 20px;
        border-radius: 5px;
    }}
    QScrollBar::handle:vertical:hover {{
        background-color: {accent_hex};
    }}
    QScrollBar::add-line:vertical, QScrollBar::sub-line:vertical {{
        height: 0px;
    }}
    QScrollBar:horizontal {{
        background-color: #0F172A;
        height: 10px;
        margin: 0px;
    }}
    QScrollBar::handle:horizontal {{
        background-color: #334155;
        min-width: 20px;
        border-radius: 5px;
    }}
    QScrollBar::handle:horizontal:hover {{
        background-color: {accent_hex};
    }}
    QScrollBar::add-line:horizontal, QScrollBar::sub-line:horizontal {{
        width: 0px;
    }}
    """

# -----------------------------------------------------------------------------
# SYNTAX HIGHLIGHTERS
# -----------------------------------------------------------------------------
class HtmlHighlighter(QSyntaxHighlighter):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.rules = []

        # Tag format (e.g., <div>, </span>)
        tag_fmt = QTextCharFormat()
        tag_fmt.setForeground(QColor("#38BDF8"))  # Light Cyan/Sky Blue
        tag_fmt.setFontWeight(QFont.Bold)
        self.rules.append((re.compile(r"</?[a-zA-Z0-9\-]+"), tag_fmt))
        self.rules.append((re.compile(r"/?>"), tag_fmt))

        # Attribute name format (e.g., class=, id=, src=)
        attr_fmt = QTextCharFormat()
        attr_fmt.setForeground(QColor("#F472B6"))  # Pink
        self.rules.append((re.compile(r"\b[a-zA-Z\-]+(?=\=)"), attr_fmt))

        # Attribute value strings (e.g., "container", 'main')
        string_fmt = QTextCharFormat()
        string_fmt.setForeground(QColor("#FBBF24"))  # Amber
        self.rules.append((re.compile(r'"[^"]*"'), string_fmt))
        self.rules.append((re.compile(r"'[^']*'"), string_fmt))

        # HTML Comments (e.g., <!-- comment -->)
        comment_fmt = QTextCharFormat()
        comment_fmt.setForeground(QColor("#64748B"))  # Slate Gray
        comment_fmt.setFontItalic(True)
        self.rules.append((re.compile(r"<!--[^\n]*?-->"), comment_fmt))

        # Doctype
        doctype_fmt = QTextCharFormat()
        doctype_fmt.setForeground(QColor("#A78BFA"))  # Purple
        doctype_fmt.setFontWeight(QFont.Bold)
        self.rules.append((re.compile(r"<!DOCTYPE[^>]*>", re.IGNORECASE), doctype_fmt))

    def highlightBlock(self, text):
        for pattern, fmt in self.rules:
            for match in pattern.finditer(text):
                start, end = match.span()
                self.setFormat(start, end - start, fmt)


class CssHighlighter(QSyntaxHighlighter):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.rules = []

        # CSS Selectors / Tags / Classes / IDs
        selector_fmt = QTextCharFormat()
        selector_fmt.setForeground(QColor("#F472B6"))  # Pink
        selector_fmt.setFontWeight(QFont.Bold)
        self.rules.append((re.compile(r"[\.\#]?[a-zA-Z0-9_\-\:]+(?=\s*\{|\s*,)"), selector_fmt))

        # CSS Properties (e.g., color:, margin:)
        prop_fmt = QTextCharFormat()
        prop_fmt.setForeground(QColor("#38BDF8"))  # Light Blue
        self.rules.append((re.compile(r"\b[a-zA-Z\-]+(?=\s*:)"), prop_fmt))

        # Values & Units (e.g., 12px, #fff, 100%)
        value_fmt = QTextCharFormat()
        value_fmt.setForeground(QColor("#FBBF24"))  # Amber
        self.rules.append((re.compile(r":\s*([^;\}]+)"), value_fmt))

        # Comments (/* ... */)
        comment_fmt = QTextCharFormat()
        comment_fmt.setForeground(QColor("#64748B"))  # Slate Gray
        comment_fmt.setFontItalic(True)
        self.rules.append((re.compile(r"/\*.*?\*/"), comment_fmt))

    def highlightBlock(self, text):
        for pattern, fmt in self.rules:
            for match in pattern.finditer(text):
                start, end = match.span()
                self.setFormat(start, end - start, fmt)


class JsHighlighter(QSyntaxHighlighter):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.rules = []

        # Keywords
        keywords = [
            "function", "var", "let", "const", "return", "if", "else",
            "for", "while", "do", "switch", "case", "break", "continue",
            "new", "this", "class", "extends", "export", "import", "default",
            "null", "undefined", "true", "false", "async", "await", "try", "catch"
        ]
        kw_fmt = QTextCharFormat()
        kw_fmt.setForeground(QColor("#A78BFA"))  # Purple
        kw_fmt.setFontWeight(QFont.Bold)
        kw_pattern = r"\b(" + "|".join(keywords) + r")\b"
        self.rules.append((re.compile(kw_pattern), kw_fmt))

        # Built-in Objects / Globals
        builtins = ["console", "document", "window", "Math", "Array", "Object", "String", "Number", "Promise"]
        bi_fmt = QTextCharFormat()
        bi_fmt.setForeground(QColor("#38BDF8"))  # Cyan
        bi_pattern = r"\b(" + "|".join(builtins) + r")\b"
        self.rules.append((re.compile(bi_pattern), bi_fmt))

        # Functions (e.g., log(), addEventListener())
        fn_fmt = QTextCharFormat()
        fn_fmt.setForeground(QColor("#60A5FA"))  # Soft Blue
        self.rules.append((re.compile(r"\b[a-zA-Z0-9_]+(?=\()"), fn_fmt))

        # Numbers
        num_fmt = QTextCharFormat()
        num_fmt.setForeground(QColor("#F59E0B"))  # Orange/Amber
        self.rules.append((re.compile(r"\b\d+(\.\d+)?\b"), num_fmt))

        # Strings
        str_fmt = QTextCharFormat()
        str_fmt.setForeground(QColor("#34D399"))  # Emerald Green
        self.rules.append((re.compile(r'"[^"]*"'), str_fmt))
        self.rules.append((re.compile(r"'[^']*'"), str_fmt))
        self.rules.append((re.compile(r"`[^`]*`"), str_fmt))

        # Comments
        comment_fmt = QTextCharFormat()
        comment_fmt.setForeground(QColor("#64748B"))  # Slate Gray
        comment_fmt.setFontItalic(True)
        self.rules.append((re.compile(r"//[^\n]*"), comment_fmt))
        self.rules.append((re.compile(r"/\*.*?\*/"), comment_fmt))

    def highlightBlock(self, text):
        for pattern, fmt in self.rules:
            for match in pattern.finditer(text):
                start, end = match.span()
                self.setFormat(start, end - start, fmt)


# -----------------------------------------------------------------------------
# CODE EDITOR WITH LINE NUMBERS
# -----------------------------------------------------------------------------
class LineNumberArea(QWidget):
    def __init__(self, editor):
        super().__init__(editor)
        self.codeEditor = editor

    def sizeHint(self):
        return QSize(self.codeEditor.lineNumberAreaWidth(), 0)

    def paintEvent(self, event):
        self.codeEditor.lineNumberAreaPaintEvent(event)


class CodeEditor(QPlainTextEdit):
    def __init__(self, language="html", tab_size=4, font_size=13, parent=None):
        super().__init__(parent)
        self.language = language
        self.tab_size = tab_size

        # Monospace Font
        font = QFont("Consolas", font_size)
        font.setStyleHint(QFont.Monospace)
        font.setFixedPitch(True)
        self.setFont(font)

        # Line Number Area Setup
        self.lineNumberArea = LineNumberArea(self)
        self.blockCountChanged.connect(self.updateLineNumberAreaWidth)
        self.updateRequest.connect(self.updateLineNumberArea)
        self.cursorPositionChanged.connect(self.highlightCurrentLine)
        self.updateLineNumberAreaWidth(0)

        # Tab Indentation
        self.setTabStopDistance(self.fontMetrics().horizontalAdvance(' ') * self.tab_size)

        # Attach Highlighter
        if language == "html":
            self.highlighter = HtmlHighlighter(self.document())
        elif language == "css":
            self.highlighter = CssHighlighter(self.document())
        elif language == "js":
            self.highlighter = JsHighlighter(self.document())

    def update_settings(self, font_size, tab_size):
        self.tab_size = tab_size
        font = self.font()
        font.setPointSize(font_size)
        self.setFont(font)
        self.setTabStopDistance(self.fontMetrics().horizontalAdvance(' ') * self.tab_size)
        self.updateLineNumberAreaWidth(0)

    def lineNumberAreaWidth(self):
        digits = 1
        max_val = max(1, self.blockCount())
        while max_val >= 10:
            max_val //= 10
            digits += 1
        space = 14 + self.fontMetrics().horizontalAdvance('9') * digits
        return space

    def updateLineNumberAreaWidth(self, _):
        self.setViewportMargins(self.lineNumberAreaWidth(), 0, 0, 0)

    def updateLineNumberArea(self, rect, dy):
        if dy:
            self.lineNumberArea.scroll(0, dy)
        else:
            self.lineNumberArea.update(0, rect.y(), self.lineNumberArea.width(), rect.height())

        if rect.contains(self.viewport().rect()):
            self.updateLineNumberAreaWidth(0)

    def resizeEvent(self, event):
        super().resizeEvent(event)
        cr = self.contentsRect()
        self.lineNumberArea.setGeometry(QRect(cr.left(), cr.top(), self.lineNumberAreaWidth(), cr.height()))

    def lineNumberAreaPaintEvent(self, event):
        painter = QPainter(self.lineNumberArea)
        painter.fillRect(event.rect(), QColor("#0F172A"))

        block = self.firstVisibleBlock()
        blockNumber = block.blockNumber()
        top = int(self.blockBoundingGeometry(block).translated(self.contentOffset()).top())
        bottom = top + int(self.blockBoundingRect(block).height())

        painter.setFont(self.font())

        while block.isValid() and top <= event.rect().bottom():
            if block.isVisible() and bottom >= event.rect().top():
                number = str(blockNumber + 1)
                if blockNumber == self.textCursor().blockNumber():
                    painter.setPen(QColor("#F8FAFC"))
                else:
                    painter.setPen(QColor("#475569"))
                painter.drawText(0, top, self.lineNumberArea.width() - 8, self.fontMetrics().height(),
                                 Qt.AlignRight, number)

            block = block.next()
            top = bottom
            bottom = top + int(self.blockBoundingRect(block).height())
            blockNumber += 1

    def highlightCurrentLine(self):
        extraSelections = []
        if not self.isReadOnly():
            selection = QTextEdit.ExtraSelection()
            lineColor = QColor("#1E293B")
            selection.format.setBackground(lineColor)
            selection.format.setProperty(QTextCharFormat.FullWidthSelection, True)
            selection.cursor = self.textCursor()
            selection.cursor.clearSelection()
            extraSelections.append(selection)
        self.setExtraSelections(extraSelections)

    def keyPressEvent(self, event):
        # Intercept Tab key for space indentation
        if event.key() == Qt.Key_Tab:
            self.insertPlainText(" " * self.tab_size)
        else:
            super().keyPressEvent(event)


# -----------------------------------------------------------------------------
# SETTINGS DIALOG
# -----------------------------------------------------------------------------
class SettingsDialog(QDialog):
    def __init__(self, font_size=13, tab_size=4, auto_run=True, parent=None):
        super().__init__(parent)
        self.setWindowTitle("Editor Settings")
        self.setMinimumWidth(320)
        self.setStyleSheet("""
            QDialog {
                background-color: #1E293B;
                color: #F8FAFC;
            }
            QLabel {
                color: #E2E8F0;
                font-weight: 500;
            }
            QSpinBox {
                background-color: #334155;
                color: #F8FAFC;
                border: 1px solid #475569;
                border-radius: 4px;
                padding: 4px;
            }
            QCheckBox {
                color: #E2E8F0;
            }
        """)

        layout = QVBoxLayout(self)
        form = QFormLayout()

        self.fontSizeBox = QSpinBox()
        self.fontSizeBox.setRange(8, 32)
        self.fontSizeBox.setValue(font_size)
        form.addRow("Font Size (pt):", self.fontSizeBox)

        self.tabSizeBox = QSpinBox()
        self.tabSizeBox.setRange(2, 8)
        self.tabSizeBox.setValue(tab_size)
        form.addRow("Tab Size (spaces):", self.tabSizeBox)

        self.autoRunCheck = QCheckBox("Auto-Update Live Preview")
        self.autoRunCheck.setChecked(auto_run)
        form.addRow("", self.autoRunCheck)

        layout.addLayout(form)

        buttons = QDialogButtonBox(QDialogButtonBox.Ok | QDialogButtonBox.Cancel)
        buttons.accepted.connect(self.accept)
        buttons.rejected.connect(self.reject)
        layout.addWidget(buttons)

    def get_settings(self):
        return {
            "font_size": self.fontSizeBox.value(),
            "tab_size": self.tabSizeBox.value(),
            "auto_run": self.autoRunCheck.isChecked()
        }


# -----------------------------------------------------------------------------
# MAIN APPLICATION WINDOW
# -----------------------------------------------------------------------------
class CodeEditorApp(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("NV Web Studio Pro - HTML/CSS/JS Live Code Editor")
        self.resize(1280, 800)

        # Default Settings
        self.font_size = 13
        self.tab_size = 4
        self.auto_run = True
        self.current_accent = DEFAULT_ACCENT
        self.current_folder = None

        # Timer for Live Preview Debounce
        self.preview_timer = QTimer()
        self.preview_timer.setSingleShot(True)
        self.preview_timer.timeout.connect(self.update_live_preview)

        # Apply Global Theme
        self.apply_accent_theme(self.current_accent)

        # Setup Main UI Layout
        self.init_ui()

        # Load Sample Demo Code
        self.load_sample_code()

        # Initial Render
        self.update_live_preview()

    def apply_accent_theme(self, accent_name):
        self.current_accent = accent_name
        accent_hex = ACCENT_COLORS.get(accent_name, DEFAULT_ACCENT_HEX)
        self.setStyleSheet(generate_stylesheet(accent_hex))

    def init_ui(self):
        central_widget = QWidget()
        self.setCentralWidget(central_widget)
        main_layout = QVBoxLayout(central_widget)
        main_layout.setContentsMargins(0, 0, 0, 0)
        main_layout.setSpacing(0)

        # --- 1. TOP CONTROL BAR ---
        top_bar = QFrame()
        top_bar.setObjectName("TopBar")
        top_layout = QHBoxLayout(top_bar)
        top_layout.setContentsMargins(12, 8, 12, 8)

        title_label = QLabel("⚡ Live Code Editor")
        title_label.setObjectName("AppTitle")

        badge_label = QLabel("PRO")
        badge_label.setObjectName("Badge")

        top_layout.addWidget(title_label)
        top_layout.addWidget(badge_label)
        top_layout.addSpacing(20)

        # Folder Select Button
        self.btn_folder = QPushButton("📁 Open Folder")
        self.btn_folder.setToolTip("Select local project folder")
        self.btn_folder.clicked.connect(self.open_folder_dialog)
        top_layout.addWidget(self.btn_folder)

        # Save File Button
        self.btn_save = QPushButton("💾 Save File")
        self.btn_save.setToolTip("Save HTML/CSS/JS files locally")
        self.btn_save.clicked.connect(self.save_file_dialog)
        top_layout.addWidget(self.btn_save)

        # Run / Refresh Preview Button
        self.btn_run = QPushButton("▶ Run Preview")
        self.btn_run.setObjectName("PrimaryBtn")
        self.btn_run.clicked.connect(self.update_live_preview)
        top_layout.addWidget(self.btn_run)

        top_layout.addStretch()

        # Color Changing Dropdown
        accent_label = QLabel("Theme Accent:")
        accent_label.setStyleSheet("color: #94A3B8; font-weight: 500; font-size: 12px;")
        top_layout.addWidget(accent_label)

        self.accent_combo = QComboBox()
        for name in ACCENT_COLORS.keys():
            self.accent_combo.addItem(name)
        self.accent_combo.setCurrentText(self.current_accent)
        self.accent_combo.currentTextChanged.connect(self.on_accent_changed)
        top_layout.addWidget(self.accent_combo)

        top_layout.addSpacing(10)

        # Settings Button
        self.btn_settings = QPushButton("⚙ Settings")
        self.btn_settings.clicked.connect(self.open_settings_dialog)
        top_layout.addWidget(self.btn_settings)

        main_layout.addWidget(top_bar)

        # --- 2. MAIN SPLITTER (LEFT: CODE EDITOR, RIGHT: LIVE PREVIEW) ---
        self.splitter = QSplitter(Qt.Horizontal)

        # --- LEFT PANEL: CODE EDITOR TABS ---
        left_widget = QWidget()
        left_layout = QVBoxLayout(left_widget)
        left_layout.setContentsMargins(8, 8, 4, 8)

        self.tab_widget = QTabWidget()

        # HTML Tab
        self.html_editor = CodeEditor(language="html", tab_size=self.tab_size, font_size=self.font_size)
        self.html_editor.textChanged.connect(self.on_code_changed)
        self.tab_widget.addTab(self.html_editor, "HTML")

        # CSS Tab
        self.css_editor = CodeEditor(language="css", tab_size=self.tab_size, font_size=self.font_size)
        self.css_editor.textChanged.connect(self.on_code_changed)
        self.tab_widget.addTab(self.css_editor, "CSS")

        # JS Tab
        self.js_editor = CodeEditor(language="js", tab_size=self.tab_size, font_size=self.font_size)
        self.js_editor.textChanged.connect(self.on_code_changed)
        self.tab_widget.addTab(self.js_editor, "JavaScript")

        left_layout.addWidget(self.tab_widget)
        self.splitter.addWidget(left_widget)

        # --- RIGHT PANEL: LIVE DEVICE PREVIEW ---
        right_widget = QWidget()
        right_layout = QVBoxLayout(right_widget)
        right_layout.setContentsMargins(4, 8, 8, 8)

        # Preview Header Controls
        preview_header = QFrame()
        preview_header.setObjectName("PreviewHeader")
        p_head_layout = QHBoxLayout(preview_header)
        p_head_layout.setContentsMargins(12, 6, 12, 6)

        p_head_title = QLabel("Device Preview")
        p_head_title.setStyleSheet("font-weight: 600; font-size: 13px; color: #F8FAFC;")
        p_head_layout.addWidget(p_head_title)

        p_head_layout.addStretch()

        # Exact 3 Device Preset Buttons
        device_label = QLabel("Device:")
        device_label.setStyleSheet("color: #94A3B8; font-size: 12px; margin-right: 4px;")
        p_head_layout.addWidget(device_label)

        self.btn_mobile = QPushButton("📱 Mobile")
        self.btn_mobile.clicked.connect(lambda: self.set_device_mode("mobile"))
        p_head_layout.addWidget(self.btn_mobile)

        self.btn_laptop = QPushButton("💻 Laptop/Desktop")
        self.btn_laptop.clicked.connect(lambda: self.set_device_mode("laptop"))
        p_head_layout.addWidget(self.btn_laptop)

        self.btn_tablet = QPushButton("📱 iPad/Tablet")
        self.btn_tablet.clicked.connect(lambda: self.set_device_mode("tablet"))
        p_head_layout.addWidget(self.btn_tablet)

        right_layout.addWidget(preview_header)

        # Scrollable Preview Area for device sizing
        self.preview_scroll = QScrollArea()
        self.preview_scroll.setWidgetResizable(True)
        self.preview_scroll.setStyleSheet("QScrollArea { border: none; background-color: #0B1120; }")

        self.preview_container = QWidget()
        self.preview_container_layout = QVBoxLayout(self.preview_container)
        self.preview_container_layout.setAlignment(Qt.AlignCenter)

        # Device Frame Outer Box
        self.device_frame = QFrame()
        self.device_frame.setObjectName("PreviewDeviceFrame")
        self.device_frame_layout = QVBoxLayout(self.device_frame)
        self.device_frame_layout.setContentsMargins(0, 0, 0, 0)

        # WebEngine View
        self.web_view = QWebEngineView()
        self.device_frame_layout.addWidget(self.web_view)

        self.preview_container_layout.addWidget(self.device_frame)
        self.preview_scroll.setWidget(self.preview_container)

        right_layout.addWidget(self.preview_scroll)
        self.splitter.addWidget(right_widget)

        # Set Initial Splitter Proportions (50% / 50%)
        self.splitter.setSizes([600, 600])
        main_layout.addWidget(self.splitter)

        # Set Default Device Mode
        self.set_device_mode("laptop")

        # --- 3. BOTTOM FOOTER ---
        footer_bar = QFrame()
        footer_bar.setObjectName("FooterBar")
        footer_layout = QHBoxLayout(footer_bar)
        footer_layout.setContentsMargins(16, 6, 16, 6)

        footer_info = QLabel("NV Web Studio Pro • Python PySide6 Desktop App")
        footer_info.setStyleSheet("color: #64748B; font-size: 11px; font-weight: 500;")
        footer_layout.addWidget(footer_info)

        footer_layout.addStretch()

        social_links = [
            ("GitHub", "https://github.com/aadisoni8044-code"),
            ("LinkedIn", "https://www.linkedin.com/in/aadi-soni-a9ba35394/"),
            ("Instagram", "https://www.instagram.com/aadisoni8044/"),
            ("X", "https://x.com/soni_aadi70883"),
        ]

        for idx, (name, url) in enumerate(social_links):
            link_lbl = QLabel(f'<a href="{url}" style="color:#94A3B8; text-decoration:none; font-weight:600;">{name}</a>')
            link_lbl.setOpenExternalLinks(True)
            link_lbl.setStyleSheet("font-size: 12px;")
            footer_layout.addWidget(link_lbl)

            if idx < len(social_links) - 1:
                sep = QLabel("•")
                sep.setStyleSheet("color: #475569; font-size: 12px; margin: 0 4px;")
                footer_layout.addWidget(sep)

        main_layout.addWidget(footer_bar)

    # -------------------------------------------------------------------------
    # DEVICE PREVIEW MODES
    # -------------------------------------------------------------------------
    def set_device_mode(self, mode):
        # Preset Dimensions
        if mode == "mobile":
            # Mobile Viewport: 375 x 667
            self.device_frame.setFixedSize(375, 667)
            self.device_frame.setStyleSheet("""
                #PreviewDeviceFrame {
                    background-color: #000000;
                    border: 10px solid #1E293B;
                    border-radius: 24px;
                }
            """)
        elif mode == "tablet":
            # iPad / Tablet Viewport: 768 x 1024
            self.device_frame.setFixedSize(768, 960)
            self.device_frame.setStyleSheet("""
                #PreviewDeviceFrame {
                    background-color: #000000;
                    border: 12px solid #1E293B;
                    border-radius: 18px;
                }
            """)
        else: # laptop / desktop
            self.device_frame.setMinimumSize(0, 0)
            self.device_frame.setMaximumSize(16777215, 16777215)
            self.device_frame.setSizePolicy(QSizePolicy.Expanding, QSizePolicy.Expanding)
            self.device_frame.setStyleSheet("""
                #PreviewDeviceFrame {
                    background-color: #0F172A;
                    border: 1px solid #334155;
                    border-radius: 8px;
                }
            """)

    # -------------------------------------------------------------------------
    # CODE EDITING & LIVE PREVIEW UPDATING
    # -------------------------------------------------------------------------
    def on_code_changed(self):
        if hasattr(self, 'preview_timer') and self.auto_run:
            self.preview_timer.start(300)

    def generate_full_html(self):
        html_code = self.html_editor.toPlainText()
        css_code = self.css_editor.toPlainText()
        js_code = self.js_editor.toPlainText()

        return f"""<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>
{css_code}
</style>
</head>
<body>
{html_code}
<script>
{js_code}
</script>
</body>
</html>"""

    def update_live_preview(self):
        full_content = self.generate_full_html()
        self.web_view.setHtml(full_content)

    def load_sample_code(self):
        sample_html = """<div class="card">
  <h1>🚀 NV Web Studio</h1>
  <p>Welcome to your real-time HTML, CSS & JavaScript code editor!</p>
  <button id="counterBtn">Clicks: <span id="count">0</span></button>
</div>"""

        sample_css = """body {
  margin: 0;
  padding: 0;
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background: linear-gradient(135deg, #0f172a 0%, #1e1b4b 100%);
  font-family: 'Segoe UI', system-ui, sans-serif;
  color: #f8fafc;
}

.card {
  background: rgba(30, 41, 59, 0.8);
  backdrop-filter: blur(12px);
  border: 1px solid rgba(255, 255, 255, 0.1);
  padding: 32px;
  border-radius: 16px;
  text-align: center;
  box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.5);
  max-width: 400px;
}

h1 {
  font-size: 24px;
  margin-bottom: 12px;
  color: #38bdf8;
}

p {
  font-size: 14px;
  color: #94a3b8;
  line-height: 1.5;
  margin-bottom: 24px;
}

button {
  background: #6366f1;
  color: #ffffff;
  border: none;
  padding: 10px 20px;
  font-size: 14px;
  font-weight: 600;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s ease;
}

button:hover {
  background: #4f46e5;
  transform: translateY(-2px);
}"""

        sample_js = """let count = 0;
const btn = document.getElementById('counterBtn');
const countSpan = document.getElementById('count');

btn.addEventListener('click', () => {
  count++;
  countSpan.textContent = count;
});"""

        self.html_editor.setPlainText(sample_html)
        self.css_editor.setPlainText(sample_css)
        self.js_editor.setPlainText(sample_js)

    # -------------------------------------------------------------------------
    # FEATURE 1: SETTINGS
    # -------------------------------------------------------------------------
    def open_settings_dialog(self):
        dialog = SettingsDialog(self.font_size, self.tab_size, self.auto_run, self)
        if dialog.exec():
            res = dialog.get_settings()
            self.font_size = res["font_size"]
            self.tab_size = res["tab_size"]
            self.auto_run = res["auto_run"]

            self.html_editor.update_settings(self.font_size, self.tab_size)
            self.css_editor.update_settings(self.font_size, self.tab_size)
            self.js_editor.update_settings(self.font_size, self.tab_size)

            if self.auto_run:
                self.update_live_preview()

    # -------------------------------------------------------------------------
    # FEATURE 2: COLOR CHANGING
    # -------------------------------------------------------------------------
    def on_accent_changed(self, accent_name):
        self.apply_accent_theme(accent_name)

    # -------------------------------------------------------------------------
    # FEATURE 3: FOLDER SELECT
    # -------------------------------------------------------------------------
    def open_folder_dialog(self):
        folder = QFileDialog.getExistingDirectory(self, "Select Project Folder")
        if folder:
            self.current_folder = folder
            html_path = os.path.join(folder, "index.html")
            css_path = os.path.join(folder, "style.css")
            js_path = os.path.join(folder, "script.js")

            if os.path.exists(html_path):
                with open(html_path, "r", encoding="utf-8") as f:
                    self.html_editor.setPlainText(f.read())
            if os.path.exists(css_path):
                with open(css_path, "r", encoding="utf-8") as f:
                    self.css_editor.setPlainText(f.read())
            if os.path.exists(js_path):
                with open(js_path, "r", encoding="utf-8") as f:
                    self.js_editor.setPlainText(f.read())

            QMessageBox.information(
                self, "Folder Loaded",
                f"Project folder selected:\n{folder}\n\nFiles loaded if available (index.html, style.css, script.js)."
            )

    # -------------------------------------------------------------------------
    # FEATURE 4: SAVE FILE
    # -------------------------------------------------------------------------
    def save_file_dialog(self):
        current_tab_idx = self.tab_widget.currentIndex()
        if current_tab_idx == 0:
            filename, _ = QFileDialog.getSaveFileName(self, "Save HTML File", self.current_folder or "", "HTML Files (*.html)")
            if filename:
                with open(filename, "w", encoding="utf-8") as f:
                    f.write(self.html_editor.toPlainText())
        elif current_tab_idx == 1:
            filename, _ = QFileDialog.getSaveFileName(self, "Save CSS File", self.current_folder or "", "CSS Files (*.css)")
            if filename:
                with open(filename, "w", encoding="utf-8") as f:
                    f.write(self.css_editor.toPlainText())
        elif current_tab_idx == 2:
            filename, _ = QFileDialog.getSaveFileName(self, "Save JavaScript File", self.current_folder or "", "JavaScript Files (*.js)")
            if filename:
                with open(filename, "w", encoding="utf-8") as f:
                    f.write(self.js_editor.toPlainText())


# -----------------------------------------------------------------------------
# MAIN APPLICATION ENTRY POINT
# -----------------------------------------------------------------------------
def main():
    app = QApplication(sys.argv)
    window = CodeEditorApp()
    window.show()
    sys.exit(app.exec())

if __name__ == "__main__":
    main()
