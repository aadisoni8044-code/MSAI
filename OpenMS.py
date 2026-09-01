#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
================================================================================
 OpenMS Desktop IDE & Interpreter Engine
================================================================================
A modular, native Python VS Code desktop code editor with live syntax
highlighting, Activity Bar, Primary Sidebar file tree, tabbed editor, AI Copilot,
Command Palette, live theme switcher, integrated terminal log, and complete
tokenizer -> parser -> executor interpreter engine for the 14-function OpenMS language:
    1D: machine(), input(), function(), open(), if()
    2D/3D: box(), bol(), size(), photo(), time(), house(), game(),
           boody_2D(), boody_3D()

Run with:   python3 OpenMS.py  or  python3 app.py
===============================================================================
"""

import sys
import tkinter as tk

from openms.models import (
    OpenMSError, OMSBox, OMSBall, OMSHouse, OMSGame, OMSPhoto, OMSBody2D, OMSBody3D
)
from openms.interpreter.engine import OpenMSInterpreter
from openms.ui.main_window import OpenMSIDE


def main():
    root = tk.Tk()
    app = OpenMSIDE(root)
    root.mainloop()


if __name__ == "__main__":
    main()
