"""
NV Studio Workspace Manager
Handles project files creation, opening, reading, saving, renaming, deleting, and default project boilerplate generation.
"""

import os
import shutil
from pathlib import Path
from typing import List, Optional, Tuple


DEFAULT_INDEX_HTML = """<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My NV Studio Website</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="container">
        <header>
            <h1 id="title">Welcome to NV Studio</h1>
            <p class="subtitle">A modern, professional desktop code editor for web developers.</p>
        </header>

        <main>
            <div class="card">
                <h2>Interactive Demo</h2>
                <p>Edit HTML, CSS, and JavaScript, then click <strong>▶ Run</strong> to preview instantly.</p>
                <button id="actionBtn" onclick="handleButtonClick()">Click Me!</button>
            </div>

            <div class="features">
                <div class="feature-item">⚡ Fast Execution</div>
                <div class="feature-item">📱 Responsive Preview</div>
                <div class="feature-item">💾 Auto-Save</div>
            </div>
        </main>
    </div>

    <script src="script.js"></script>
</body>
</html>
"""

DEFAULT_STYLE_CSS = """/* NV Studio Default Stylesheet */
* {
    box-sizing: border-box;
    margin: 0;
    padding: 0;
}

body {
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
    background: linear-gradient(135deg, #0f172a 0%, #1e1b4b 100%);
    color: #f8fafc;
    min-height: 100vh;
    display: flex;
    justify-content: center;
    align-items: center;
    padding: 20px;
}

.container {
    max-width: 600px;
    width: 100%;
    background: rgba(30, 41, 59, 0.8);
    backdrop-filter: blur(12px);
    border: 1px solid rgba(255, 255, 255, 0.1);
    border-radius: 16px;
    padding: 32px;
    box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.5);
    text-align: center;
}

header h1 {
    font-size: 2.2rem;
    color: #6366f1;
    margin-bottom: 8px;
}

.subtitle {
    color: #94a3b8;
    font-size: 0.95rem;
    margin-bottom: 24px;
}

.card {
    background: #0f172a;
    padding: 20px;
    border-radius: 12px;
    border: 1px solid #334155;
    margin-bottom: 24px;
}

.card h2 {
    font-size: 1.25rem;
    margin-bottom: 8px;
    color: #e2e8f0;
}

.card p {
    color: #94a3b8;
    font-size: 0.9rem;
    margin-bottom: 16px;
}

button {
    background: #4f46e5;
    color: #ffffff;
    border: none;
    padding: 10px 24px;
    font-size: 0.95rem;
    font-weight: 600;
    border-radius: 8px;
    cursor: pointer;
    transition: all 0.2s ease;
}

button:hover {
    background: #6366f1;
    transform: translateY(-1px);
}

.features {
    display: flex;
    gap: 12px;
    justify-content: center;
}

.feature-item {
    background: #1e293b;
    padding: 8px 14px;
    border-radius: 20px;
    font-size: 0.8rem;
    color: #cbd5e1;
    border: 1px solid #334155;
}
"""

DEFAULT_SCRIPT_JS = """// NV Studio Default JavaScript
console.log("NV Studio: Script loaded successfully!");

function handleButtonClick() {
    const title = document.getElementById("title");
    const colors = ["#6366f1", "#10b981", "#f59e0b", "#ec4899", "#8b5cf6"];
    const randomColor = colors[Math.floor(Math.random() * colors.length)];

    title.style.color = randomColor;
    console.log("Color changed to: " + randomColor);

    alert("Hello from NV Studio! Your website code is running perfectly.");
}
"""


class WorkspaceManager:
    """Manages project file hierarchy, reading, writing, and file operations."""

    def __init__(self, root_path: Optional[str] = None):
        if root_path is None or not Path(root_path).exists():
            root_path = self.get_default_workspace_path()
        self.root_path = Path(root_path).resolve()
        self.ensure_default_project()

    @staticmethod
    def get_default_workspace_path() -> Path:
        """Returns default user workspace directory (~/NVStudioProjects/My Website)."""
        base_dir = Path.home() / "NVStudioProjects" / "My Website"
        base_dir.mkdir(parents=True, exist_ok=True)
        return base_dir

    def ensure_default_project(self) -> None:
        """Creates default index.html, style.css, script.js if directory is empty."""
        self.root_path.mkdir(parents=True, exist_ok=True)

        index_html = self.root_path / "index.html"
        style_css = self.root_path / "style.css"
        script_js = self.root_path / "script.js"

        if not index_html.exists():
            index_html.write_text(DEFAULT_INDEX_HTML, encoding="utf-8")
        if not style_css.exists():
            style_css.write_text(DEFAULT_STYLE_CSS, encoding="utf-8")
        if not script_js.exists():
            script_js.write_text(DEFAULT_SCRIPT_JS, encoding="utf-8")

    def set_root_path(self, new_path: str) -> None:
        """Switches the active project root directory."""
        path = Path(new_path).resolve()
        path.mkdir(parents=True, exist_ok=True)
        self.root_path = path

    def list_files(self) -> List[Path]:
        """Returns all relative file paths in the workspace."""
        files = []
        if not self.root_path.exists():
            return files
        for p in sorted(self.root_path.rglob("*")):
            if p.is_file() and not p.name.startswith("."):
                files.append(p.relative_to(self.root_path))
        return files

    def read_file(self, rel_path: str) -> str:
        """Reads file content relative to project root."""
        full_path = self.root_path / rel_path
        if full_path.exists() and full_path.is_file():
            return full_path.read_text(encoding="utf-8", errors="replace")
        return ""

    def save_file(self, rel_path: str, content: str) -> bool:
        """Saves file content relative to project root."""
        try:
            full_path = self.root_path / rel_path
            full_path.parent.mkdir(parents=True, exist_ok=True)
            full_path.write_text(content, encoding="utf-8")
            return True
        except Exception as e:
            print(f"[WorkspaceManager] Error saving file {rel_path}: {e}")
            return False

    def create_file(self, rel_path: str, initial_content: str = "") -> bool:
        """Creates a new file in the workspace."""
        try:
            full_path = self.root_path / rel_path
            if full_path.exists():
                return False
            full_path.parent.mkdir(parents=True, exist_ok=True)
            full_path.write_text(initial_content, encoding="utf-8")
            return True
        except Exception as e:
            print(f"[WorkspaceManager] Error creating file {rel_path}: {e}")
            return False

    def rename_file(self, old_rel_path: str, new_rel_path: str) -> bool:
        """Renames or moves a file within the workspace."""
        try:
            old_full = self.root_path / old_rel_path
            new_full = self.root_path / new_rel_path
            if not old_full.exists() or new_full.exists():
                return False
            new_full.parent.mkdir(parents=True, exist_ok=True)
            old_full.rename(new_full)
            return True
        except Exception as e:
            print(f"[WorkspaceManager] Error renaming {old_rel_path} to {new_rel_path}: {e}")
            return False

    def delete_file(self, rel_path: str) -> bool:
        """Deletes a file or directory relative to project root."""
        try:
            full_path = self.root_path / rel_path
            if not full_path.exists():
                return False
            if full_path.is_dir():
                shutil.rmtree(full_path)
            else:
                full_path.unlink()
            return True
        except Exception as e:
            print(f"[WorkspaceManager] Error deleting {rel_path}: {e}")
            return False
