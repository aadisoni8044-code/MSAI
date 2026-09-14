#!/usr/bin/env python3
"""
NV Studio - Entry Point Launcher
Run this script to start the NV Studio desktop code editor application.
"""

import sys
from nvstudio.ui.main_window import NVStudioApp


def main():
    test_mode = "--test-launch" in sys.argv
    app = NVStudioApp(test_launch=test_mode)
    if not test_mode:
        app.mainloop()


if __name__ == "__main__":
    main()
