"""Output Detector module for verifying and testing generated executables."""

import os
import time
import subprocess
from typing import Optional, Dict, Any
from app.logger import logger


class OutputDetector:
    """Detects, verifies, and tests generated executable files."""

    def __init__(self, project_path: str, output_dir: str = "dist"):
        self.project_path = os.path.abspath(project_path)
        self.output_dir = os.path.abspath(
            output_dir if os.path.isabs(output_dir) else os.path.join(self.project_path, output_dir)
        )

    def detect_exe(self, app_name: Optional[str] = None) -> Optional[str]:
        """Searches output directory for generated .exe file."""
        if not os.path.exists(self.output_dir):
            return None

        # Direct match check
        if app_name:
            if not app_name.lower().endswith(".exe"):
                app_name_exe = f"{app_name}.exe"
            else:
                app_name_exe = app_name
            target = os.path.join(self.output_dir, app_name_exe)
            if os.path.isfile(target):
                return target

        # Search for any .exe in output_dir
        exe_files = []
        for root, _, files in os.walk(self.output_dir):
            for file in files:
                if file.lower().endswith(".exe"):
                    exe_files.append(os.path.join(root, file))

        if not exe_files:
            return None

        # Return most recently modified EXE
        exe_files.sort(key=lambda x: os.path.getmtime(x), reverse=True)
        return exe_files[0]

    def verify_exe(self, exe_path: str) -> Dict[str, Any]:
        """Verifies the generated executable file integrity."""
        path_obj = os.path.abspath(exe_path)
        exists = os.path.isfile(path_obj)
        size_bytes = os.path.getsize(path_obj) if exists else 0
        has_exe_ext = path_obj.lower().endswith(".exe")

        is_valid = exists and size_bytes > 0 and has_exe_ext

        verification_result = {
            "exe_path": path_obj,
            "exists": exists,
            "size_bytes": size_bytes,
            "size_mb": round(size_bytes / (1024 * 1024), 2) if exists else 0,
            "has_exe_extension": has_exe_ext,
            "is_valid": is_valid
        }

        logger.info(f"EXE Verification Result for '{path_obj}': {verification_result}")
        return verification_result

    def test_launch_exe(self, exe_path: str, timeout_seconds: float = 3.0) -> Dict[str, Any]:
        """Optionally performs a basic launch test to ensure the EXE doesn't crash immediately."""
        if not os.path.isfile(exe_path):
            return {"launched": False, "crashed_immediately": True, "error": "File does not exist"}

        logger.info(f"Testing basic launch of '{exe_path}' for {timeout_seconds}s...")

        try:
            process = subprocess.Popen(
                [exe_path],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )

            time.sleep(timeout_seconds)
            exit_code = process.poll()

            if exit_code is None:
                # Still running after timeout -> Launch successful!
                try:
                    process.terminate()
                    process.wait(timeout=1.0)
                except Exception:
                    process.kill()
                return {
                    "launched": True,
                    "crashed_immediately": False,
                    "message": "EXE launched and ran stably during launch test window."
                }
            elif exit_code == 0:
                return {
                    "launched": True,
                    "crashed_immediately": False,
                    "message": "EXE launched and exited cleanly with code 0."
                }
            else:
                stderr_output = ""
                try:
                    _, stderr_output = process.communicate(timeout=0.5)
                except Exception:
                    pass
                return {
                    "launched": True,
                    "crashed_immediately": True,
                    "exit_code": exit_code,
                    "stderr": stderr_output,
                    "message": f"EXE crashed immediately on launch with exit code {exit_code}."
                }
        except Exception as e:
            logger.error(f"Error launching EXE for test: {e}")
            return {
                "launched": False,
                "crashed_immediately": True,
                "error": str(e)
            }
