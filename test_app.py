import os
import pytest
from PySide6.QtWidgets import QApplication
from app import CodeEditorApp, generate_stylesheet, ACCENT_COLORS, HtmlHighlighter, CssHighlighter, JsHighlighter

@pytest.fixture(scope="session")
def qapp():
    app = QApplication.instance()
    if app is None:
        app = QApplication([])
    return app

def test_app_initialization(qapp):
    window = CodeEditorApp()
    assert window is not None
    assert window.html_editor.toPlainText() != ""
    assert window.css_editor.toPlainText() != ""
    assert window.js_editor.toPlainText() != ""

def test_generate_full_html(qapp):
    window = CodeEditorApp()
    window.html_editor.setPlainText("<h1>Hello Test</h1>")
    window.css_editor.setPlainText("h1 { color: red; }")
    window.js_editor.setPlainText("console.log('test');")

    full_html = window.generate_full_html()
    assert "<h1>Hello Test</h1>" in full_html
    assert "h1 { color: red; }" in full_html
    assert "console.log('test');" in full_html

def test_device_mode_switching(qapp):
    window = CodeEditorApp()

    # Mobile
    window.set_device_mode("mobile")
    assert window.device_frame.width() == 375
    assert window.device_frame.height() == 667

    # Tablet
    window.set_device_mode("tablet")
    assert window.device_frame.width() == 768
    assert window.device_frame.height() == 960

    # Laptop
    window.set_device_mode("laptop")
    assert window.device_frame.maximumWidth() == 16777215

def test_accent_color_changing(qapp):
    window = CodeEditorApp()
    initial_accent = window.current_accent

    window.on_accent_changed("Emerald")
    assert window.current_accent == "Emerald"
    assert ACCENT_COLORS["Emerald"] in window.styleSheet()

def test_syntax_highlighters(qapp):
    window = CodeEditorApp()

    # HTML highlighter
    html_hl = HtmlHighlighter(window.html_editor.document())
    assert len(html_hl.rules) > 0

    # CSS highlighter
    css_hl = CssHighlighter(window.css_editor.document())
    assert len(css_hl.rules) > 0

    # JS highlighter
    js_hl = JsHighlighter(window.js_editor.document())
    assert len(js_hl.rules) > 0

def test_folder_loading(qapp, tmp_path):
    window = CodeEditorApp()

    # Create temp files
    html_file = tmp_path / "index.html"
    css_file = tmp_path / "style.css"
    js_file = tmp_path / "script.js"

    html_file.write_text("<div>Test Folder HTML</div>", encoding="utf-8")
    css_file.write_text("body { background: black; }", encoding="utf-8")
    js_file.write_text("alert('hi');", encoding="utf-8")

    window.current_folder = str(tmp_path)

    # Simulate loading folder files
    with open(html_file, "r", encoding="utf-8") as f:
        window.html_editor.setPlainText(f.read())
    with open(css_file, "r", encoding="utf-8") as f:
        window.css_editor.setPlainText(f.read())
    with open(js_file, "r", encoding="utf-8") as f:
        window.js_editor.setPlainText(f.read())

    assert window.html_editor.toPlainText() == "<div>Test Folder HTML</div>"
    assert window.css_editor.toPlainText() == "body { background: black; }"
    assert window.js_editor.toPlainText() == "alert('hi');"
