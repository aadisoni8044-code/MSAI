"""
Theme Manager for OpenMS Code Studio
"""

from openms.config import THEMES


class ThemeManager:
    """Manages active theme state and notifies registered widgets on theme change."""

    def __init__(self, theme_name="dark_plus"):
        self.active_theme_name = theme_name
        self.theme = THEMES.get(theme_name, THEMES["dark_plus"])
        self._listeners = []

    def register(self, listener_cb):
        if listener_cb not in self._listeners:
            self._listeners.append(listener_cb)

    def unregister(self, listener_cb):
        if listener_cb in self._listeners:
            self._listeners.remove(listener_cb)

    def set_theme(self, theme_name):
        if theme_name in THEMES:
            self.active_theme_name = theme_name
            self.theme = THEMES[theme_name]
            for cb in self._listeners:
                try:
                    cb(self.theme)
                except Exception as e:
                    print(f"[ThemeManager Error] Listener failed: {e}")

    def get(self, key, default=None):
        return self.theme.get(key, default)
