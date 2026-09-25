"""SQLite Database module for storing project build history and successful strategies."""

import sqlite3
import json
import os
import time
from typing import List, Dict, Any, Optional
from models.project_info import ProjectInfo
from models.build_strategy import BuildAttempt, BuildResult, BuildStrategy
from app.logger import logger


class BuildHistoryDB:
    """Manages local SQLite database persistence for projects, build attempts, errors, and successful strategies."""

    def __init__(self, db_path: str = "kora_history.db"):
        self.db_path = os.path.abspath(db_path)
        self._init_db()

    def _get_connection(self) -> sqlite3.Connection:
        conn = sqlite3.connect(self.db_path)
        conn.row_factory = sqlite3.Row
        return conn

    def _init_db(self):
        """Initializes database schema."""
        with self._get_connection() as conn:
            cursor = conn.cursor()

            cursor.execute("""
            CREATE TABLE IF NOT EXISTS projects (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                project_path TEXT UNIQUE NOT NULL,
                project_name TEXT NOT NULL,
                last_entry_point TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
            """)

            cursor.execute("""
            CREATE TABLE IF NOT EXISTS build_attempts (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                project_path TEXT NOT NULL,
                attempt_number INTEGER NOT NULL,
                builder_name TEXT NOT NULL,
                command TEXT NOT NULL,
                exit_code INTEGER,
                status TEXT NOT NULL,
                error_type TEXT,
                error_message TEXT,
                duration REAL,
                timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
            """)

            cursor.execute("""
            CREATE TABLE IF NOT EXISTS successful_strategies (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                project_path TEXT UNIQUE NOT NULL,
                builder_name TEXT NOT NULL,
                mode TEXT NOT NULL,
                is_gui BOOLEAN NOT NULL,
                entry_point TEXT NOT NULL,
                last_successful_build TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
            """)

            conn.commit()

    def save_project(self, project_info: ProjectInfo):
        """Saves or updates project record."""
        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("""
            INSERT INTO projects (project_path, project_name, last_entry_point, updated_at)
            VALUES (?, ?, ?, CURRENT_TIMESTAMP)
            ON CONFLICT(project_path) DO UPDATE SET
                project_name=excluded.project_name,
                last_entry_point=excluded.last_entry_point,
                updated_at=CURRENT_TIMESTAMP
            """, (project_info.project_path, project_info.project_name, project_info.selected_entry_point))
            conn.commit()

    def record_build_attempt(self, project_path: str, attempt: BuildAttempt):
        """Records an individual build attempt."""
        cmd_str = " ".join(attempt.command) if isinstance(attempt.command, list) else str(attempt.command)
        exit_code = attempt.command_result.exit_code if attempt.command_result else -1
        duration = attempt.command_result.duration if attempt.command_result else 0.0

        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("""
            INSERT INTO build_attempts (
                project_path, attempt_number, builder_name, command, exit_code, status, error_type, error_message, duration
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            """, (
                project_path, attempt.attempt_number, attempt.builder_name, cmd_str,
                exit_code, attempt.status, attempt.error_type, attempt.error_message, duration
            ))
            conn.commit()

    def record_successful_strategy(self, project_path: str, strategy: BuildStrategy, entry_point: str):
        """Saves a known successful strategy for a project."""
        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("""
            INSERT INTO successful_strategies (project_path, builder_name, mode, is_gui, entry_point, last_successful_build)
            VALUES (?, ?, ?, ?, ?, CURRENT_TIMESTAMP)
            ON CONFLICT(project_path) DO UPDATE SET
                builder_name=excluded.builder_name,
                mode=excluded.mode,
                is_gui=excluded.is_gui,
                entry_point=excluded.entry_point,
                last_successful_build=CURRENT_TIMESTAMP
            """, (project_path, strategy.builder_name, strategy.mode, 1 if strategy.is_gui else 0, entry_point))
            conn.commit()

    def get_successful_strategy(self, project_path: str) -> Optional[Dict[str, Any]]:
        """Retrieves previously successful build strategy for a project."""
        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM successful_strategies WHERE project_path = ?", (project_path,))
            row = cursor.fetchone()
            if row:
                return dict(row)
        return None

    def get_build_history(self, project_path: str) -> List[Dict[str, Any]]:
        """Gets all build attempt logs for a project."""
        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM build_attempts WHERE project_path = ? ORDER BY id DESC", (project_path,))
            rows = cursor.fetchall()
            return [dict(r) for r in rows]
