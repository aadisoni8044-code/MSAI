"""
NV Studio Theme Configuration
Defines Dark Mode and White Mode color schemes, fonts, and widget styles.
"""

from typing import Any, Dict

DARK_THEME = {
    "name": "dark",
    "bg_main": "#0f172a",          # Slate 900
    "bg_sidebar": "#1e293b",       # Slate 800
    "bg_panel": "#1e293b",         # Slate 800
    "bg_editor": "#020617",        # Slate 950
    "bg_tab": "#0f172a",           # Slate 900
    "bg_tab_active": "#1e293b",    # Slate 800
    "bg_preview_frame": "#020617", # Slate 950
    "bg_input": "#334155",         # Slate 700
    "fg_text": "#f8fafc",          # Slate 50
    "fg_subtext": "#94a3b8",       # Slate 400
    "fg_muted": "#64748b",         # Slate 500
    "accent": "#6366f1",           # Indigo 500
    "accent_hover": "#4f46e5",     # Indigo 600
    "accent_fg": "#ffffff",
    "border": "#334155",           # Slate 700
    "border_active": "#6366f1",    # Indigo 500
    "line_number_bg": "#0f172a",
    "line_number_fg": "#475569",
    "run_btn": "#10b981",          # Emerald 500
    "run_btn_hover": "#059669",    # Emerald 600
    "danger": "#ef4444",           # Red 500
    "success": "#10b981",

    # Syntax Highlighting Colors
    "syn_tag": "#818cf8",          # Indigo light
    "syn_attr": "#38bdf8",         # Sky light
    "syn_keyword": "#f472b6",      # Pink
    "syn_string": "#34d399",       # Emerald
    "syn_comment": "#64748b",      # Slate 500
    "syn_number": "#fbbf24",       # Amber
    "syn_entity": "#a78bfa",       # Purple
}

LIGHT_THEME = {
    "name": "light",
    "bg_main": "#f8fafc",          # Slate 50
    "bg_sidebar": "#f1f5f9",       # Slate 100
    "bg_panel": "#ffffff",         # White
    "bg_editor": "#ffffff",        # White
    "bg_tab": "#e2e8f0",           # Slate 200
    "bg_tab_active": "#ffffff",    # White
    "bg_preview_frame": "#f1f5f9", # Slate 100
    "bg_input": "#e2e8f0",         # Slate 200
    "fg_text": "#0f172a",          # Slate 900
    "fg_subtext": "#475569",       # Slate 600
    "fg_muted": "#94a3b8",         # Slate 400
    "accent": "#4f46e5",           # Indigo 600
    "accent_hover": "#4338ca",     # Indigo 700
    "accent_fg": "#ffffff",
    "border": "#cbd5e1",           # Slate 300
    "border_active": "#4f46e5",    # Indigo 600
    "line_number_bg": "#f8fafc",
    "line_number_fg": "#94a3b8",
    "run_btn": "#059669",          # Emerald 600
    "run_btn_hover": "#047857",    # Emerald 700
    "danger": "#dc2626",           # Red 600
    "success": "#059669",

    # Syntax Highlighting Colors
    "syn_tag": "#4338ca",          # Indigo dark
    "syn_attr": "#0284c7",         # Sky dark
    "syn_keyword": "#db2777",      # Pink dark
    "syn_string": "#059669",       # Emerald dark
    "syn_comment": "#94a3b8",      # Slate 400
    "syn_number": "#d97706",       # Amber dark
    "syn_entity": "#7c3aed",       # Purple dark
}


def get_theme(theme_name: str) -> Dict[str, Any]:
    """Returns theme dictionary by name ('dark' or 'light'/'white')."""
    if theme_name and theme_name.lower() in ["light", "white"]:
        return LIGHT_THEME
    return DARK_THEME
