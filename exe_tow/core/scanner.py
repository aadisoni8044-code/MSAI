import os
from pathlib import Path
import re

def scan_project_folder(folder_path: str) -> dict:
    """
    Scans a directory for Python files, main entry point, assets, and dependencies.
    """
    if not folder_path or not os.path.exists(folder_path) or not os.path.isdir(folder_path):
        return {
            "valid": False,
            "error": "Directory does not exist or is invalid.",
            "folder_path": folder_path,
            "project_name": os.path.basename(folder_path.rstrip(r"\/")) if folder_path else "",
            "main_file": "",
            "python_files": [],
            "total_files": 0,
            "has_python": False,
            "dependencies": [],
            "asset_folders": []
        }

    folder = Path(folder_path)
    project_name = folder.name or "PythonApp"

    python_files = []
    all_files = []
    asset_folders = []
    dependencies = []

    possible_main_names = ["main.py", "app.py", "run.py", "index.py", "cli.py", "__main__.py"]
    main_file = ""
    main_file_score = {}

    for root, dirs, files in os.walk(folder):
        # Ignore common hidden/build/venv dirs
        dirs[:] = [d for d in dirs if d not in [".git", "__pycache__", "venv", ".venv", "build", "dist", ".idea", ".vscode", "node_modules"]]
        rel_root = os.path.relpath(root, folder)
        if rel_root != "." and os.path.basename(root) in ["assets", "images", "img", "static", "media", "data", "resources"]:
            asset_folders.append(rel_root)

        for file in files:
            all_files.append(os.path.join(root, file))
            rel_path = os.path.relpath(os.path.join(root, file), folder)

            if file.endswith(".py"):
                python_files.append(rel_path)
                score = 0
                if file.lower() in possible_main_names:
                    score += 10 - possible_main_names.index(file.lower())

                # Check for __main__ block
                try:
                    full_p = os.path.join(root, file)
                    with open(full_p, "r", encoding="utf-8", errors="ignore") as f:
                        content = f.read(2048) # Read first 2KB
                        if 'if __name__' in content and '__main__' in content:
                            score += 15
                except Exception:
                    pass

                main_file_score[rel_path] = score

            elif file in ["requirements.txt", "Pipfile", "pyproject.toml", "setup.py"]:
                if file == "requirements.txt":
                    try:
                        with open(os.path.join(root, file), "r", encoding="utf-8", errors="ignore") as f:
                            for line in f:
                                line = line.strip()
                                if line and not line.startswith("#"):
                                    dep_name = re.split(r"[=<>]", line)[0].strip()
                                    if dep_name:
                                        dependencies.append(dep_name)
                    except Exception:
                        pass
                else:
                    dependencies.append(file)

    if main_file_score:
        sorted_mains = sorted(main_file_score.items(), key=lambda x: x[1], reverse=True)
        main_file = sorted_mains[0][0]
    elif python_files:
        main_file = python_files[0]

    return {
        "valid": bool(python_files),
        "folder_path": str(folder.resolve()),
        "project_name": project_name,
        "main_file": main_file,
        "python_files": python_files,
        "total_files": len(all_files),
        "has_python": bool(python_files),
        "dependencies": list(set(dependencies)),
        "asset_folders": list(set(asset_folders))
    }
