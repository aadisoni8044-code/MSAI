"""Views package initialization."""

from app.ui.views.dashboard_view import DashboardView
from app.ui.views.build_view import BuildView
from app.ui.views.history_view import HistoryView
from app.ui.views.logs_view import LogsView
from app.ui.views.settings_view import SettingsView

__all__ = [
    "DashboardView",
    "BuildView",
    "HistoryView",
    "LogsView",
    "SettingsView"
]
