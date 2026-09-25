"""Main application entry point for Kora."""

import sys
import os

# Add root directory to sys.path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app.logger import logger
from app.ui.main_window import MainWindow


def main():
    logger.info("Starting Kora Python → EXE Build System...")
    app = MainWindow()
    app.mainloop()


if __name__ == "__main__":
    main()
