"""
MSAI Studio - Git Commands Helper
"""
import subprocess
import os
from typing import Tuple, List, Dict

class GitCommands:
    """Provides wrapper for running Git CLI commands safely."""

    @staticmethod
    def run_command(cmd: List[str], repo_path: str) -> Tuple[bool, str]:
        """Runs git command inside repo_path."""
        if not repo_path or not os.path.exists(repo_path):
            return False, "Invalid repository path"

        try:
            res = subprocess.run(
                ["git"] + cmd,
                cwd=repo_path,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                timeout=10
            )
            if res.returncode == 0:
                return True, res.stdout.strip()
            else:
                return False, res.stderr.strip() or res.stdout.strip()
        except FileNotFoundError:
            return False, "Git executable not found"
        except Exception as e:
            return False, f"Git command failed: {e}"
