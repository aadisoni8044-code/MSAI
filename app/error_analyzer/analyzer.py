"""Error Analyzer module for classifying build errors and providing structured fix suggestions."""

import re
from typing import Dict, Any, Optional
from models.command_result import CommandResult
from app.logger import logger


class ErrorAnalyzer:
    """Analyzes stdout/stderr output from build failures and classifies errors into categories with suggested fixes."""

    ERROR_TYPES = [
        "MISSING_PACKAGE",
        "PYTHON_VERSION",
        "MISSING_MODULE",
        "IMPORT_ERROR",
        "DLL_ERROR",
        "PATH_ERROR",
        "PERMISSION_ERROR",
        "BUILDER_NOT_INSTALLED",
        "BUILD_SCRIPT_ERROR",
        "ENTRY_POINT_ERROR",
        "DATA_FILE_MISSING",
        "GUI_RESOURCE_MISSING",
        "COMPILER_ERROR",
        "UNKNOWN"
    ]

    PATTERNS = [
        (r"No module named ['\"]([^'\"]+)['\"]", "MISSING_MODULE"),
        (r"ModuleNotFoundError: No module named ['\"]([^'\"]+)['\"]", "MISSING_MODULE"),
        (r"ImportError: cannot import name ['\"]([^'\"]+)['\"]", "IMPORT_ERROR"),
        (r"ImportError: DLL load failed", "DLL_ERROR"),
        (r"FileNotFoundError: \[Errno 2\] No such file or directory: ['\"]([^'\"]+)['\"]", "DATA_FILE_MISSING"),
        (r"PermissionError: \[Errno 13\] Permission denied", "PERMISSION_ERROR"),
        (r"PyInstaller: command not found|No module named PyInstaller", "BUILDER_NOT_INSTALLED"),
        (r"Nuitka: command not found|No module named nuitka", "BUILDER_NOT_INSTALLED"),
        (r"cx_Freeze: command not found|No module named cx_Freeze", "BUILDER_NOT_INSTALLED"),
        (r"gcc|cl.exe|g\+\+|c\+\+ compiler not found", "COMPILER_ERROR"),
        (r"SyntaxError:", "BUILD_SCRIPT_ERROR"),
    ]

    def analyze(self, result: CommandResult, builder_name: str = "") -> Dict[str, Any]:
        """Classifies the command failure output."""
        output = (result.stdout or "") + "\n" + (result.stderr or "")

        error_type = "UNKNOWN"
        missing_module = None
        missing_file = None

        for pattern, etype in self.PATTERNS:
            match = re.search(pattern, output, re.IGNORECASE)
            if match:
                error_type = etype
                if etype in ("MISSING_MODULE", "MISSING_PACKAGE") and match.groups():
                    missing_module = match.group(1)
                elif etype == "DATA_FILE_MISSING" and match.groups():
                    missing_file = match.group(1)
                break

        # Check for builder missing specifically
        if error_type == "UNKNOWN":
            if "not recognized as an internal or external command" in output or "No module named" in output:
                if builder_name.lower() in output.lower():
                    error_type = "BUILDER_NOT_INSTALLED"

        suggested_fix = self._determine_suggested_fix(error_type, missing_module, missing_file, builder_name)

        analysis = {
            "error_type": error_type,
            "missing_module": missing_module,
            "missing_file": missing_file,
            "builder_name": builder_name,
            "suggested_fix": suggested_fix,
            "can_safe_fix": suggested_fix is not None and suggested_fix.get("is_safe", False),
            "summary": f"Detected error: {error_type}" + (f" ({missing_module})" if missing_module else "")
        }

        logger.info(f"Error Analysis Result: {analysis['summary']}")
        return analysis

    def _determine_suggested_fix(
        self,
        error_type: str,
        missing_module: Optional[str],
        missing_file: Optional[str],
        builder_name: str
    ) -> Optional[Dict[str, Any]]:
        if error_type in ("MISSING_MODULE", "MISSING_PACKAGE") and missing_module:
            return {
                "action": "INSTALL_PACKAGE",
                "package": missing_module,
                "is_safe": True,
                "description": f"Install missing package '{missing_module}' via pip."
            }
        elif error_type == "BUILDER_NOT_INSTALLED" and builder_name:
            return {
                "action": "INSTALL_BUILDER",
                "package": builder_name,
                "is_safe": True,
                "description": f"Install build tool '{builder_name}' via pip."
            }
        elif error_type == "DATA_FILE_MISSING" and missing_file:
            return {
                "action": "INCLUDE_ASSET",
                "asset_path": missing_file,
                "is_safe": True,
                "description": f"Include missing data file '{missing_file}' in bundle assets."
            }
        return None
