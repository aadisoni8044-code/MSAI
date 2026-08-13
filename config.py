"""
config.py

App-wide constants, settings, logging configuration, and default parameters
for OpenMS Analyzer.
"""

import os
import logging

# App Information
APP_NAME = "OpenMS Analyzer"
VERSION = "1.0.0"

# Google Drive API Settings
SCOPES = ["https://www.googleapis.com/auth/drive.file"]
CREDENTIALS_FILE = "credentials.json"
TOKEN_FILE = "token.json"
DEFAULT_RESULTS_FOLDER_NAME = "OpenMS Analyzer Results"

# Default Pipeline Parameters
DEFAULT_PARAMS = {
    # Peak Picking (Centroiding) Options
    "peak_picking_enabled": True,
    "peak_picking_signal_to_noise": 1.0,

    # Feature Finder Options
    "ff_min_spectra": 5,          # mass_trace:min_spectra
    "ff_charge_low": 1,           # isotopic_pattern:charge_low
    "ff_charge_high": 4,          # isotopic_pattern:charge_high
    "ff_mz_tolerance": 0.03,      # mass_trace:mz_tolerance
    "ff_min_score": 0.5,          # seed:min_score
}

def setup_logging():
    """
    Sets up basic logging configuration to output to console.
    """
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S"
    )
    logger = logging.getLogger(APP_NAME)
    logger.info(f"Initialized logging for {APP_NAME} v{VERSION}")
    return logger

logger = setup_logging()
