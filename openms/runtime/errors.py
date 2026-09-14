"""
OpenMS Exception Definitions
"""

class OpenMSError(Exception):
    """Base exception class raised for OpenMS interpreter runtime errors."""
    pass


class OpenMSSyntaxError(OpenMSError):
    """Raised when parsing or tokenizing OpenMS code fails due to syntax errors."""
    pass


class OpenMSRuntimeError(OpenMSError):
    """Raised during OpenMS code execution."""
    pass
