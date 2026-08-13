"""
drive_client.py

Handles interaction with Google Drive API. Performs OAuth authorization, lists
accessible files, handles downloads, and uploads output reports.
"""

import os
import io
import logging
from typing import List, Dict, Any, Optional

from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.http import MediaFileUpload, MediaIoBaseDownload

import config

logger = logging.getLogger("OpenMS Analyzer.drive_client")

class DriveClient:
    """
    Google Drive API Client managing OAuth 2.0 credentials and operations.
    """

    def __init__(self):
        self.creds: Optional[Credentials] = None
        self.service: Optional[Any] = None

    def authenticate(self) -> bool:
        """
        Loads cached token or prompts OAuth 2.0 authorization in browser.
        Saves authorized state in token.json.

        Returns:
            bool: True if authentication succeeded, False otherwise.
        """
        try:
            # Check cached token.json
            if os.path.exists(config.TOKEN_FILE):
                self.creds = Credentials.from_authorized_user_file(config.TOKEN_FILE, config.SCOPES)

            # If there are no (valid) credentials available, let the user log in.
            if not self.creds or not self.creds.valid:
                if self.creds and self.creds.expired and self.creds.refresh_token:
                    logger.info("Refreshing expired Google OAuth credentials...")
                    self.creds.refresh(Request())
                else:
                    logger.info("Initializing browser-based OAuth 2.0 flow...")
                    if not os.path.exists(config.CREDENTIALS_FILE):
                        logger.error(f"Credentials configuration {config.CREDENTIALS_FILE} is missing!")
                        return False

                    flow = InstalledAppFlow.from_client_secrets_file(
                        config.CREDENTIALS_FILE, config.SCOPES
                    )
                    self.creds = flow.run_local_server(port=0)

                # Save the credentials for the next run
                with open(config.TOKEN_FILE, "w") as token:
                    token.write(self.creds.to_json())

            self.service = build("drive", "v3", credentials=self.creds)
            logger.info("Successfully established connection to Google Drive.")
            return True
        except Exception as e:
            logger.exception("Google Drive authentication failed.")
            return False

    def list_files(self, folder_id: Optional[str] = None, mime_filter: Optional[str] = None) -> List[Dict[str, Any]]:
        """
        Lists files within Google Drive matching optional criteria.

        Args:
            folder_id (str, optional): Filters search inside a parent folder.
            mime_filter (str, optional): Custom file type filter string.

        Returns:
            List[Dict[str, Any]]: List of file records (id, name, size, modifiedTime).
        """
        if not self.service:
            if not self.authenticate():
                raise ConnectionError("Google Drive service is not authenticated.")

        query_parts = ["trashed = false"]

        if folder_id:
            query_parts.append(f"'{folder_id}' in parents")

        if mime_filter:
            # Custom mime filters or name extensions
            query_parts.append(mime_filter)

        q = " and ".join(query_parts)

        try:
            results = self.service.files().list(
                q=q,
                spaces="drive",
                fields="nextPageToken, files(id, name, size, mimeType, modifiedTime)",
                pageSize=100
            ).execute()
            return results.get("files", [])
        except Exception as e:
            logger.error(f"Failed to query files list: {e}")
            raise

    def download_file(self, file_id: str, dest_path: str, progress_callback: Optional[Any] = None) -> None:
        """
        Downloads a Google Drive file to the specified local path.

        Args:
            file_id (str): Google Drive unique file identifier.
            dest_path (str): Destination local absolute/relative path.
            progress_callback (callable, optional): Receives download percent.
        """
        if not self.service:
            if not self.authenticate():
                raise ConnectionError("Google Drive service is not authenticated.")

        try:
            request = self.service.files().get_media(fileId=file_id)
            fh = io.FileIO(dest_path, "wb")
            downloader = MediaIoBaseDownload(fh, request)
            done = False
            while not done:
                status, done = downloader.next_chunk()
                if status and progress_callback:
                    progress_callback(int(status.progress() * 100))
            logger.info(f"Downloaded file ID {file_id} to {dest_path}")
        except Exception as e:
            logger.error(f"Download of file ID {file_id} failed: {e}")
            raise

    def upload_file(self, local_path: str, folder_id: Optional[str] = None) -> str:
        """
        Uploads a local file to Google Drive.

        Args:
            local_path (str): Local file path.
            folder_id (str, optional): Target folder ID.

        Returns:
            str: Uploaded file ID.
        """
        if not self.service:
            if not self.authenticate():
                raise ConnectionError("Google Drive service is not authenticated.")

        if not os.path.exists(local_path):
            raise FileNotFoundError(f"Local file to upload not found: {local_path}")

        file_metadata = {"name": os.path.basename(local_path)}
        if folder_id:
            file_metadata["parents"] = [folder_id]

        media = MediaFileUpload(local_path, resumable=True)

        try:
            file_obj = self.service.files().create(
                body=file_metadata,
                media_body=media,
                fields="id"
            ).execute()

            file_id = file_obj.get("id")
            logger.info(f"Uploaded local file {local_path} to Drive as ID {file_id}")
            return file_id
        except Exception as e:
            logger.error(f"Failed to upload {local_path}: {e}")
            raise

    def create_results_folder(self, name: str) -> str:
        """
        Creates a new folder on Google Drive. If a folder with the same name already
        exists in the root, returns its ID instead of making a duplicate.

        Args:
            name (str): Folder name.

        Returns:
            str: Folder ID.
        """
        if not self.service:
            if not self.authenticate():
                raise ConnectionError("Google Drive service is not authenticated.")

        # Check if folder already exists
        try:
            q = f"mimeType = 'application/vnd.google-apps.folder' and name = '{name}' and trashed = false"
            results = self.service.files().list(q=q, fields="files(id, name)").execute()
            existing = results.get("files", [])
            if existing:
                folder_id = existing[0]["id"]
                logger.info(f"Using existing results folder: '{name}' (ID: {folder_id})")
                return folder_id
        except Exception as e:
            logger.warning(f"Error checking existing folder '{name}': {e}. Creating a new one.")

        # Create folder
        file_metadata = {
            "name": name,
            "mimeType": "application/vnd.google-apps.folder"
        }
        try:
            folder = self.service.files().create(
                body=file_metadata,
                fields="id"
            ).execute()
            folder_id = folder.get("id")
            logger.info(f"Created new results folder: '{name}' (ID: {folder_id})")
            return folder_id
        except Exception as e:
            logger.error(f"Failed to create results folder '{name}': {e}")
            raise
