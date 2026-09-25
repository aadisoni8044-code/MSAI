"""Permission Manager module for handling system execution permissions safely."""

from models.settings import PermissionRequest
from app.logger import logger


class PermissionManager:
    """Manages build execution permissions and validates action requests against granted permissions."""

    def __init__(self, permissions: PermissionRequest = None):
        self.permissions = permissions or PermissionRequest()

    def update_permissions(self, permissions: PermissionRequest):
        self.permissions = permissions
        logger.info(f"Updated build permissions: {self.permissions}")

    def check_folder_access(self) -> bool:
        return self.permissions.folder_access

    def check_execute_commands(self) -> bool:
        return self.permissions.execute_commands

    def check_create_files(self) -> bool:
        return self.permissions.create_files

    def check_install_packages(self) -> bool:
        return self.permissions.install_packages

    def check_internet_access(self) -> bool:
        return self.permissions.internet_access

    def validate_action(self, action_type: str) -> bool:
        """Validates if a specific action type is allowed under current permissions."""
        if action_type == "FOLDER_ACCESS":
            return self.permissions.folder_access
        elif action_type == "EXECUTE_COMMAND":
            return self.permissions.execute_commands
        elif action_type == "CREATE_FILES":
            return self.permissions.create_files
        elif action_type == "INSTALL_PACKAGES":
            return self.permissions.install_packages
        elif action_type == "INTERNET_ACCESS":
            return self.permissions.internet_access
        return False
