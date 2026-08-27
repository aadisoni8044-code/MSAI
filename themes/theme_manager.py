"""
Theme manager for applying and toggling QSS styles.
"""

from PyQt6.QtWidgets import QApplication

from themes.dark_theme import DARK_THEME_QSS
from themes.light_theme import LIGHT_THEME_QSS


class ThemeManager:
    """Manages applying dark/light QSS theme styles to QApplication."""

    @staticmethod
    def apply_theme(app: QApplication, theme_name: str) -> None:
        """Applies specified theme ('dark' or 'light') to the application instance."""
        if theme_name.lower() == "light":
            app.setStyleSheet(LIGHT_THEME_QSS)
        else:
            app.setStyleSheet(DARK_THEME_QSS)

    @staticmethod
    def is_dark_theme(theme_name: str) -> bool:
        """Returns True if theme name is dark."""
        return theme_name.lower() != "light"
