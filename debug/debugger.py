"""
MSAI Studio - Python Debugger Architecture
"""
import sys
import os
import bdb
from typing import Dict, List, Set, Any, Optional
from PyQt6.QtCore import QObject, pyqtSignal

class Debugger(QObject):
    """
    Python Debugger backend supporting breakpoints, call stack, frame variable inspection,
    and stepping actions (step over, step into, step out, continue).
    """
    breakpoint_hit = pyqtSignal(str, int, dict) # filename, line, frame_variables
    stack_changed = pyqtSignal(list)            # stack_frames
    debugger_stopped = pyqtSignal()
    debugger_started = pyqtSignal(str)

    def __init__(self, parent=None):
        super().__init__(parent)
        self.breakpoints: Dict[str, Set[int]] = {}
        self.is_active = False
        self.current_frame = None
        self.stack_frames = []

    def set_breakpoint(self, filename: str, line: int):
        """Adds a breakpoint."""
        norm_file = os.path.abspath(filename)
        if norm_file not in self.breakpoints:
            self.breakpoints[norm_file] = set()
        self.breakpoints[norm_file].add(line)

    def remove_breakpoint(self, filename: str, line: int):
        """Removes a breakpoint."""
        norm_file = os.path.abspath(filename)
        if norm_file in self.breakpoints and line in self.breakpoints[norm_file]:
            self.breakpoints[norm_file].remove(line)

    def toggle_breakpoint(self, filename: str, line: int) -> bool:
        """Toggles breakpoint and returns True if active."""
        norm_file = os.path.abspath(filename)
        if norm_file in self.breakpoints and line in self.breakpoints[norm_file]:
            self.remove_breakpoint(norm_file, line)
            return False
        else:
            self.set_breakpoint(norm_file, line)
            return True

    def start_debugging(self, script_path: str):
        """Starts debugging target script."""
        if not os.path.exists(script_path):
            return False
        self.is_active = True
        self.debugger_started.emit(script_path)
        return True

    def stop_debugging(self):
        """Stops active debugging session."""
        self.is_active = False
        self.debugger_stopped.emit()

    def get_variables(self, frame=None) -> Dict[str, str]:
        """Returns string representation of local variables in current frame."""
        vars_dict = {}
        target_frame = frame or self.current_frame
        if target_frame and hasattr(target_frame, "f_locals"):
            for k, v in target_frame.f_locals.items():
                if not k.startswith("__"):
                    try:
                        vars_dict[k] = repr(v)
                    except Exception:
                        vars_dict[k] = "<unrepresentable>"
        return vars_dict
