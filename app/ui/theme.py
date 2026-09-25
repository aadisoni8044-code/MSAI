"""Theme and Color Palette definition for Kora Application."""

from dataclasses import dataclass, field
from typing import Dict, Any


@dataclass
class ColorPalette:
    bg_dark: str = "#0B1020"
    sidebar_bg: str = "#0F172A"
    card_bg: str = "#111827"
    card_elevated: str = "#172033"
    card_border: str = "#1E293B"
    primary: str = "#6366F1"
    primary_hover: str = "#4F46E5"
    success: str = "#22C55E"
    warning: str = "#F59E0B"
    error: str = "#EF4444"
    text_primary: str = "#F8FAFC"
    text_secondary: str = "#94A3B8"
    terminal_bg: str = "#090D16"
    terminal_fg: str = "#E2E8F0"
    input_bg: str = "#1E293B"


DARK_PALETTE = ColorPalette(
    bg_dark="#0B1020",
    sidebar_bg="#0F172A",
    card_bg="#111827",
    card_elevated="#172033",
    card_border="#1E293B",
    primary="#6366F1",
    primary_hover="#4F46E5",
    success="#22C55E",
    warning="#F59E0B",
    error="#EF4444",
    text_primary="#F8FAFC",
    text_secondary="#94A3B8",
    terminal_bg="#090D16",
    terminal_fg="#E2E8F0",
    input_bg="#1E293B"
)

LIGHT_PALETTE = ColorPalette(
    bg_dark="#F8FAFC",
    sidebar_bg="#F1F5F9",
    card_bg="#FFFFFF",
    card_elevated="#F1F5F9",
    card_border="#E2E8F0",
    primary="#4F46E5",
    primary_hover="#4338CA",
    success="#16A34A",
    warning="#D97706",
    error="#DC2626",
    text_primary="#0F172A",
    text_secondary="#64748B",
    terminal_bg="#0F172A",
    terminal_fg="#F8FAFC",
    input_bg="#F1F5F9"
)


class ThemeManager:
    """Manages application themes and active color configuration."""

    def __init__(self, theme_mode: str = "Dark"):
        self.theme_mode = theme_mode  # "Dark", "Light", "System"
        self.colors = DARK_PALETTE if theme_mode.lower() != "light" else LIGHT_PALETTE

    def set_mode(self, mode: str):
        self.theme_mode = mode
        if mode.lower() == "light":
            self.colors = LIGHT_PALETTE
        else:
            self.colors = DARK_PALETTE

    def get_colors() -> ColorPalette:
        return self.colors
