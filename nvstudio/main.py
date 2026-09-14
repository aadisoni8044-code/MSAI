import sys
from PyQt6.QtWidgets import QApplication
from nvstudio.config import ConfigManager, APP_NAME
from nvstudio.workspace import WorkspaceManager
from nvstudio.ui.main_window import MainWindow
from nvstudio.ui.dialogs import FirstLaunchConsentDialog, FirstLaunchThemeDialog


def main():
    # Pass sys.argv to QApplication
    app = QApplication(sys.argv)
    app.setApplicationName(APP_NAME)

    config_manager = ConfigManager()
    workspace_manager = WorkspaceManager()

    # First launch consent dialog
    if not config_manager.get("permission_granted", False):
        consent_dialog = FirstLaunchConsentDialog()
        if consent_dialog.exec() == FirstLaunchConsentDialog.DialogCode.Accepted:
            config_manager.set("permission_granted", True)
        else:
            sys.exit(0)

    # First launch theme dialog
    if not config_manager.get("theme_chosen", False):
        theme_dialog = FirstLaunchThemeDialog()
        if theme_dialog.exec() == FirstLaunchThemeDialog.DialogCode.Accepted:
            config_manager.set("theme", theme_dialog.selected_theme)
            config_manager.set("theme_chosen", True)
        else:
            sys.exit(0)

    # Launch Main Window
    window = MainWindow(config_manager, workspace_manager)
    window.show()

    sys.exit(app.exec())


if __name__ == "__main__":
    main()
