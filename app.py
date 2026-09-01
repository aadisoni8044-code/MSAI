#!/usr/bin/env python3
"""
OpenMS Code Studio - Desktop Application Launcher
"""

import sys
import tkinter as tk
from openms.ui.main_window import OpenMSIDE


def main():
    root = tk.Tk()
    app = OpenMSIDE(root)
    root.mainloop()


if __name__ == "__main__":
    main()
