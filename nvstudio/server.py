"""
NV Studio Local Live Preview Server
Provides an embedded HTTP server to serve HTML, CSS, JavaScript, assets, and project files.
"""

import http.server
import socket
import socketserver
import threading
from pathlib import Path
from typing import Optional


class NVStudioHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    """Custom HTTP Handler to set correct MIME types, CORS headers, and disable caching."""

    def end_headers(self) -> None:
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Cache-Control", "no-cache, no-store, must-revalidate")
        self.send_header("Pragma", "no-cache")
        self.send_header("Expires", "0")
        super().end_headers()

    def log_message(self, format: str, *args) -> None:
        # Suppress standard HTTP log noise in terminal
        pass


class LocalServer:
    """Runs a local HTTP server in a daemon thread on a free dynamic port."""

    def __init__(self, directory: Path):
        self.directory = Path(directory).resolve()
        self.port = self._find_free_port()
        self.httpd: Optional[socketserver.TCPServer] = None
        self.server_thread: Optional[threading.Thread] = None

    @staticmethod
    def _find_free_port() -> int:
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            s.bind(("127.0.0.1", 0))
            return s.getsockname()[1]

    def update_directory(self, new_directory: Path) -> None:
        self.directory = Path(new_directory).resolve()

    def start(self) -> str:
        """Starts the server thread if not already running."""
        if self.httpd is not None:
            return self.get_url()

        handler = lambda *args, **kwargs: NVStudioHTTPRequestHandler(
            *args, directory=str(self.directory), **kwargs
        )
        self.httpd = socketserver.TCPServer(("127.0.0.1", self.port), handler)
        self.httpd.allow_reuse_address = True

        self.server_thread = threading.Thread(
            target=self.httpd.serve_forever, daemon=True
        )
        self.server_thread.start()
        print(f"[LocalServer] Running live preview server at {self.get_url()}")
        return self.get_url()

    def stop(self) -> None:
        """Stops the server."""
        if self.httpd:
            self.httpd.shutdown()
            self.httpd.server_close()
            self.httpd = None
            self.server_thread = None
            print("[LocalServer] Server stopped.")

    def get_url(self, file_path: str = "index.html") -> str:
        return f"http://127.0.0.1:{self.port}/{file_path}"
