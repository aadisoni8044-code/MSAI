"""Build script to package Kora itself into Kora.exe using PyInstaller."""

import os
import sys
import subprocess


def build_kora():
    print("=== Building Kora into Kora.exe ===")

    python_exe = sys.executable
    root_dir = os.path.dirname(os.path.abspath(__file__))
    entry_point = os.path.join(root_dir, "main.py")
    dist_dir = os.path.join(root_dir, "dist")

    cmd = [
        python_exe, "-m", "PyInstaller",
        "--onefile",
        "--noconsole",
        "--name", "Kora",
        "--clean",
        "-y",
        entry_point
    ]

    print(f"Executing build command:\n{' '.join(cmd)}\n")

    try:
        res = subprocess.run(cmd, cwd=root_dir)
        if res.returncode == 0:
            print(f"\n✓ Kora built successfully! Executable located in: {os.path.join(dist_dir, 'Kora.exe')}")
        else:
            print(f"\n❌ Failed to build Kora. Exit code: {res.returncode}")
            sys.exit(res.returncode)
    except Exception as e:
        print(f"\n❌ Error building Kora: {e}")
        sys.exit(1)


if __name__ == "__main__":
    build_kora()
