"""
OpenMS Application Configuration & Theme Definitions
"""

APP_NAME = "OpenMS Desktop IDE"
APP_VERSION = "1.0.0"

DEFAULT_SCRIPT = """# OpenMS Sample Script
game = box(100)
game2 = boody_2D(game)
machine("OpenMS Engine initialized successfully!", game, game2)
"""

FUNCTION_HELP = {
    "machine": "machine(*values) -> prints values directly to the Terminal Log panel.",
    "input": "input(prompt) -> opens a native input dialog and returns user string input.",
    "function": "function name(params): ... -> defines a reusable block of OpenMS code.",
    "open": "open(path) -> reads a text file from disk (opens file picker if path omitted).",
    "if": "if(condition): ... -> executes indented block when condition is truthy.",
    "box": "box(size, color) -> creates a Box shape primitive.",
    "bol": "bol(radius, color) -> creates a Ball (circle/sphere) shape primitive.",
    "size": "size(obj, value) -> modifies shape object's size or radius in place.",
    "photo": "photo(path) -> creates a Photo asset reference.",
    "time": "time(seconds) -> registers a non-blocking simulated timer.",
    "house": "house(width, height) -> creates a composite House shape.",
    "game": "game(title, width, height) -> creates a Game world container object.",
    "boody_2D": "boody_2D(obj) -> renders shape or game world into a live 2D window.",
    "boody_3D": "boody_3D(obj) -> renders shape or game world into a live pseudo-3D window.",
}

# Theme Color Schemes
THEMES = {
    "VS Code Dark": {
        "name": "VS Code Dark",
        "bg_main": "#1e1e1e",
        "bg_side": "#252526",
        "bg_header": "#323233",
        "bg_editor": "#1e1e1e",
        "bg_terminal": "#181818",
        "fg_text": "#d4d4d4",
        "fg_dim": "#858585",
        "accent": "#007acc",
        "accent_hover": "#1f8ad2",
        "border": "#3c3c3c",
        "line_num_bg": "#1e1e1e",
        "line_num_fg": "#858585",
        "kw_color": "#c586c0",
        "func_color": "#dcdcaa",
        "num_color": "#b5cea8",
        "str_color": "#ce9178",
    },
    "Obsidian Dark": {
        "name": "Obsidian Dark",
        "bg_main": "#121212",
        "bg_side": "#1a1a1a",
        "bg_header": "#181818",
        "bg_editor": "#121212",
        "bg_terminal": "#0d0d0d",
        "fg_text": "#e3e3e3",
        "fg_dim": "#8a8a8a",
        "accent": "#4a90e2",
        "accent_hover": "#0a84ff",
        "border": "#2b2b2b",
        "line_num_bg": "#121212",
        "line_num_fg": "#555555",
        "kw_color": "#ff79c6",
        "func_color": "#50fa7b",
        "num_color": "#bd93f9",
        "str_color": "#f1fa8c",
    },
    "Monokai": {
        "name": "Monokai",
        "bg_main": "#272822",
        "bg_side": "#1e1f1c",
        "bg_header": "#2d2e2a",
        "bg_editor": "#272822",
        "bg_terminal": "#181915",
        "fg_text": "#f8f8f2",
        "fg_dim": "#75715e",
        "accent": "#a6e22e",
        "accent_hover": "#b6f23e",
        "border": "#3e3d32",
        "line_num_bg": "#272822",
        "line_num_fg": "#75715e",
        "kw_color": "#f92672",
        "func_color": "#66d9ef",
        "num_color": "#ae81ff",
        "str_color": "#e6db74",
    },
    "Cyberpunk": {
        "name": "Cyberpunk",
        "bg_main": "#0f051d",
        "bg_side": "#190a30",
        "bg_header": "#220e42",
        "bg_editor": "#0f051d",
        "bg_terminal": "#080212",
        "fg_text": "#00f0ff",
        "fg_dim": "#714674",
        "accent": "#ff0055",
        "accent_hover": "#ff3377",
        "border": "#3a1259",
        "line_num_bg": "#0f051d",
        "line_num_fg": "#714674",
        "kw_color": "#ff0055",
        "func_color": "#ffe600",
        "num_color": "#00ff66",
        "str_color": "#ff9900",
    },
    "Light Slate": {
        "name": "Light Slate",
        "bg_main": "#f8fafc",
        "bg_side": "#f1f5f9",
        "bg_header": "#e2e8f0",
        "bg_editor": "#ffffff",
        "bg_terminal": "#f1f5f9",
        "fg_text": "#0f172a",
        "fg_dim": "#64748b",
        "accent": "#2563eb",
        "accent_hover": "#1d4ed8",
        "border": "#cbd5e1",
        "line_num_bg": "#f8fafc",
        "line_num_fg": "#94a3b8",
        "kw_color": "#9333ea",
        "func_color": "#0284c7",
        "num_color": "#16a34a",
        "str_color": "#d97706",
    },
}

DEFAULT_THEME = "VS Code Dark"
