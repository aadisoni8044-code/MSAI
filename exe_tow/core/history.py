"""
exe/tow - Build History Manager
Saves, retrieves, and clears build execution history records in JSON format.
"""

import json
import os
import time
from typing import Dict, List, Optional

class HistoryManager:
    """Manages history records for exe/tow builds."""

    def __init__(self, history_file: str = "exe_tow_history.json"):
        self.history_file = history_file
        self.records: List[Dict] = []
        self.load()

    def load(self) -> List[Dict]:
        """Loads build history from JSON file."""
        if os.path.exists(self.history_file) and os.path.getsize(self.history_file) > 0:
            try:
                with open(self.history_file, "r", encoding="utf-8") as f:
                    self.records = json.load(f)
            except Exception as e:
                print(f"[exe/tow history] Warning loading history: {e}")
                self.records = []
        else:
            self.records = []
        return self.records

    def save(self) -> bool:
        """Saves build history to JSON file."""
        try:
            with open(self.history_file, "w", encoding="utf-8") as f:
                json.dump(self.records, f, indent=4)
            return True
        except Exception as e:
            print(f"[exe/tow history] Error saving history: {e}")
            return False

    def add_record(self, record: Dict) -> Dict:
        """
        Adds a new build record to history.
        """
        if "id" not in record:
            record["id"] = f"build_{int(time.time() * 1000)}"
        if "timestamp" not in record:
            record["timestamp"] = time.strftime("%Y-%m-%d %H:%M:%S")

        self.records.insert(0, record)  # Most recent first
        self.records = self.records[:50]  # Store up to 50 builds
        self.save()
        return record

    def get_records(self) -> List[Dict]:
        return self.records

    def clear(self) -> bool:
        self.records = []
        return self.save()
