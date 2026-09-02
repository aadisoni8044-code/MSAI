"""
MSAI Studio - Global Search Engine
"""
import os
import re
from typing import List, Dict, Any

class SearchEngine:
    """Provides project-wide text search and replace capabilities."""

    @staticmethod
    def search_in_directory(
        directory: str,
        query: str,
        case_sensitive: bool = False,
        whole_word: bool = False,
        use_regex: bool = False
    ) -> List[Dict[str, Any]]:
        """
        Searches directory files for query string or regex pattern.
        Returns list of matches grouped by file with line numbers and preview snippet.
        """
        results = []
        if not directory or not os.path.exists(directory) or not query:
            return results

        pattern_str = query
        if not use_regex:
            pattern_str = re.escape(query)
        if whole_word:
            pattern_str = r"\b" + pattern_str + r"\b"

        flags = 0 if case_sensitive else re.IGNORECASE

        try:
            compiled_regex = re.compile(pattern_str, flags)
        except re.error as e:
            print(f"[SearchEngine] Invalid regex: {e}")
            return results

        for root, dirs, files in os.walk(directory):
            # Exclude version control and build folders
            dirs[:] = [d for d in dirs if not d.startswith(".") and d not in ("__pycache__", "venv", "node_modules", "build", "dist")]

            for file in files:
                # Limit text search to readable text extensions
                ext = os.path.splitext(file)[1].lower()
                if ext in (".pyc", ".pyo", ".png", ".jpg", ".jpeg", ".exe", ".so", ".dll", ".zip", ".tar", ".gz"):
                    continue

                full_path = os.path.join(root, file)
                rel_path = os.path.relpath(full_path, directory)

                try:
                    with open(full_path, "r", encoding="utf-8", errors="ignore") as f:
                        file_matches = []
                        for line_idx, line in enumerate(f, start=1):
                            for match in compiled_regex.finditer(line):
                                file_matches.append({
                                    "line_number": line_idx,
                                    "col": match.start(),
                                    "line_text": line.strip(),
                                    "match_text": match.group(0)
                                })
                        if file_matches:
                            results.append({
                                "file_path": full_path,
                                "relative_path": rel_path,
                                "matches": file_matches
                            })
                except Exception as e:
                    print(f"[SearchEngine] Error reading {full_path}: {e}")

        return results

    @staticmethod
    def replace_in_file(file_path: str, search_query: str, replace_text: str, case_sensitive: bool = False, whole_word: bool = False, use_regex: bool = False) -> int:
        """Replaces matching occurrences in specified file and returns count replaced."""
        if not os.path.exists(file_path):
            return 0

        pattern_str = search_query
        if not use_regex:
            pattern_str = re.escape(search_query)
        if whole_word:
            pattern_str = r"\b" + pattern_str + r"\b"

        flags = 0 if case_sensitive else re.IGNORECASE

        try:
            compiled_regex = re.compile(pattern_str, flags)
            with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
                content = f.read()

            new_content, count = compiled_regex.subn(replace_text, content)
            if count > 0:
                with open(file_path, "w", encoding="utf-8") as f:
                    f.write(new_content)
            return count
        except Exception as e:
            print(f"[SearchEngine] Error replacing in {file_path}: {e}")
            return 0
