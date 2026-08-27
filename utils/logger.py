"""
Centralized logging utility for PyCodeStudio.
"""

import logging
import sys
from pathlib import Path

def setup_logger(name: str = "PyCodeStudio") -> logging.Logger:
    """Configures and returns a logger instance with console and file output."""
    logger = logging.getLogger(name)
    if logger.hasHandlers():
        return logger

    logger.setLevel(logging.INFO)

    formatter = logging.Formatter(
        "[%(asctime)s] [%(levelname)s] [%(name)s]: %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S"
    )

    # Console Handler
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setFormatter(formatter)
    logger.addHandler(console_handler)

    # File Handler in user home logs directory
    log_dir = Path.home() / ".pycodestudio" / "logs"
    try:
        log_dir.mkdir(parents=True, exist_ok=True)
        file_handler = logging.FileHandler(log_dir / "app.log", encoding="utf-8")
        file_handler.setFormatter(formatter)
        logger.addHandler(file_handler)
    except Exception as e:
        logger.warning(f"Failed to create file logger: {e}")

    return logger

logger = setup_logger()
