"""
1D Builtin functions for OpenMS Language
"""

import os
from tkinter import simpledialog, filedialog
from openms.models import OpenMSError


class Builtins1D:
    """Provides 1D language builtin implementations."""

    def __init__(self, root, terminal_write_cb):
        self.root = root
        self.terminal_write = terminal_write_cb

    def b_machine(self, *args):
        formatted = " ".join(str(a) for a in args)
        self.terminal_write(f"[machine] {formatted}")
        return formatted

    def b_input(self, prompt=""):
        res = simpledialog.askstring("OpenMS input()", str(prompt), parent=self.root)
        val = res if res is not None else ""
        self.terminal_write(f"[input] User entered: {val!r}")
        return val

    def b_open(self, path=None):
        if not path:
            path = filedialog.askopenfilename(
                title="Select File to Open",
                filetypes=[("All Files", "*.*")],
                parent=self.root,
            )
        if not path:
            return ""
        try:
            with open(path, "r", encoding="utf-8", errors="replace") as f:
                content = f.read()
            self.terminal_write(f"[open] Loaded '{path}' ({len(content)} chars)")
            return content
        except Exception as e:
            raise OpenMSError(f"Cannot open '{path}': {e}")

    def b_function(self, *args, **kwargs):
        return None

    def b_if(self, *args, **kwargs):
        return None
