#!/usr/bin/env python3
"""
OpenMS Desktop IDE Launcher
"""

import sys
import tkinter as tk
from openms.ui.app import OpenMSIDE
from openms.config import APP_NAME, APP_VERSION


def main():
    if "--version" in sys.argv:
        print(f"{APP_NAME} v{APP_VERSION}")
        return

    root = tk.Tk()
    if "--check" in sys.argv:
        # Non-interactive check mode for CI/headless verification
        app = OpenMSIDE(root)
        print(f"OpenMS Desktop IDE initialized successfully in check mode.")
        root.destroy()
        return

    app = OpenMSIDE(root)
    root.mainloop()


if __name__ == "__main__":
    main()
