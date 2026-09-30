import datetime
from typing import List, Callable, Optional


class BuildLogger:
    """Buffer and log formatter for build output."""

    def __init__(self, callback: Optional[Callable[[str], None]] = None):
        self.logs: List[str] = []
        self.callback = callback

    def log(self, message: str) -> str:
        timestamp = datetime.datetime.now().strftime("%H:%M:%S")
        formatted = f"[{timestamp}] {message}"
        self.logs.append(formatted)
        if self.callback:
            self.callback(formatted)
        return formatted

    def clear(self) -> None:
        self.logs.clear()

    def get_text(self) -> str:
        return "\n".join(self.logs)
