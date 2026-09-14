import os
import json
import shutil
from pathlib import Path
from nvstudio.config import CONFIG_DIR, WORKSPACE_FILE

DEFAULT_HTML = """<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NV Studio Project</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="container">
        <h1>Welcome to NV Studio</h1>
        <p>Edit HTML, CSS, and JavaScript, then click <strong>Run ▶</strong> to preview!</p>
        <button id="btn">Click Me</button>
        <p id="output"></p>
    </div>
    <script src="script.js"></script>
</body>
</html>
"""

DEFAULT_CSS = """/* NV Studio Styling */
body {
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    background: linear-gradient(135deg, #1e1b4b 0%, #311b92 100%);
    color: #ffffff;
    display: flex;
    justify-content: center;
    align-items: center;
    min-height: 100vh;
    margin: 0;
}

.container {
    background: rgba(255, 255, 255, 0.08);
    backdrop-filter: blur(10px);
    border: 1px solid rgba(255, 255, 255, 0.18);
    border-radius: 16px;
    padding: 32px;
    text-align: center;
    box-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.37);
    max-width: 480px;
}

h1 {
    margin-top: 0;
    color: #818cf8;
}

button {
    background: #6366f1;
    color: #ffffff;
    border: none;
    padding: 10px 20px;
    border-radius: 8px;
    font-size: 15px;
    font-weight: bold;
    cursor: pointer;
    transition: background 0.2s ease;
}

button:hover {
    background: #4f46e5;
}
"""

DEFAULT_JS = """// NV Studio JavaScript
document.addEventListener('DOMContentLoaded', () => {
    const btn = document.getElementById('btn');
    const output = document.getElementById('output');
    let count = 0;

    if (btn && output) {
        btn.addEventListener('click', () => {
            count++;
            output.textContent = `Button clicked ${count} time${count === 1 ? '' : 's'}!`;
        });
    }
});
"""

DEFAULT_PROJECT_DIR = CONFIG_DIR / "default_project"


class WorkspaceManager:
    """Manages NV Studio project state, auto-saves, and restores open files."""

    def __init__(self, workspace_path=WORKSPACE_FILE):
        self.workspace_path = Path(workspace_path)
        self.state = {
            "project_dir": str(DEFAULT_PROJECT_DIR),
            "open_files": [],
            "active_file": "",
            "unsaved_changes": {}
        }

    def ensure_default_project(self):
        project_dir = Path(self.state.get("project_dir", DEFAULT_PROJECT_DIR))
        if not project_dir.exists():
            project_dir.mkdir(parents=True, exist_ok=True)

        html_file = project_dir / "index.html"
        css_file = project_dir / "style.css"
        js_file = project_dir / "script.js"

        if not html_file.exists():
            html_file.write_text(DEFAULT_HTML, encoding="utf-8")
        if not css_file.exists():
            css_file.write_text(DEFAULT_CSS, encoding="utf-8")
        if not js_file.exists():
            js_file.write_text(DEFAULT_JS, encoding="utf-8")

        if not self.state.get("open_files"):
            self.state["open_files"] = [str(html_file), str(css_file), str(js_file)]
            self.state["active_file"] = str(html_file)

    def load(self):
        if self.workspace_path.exists():
            try:
                with open(self.workspace_path, "r", encoding="utf-8") as f:
                    loaded = json.load(f)
                    self.state.update(loaded)
            except Exception as e:
                print(f"[WorkspaceManager] Error loading workspace: {e}")

        self.ensure_default_project()

    def save(self):
        try:
            self.workspace_path.parent.mkdir(parents=True, exist_ok=True)
            with open(self.workspace_path, "w", encoding="utf-8") as f:
                json.dump(self.state, f, indent=2)
        except Exception as e:
            print(f"[WorkspaceManager] Error saving workspace: {e}")

    def get_project_dir(self):
        return Path(self.state.get("project_dir", DEFAULT_PROJECT_DIR))

    def set_project_dir(self, path):
        self.state["project_dir"] = str(path)
        self.save()

    def get_open_files(self):
        return [f for f in self.state.get("open_files", []) if os.path.exists(f)]

    def set_open_files(self, file_paths, active_file=""):
        self.state["open_files"] = [str(p) for p in file_paths]
        if active_file:
            self.state["active_file"] = str(active_file)
        self.save()
