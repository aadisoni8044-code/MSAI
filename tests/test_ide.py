import os
import pytest
from ide import JpsIDE

def test_ide_creation_and_file_operations(tmp_path):
    os.environ["SDL_VIDEODRIVER"] = "dummy"
    app = JpsIDE()

    # Test initial tab
    assert app.get_current_editor() is not None

    # Write test file
    test_file = tmp_path / "test_sample.jps"
    test_content = "import.box\na = body_2D.box()\nprint(a)"
    test_file.write_text(test_content)

    # Open file in IDE
    app.open_file(str(test_file))
    current_text = app.get_current_editor().get_text()
    assert "import.box" in current_text

    # Run code from IDE
    app.run_code()
    console_out = app.console_text.get("1.0", "end")
    assert "[Compiler] Imported module 'box'" in console_out
    assert "[IDE] Execution finished successfully." in console_out

    app.destroy()
