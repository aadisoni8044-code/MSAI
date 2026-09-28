from typing import List, Dict, Any, Optional
from exe_tow.core.models import ErrorCategory, CommandExecution

class RecoveryManager:
    @staticmethod
    def classify_error(execution: CommandExecution) -> ErrorCategory:
        text = (execution.stdout + "\n" + execution.stderr).lower()

        if "no module named pyinstaller" in text or "pyinstaller: command not found" in text or "'pyinstaller' is not recognized" in text:
            return ErrorCategory.PYINSTALLER_NOT_FOUND
        if "no module named pip" in text or "pip: command not found" in text:
            return ErrorCategory.PIP_NOT_FOUND
        if "modulenotfounderror" in text or "no module named" in text:
            return ErrorCategory.MISSING_MODULE
        if "permission denied" in text or "access is denied" in text:
            return ErrorCategory.PERMISSION_ERROR
        if "no such file or directory" in text or "cannot find the path" in text:
            return ErrorCategory.INVALID_PATH
        if "python was not found" in text or "python: command not found" in text:
            return ErrorCategory.PYTHON_NOT_FOUND

        return ErrorCategory.BUILD_COMMAND_FAILED

    @staticmethod
    def get_recovery_command(
        error_category: ErrorCategory,
        python_exe: str,
        pip_exe: Optional[str]
    ) -> Optional[List[str]]:
        if error_category == ErrorCategory.PYINSTALLER_NOT_FOUND:
            if pip_exe:
                return [pip_exe, "install", "pyinstaller"]
            return [python_exe, "-m", "pip", "install", "pyinstaller"]

        if error_category == ErrorCategory.PIP_NOT_FOUND:
            return [python_exe, "-m", "ensurepip", "--upgrade"]

        return None
