"""
OpenMS Theme Manager
"""

from openms.config import THEMES, DEFAULT_THEME


class ThemeManager:
    """Manages active themes and notifies registered UI components on theme change."""

    def __init__(self, theme_name=DEFAULT_THEME):
        self.active_theme_name = theme_name
        self.theme = THEMES.get(theme_name, THEMES[DEFAULT_THEME])
        self._subscribers = []

    def subscribe(self, callback):
        if callback not in self._subscribers:
            self._subscribers.append(callback)

    def unsubscribe(self, callback):
        if callback in self._subscribers:
            self._subscribers.remove(callback)

    def set_theme(self, theme_name):
        if theme_name in THEMES:
            self.active_theme_name = theme_name
            self.theme = THEMES[theme_name]
            self.notify()

    def get_theme_names(self):
        return list(THEMES.keys())

    def notify(self):
        for callback in list(self._subscribers):
            try:
                callback(self.theme)
            except Exception as e:
                print(f"[ThemeManager Error] Failed callback: {e}")
