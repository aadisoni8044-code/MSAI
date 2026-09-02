"""
MSAI Studio - Git Manager
"""
import os
from typing import List, Dict, Optional, Tuple
from git.git_commands import GitCommands

class GitManager:
    """Manages source control state, branches, staged and untracked file status."""

    def __init__(self, repo_path: str = None):
        self.repo_path = repo_path

    def set_repo_path(self, repo_path: str):
        self.repo_path = repo_path

    def is_git_repo(self) -> bool:
        """Checks if repo_path is inside a git repo."""
        if not self.repo_path:
            return False
        ok, _ = GitCommands.run_command(["rev-parse", "--is-inside-work-tree"], self.repo_path)
        return ok

    def get_current_branch(self) -> str:
        """Gets active branch name."""
        if not self.is_git_repo():
            return "No Git Repo"
        ok, out = GitCommands.run_command(["rev-parse", "--abbrev-ref", "HEAD"], self.repo_path)
        return out if ok else "main"

    def get_branches(self) -> List[str]:
        """Gets list of local branches."""
        if not self.is_git_repo():
            return []
        ok, out = GitCommands.run_command(["branch", "--format=%(refname:short)"], self.repo_path)
        if ok and out:
            return [b.strip() for b in out.splitlines() if b.strip()]
        return []

    def get_status(self) -> Dict[str, List[Dict[str, str]]]:
        """
        Returns dict containing staged and unstaged/untracked changed files.
        {"staged": [{"file": "app.py", "status": "M"}], "unstaged": [...]}
        """
        result = {"staged": [], "unstaged": []}
        if not self.is_git_repo():
            return result

        ok, out = GitCommands.run_command(["status", "--porcelain"], self.repo_path)
        if not ok or not out:
            return result

        for line in out.splitlines():
            if len(line) < 4:
                continue
            x = line[0] # Staged status
            y = line[1] # Unstaged status
            file_path = line[3:].strip()

            if x != ' ' and x != '?':
                result["staged"].append({"file": file_path, "status": x})
            if y != ' ':
                status_code = "U" if y == '?' else y
                result["unstaged"].append({"file": file_path, "status": status_code})

        return result

    def stage_file(self, file_path: str) -> Tuple[bool, str]:
        """Stages file or all files."""
        return GitCommands.run_command(["add", file_path], self.repo_path)

    def unstage_file(self, file_path: str) -> Tuple[bool, str]:
        """Unstages file."""
        return GitCommands.run_command(["reset", "HEAD", file_path], self.repo_path)

    def commit(self, message: str) -> Tuple[bool, str]:
        """Commits staged changes with message."""
        if not message.strip():
            return False, "Commit message cannot be empty"
        return GitCommands.run_command(["commit", "-m", message], self.repo_path)
