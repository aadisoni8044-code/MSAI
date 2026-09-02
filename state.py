"""
MSAI Studio - Global App State & Signals
"""
from PyQt6.QtCore import QObject, pyqtSignal

class AppState(QObject):
    """
    Central Application State and Event Bus.
    Provides signals for reactive UI updates across decoupled widgets.
    """
    # File / Editor signals
    active_editor_changed = pyqtSignal(str)          # file_path
    file_opened = pyqtSignal(str)                   # file_path
    file_saved = pyqtSignal(str)                    # file_path
    file_closed = pyqtSignal(str)                   # file_path
    file_modified_changed = pyqtSignal(str, bool)   # file_path, is_modified
    cursor_position_changed = pyqtSignal(int, int)   # line, col

    # Project signals
    project_opened = pyqtSignal(str)                # project_path
    project_closed = pyqtSignal()
    tree_refresh_requested = pyqtSignal()

    # Interpreter & Run signals
    interpreter_changed = pyqtSignal(str)           # interpreter_path
    python_execution_started = pyqtSignal(str)      # script_path
    python_execution_finished = pyqtSignal(int)     # exit_code
    output_received = pyqtSignal(str)               # output_text

    # Git signals
    git_status_updated = pyqtSignal(str)            # branch_name or status

    # UI Theme & Settings signals
    settings_changed = pyqtSignal(dict)
    theme_changed = pyqtSignal(str)                 # theme_name
    terminal_toggle_requested = pyqtSignal()
    sidebar_toggle_requested = pyqtSignal()
    active_sidebar_tab_changed = pyqtSignal(int)    # tab index

    def __init__(self):
        super().__init__()
        self.active_file = None
        self.active_project = None
        self.modified_files = set()
        self.python_interpreter = None
        self.current_git_branch = "main"

state = AppState()
