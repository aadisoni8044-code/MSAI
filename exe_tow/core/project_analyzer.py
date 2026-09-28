import os
import ast
from pathlib import Path
from typing import List, Optional
from exe_tow.core.models import ProjectInfo

class ProjectAnalyzer:
    def __init__(self, target_path: str):
        self.target_path = Path(target_path).resolve()

    def analyze(self) -> ProjectInfo:
        if not self.target_path.exists():
            raise FileNotFoundError(f"Target path does not exist: {self.target_path}")

        if self.target_path.is_file():
            is_single_file = True
            project_dir = self.target_path.parent
            entry_file = self.target_path
            project_name = self.target_path.stem
        else:
            is_single_file = False
            project_dir = self.target_path
            entry_file = self._find_entry_file(project_dir)
            project_name = project_dir.name

        has_reqs, reqs_path = self._find_requirements(project_dir)
        has_venv, venv_path = self._find_venv(project_dir)
        imports = self._scan_imports(entry_file)
        assets = self._scan_assets(project_dir)

        return ProjectInfo(
            project_path=str(project_dir),
            entry_file=str(entry_file),
            project_name=project_name,
            is_single_file=is_single_file,
            has_requirements=has_reqs,
            requirements_path=str(reqs_path) if reqs_path else None,
            has_venv=has_venv,
            venv_path=str(venv_path) if venv_path else None,
            detected_imports=imports,
            local_assets=assets
        )

    def _find_entry_file(self, project_dir: Path) -> Path:
        common_entries = ["main.py", "app.py", "run.py", "__main__.py", "index.py", "cli.py"]
        for entry in common_entries:
            candidate = project_dir / entry
            if candidate.exists():
                return candidate

        # Look for any .py file at root
        py_files = list(project_dir.glob("*.py"))
        if py_files:
            return py_files[0]

        raise FileNotFoundError(f"No entry Python file found in {project_dir}")

    def _find_requirements(self, project_dir: Path) -> (bool, Optional[Path]):
        reqs = project_dir / "requirements.txt"
        if reqs.exists():
            return True, reqs
        return False, None

    def _find_venv(self, project_dir: Path) -> (bool, Optional[Path]):
        common_venvs = ["venv", ".venv", "env", ".env"]
        for v in common_venvs:
            cand = project_dir / v
            if cand.exists() and cand.is_dir() and (cand / "pyvenv.cfg").exists():
                return True, cand
        return False, None

    def _scan_imports(self, entry_file: Path) -> List[str]:
        imports = set()
        if not entry_file.exists():
            return []

        try:
            with open(entry_file, "r", encoding="utf-8", errors="ignore") as f:
                tree = ast.parse(f.read(), filename=str(entry_file))

            for node in ast.walk(tree):
                if isinstance(node, ast.Import):
                    for alias in node.names:
                        imports.add(alias.name.split('.')[0])
                elif isinstance(node, ast.ImportFrom):
                    if node.module:
                        imports.add(node.module.split('.')[0])
        except Exception:
            pass

        return sorted(list(imports))

    def _scan_assets(self, project_dir: Path) -> List[str]:
        asset_exts = {".png", ".jpg", ".jpeg", ".ico", ".svg", ".json", ".yaml", ".yml", ".txt", ".csv", ".db"}
        assets = []
        try:
            for root, _, files in os.walk(project_dir):
                if any(ignored in root for ignored in ["venv", ".venv", "__pycache__", ".git", "build", "dist"]):
                    continue
                for f in files:
                    ext = Path(f).suffix.lower()
                    if ext in asset_exts and f != "requirements.txt":
                        rel = Path(root, f).relative_to(project_dir)
                        assets.append(str(rel))
        except Exception:
            pass
        return assets[:50]  # Limit
