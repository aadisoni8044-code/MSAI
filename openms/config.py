"""
Configuration, theme palettes, and constants for OpenMS Code Studio.
"""

import re

# Theme Definitions
THEMES = {
    "dark_plus": {
        "name": "VS Code Dark+",
        "bg_activity": "#333333",
        "fg_activity": "#ffffff",
        "active_activity": "#007acc",
        "bg_sidebar": "#252526",
        "fg_sidebar": "#cccccc",
        "bg_main": "#1e1e1e",
        "fg_text": "#d4d4d4",
        "bg_editor": "#1e1e1e",
        "fg_editor": "#d4d4d4",
        "bg_tab": "#2d2d2d",
        "bg_active_tab": "#1e1e1e",
        "fg_active_tab": "#ffffff",
        "bg_terminal": "#1e1e1e",
        "fg_terminal": "#cccccc",
        "bg_status": "#007acc",
        "fg_status": "#ffffff",
        "accent_blue": "#007acc",
        "accent_green": "#4ec9b0",
        "border": "#3f3f46",
        "line_number_fg": "#858585",
        "line_highlight": "#2a2d2e",
        "syntax": {
            "keyword": "#569cd6",      # blue
            "corefunc": "#dcdcaa",     # yellow/gold
            "number": "#b5cea8",       # pale green
            "string": "#ce9178",       # orange/red
            "comment": "#6a9955",      # green
            "variable": "#9cdcfe",     # light blue
        }
    },
    "light_plus": {
        "name": "VS Code Light+",
        "bg_activity": "#2c2c2c",
        "fg_activity": "#ffffff",
        "active_activity": "#007acc",
        "bg_sidebar": "#f3f3f3",
        "fg_sidebar": "#333333",
        "bg_main": "#ffffff",
        "fg_text": "#000000",
        "bg_editor": "#ffffff",
        "fg_editor": "#000000",
        "bg_tab": "#ececec",
        "bg_active_tab": "#ffffff",
        "fg_active_tab": "#000000",
        "bg_terminal": "#f3f3f3",
        "fg_terminal": "#1e1e1e",
        "bg_status": "#007acc",
        "fg_status": "#ffffff",
        "accent_blue": "#007acc",
        "accent_green": "#098658",
        "border": "#e5e5e5",
        "line_number_fg": "#237893",
        "line_highlight": "#f0f0f0",
        "syntax": {
            "keyword": "#0000ff",
            "corefunc": "#795e26",
            "number": "#098658",
            "string": "#a31515",
            "comment": "#008000",
            "variable": "#001080",
        }
    },
    "monokai": {
        "name": "Monokai Pro",
        "bg_activity": "#19181a",
        "fg_activity": "#ffd866",
        "active_activity": "#ff6188",
        "bg_sidebar": "#221f22",
        "fg_sidebar": "#c1c0c0",
        "bg_main": "#2d2a2e",
        "fg_text": "#fcfcfa",
        "bg_editor": "#2d2a2e",
        "fg_editor": "#fcfcfa",
        "bg_tab": "#221f22",
        "bg_active_tab": "#2d2a2e",
        "fg_active_tab": "#ffd866",
        "bg_terminal": "#221f22",
        "fg_terminal": "#fcfcfa",
        "bg_status": "#ff6188",
        "fg_status": "#ffffff",
        "accent_blue": "#78dce8",
        "accent_green": "#a9dc76",
        "border": "#403e41",
        "line_number_fg": "#727072",
        "line_highlight": "#3a383c",
        "syntax": {
            "keyword": "#ff6188",
            "corefunc": "#a9dc76",
            "number": "#ab9df2",
            "string": "#ffd866",
            "comment": "#727072",
            "variable": "#78dce8",
        }
    },
    "solarized_dark": {
        "name": "Solarized Dark",
        "bg_activity": "#073642",
        "fg_activity": "#839496",
        "active_activity": "#268bd2",
        "bg_sidebar": "#00212b",
        "fg_sidebar": "#839496",
        "bg_main": "#002b36",
        "fg_text": "#839496",
        "bg_editor": "#002b36",
        "fg_editor": "#839496",
        "bg_tab": "#073642",
        "bg_active_tab": "#002b36",
        "fg_active_tab": "#268bd2",
        "bg_terminal": "#073642",
        "fg_terminal": "#839496",
        "bg_status": "#268bd2",
        "fg_status": "#ffffff",
        "accent_blue": "#268bd2",
        "accent_green": "#859900",
        "border": "#073642",
        "line_number_fg": "#586e75",
        "line_highlight": "#073642",
        "syntax": {
            "keyword": "#859900",
            "corefunc": "#b58900",
            "number": "#d33682",
            "string": "#2aa198",
            "comment": "#586e75",
            "variable": "#268bd2",
        }
    }
}

DEFAULT_SCRIPT = """game = box(1000-1000)
game2 = boody_2D(game)
machine(game, game2)
"""

FUNCTION_HELP = {
    "machine": "machine(*values) -> prints values straight to the Terminal Log panel.",
    "input": "input(prompt) -> opens a native input dialog and returns what the user typed.",
    "function": "function name(params): ... -> defines a reusable block of OpenMS code.",
    "open": "open(path) -> reads a text file from disk (opens a file picker if no path given).",
    "if": "if(condition): ... -> runs the indented block only when condition is truthy.",
    "box": "box(size, color) -> creates a Box shape object.",
    "bol": "bol(radius, color) -> creates a Ball (circle/sphere) shape object.",
    "size": "size(obj, value) -> changes an object's size/radius in place.",
    "photo": "photo(path) -> creates a Photo asset reference from an image path.",
    "time": "time(seconds) -> registers a (simulated) timer/delay.",
    "house": "house(width, height) -> creates a composite House shape.",
    "game": "game(title, width, height) -> creates a Game world container object.",
    "boody_2D": "boody_2D(obj) -> renders any shape/world object into a live 2D window.",
    "boody_3D": "boody_3D(obj) -> renders any shape/world object into a live pseudo-3D window.",
}

# Regex Syntax Highlighting Patterns
CORE_FUNCTIONS = list(FUNCTION_HELP.keys())

KEYWORD_PATTERN = re.compile(r"\b(def|return|if|else|elif|while|for|in|class|import|from|pass|break|continue|and|or|not)\b")
COREFUNC_PATTERN = re.compile(r"\b(" + "|".join(CORE_FUNCTIONS) + r")\b")
NUMBER_PATTERN = re.compile(r"\b\d+(\.\d+)?\b")
STRING_PATTERN = re.compile(r'("(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\')')
COMMENT_PATTERN = re.compile(r'#.*$')
