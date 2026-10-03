import os
import pytest
from vs_code_ide import VSCodeIDE, CodeEditor

def test_ide_initialization(tmp_path):
    # Create test .jps and .jap files
    f1 = tmp_path / "test1.jps"
    f1.write_text("import.box\na = body_2D.box()\n", encoding="utf-8")
    f2 = tmp_path / "test2.jap"
    f2.write_text("import.game\n", encoding="utf-8")

    app = VSCodeIDE(workspace_dir=str(tmp_path))
    assert app.file_listbox.size() == 2

    # Open tab
    app.open_file_in_tab(str(f1))
    editor = app.get_active_editor()
    assert editor is not None
    assert editor.filepath == str(f1)
    assert "body_2D.box()" in editor.text.get("1.0", "end-1c")

    app.destroy()
