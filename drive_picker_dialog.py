"""
drive_picker_dialog.py

Custom Qt Dialog showcasing Google Drive mzML/mzXML files. Allows search,
sorting, item size checking, and triggers background download.
"""

import logging
from PyQt5.QtWidgets import (
    QDialog, QVBoxLayout, QHBoxLayout, QLineEdit, QListWidget, QListWidgetItem,
    QPushButton, QLabel, QMessageBox, QProgressDialog
)
from PyQt5.QtCore import Qt
from drive_client import DriveClient

logger = logging.getLogger("OpenMS Analyzer.drive_picker_dialog")

class DrivePickerDialog(QDialog):
    """
    Dialog facilitating selection and download of mass-spec datasets
    saved within Google Drive.
    """
    def __init__(self, drive_client: DriveClient, parent=None):
        super().__init__(parent)
        self.drive_client = drive_client
        self.selected_file_id = None
        self.selected_file_name = None
        self.files_cache = []

        self.setWindowTitle("Open from Google Drive")
        self.resize(500, 400)
        self.setup_ui()
        self.refresh_files()

    def setup_ui(self):
        layout = QVBoxLayout(self)

        # 1. Search Box
        search_layout = QHBoxLayout()
        search_layout.addWidget(QLabel("Search File:"))
        self.txt_search = QLineEdit()
        self.txt_search.setPlaceholderText("Filter files by name...")
        self.txt_search.textChanged.connect(self.filter_files)
        search_layout.addWidget(self.txt_search)
        layout.addLayout(search_layout)

        # 2. File List
        self.lst_files = QListWidget()
        self.lst_files.itemDoubleClicked.connect(self.accept_selection)
        layout.addWidget(self.lst_files)

        # 3. Action Buttons
        button_layout = QHBoxLayout()

        self.btn_refresh = QPushButton("Refresh")
        self.btn_refresh.clicked.connect(self.refresh_files)
        button_layout.addWidget(self.btn_refresh)

        button_layout.addStretch()

        self.btn_open = QPushButton("Download & Open")
        self.btn_open.setStyleSheet("font-weight: bold;")
        self.btn_open.clicked.connect(self.accept_selection)
        button_layout.addWidget(self.btn_open)

        self.btn_cancel = QPushButton("Cancel")
        self.btn_cancel.clicked.connect(self.reject)
        button_layout.addWidget(self.btn_cancel)

        layout.addLayout(button_layout)
        self.setLayout(layout)

    def refresh_files(self):
        """
        Queries Google Drive API for mzML, mzXML and XML files.
        """
        self.lst_files.clear()
        self.lst_files.addItem("Loading files from Google Drive...")
        self.btn_open.setEnabled(False)
        self.txt_search.setEnabled(False)

        try:
            # Match mzML / mzXML files
            mime_filter = "(name contains '.mzML' or name contains '.mzXML' or name contains '.xml')"
            files = self.drive_client.list_files(mime_filter=mime_filter)
            self.files_cache = files
            self.populate_list(files)
        except Exception as e:
            logger.exception("Could not refresh Drive files list.")
            QMessageBox.critical(self, "Google Drive Error", f"Failed to retrieve files: {str(e)}")
            self.lst_files.clear()
            self.lst_files.addItem("Failed to load files.")
        finally:
            self.txt_search.setEnabled(True)

    def populate_list(self, files):
        self.lst_files.clear()
        if not files:
            self.lst_files.addItem("No mzML or mzXML files found in your Google Drive.")
            self.btn_open.setEnabled(False)
            return

        for f in files:
            size_kb = int(f.get("size", 0)) / 1024.0
            size_str = f"{size_kb:.1f} KB" if size_kb < 1024 else f"{(size_kb/1024.0):.2f} MB"
            display_text = f"{f['name']} ({size_str}) - Modified: {f.get('modifiedTime', 'N/A')[:10]}"

            item = QListWidgetItem(display_text)
            item.setData(Qt.UserRole, f["id"])
            item.setData(Qt.UserRole + 1, f["name"])
            self.lst_files.addItem(item)

        self.btn_open.setEnabled(True)

    def filter_files(self):
        query = self.txt_search.text().lower()
        if not query:
            self.populate_list(self.files_cache)
            return

        filtered = [f for f in self.files_cache if query in f["name"].lower()]
        self.populate_list(filtered)

    def accept_selection(self):
        item = self.lst_files.currentItem()
        if not item:
            QMessageBox.warning(self, "No Selection", "Please select a file to download.")
            return

        file_id = item.data(Qt.UserRole)
        file_name = item.data(Qt.UserRole + 1)

        if not file_id:
            return

        self.selected_file_id = file_id
        self.selected_file_name = file_name
        self.accept()
