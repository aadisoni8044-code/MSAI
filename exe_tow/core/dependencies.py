import os
import ast
import re
from typing import List, Dict, Any, Set

STANDARD_MODULES = {
    "os", "sys", "time", "math", "random", "datetime", "json", "re", "pathlib",
    "shutil", "subprocess", "typing", "collections", "itertools", "functools",
    "threading", "multiprocessing", "asyncio", "socket", "urllib", "http",
    "tkinter", "sqlite3", "ctypes", "unittest", "logging", "argparse", "copy",
    "tempfile", "traceback", "io", "string", "struct", "platform", "enum", "hashlib"
}


class DependencyParser:
    """Parses dependencies from requirements.txt, pyproject.toml, and source imports."""

    def __init__(self, project_path: str, python_files: List[str]):
        self.project_path = os.path.abspath(project_path)
        self.python_files = python_files

    def parse(self) -> Dict[str, Any]:
        req_dependencies = self._parse_requirements()
        toml_dependencies = self._parse_pyproject()
        import_dependencies = self._parse_imports()

        all_deps: Set[str] = set()
        all_deps.update(req_dependencies)
        all_deps.update(toml_dependencies)
        all_deps.update(import_dependencies)

        clean_deps = sorted(list(all_deps))

        return {
            "dependencies": clean_deps,
            "count": len(clean_deps),
            "from_requirements": req_dependencies,
            "from_pyproject": toml_dependencies,
            "from_imports": import_dependencies
        }

    def _parse_requirements(self) -> List[str]:
        req_file = os.path.join(self.project_path, "requirements.txt")
        deps = []
        if os.path.exists(req_file):
            try:
                with open(req_file, "r", encoding="utf-8", errors="ignore") as f:
                    for line in f:
                        line = line.strip()
                        if line and not line.startswith("#"):
                            pkg = re.split(r'[=<>;\s]', line)[0].strip()
                            if pkg:
                                deps.append(pkg)
            except Exception:
                pass
        return deps

    def _parse_pyproject(self) -> List[str]:
        toml_file = os.path.join(self.project_path, "pyproject.toml")
        deps = []
        if os.path.exists(toml_file):
            try:
                with open(toml_file, "r", encoding="utf-8", errors="ignore") as f:
                    content = f.read()
                    matches = re.findall(r'dependencies\s*=\s*\[(.*?)\]', content, re.DOTALL)
                    for match in matches:
                        pkgs = re.findall(r'["\']([a-zA-Z0-9_\-]+)', match)
                        deps.extend(pkgs)
            except Exception:
                pass
        return deps

    def _parse_imports(self) -> List[str]:
        imports: Set[str] = set()
        for rel_path in self.python_files:
            full_path = os.path.join(self.project_path, rel_path)
            if not os.path.exists(full_path):
                continue
            try:
                with open(full_path, "r", encoding="utf-8", errors="ignore") as f:
                    tree = ast.parse(f.read(), filename=full_path)

                for node in ast.walk(tree):
                    if isinstance(node, ast.Import):
                        for alias in node.names:
                            pkg = alias.name.split('.')[0]
                            if pkg not in STANDARD_MODULES and not self._is_local_module(pkg):
                                imports.add(pkg)
                    elif isinstance(node, ast.ImportFrom):
                        if node.module:
                            pkg = node.module.split('.')[0]
                            if pkg not in STANDARD_MODULES and not self._is_local_module(pkg):
                                imports.add(pkg)
            except Exception:
                pass
        return sorted(list(imports))

    def _is_local_module(self, name: str) -> bool:
        if os.path.exists(os.path.join(self.project_path, f"{name}.py")):
            return True
        if os.path.exists(os.path.join(self.project_path, name)):
            return True
        return False
