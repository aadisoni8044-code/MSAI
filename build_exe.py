"""
Self-packaging script for EXE/TOW.
Compiles the application into a standalone EXE/TOW.exe executable using PyInstaller.
"""

import sys
import os
import subprocess
from pathlib import Path

def build_exe():
    root_dir = Path(__file__).parent.resolve()
    main_script = root_dir / "main.py"

    cmd = [
        sys.executable,
        "-m", "PyInstaller",
        "--onefile",
        "--noconfirm",
        "--clean",
        "--name", "EXE_TOW",
        "--distpath", str(root_dir / "dist"),
        "--workpath", str(root_dir / "build"),
        "--specpath", str(root_dir / "spec"),
        str(main_script)
    ]

    print("Building EXE/TOW standalone executable...")
    print(f"Command: {' '.join(cmd)}")

    res = subprocess.run(cmd, cwd=root_dir)
    if res.returncode == 0:
        print("\n🎉 EXE/TOW build completed successfully!")
        print(f"Output executable: {root_dir / 'dist' / 'EXE_TOW.exe'}")
    else:
        print("\n❌ EXE/TOW build failed with exit code:", res.returncode)
        sys.exit(res.returncode)

if __name__ == "__main__":
    build_exe()
