import os
import re
from typing import List, Dict, Any, Optional

ENTRY_FILE_SCORES = {
    "main.py": 100,
    "app.py": 90,
    "run.py": 85,
    "launcher.py": 80,
    "gui.py": 75,
    "__main__.py": 70,
    "cli.py": 65,
    "index.py": 60,
    "start.py": 55,
}

MAIN_BLOCK_REGEX = re.compile(r'if\s+__name__\s*==\s*[\'"]__main__[\'"]\s*:', re.MULTILINE)


class EntryFileDetector:
    """Detects likely Python entry/main files in a project folder."""

    def __init__(self, project_path: str, python_files: List[str]):
        self.project_path = os.path.abspath(project_path)
        self.python_files = python_files

    def detect(self) -> Dict[str, Any]:
        candidates: List[Dict[str, Any]] = []

        for rel_path in self.python_files:
            filename = os.path.basename(rel_path).lower()
            score = 0

            # Score by filename pattern
            if filename in ENTRY_FILE_SCORES:
                score += ENTRY_FILE_SCORES[filename]

            # Prefer top-level files over deeply nested ones
            depth = rel_path.count(os.sep)
            if depth == 0:
                score += 30
            elif depth == 1:
                score += 10

            # Check if file contains `if __name__ == '__main__':`
            full_path = os.path.join(self.project_path, rel_path)
            has_main_block = False
            try:
                if os.path.exists(full_path):
                    with open(full_path, "r", encoding="utf-8", errors="ignore") as f:
                        content = f.read(5000) # Read first 5KB
                        if MAIN_BLOCK_REGEX.search(content):
                            score += 50
                            has_main_block = True
            except Exception:
                pass

            if score > 0 or depth == 0:
                candidates.append({
                    "rel_path": rel_path,
                    "score": score,
                    "has_main_block": has_main_block,
                    "filename": os.path.basename(rel_path)
                })

        # Sort candidates by score descending
        candidates.sort(key=lambda x: x["score"], reverse=True)

        selected_entry = candidates[0]["rel_path"] if candidates else (self.python_files[0] if self.python_files else "")
        possible_entries = [c["rel_path"] for c in candidates if c["score"] > 0] if candidates else self.python_files

        return {
            "selected_entry": selected_entry,
            "possible_entries": possible_entries,
            "candidates": candidates
        }
