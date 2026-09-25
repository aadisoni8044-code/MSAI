"""Logging module for Kora Application."""

import os
import logging
from pathlib import Path


def setup_logger(log_dir: str = "logs") -> logging.Logger:
    """Configures application, build, and error logging."""
    os.makedirs(log_dir, exist_ok=True)

    app_logger = logging.getLogger("kora")
    app_logger.setLevel(logging.DEBUG)
    app_logger.handlers.clear()

    formatter = logging.Formatter(
        "[%(asctime)s] [%(levelname)s] [%(name)s]: %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S"
    )

    # Console handler
    console_handler = logging.StreamHandler()
    console_handler.setLevel(logging.INFO)
    console_handler.setFormatter(formatter)
    app_logger.addHandler(console_handler)

    # Application log file
    app_file_handler = logging.FileHandler(os.path.join(log_dir, "application.log"), encoding="utf-8")
    app_file_handler.setLevel(logging.DEBUG)
    app_file_handler.setFormatter(formatter)
    app_logger.addHandler(app_file_handler)

    # Error log file
    error_file_handler = logging.FileHandler(os.path.join(log_dir, "error.log"), encoding="utf-8")
    error_file_handler.setLevel(logging.ERROR)
    error_file_handler.setFormatter(formatter)
    app_logger.addHandler(error_file_handler)

    return app_logger


def get_build_logger(log_dir: str = "logs") -> logging.Logger:
    """Returns logger dedicated to build output logs."""
    os.makedirs(log_dir, exist_ok=True)
    build_logger = logging.getLogger("kora.build")
    build_logger.setLevel(logging.DEBUG)

    if not build_logger.handlers:
        formatter = logging.Formatter("[%(asctime)s] %(message)s", datefmt="%H:%M:%S")
        fh = logging.FileHandler(os.path.join(log_dir, "build.log"), encoding="utf-8")
        fh.setFormatter(formatter)
        build_logger.addHandler(fh)

    return build_logger


# Default instance
logger = setup_logger()
