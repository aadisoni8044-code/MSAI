"""Command result model."""

from dataclasses import dataclass
from typing import List, Optional


@dataclass
class CommandResult:
    """Encapsulates the result of running an external command."""
    command: List[str]
    exit_code: int
    stdout: str
    stderr: str
    duration: float
    cancelled: bool = False
    timed_out: bool = False

    @property
    def is_success(self) -> bool:
        return self.exit_code == 0 and not self.cancelled and not self.timed_out
