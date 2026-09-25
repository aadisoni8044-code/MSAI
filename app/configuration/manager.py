"""Configuration Manager module for managing settings and workspace configuration."""

import os
import json
from models.settings import Settings
from app.logger import logger


class ConfigurationManager:
    """Manages application settings persistence and environment workspace configurations."""

    CONFIG_FILE_NAME = "kora_config.json"

    def __init__(self, config_dir: str = "."):
        self.config_dir = config_dir
        self.config_file_path = os.path.join(self.config_dir, self.CONFIG_FILE_NAME)
        self.settings = self.load_settings()

    def load_settings(self) -> Settings:
        """Loads settings from config file if present, else default."""
        if os.path.exists(self.config_file_path):
            try:
                with open(self.config_file_path, "r", encoding="utf-8") as f:
                    data = json.load(f)
                    return Settings(**data)
            except Exception as e:
                logger.error(f"Error loading configuration: {e}. Using defaults.")
        return Settings()

    def save_settings(self, settings: Settings):
        """Saves settings to config file."""
        self.settings = settings
        try:
            with open(self.config_file_path, "w", encoding="utf-8") as f:
                json.dump(settings.to_dict(), f, indent=2)
            logger.info("Settings saved successfully.")
        except Exception as e:
            logger.error(f"Error saving configuration: {e}")

    def get_settings(self) -> Settings:
        return self.settings
